# QuickShell

## Mail bar section widget


### Gmail

`You need to have libsecret installed`

Generate a Gmail App password [there](https://myaccount.google.com/apppasswords)
```sh
secret-tool store --label="Mail (bar)" service imap.gmail.com user [your email address]
```

### Other providers

The `./scripts/mail-sync.py` script should handle most of the mail providers based on the accounts stored in Thunderbird without the need of using libsecret

But if the mail provider is using some OAuth2 you will need to use the same logic with libsecret just like Gmail

