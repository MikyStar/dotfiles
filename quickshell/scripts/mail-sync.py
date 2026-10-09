#!/usr/bin/env python3
"""Polls every IMAP account configured in Thunderbird for unread mail, without launching it.
Prints one JSON object to stdout: {"count": int, "messages": [...], "accounts": [...]}.

The account list (host/port/username) is read straight from Thunderbird's prefs.js, so an
account added in Thunderbird later shows up here with no changes to this script.

Credentials are never stored here or in Quickshell:
- A plain-password account's password is decrypted straight out of Thunderbird's own
  NSS-encrypted login store (key4.db/logins.json) via libnss3, the same store Thunderbird
  itself uses -- so it stays in sync automatically.
- An OAuth2 account (Gmail, Outlook, ...) has no reusable password in that store, so it
  falls back to an app password looked up from the OS keyring via `secret-tool` (stored
  there once, manually, per such account):
    secret-tool store --label="Mail (bar)" service <hostname> user <username>
"""

import ctypes
import ctypes.util
import email.header
import email.message
import email.utils
import glob
import imaplib
import json
import re
import subprocess
import sys
from base64 import b64decode
from pathlib import Path

THUNDERBIRD_CONFIG = Path.home() / ".config" / "thunderbird"
OAUTH_AUTH_METHOD = "10"
MAX_MESSAGES = 20
IMAP_TIMEOUT = 10


def find_profile_dir():
    profiles_ini = THUNDERBIRD_CONFIG / "profiles.ini"
    if not profiles_ini.exists():
        return None
    text = profiles_ini.read_text()
    profiles = []
    for section in re.split(r"\n(?=\[)", text):
        if not section.startswith("[Profile"):
            continue
        profiles.append(dict(re.findall(r"^(\w+)=(.*)$", section, re.MULTILINE)))
    if not profiles:
        return None
    default = next((p for p in profiles if p.get("Default") == "1"), profiles[0])
    path = default.get("Path", "")
    base = THUNDERBIRD_CONFIG if default.get("IsRelative", "1") == "1" else Path("/")
    return base / path


def parse_accounts(profile_dir):
    prefs_path = profile_dir / "prefs.js"
    if not prefs_path.exists():
        return []
    text = prefs_path.read_text()
    servers = {}
    for server_id, key, raw in re.findall(
        r'user_pref\("mail\.server\.(server\d+)\.(\w+)",\s*(.*?)\);', text
    ):
        value = raw.strip()
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        servers.setdefault(server_id, {})[key] = value

    accounts = []
    for fields in servers.values():
        if fields.get("type") != "imap":
            continue
        host, user = fields.get("hostname", ""), fields.get("userName", "")
        if not host or not user:
            continue
        accounts.append(
            {
                "host": host,
                "port": int(fields.get("port") or 993),
                "user": user,
                "name": fields.get("name") or user,
                "oauth2": fields.get("authMethod") == OAUTH_AUTH_METHOD,
            }
        )
    return accounts


class _SECItem(ctypes.Structure):
    _fields_ = [
        ("type", ctypes.c_uint),
        ("data", ctypes.c_char_p),
        ("len", ctypes.c_uint),
    ]


class NssDecryptor:
    """Decrypts Thunderbird's own stored logins via libnss3 (NSS_Init + PK11SDR_Decrypt),
    the same mechanism Thunderbird itself uses -- no crypto reimplemented here."""

    def __init__(self, profile_dir):
        libnss_path = self._find_libnss()
        if not libnss_path:
            raise RuntimeError("libnss3.so not found")
        nss = ctypes.CDLL(libnss_path)
        nss.NSS_Init.argtypes = [ctypes.c_char_p]
        nss.NSS_Init.restype = ctypes.c_int
        nss.NSS_Shutdown.restype = ctypes.c_int
        nss.PK11_GetInternalKeySlot.restype = ctypes.c_void_p
        nss.PK11_FreeSlot.argtypes = [ctypes.c_void_p]
        nss.PK11_CheckUserPassword.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
        nss.PK11_CheckUserPassword.restype = ctypes.c_int
        nss.PK11SDR_Decrypt.argtypes = [
            ctypes.POINTER(_SECItem),
            ctypes.POINTER(_SECItem),
            ctypes.c_void_p,
        ]
        nss.PK11SDR_Decrypt.restype = ctypes.c_int
        nss.SECITEM_FreeItem.argtypes = [ctypes.POINTER(_SECItem), ctypes.c_int]
        self._nss = nss

        if nss.NSS_Init(f"sql:{profile_dir}".encode()) != 0:
            raise RuntimeError("NSS_Init failed")
        self._slot = nss.PK11_GetInternalKeySlot()
        if not self._slot:
            nss.NSS_Shutdown()
            raise RuntimeError("no NSS key slot")
        if nss.PK11_CheckUserPassword(self._slot, b"") != 0:
            nss.PK11_FreeSlot(self._slot)
            nss.NSS_Shutdown()
            raise RuntimeError("Thunderbird profile has a primary password set")

    @staticmethod
    def _find_libnss():
        candidates = sorted(
            glob.glob("/nix/store/*-nss-3*/lib/libnss3.so"), reverse=True
        )
        return candidates[0] if candidates else ctypes.util.find_library("nss3")

    def decrypt(self, b64_text):
        raw = b64decode(b64_text)
        inp = _SECItem(0, raw, len(raw))
        out = _SECItem()
        if self._nss.PK11SDR_Decrypt(ctypes.byref(inp), ctypes.byref(out), None) != 0:
            raise RuntimeError("PK11SDR_Decrypt failed")
        try:
            return ctypes.string_at(out.data, out.len).decode()
        finally:
            self._nss.SECITEM_FreeItem(ctypes.byref(out), 0)

    def close(self):
        self._nss.PK11_FreeSlot(self._slot)
        self._nss.NSS_Shutdown()


def load_logins(profile_dir):
    logins_path = profile_dir / "logins.json"
    if not logins_path.exists():
        return []
    return json.loads(logins_path.read_text()).get("logins", [])


def find_stored_password(logins, host, user, decryptor):
    for login in logins:
        # Thunderbird stores these as "<scheme>://<host>" (e.g. "imap://imap.example.com");
        # strip the scheme and compare the host exactly, not as a substring.
        login_host = login.get("hostname", "").split("://", 1)[-1]
        if login_host.lower() != host.lower():
            continue
        try:
            if decryptor.decrypt(login["encryptedUsername"]).lower() != user.lower():
                continue
            return decryptor.decrypt(login["encryptedPassword"])
        except Exception:
            continue
    return None


def secret_tool_lookup(host, user):
    try:
        result = subprocess.run(
            ["secret-tool", "lookup", "service", host, "user", user],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    return result.stdout if result.returncode == 0 and result.stdout else None


def resolve_password(account, decryptor, logins):
    if not account["oauth2"] and decryptor is not None:
        password = find_stored_password(
            logins, account["host"], account["user"], decryptor
        )
        if password:
            return password, None
    password = secret_tool_lookup(account["host"], account["user"])
    if password:
        return password, None
    return None, (
        "no credentials found -- run: secret-tool store --label='Mail (bar)' service "
        f"{account['host']} user {account['user']}"
    )


def _decode_header(value):
    if not value:
        return ""
    try:
        return str(email.header.make_header(email.header.decode_header(value)))
    except Exception:
        return value


def fetch_unread(account, password):
    name, messages, error, count = account["name"], [], None, 0
    try:
        conn = imaplib.IMAP4_SSL(account["host"], account["port"], timeout=IMAP_TIMEOUT)
        try:
            conn.login(account["user"], password)
            conn.select("INBOX", readonly=True)
            status, data = conn.search(None, "UNSEEN")
            if status != "OK":
                raise RuntimeError("UNSEEN search failed")
            ids = data[0].split()
            count = len(ids)
            for msg_id in ids[-MAX_MESSAGES:]:
                status, msg_data = conn.fetch(
                    msg_id, "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT DATE)])"
                )
                if status != "OK" or not msg_data or not msg_data[0]:
                    continue
                headers = email.message_from_bytes(msg_data[0][1])
                date = headers.get("Date", "")
                try:
                    ts = email.utils.parsedate_to_datetime(date).timestamp()
                except Exception:
                    ts = 0
                messages.append(
                    (
                        ts,
                        {
                            "from": _decode_header(headers.get("From", "")),
                            "subject": _decode_header(headers.get("Subject", "")),
                            "date": date,
                            "account": name,
                        },
                    )
                )
        finally:
            try:
                conn.logout()
            except Exception:
                pass
    except Exception as exc:
        error = str(exc)
    return {"name": name, "count": count, "error": error, "messages": messages}


def main():
    profile_dir = find_profile_dir()
    if profile_dir is None:
        return {
            "count": 0,
            "messages": [],
            "accounts": [],
            "error": "no Thunderbird profile found",
        }

    accounts = parse_accounts(profile_dir)

    decryptor, logins = None, []
    try:
        decryptor = NssDecryptor(profile_dir)
        logins = load_logins(profile_dir)
    except Exception:
        decryptor = None

    accounts_out, all_messages, total = [], [], 0
    for account in accounts:
        password, error = resolve_password(account, decryptor, logins)
        if error:
            accounts_out.append({"name": account["name"], "count": 0, "error": error})
            continue
        result = fetch_unread(account, password)
        accounts_out.append(
            {"name": result["name"], "count": result["count"], "error": result["error"]}
        )
        total += result["count"]
        all_messages.extend(result["messages"])

    if decryptor:
        decryptor.close()

    all_messages.sort(key=lambda m: m[0], reverse=True)
    return {
        "count": total,
        "accounts": accounts_out,
        "messages": [m for _, m in all_messages[:MAX_MESSAGES]],
    }


if __name__ == "__main__":
    try:
        output = main()
    except Exception as exc:
        output = {"count": 0, "messages": [], "accounts": [], "error": str(exc)}
    print(json.dumps(output))
    sys.stdout.flush()
