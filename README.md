# Poppy — Shortcut Shelf

[![Release](https://github.com/iRedlof/Poppy/actions/workflows/release.yml/badge.svg)](https://github.com/iRedlof/Poppy/actions/workflows/release.yml)
[![Version](https://img.shields.io/badge/version-1.6.0-green)](https://github.com/iRedlof/Poppy/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/iRedlof/Poppy/total)](https://github.com/iRedlof/Poppy/releases)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/iRedlof/Poppy/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2015%2B-blue)]()
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)]()

A friendly macOS menu bar shortcut shelf. Launch apps, run shell commands, open URLs, and manage everyday workflows — all from a single popover.

## Features

- **Menu bar popover** with search, grouped shortcuts, and recent history
- **Command types**: app, shell, terminal, URL, file/folder, editor
- **Placeholder parameters** with last-used memory
- **Screenshot watcher** — copies new screenshot paths to clipboard
- **Time converter** — floating panel with day offset indicator
- **Toast notifications** — non-intrusive HUD alerts
- **Settings** — default apps, time zones, export/import, launch at login
- **Sparkle auto-updates** — in-app update notifications

## Setup

On first launch, Poppy will:
1. Appear in your menu bar (no Dock icon by default)
2. Prompt for **Accessibility** permission (required for the global hotkey ⌘⇧K)
3. Additional permissions (Automation, Full Disk Access) are requested as needed

Press **⌘⇧K** from any app to open the popover, or click the menu bar icon.

## Architecture

Built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA) and Swift 6 strict concurrency.

- `AppFeature` → `ShortcutsFeature` via `Scope`
- `@Dependency` clients: `ExecutorClient`, `PersistenceClient`, `PermissionClient`, `ScreenshotClient`, `ToastClient`, `ClipboardClient`
- `@Shared(.appSettings)` file storage — no UserDefaults
- `IdentifiedArrayOf` for shortcuts and groups
- Semantic typography and accessibility labels throughout

## Requirements

- macOS 15.0+
- Xcode 16+
- Swift 6.0
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Development

### Building

Open in Xcode (recommended):

```bash
xcodegen generate
open Poppy.xcodeproj
```

Or build from the command line:

```bash
xcodegen generate
xcodebuild -project Poppy.xcodeproj -scheme Poppy -configuration Debug build -skipMacroValidation
```

`-skipMacroValidation` is required because several SPM dependencies (TCA, swift-dependencies, swift-case-paths, swift-perception) use Swift macros. Xcode trusts them automatically via its UI; the CLI requires the flag.

### Testing

```bash
cd PoppyCore && swift test
```

Tests live in `PoppyCore/Tests/PoppyCoreTests/` and cover models, reducers, dependency clients, and feature logic. All tests use Swift Testing (`@Test`, `#expect`) — no XCTest.

### Code Signing

The project uses `CODE_SIGN_STYLE = Automatic`. Debug builds sign with "Apple Development" — make sure you have a valid Apple Development certificate in your keychain and your team is selected in Xcode's Signing & Capabilities tab.

- The `project.yml` has `DEVELOPMENT_TEAM` and `CODE_SIGN_STYLE = Automatic` pre-configured. Do **not** pass `DEVELOPMENT_TEAM` or `CODE_SIGN_IDENTITY` on the xcodebuild command line — this overrides the project settings and breaks SPM macro plugin signing.
- CLI builds use `-skipMacroValidation` to bypass the macro trust prompt (which only works in Xcode GUI).
- GitHub Actions CI also uses `-skipMacroValidation` and handles signing via an imported certificate.

## Project Structure

```
Poppy/                          # App target (SwiftUI views, AppKit integration)
  App/                          # AppDelegate, MenuBarManager, PopoverManager, ToastWindow, etc.
  Features/                     # Views: Dashboard, Preferences, DeveloperWindow, etc.
  Assets.xcassets/              # App icon and menu bar icon
PoppyCore/                      # Swift package (testable core logic)
  Sources/PoppyCore/
    AppFeature.swift            # Root TCA reducer
    ShortcutsFeature.swift      # Shortcuts CRUD, execution, import/export
    Models/                     # Shortcut, ShortcutGroup, AppSettings, etc.
    Logic/                      # Dependency clients (Executor, Persistence, Permission, etc.)
  Tests/PoppyCoreTests/         # All tests
project.yml                     # XcodeGen spec (source of truth for project config)
```

## Permissions

| Permission | Why | How to grant |
|---|---|---|
| **Accessibility** | Global hotkey (⌘⇧K) | System Settings → Privacy & Security → Accessibility → toggle Poppy on |
| **Automation** | Send commands to Terminal/iTerm2 via AppleScript | Run a terminal shortcut once — macOS prompts automatically |
| **Full Disk Access** | Shell commands accessing protected paths | System Settings → Privacy & Security → Full Disk Access → add Poppy |

The app checks permission status every 3 seconds and shows a warning banner when any are missing, with a "Fix" button that navigates to the Permissions section.

### Resetting permissions (developer)

Reset individual services — **never use `tccutil reset All`** as it can freeze macOS:

```bash
tccutil reset Accessibility com.iredlof.poppy && \
tccutil reset AppleEvents com.iredlof.poppy && \
tccutil reset ListenEvent com.iredlof.poppy && \
tccutil reset SystemPolicyAllFiles com.iredlof.poppy
```

There's also a hidden Developer window (tap the version number 7 times in Settings → About) with a "Copy Command" button that generates the correct reset + relaunch command for the current build.

## Releasing

Releases are automated via GitHub Actions. Bump the version, run the workflow from GitHub Actions, and the release job handles signing, notarization, Sparkle metadata, and the GitHub Release.

### How to release

1. Bump `MARKETING_VERSION` in `project.yml`:
   ```yaml
   MARKETING_VERSION: "1.6.0"
   ```
2. Bump `CURRENT_PROJECT_VERSION` if needed:
   ```yaml
   CURRENT_PROJECT_VERSION: "7"
   ```
3. Update the README version badge to match.
4. Commit and push:
   ```bash
   git add -A && git commit -m "chore: bump version to 1.6.0"
   git push origin main
   ```
5. Run the `Release` workflow with `workflow_dispatch`.
6. GitHub Actions automatically:
   - Detects the version bump (compares against existing tags)
   - Runs the Xcode test target and `PoppyCore` SwiftPM tests
   - Archives and exports `Poppy.app` with Developer ID signing
   - Notarizes and staples the app
   - Creates, notarizes, and staples `Poppy-<version>.dmg`
   - Generates `appcast.xml`
   - Creates a GitHub Release (`v1.6.0`) with the DMG and appcast

Users running Poppy are notified of the update via Sparkle and can install it with one click.

### Setup (one-time)

The release workflow runs on a self-hosted macOS runner with Xcode and Homebrew. It expects these GitHub secrets:

| Secret | Purpose |
|---|---|
| `MACOS_CERTIFICATE` | Base64-encoded Developer ID Application `.p12` certificate |
| `MACOS_CERTIFICATE_PWD` | Password for the `.p12` certificate |
| `TEAM_ID` | Apple Developer Team ID |
| `APPLE_ID` | Apple ID used for notarization |
| `APPLE_ID_PASSWORD` | App-specific password for notarization |
| `SPARKLE_PRIVATE_KEY` | Sparkle EdDSA private key for update signing |

Generate the Sparkle key with:

```bash
generate_keys -x /tmp/sparkle_key.txt
gh secret set SPARKLE_PRIVATE_KEY < /tmp/sparkle_key.txt
rm /tmp/sparkle_key.txt
```

### Manual release

Prefer the GitHub Actions workflow for releases. If you need to debug locally, mirror the workflow steps in `.github/workflows/release.yml`: generate the Xcode project, run both test suites, archive/export with `method: developer-id`, notarize and staple `Poppy.app`, create and notarize `Poppy-<version>.dmg`, run Sparkle `generate_appcast`, then create the GitHub Release with the DMG and `appcast.xml`.

### Debugging CI failures

List recent workflow runs:
```bash
gh run list --repo iRedlof/Poppy --limit 10
```

View a specific failed run (use the run ID from the list):
```bash
gh run view <RUN_ID> --repo iRedlof/Poppy
```

Find the failed job ID:
```bash
gh run view <RUN_ID> --repo iRedlof/Poppy --json jobs --jq '.jobs[] | "\(.databaseId) \(.name) \(.conclusion)"'
```

Get the failed job's logs:
```bash
gh run view --log-failed --job=<JOB_ID> --repo iRedlof/Poppy
```

Common failures:
- **"No signing certificate found"** — `MACOS_CERTIFICATE` is missing, the `.p12` is invalid, or it is not a Developer ID Application certificate.
- **Notarization failed** — check `APPLE_ID`, `APPLE_ID_PASSWORD`, and `TEAM_ID`; `APPLE_ID_PASSWORD` must be an app-specific password.
- **`create-dmg` or `generate_appcast` not found** — confirm the self-hosted runner has Homebrew and can install the release tools.
- **"Library Validation failed"** — app and frameworks were signed with different identities. Ensure the release workflow uses the Developer ID identity consistently.

## License

MIT — see [LICENSE](LICENSE) for details.

## Author

[Rohit Chandani](https://rlchandani.dev/)
