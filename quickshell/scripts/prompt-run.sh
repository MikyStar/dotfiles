#!/usr/bin/env sh
# Pre-fills $1 on the prompt line -- editable/abortable, not auto-run -- then drops into an
# interactive shell. Used by widgets/infos/InfosService.qml's update-terminal action so the user
# reviews the update command (which flake inputs it touches, whether to keep the leading sudo...)
# before running it.
#
# Invoked as "$SHELL prompt-run.sh <cmd>" (not via this shebang), so it actually runs under
# whatever shell the user has configured, not a hardcoded one -- $ZSH_VERSION/$BASH_VERSION are
# set by the shell binary itself regardless of how it was invoked, so branch on those to pick the
# right pre-fill mechanism (there's no POSIX-portable way to seed a prompt's edit buffer). A shell
# with neither (dash, fish, ...) just falls back to running the command straight.
#
# Usage: prompt-run.sh "<command to pre-fill>"

if [ -n "$ZSH_VERSION" ]; then
    zmodload zsh/zle 2>/dev/null
    line="$1"
    vared -p '$ ' line
    eval "$line"
elif [ -n "$BASH_VERSION" ]; then
    read -e -i "$1" -p '$ ' line
    eval "$line"
else
    printf '$ %s\n' "$1"
    eval "$1"
fi

exec "${SHELL:-sh}"
