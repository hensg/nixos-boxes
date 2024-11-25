+++
title = 'GPG, Yubikeys, and Signed Commits'
date = 2024-05-27T20:13:50-03:00
tags = ["gpg", "yubikey"]
categories = ["gpg"]
+++

How to configure GPG keys and upload them to multiple Yubikeys.
Also, how to use GPG keys for git signed commits.

<!--more-->

## Requirements

- GnuPG
- SCDaemon (Smartcard daemon for GnuPG)

# Create GPG key pair

Generating GPG keys with all capabilities included:
```shell
$ gpg --expert --full-gen-key

gpg (GnuPG) 2.4.5; Copyright (C) 2024 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC (sign and encrypt) *default*
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
  (14) Existing key from card
Your selection? 8

Possible actions for this RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Sign Certify Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? A

Possible actions for this RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Sign Certify Encrypt Authenticate

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? Q
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 2y
Key expires at Tue Oct 27 10:05:16 2026 -03
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Henrique Goulart
Email address: henriquedsg89@gmail.com
Comment:
You selected this USER-ID:
    "Henrique Goulart <henriquedsg89@gmail.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: revocation certificate stored as '/home/henrique/.gnupg/openpgp-revocs.d/94D6AFB0CB45286CADCCC4151D250373625D7750.rev'
public and secret key created and signed.

pub   rsa4096 2024-10-27 [SCEA] [expires: 2026-10-27]
      94D6AFB0CB45286CADCCC4151D250373625D7750
uid                      Henrique Goulart <henriquedsg89@gmail.com>
```

Keys have been generated and are now in the `.gnupg` folder.

**NOTE: Backup your `.gnupg` folder into an encrypted USB storage device**


## Move GPG keys to Yubikey

Uploading GPG keys to the YubiKey transfers them from the `.gnupg` folder to the YubiKey, securely storing the private keys on the device where they cannot be recovered or extracted. Once configured, the GPG system interacts directly with the YubiKey to sign data, as the keys now reside exclusively on the YubiKey and are no longer stored on your operating system.

After running `gpg --card-status`, you will see `ssb>` before the key, where the `>` symbol indicates that the private key is not in the GPG agent but securely stored on the YubiKey.



List secret keys:

```shell
$ gpg --list-secret-keys

/home/henrique/.gnupg/pubring.kbx
---------------------------------
sec   rsa4096 2024-07-23 [C]
      661DCBE88A7EDCFCEB97ACC5BA8131FA6F593DDD
uid           [ultimate] Henrique Goulart <henriquedsg89@gmail.com>
uid           [ultimate] Henrique Goulart <henrique@fedi.xyz>
uid           [ultimate] Henrique Goulart <sgoulart.henrique@gmail.com>
ssb   rsa4096 2024-07-23 [S] [expires: 2026-07-23]
ssb   rsa4096 2024-07-23 [E] [expires: 2026-07-23]
ssb   rsa4096 2024-07-23 [A] [expires: 2026-07-23]
```

Edit key to upload it to Yubikey
```shell
gpg --edit-key 661DCBE88A7EDCFCEB97ACC5BA8131FA6F593DDD
gpg (GnuPG) 2.4.5; Copyright (C) 2024 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/BA8131FA6F593DDD
     created: 2024-07-23  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb  rsa4096/C7CE10D08294E246
     created: 2024-07-23  expires: 2026-07-23  usage: S
ssb  rsa4096/A09C1EDBDBCFF0D1
     created: 2024-07-23  expires: 2026-07-23  usage: E
ssb  rsa4096/8B50E2CD24117793
     created: 2024-07-23  expires: 2026-07-23  usage: A
[ultimate] (1). Henrique Goulart <henriquedsg89@gmail.com>
[ultimate] (2)  Henrique Goulart <henrique@fedi.xyz>
[ultimate] (3)  Henrique Goulart <sgoulart.henrique@gmail.com>

gpg> key 1

sec  rsa4096/BA8131FA6F593DDD
     created: 2024-07-23  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/C7CE10D08294E246
     created: 2024-07-23  expires: 2026-07-23  usage: S
ssb  rsa4096/A09C1EDBDBCFF0D1
     created: 2024-07-23  expires: 2026-07-23  usage: E
ssb  rsa4096/8B50E2CD24117793
     created: 2024-07-23  expires: 2026-07-23  usage: A
[ultimate] (1). Henrique Goulart <henriquedsg89@gmail.com>
[ultimate] (2)  Henrique Goulart <henrique@fedi.xyz>
[ultimate] (3)  Henrique Goulart <sgoulart.henrique@gmail.com>

gpg> keytocard
Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

sec  rsa4096/BA8131FA6F593DDD
     created: 2024-07-23  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/C7CE10D08294E246
     created: 2024-07-23  expires: 2026-07-23  usage: S
ssb  rsa4096/A09C1EDBDBCFF0D1
     created: 2024-07-23  expires: 2026-07-23  usage: E
ssb  rsa4096/8B50E2CD24117793
     created: 2024-07-23  expires: 2026-07-23  usage: A
[ultimate] (1). Henrique Goulart <henriquedsg89@gmail.com>
[ultimate] (2)  Henrique Goulart <henrique@fedi.xyz>
[ultimate] (3)  Henrique Goulart <sgoulart.henrique@gmail.com>

gpg> save
```

Do the same thing for others keys if you have created them one by one.

**NOTE:** To store the GPG keys on additional YubiKeys, you will need to restore the `.gnupg` folder from your backup, as the keys were moved to the YubiKey and are no longer available locally.


## Agent configuration

Add the following configuration to these files:

```shell
# ~/.gnupg/gpg-agent.conf
enable-ssh-support
ttyname $GPG_TTY
default-cache-ttl 600
max-cache-ttl 1200
```

```shell
# ~/.bashrc
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY=$(tty)
```

# Signing commits

Set the following configuration in git:
```shell
git config --global --unset gpg.format
git config --global user.signingkey <your_signing_key(S)>
git config --global commit.gpgsign true
```

# Yubikey

Check yubikey info:
```shell 
ykman openpgp info
```

Change pin:
```shell 
ykman openpgp access change-pin
```

Change admin pin (PUK):
```shell 
ykman openpgp access change-admin-pin
```

# Troubleshooting

## Open PGP card not available
PCSC-Lite daemon sometimes conflicts with gpg-agent. This can be solved by putting the line `disable-ccid` into `~/.gnupg/scdaemon.conf`.

Then you may able to restart the service and get the card status:
```shell
sudo systemctl restart pcscd.service
gpg --card-status

```
