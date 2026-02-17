# PW - Password Manager

Create unique theft proof passwords for each service that you use. Never store them but easily create them when you need it.

Simply enter a service and then a password. PW will then hash it using SHA1 (V1) or SHA256 (V2) and now you have super strong and unique password for that site.

- Web: https://pwapp.io/
- iOS:Available on the App Store: https://itunes.apple.com/app/apple-store/id981716752?pt=117760826&ct=GitHub&mt=8.
- macOS: https://itunes.apple.com/gb/app/pw/id1052922320?mt=12
- Android: Is no longer supported.

## How does V1 work?
PW takes the two inputs Service (the service is always converted to lowercase) and Password and runs it through a SHA1 hash with four pipes thrown in to make it a little interesting:

SHA1(“Service” + “||” + “Password” + “||”)

For example with the service “Facebook” and the password “hackference” it would be:

SHA1(facebook||hackference||)

and output:

762b679fA17b10D6Cc2d2194542d2235738b3e33

## How does V2 work?
V2 uses a stronger hashing algorithm, SHA256, and makes use of special characters, numbers and uppercase letters within the first 15 characters in order to satisfy the minimum requirements of many services.

PW takes the two inputs Service (the service is always converted to lowercase) and Password and runs it through a SHA256 hash with four pipes thrown in to make it a little interesting:

SHA256(“Service” + “||” + “Password” + “||”)

For example with the service “Facebook” and the password “hackference” it would be:

SHA256(facebook||hackference||)

and output:

## History
V1 was based on SHA1 hashing and was in individual repos for each platform.
- https://github.com/hughhopkins/PW-Site
- https://github.com/hughhopkins/PW-iOS
- https://github.com/hughhopkins/PW-OSX
- https://github.com/hughhopkins/PW-Android

V2 moves to this monorepo. The project structure is:

```
PW/
├── iOS/
├── macOS/
├── web/
├── README.md
├── README_AI_GENERATED.md
├── README_ROADMAP.md
├── README_THOUGHTS.md
├── claude.md
├── LICENSE
└── .gitignore
```

## Credits
- Based on https://github.com/simontabor/pw and outputs the same passwords.
- Big up to https://github.com/krzyzanowskim/CryptoSwift for hashing.