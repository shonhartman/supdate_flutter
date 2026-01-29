# Supdate

**Supdate** empowers busy users with **AI-automated social media updates** generated from **local device data**. Stay present online without the manual grind—your phone’s sensors and context feed an AI pipeline that drafts and posts for you.

---

## Mission

Busy people shouldn’t have to choose between living their lives and keeping their social presence fresh. Supdate turns **sensor data**, **location**, **activity**, and other on-device signals into **authentic, AI-generated social posts**—so you can share what’s happening without the extra effort.

---

## Architecture

Data flows in a single pipeline:

```
Sensor Data  →  AI  →  Social Post
```

| Stage           | Description                                                                                            |
| --------------- | ------------------------------------------------------------------------------------------------------ |
| **Sensor Data** | Local device inputs: location, motion, calendar, health, photos, and other privacy-respecting signals. |
| **AI**          | On-device or API-backed models that interpret context and generate natural-language updates.           |
| **Social Post** | Draft or published posts to connected platforms (e.g. X, Instagram, LinkedIn) with user control.       |

All processing prioritizes **user privacy**: data stays on-device by default, with clear opt-ins for any cloud or third-party services.

---

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Platforms:** iOS (primary), with Android and others possible later.
- **Tooling:** Xcode (iOS), CocoaPods, standard Flutter toolchain.

---

## Parallel Pilot: Flutter vs. SwiftUI

Supdate is being developed in **two implementations in parallel**:

- **This repo:** Flutter (`supdate_flutter`) — cross-platform potential, shared logic, fast iteration.
- **Native SwiftUI:** A separate, pure SwiftUI app — deep iOS integration, native performance, platform APIs first.

We’re running both **to find the native limits**: where Flutter is enough, where SwiftUI’s tighter iOS coupling matters, and what we should standardize on for production. Findings will influence the long-term architecture.

---

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- Xcode (iOS) with iOS Simulator runtimes and CocoaPods
- Optional: Android Studio / SDK for Android

### Setup and run

1. Clone and install dependencies:

```bash
git clone https://github.com/shonhartman/supdate_flutter.git
cd supdate_flutter
flutter pub get
```

2. Configure Supabase (required; credentials are not in the repo):

- Copy `config.json.example` to `config.json`.
- Get your project URL and anon key from [Supabase](https://supabase.com/dashboard) → your project → **Settings** → **API**.
- Put them in `config.json`:
  - `SUPABASE_URL`: your project URL (e.g. `https://xxxxx.supabase.co`)
  - `SUPABASE_ANON_KEY`: your anon (public) key

3. Run the app with the config file:

```bash
flutter run --dart-define-from-file=config.json
```

Use `flutter run -d chrome` for web, or `flutter run -d "iPhone 16"` (or your device) for iOS. Add `--dart-define-from-file=config.json` to your IDE run configuration so you don’t have to pass it every time.

### Doctor check

```bash
flutter doctor
```

Resolve any reported issues before building.

---

## Project Status

Early stage: hello-world baseline, iOS simulator and device running, deployment path (TestFlight → App Store) in progress. Feature work will follow once the production pipeline is solid.

---

## License

Proprietary. All rights reserved.
