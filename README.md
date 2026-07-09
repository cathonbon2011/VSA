# VSA — GIF Sticker Keyboard

Native SwiftUI app for iOS and iPadOS that lets you create, organize, and manage
animated GIF stickers, and use them anywhere on your device through a custom
system keyboard extension.

## Features

- **Sticker library** — grid view with categories (Reactions, Memes, Animals,
  Emotions, Uncategorized), favorites, and search.
- **Import GIFs** from the Files app or your Photos library.
- **Native GIF playback** — GIFs are decoded and animated with `ImageIO`, no
  third-party dependencies.
- **System keyboard extension (VSA Keyboard)** — browse your sticker library
  from any app (Messages, WhatsApp, Mail, etc.). Tapping a sticker copies the
  animated GIF to the clipboard so you can paste it wherever you're typing.
- **Shared storage** — the app and the keyboard extension share sticker data
  through an App Group container, so anything you add in the app instantly
  shows up in the keyboard.
- Runs on both **iPhone and iPad**, with an adaptive grid layout.

## Project layout

```
VSA/
├── project.yml            # XcodeGen project spec (source of truth)
├── VSA/                    # Main app target
│   ├── App/                 # App entry point + root view
│   ├── Store/                # StickerStore (ObservableObject)
│   ├── Views/                 # SwiftUI screens
│   ├── Components/             # Reusable views (GIF renderer, etc.)
│   └── Resources/               # Info.plist, Assets.xcassets
├── VSAKeyboard/            # Custom keyboard extension target
│   ├── KeyboardViewController.swift
│   ├── KeyboardRootView.swift
│   └── Info.plist
└── Shared/                 # Code shared by both targets
    ├── Sticker.swift
    ├── StickerFileStore.swift
    ├── GIFDecoder.swift
    ├── AppGroup.swift
    └── HostAppLauncher.swift
```

## Requirements

- macOS with **Xcode 15+**
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (generates the
  `.xcodeproj` from `project.yml` — the project file itself isn't committed,
  so this repo works cleanly with git)
- An Apple ID / Apple Developer account for code signing (a free account is
  enough to run on your own device or the simulator)

## Building

```bash
# 1. Install XcodeGen (one-time)
brew install xcodegen

# 2. From the repo root, generate the Xcode project
xcodegen generate

# 3. Open it
open VSA.xcodeproj
```

In Xcode:

1. Select the **VSA** project in the navigator, then for **both** the `VSA`
   and `VSAKeyboard` targets, set your **Team** under
   *Signing & Capabilities* (Automatic signing is already configured).
2. Both targets already declare the App Group capability
   `group.com.vsa.stickers` in `project.yml`. If Xcode complains about
   provisioning, open *Signing & Capabilities → App Groups* for each target
   and let Xcode register the group with your team, or edit the group
   identifier to match your own team's reverse-DNS if you rename the bundle
   IDs.
3. Select the **VSA** scheme and Run on a simulator or your device (custom
   keyboards work in the Simulator too).

## Enabling the keyboard on a device/simulator

1. Install and launch the VSA app once (this creates the App Group
   container).
2. On the device: **Settings → General → Keyboard → Keyboards → Add New
   Keyboard…** and choose **VSA**.
3. Tap **VSA Keyboard** in that list again and turn on **Allow Full Access**
   (required so the extension can read the shared sticker files and write to
   the clipboard).
4. In any app, switch to the VSA keyboard with the globe key, tap a sticker
   to copy it, then long-press the text field and choose **Paste**.

## Notes / known limitations

- `AppIcon` and `AccentColor` are placeholder asset catalog entries (no PNG
  supplied) — add your own artwork before archiving for the App Store; debug
  builds run fine without it.
- iOS custom keyboards can only insert **text** directly; they cannot inject
  an animated GIF into an arbitrary text field. VSA follows the same pattern
  as other GIF keyboards (e.g. Gboard, GIPHY): tapping a sticker copies it to
  the clipboard and the user pastes it manually.
- This environment does not have Xcode/macOS, so the project has not been
  compiled here — build and run it locally to verify before shipping.
