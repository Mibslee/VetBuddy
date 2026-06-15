# VetBuddy / 老铁

VetBuddy is an iOS and iPadOS SwiftUI app for daily wellness support, low-intensity exercise guidance, diet logging, and nutrition reminders for older adults.

## Repository Scope

This GitHub repository is intended to contain source code only.

For privacy and licensing reasons, the repository intentionally excludes:

- Personal voice reference files
- Generated cloned voice packs
- App Store screenshots and submission packages
- Generated exercise illustration images
- Third-party or generated video/image media
- Local build output and DerivedData

The excluded runtime assets are managed locally and are not required for reviewing the source code architecture, tests, and implementation patterns.

## Project Generation

The Xcode project is generated from `project.yml`.

```sh
./generate_project.sh
```

or:

```sh
xcodegen generate
```

## Privacy Posture

The app is designed to process health assessment answers, training records, diet records, Apple Health summaries, and camera frames locally on the device. See `PRIVACY.md` for the privacy statement.

## Medical Disclaimer

VetBuddy is a wellness, exercise guidance, and diet logging tool. It does not provide medical diagnosis, treatment, prescription, or professional medical advice.

