# Telatger Visuals

A visual-only iOS tweak scaffold for Telegram 13.2.

## Scope
- Adds a floating ✦ launcher and a frosted-glass settings panel.
- Does not call Telegram APIs, read credentials, inspect messages, or alter network traffic.
- The switches in this first scaffold are UI demonstrations only; they do not yet restyle Telegram's native chat cells.

## Build
This is a Theos tweak project. Build on a Mac/Linux environment configured with Theos and an iOS SDK:

```sh
make package
```

The resulting `.deb` contains the tweak dylib. For a sideloaded IPA, the dylib must be injected into the app's Mach-O and the modified app re-signed with a compatible certificate. Keep an untouched IPA backup. A dylib must execute inside Telegram's process to draw UI; this project intentionally avoids network/authentication hooks.

## Compatibility note
Telegram 13.2 has not yet been tested against this scaffold. The overlay uses public UIKit APIs, but stability and signing/injection compatibility must be verified on-device. No guarantee of zero account or app-integrity risk is possible with a modified client.
