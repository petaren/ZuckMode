# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

The project uses XcodeGen to generate the `.xcodeproj` from `project.yml`. Run this after editing `project.yml`:

```bash
xcodegen generate
```

**Debug build** (ad-hoc signed, no entitlements — for local testing):
```bash
xcodebuild -scheme ZuckMode -configuration Debug \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO ENABLE_HARDENED_RUNTIME=NO
```

Built app lands in `~/Library/Developer/Xcode/DerivedData/Build/Products/Debug/ZuckMode.app`.

**Release build** (Developer ID signed, notarization-ready):
```bash
xcodebuild -scheme ZuckMode -configuration Release archive \
  -archivePath build/ZuckMode.xcarchive
xcodebuild -exportArchive -archivePath build/ZuckMode.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist
```

Notarize with stored Keychain profile (`notarytool-zuckmode`):
```bash
ditto -c -k --keepParent build/export/ZuckMode.app build/ZuckMode-<version>.zip
xcrun notarytool submit build/ZuckMode-<version>.zip --keychain-profile "petar-developer-id" --wait
xcrun stapler staple build/export/ZuckMode.app
```

## Architecture

Four files, no dependencies beyond AppKit/AVFoundation/CoreImage:

- **`main.swift`** — sets `.accessory` activation policy (no Dock icon), runs the app loop.
- **`AppDelegate.swift`** — owns the lifecycle. Requests camera permission first; only creates `OverlayWindowController` and `CameraController` after the permission dialog completes. If permission is denied, the overlay still exists but the camera never starts (overlay stays invisible).
- **`CameraController.swift`** — runs an `AVCaptureSession` on a private serial queue. Uses `CIDetector` (face + smile) with `CIDetectorAccuracyHigh`. Converts the boolean `hasSmile` to a smooth float via asymmetric EMA (`riseAlpha=0.20`, `fallAlpha=0.05`) normalised by `detectionNorm=0.50`. Emits a `Float` in `[0, 1]` where 1.0 = fully smiling.
- **`OverlayWindowController.swift`** — creates one borderless black `NSWindow` per screen at `.screenSaver` level (above dock and menu bar). Window alpha = `1 - smileScore`. In Encouragement mode, shows a label (inheriting window alpha — no separate label animation). Rotates the message each time smile detection clears the screen.
- **`StatusBarController.swift`** — menu bar item (😊/😐/😑) with Standard/Encouragement mode toggle. Defines `AppMode` enum used by both this file and `OverlayWindowController`.

## Signing

- Team ID: `B3J92VMY3K`
- Debug config uses ad-hoc signing (no certificate needed).
- Release config requires "Developer ID Application" certificate in Keychain.
- Entitlements file: `ZuckMode/ZuckMode.entitlements` — only `com.apple.security.device.camera`.
- `ExportOptions.plist` at repo root configures notarytool export (method: developer-id, manual signing).
- Notarytool credentials are stored in Keychain under profile `notarytool-zuckmode` — never in files.
