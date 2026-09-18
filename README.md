# UltraTools

A small, dependency-free iOS developer toolbox written in Swift + SwiftUI.
Everything runs on-device — no network access, no analytics.

| Tool | What it does |
| --- | --- |
| **JSON Formatter** | Beautify, minify and validate JSON with configurable indentation, key sorting, copy/paste and human-readable error messages. |
| **Base64** | Encode / decode UTF-8 text, optional URL-safe alphabet and RFC 2045 line wrapping. |
| **UUID Generator** | Generate up to 100 random (RFC 4122 version 4) UUIDs at once, uppercase/hyphen formatting, per-row and bulk copy. |

- **Bundle ID:** `com.kulikoffad.UltraTools`
- **Platforms:** iPhone and iPad (universal)
- **Minimum OS:** iOS 15.0
- **Signing status of the CI artifact:** *unsigned* (see [Signing](#signing)).

## Repository layout

```text
UltraTools/
├── UltraTools/
│   ├── UltraToolsApp.swift      # @main entry point
│   ├── ContentView.swift        # root tool list + shared UI helpers
│   ├── JSONFormatterView.swift  # JSON tool + formatting engine
│   ├── Base64View.swift         # Base64 tool
│   ├── UUIDView.swift           # UUID tool
│   ├── Info.plist
│   └── Assets.xcassets/         # app icon + accent color
├── scripts/
│   └── make_app_icon.py         # regenerates Assets.xcassets/AppIcon.appiconset/AppIcon.png
├── project.yml                  # XcodeGen manifest (generates UltraTools.xcodeproj)
├── README.md
├── .gitignore
└── .github/
    └── workflows/
        └── build-ipa.yml        # CI: build + package + upload UltraTools.ipa
```

## Building locally (macOS)

Requirements: Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`).

```bash
# 1. Generate the Xcode project from project.yml
xcodegen generate

# 2. Build an unsigned device build
xcodebuild \
  -project UltraTools.xcodeproj \
  -scheme UltraTools \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

# 3. Package the .ipa
rm -rf Payload UltraTools.ipa
mkdir Payload
cp -R build/Build/Products/Release-iphoneos/UltraTools.app Payload/
zip -r -y UltraTools.ipa Payload

# 4. Verify
test -f UltraTools.ipa
unzip -l UltraTools.ipa        # must contain Payload/UltraTools.app/
```

To run on a simulator from Xcode, open `UltraTools.xcodeproj` after
`xcodegen generate` and pick any iPhone/iPad simulator.

## Continuous integration

`.github/workflows/build-ipa.yml` runs on **macos-latest** and:

1. installs XcodeGen (Homebrew, skipped when preinstalled),
2. generates the Xcode project (`xcodegen generate`),
3. builds `Release` for `iphoneos` without code signing,
4. packages `Payload/UltraTools.app` into **`UltraTools.ipa`** (`zip -r -y`),
5. verifies the archive actually contains `Payload/UltraTools.app/`,
6. uploads the file as the artifact **`UltraTools-IPA`** (retention 30 days).

Triggers:

- `workflow_dispatch` (manual run from the Actions tab),
- push to `main`,
- push to `arena/**` branches so automation branches can produce a verifiable
  IPA before merging.

The artifact contains exactly the file `UltraTools.ipa` (not the `.app`,
not an `.xcarchive`, not sources).

## Signing

The CI artifact is an **unsigned** IPA: it installs via Xcode Organizer /
side-loading tools after a resign step, e.g.

```bash
codesign --force --sign "Apple Development: you@example.com (TEAMID)" \
  --timestamp=none Payload/UltraTools.app
```

No Apple certificate or provisioning profile is present in this repository or
its CI environment, so the workflow intentionally builds with
`CODE_SIGNING_ALLOWED=NO`. To produce a signed, installable IPA, import a
signing identity on the runner (e.g. from GitHub secrets) and drop the three
`CODE_SIGNING_*` overrides from the workflow.

## App icon

`scripts/make_app_icon.py` regenerates the 1024×1024 icon (standard library
only, works on any OS):

```bash
python3 scripts/make_app_icon.py
```

## License

MIT.
