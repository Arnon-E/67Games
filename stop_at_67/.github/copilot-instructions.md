# Stop at 67 — Project Context

## Overview

**Stop at 67** is a mobile timing game built with Flutter/Dart for Android (iOS scaffolded but not primary target). Players try to stop a running timer as close to a target time (typically 6.700s) as possible. The app includes solo modes, 1v1 real-time multiplayer via Firestore, tournaments, leaderboards, a cosmetic shop, and localization in 3 languages.

- **App ID:** `com.sixtysevengames.stop_at_67`
- **Min SDK:** Flutter default (~21)
- **Java/Kotlin target:** 17
- **Signing:** Release config from `key.properties`

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter / Dart |
| State Management | Provider with ChangeNotifier |
| Backend | Firebase (Auth, Firestore, Remote Config) |
| Auth | Firebase Auth — Google Sign-In + anonymous |
| Database | Cloud Firestore |
| Local Storage | SharedPreferences via StorageService |
| Ads | Google Mobile Ads (currently disabled) |
| Subscriptions | RevenueCat (stub — not yet implemented) |
| Sound | flutter_tts + audioplayers |
| Localization | flutter_localizations + ARB files (EN, RU, HE) |
| Build | Gradle Kotlin DSL |

---

## Project Structure

```
stop_at_67/
├── lib/
│   ├── main.dart              # Entry point: Firebase init, service creation, Provider tree
│   ├── app.dart               # MaterialApp + _ScreenSwitcher (routes via GameState.screen enum)
│   ├── engine/
│   │   ├── constants.dart     # Game mode definitions, rating tiers, achievements, fortune segments
│   │   ├── scoring.dart       # Exponential decay scoring + streak multiplier
│   │   ├── progression.dart   # Mode unlock checks + achievement checker
│   │   ├── timer_engine.dart  # PrecisionTimer — Stopwatch + 16ms periodic, speed multiplier support
│   │   └── types.dart         # All data models (GameMode, ScoreResult, PlayerStats, MatchData, etc.)
│   ├── l10n/
│   │   ├── app_en.arb         # English (template)
│   │   ├── app_ru.arb         # Russian
│   │   ├── app_he.arb         # Hebrew (RTL)
│   │   └── app_localizations*.dart  # Generated — DO NOT edit manually
│   ├── screens/               # 15 screens, one per file
│   │   ├── menu_screen.dart
│   │   ├── mode_select_screen.dart
│   │   ├── countdown_screen.dart
│   │   ├── playing_screen.dart
│   │   ├── results_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── shop_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── fortune_wheel_screen.dart
│   │   ├── matchmaking_screen.dart
│   │   ├── match_lobby_screen.dart
│   │   ├── match_playing_screen.dart
│   │   └── match_results_screen.dart
│   ├── services/
│   │   ├── ads_service.dart          # AdMob interstitial + rewarded (disabled)
│   │   ├── auth_service.dart         # Firebase Auth + Firestore user doc
│   │   ├── leaderboard_service.dart  # Per-mode scores + tournaments, 5-min cache
│   │   ├── matchmaking_service.dart  # 1v1 queue + match lifecycle via Firestore
│   │   ├── sound_service.dart        # TTS voice + AudioPlayer for win/loss/67-kid
│   │   ├── storage_service.dart      # SharedPreferences wrapper
│   │   ├── subscription_service.dart # RevenueCat stub
│   │   └── update_service.dart       # Remote Config force-update check
│   ├── state/
│   │   ├── game_state.dart           # Main state (~1600 lines) — navigation, game session, 1v1, shop
│   │   ├── auth_state.dart           # Auth wrapper
│   │   ├── language_state.dart       # Locale + RTL detection
│   │   └── subscription_state.dart   # Subscription wrapper (stub)
│   ├── theme/
│   │   ├── app_theme.dart            # Dark Material 3 theme
│   │   ├── app_colors.dart           # Color tokens (dark purples, orange CTA, gold accents)
│   │   └── app_text_styles.dart      # Named text styles (timerDisplay, logoDisplay, etc.)
│   └── widgets/                      # 14 reusable components
│       ├── app_gradient_background.dart
│       ├── coin_fly_animation.dart
│       ├── countdown_display.dart
│       ├── daily_reward_modal.dart
│       ├── game_button.dart
│       ├── mode_card.dart
│       ├── score_display.dart
│       ├── screen_header.dart
│       ├── session_summary_modal.dart
│       ├── share_card_widget.dart
│       ├── stop_button.dart
│       ├── tap_area.dart
│       ├── timer_display.dart
│       └── update_dialog.dart
├── assets/
│   └── sounds/
│       ├── 67-kid.mp3       # "six seven" voice (perfect/excellent)
│       ├── Victory.mp3      # 1v1 win sound
│       └── Loser.mp3        # 1v1 loss sound
├── android/
│   └── app/
│       ├── build.gradle.kts
│       └── google-services.json
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── l10n.yaml
└── analysis_options.yaml
```

---

## Navigation

The app uses a **single-page architecture** — no named routes. `GameState._screen` is an `AppScreen` enum with 15 values. `_ScreenSwitcher` in `app.dart` maps the enum to screen widgets with `AnimatedSwitcher(250ms)`.

Back button handling uses `PopScope` — only the menu screen allows system pop (exit app). All other screens block hardware back.

---

## Game Modes (13)

| ID | Name | Target | Special |
|----|------|--------|---------|
| `classic` | Classic | 6.700s | Always unlocked |
| `extended` | Extended | 67.000s | Unlock: 900+ in Classic |
| `blind` | Blind | 6.700s | Timer hides after 3s |
| `reverse` | Reverse | 3.300s | Countdown from 10s |
| `reverse100` | Reverse 100 | 33.000s | Countdown from 100s |
| `daily` | Daily Challenge | Random | One attempt/day |
| `surge` | Accelerate | 6.700s | Speed increases, lives system |
| `fortune` | Fortune | Wheel picks | Costs 500 coins, multiplied score |
| `doubletap` | Double Tap | 6.700s | Tap midpoint + stop |
| `movingtarget` | Moving Target | 5.0–9.0s | Random target each round |
| `calibration` | Calibration | 6.700s | 5 attempts averaged |
| `pressure` | Pressure | 6.700s | Tolerance tightens per success |

---

## Scoring System

- **Formula:** `maxScore × exp(-decay × deviationMs)` with streak multiplier + perfect bonus (3×)
- **Rating tiers:** Perfect (0ms) → Incredible (≤10ms) → Excellent (≤50ms) → Great (≤100ms) → Good (≤250ms) → OK (≤500ms) → Miss (>500ms)
- **Timer:** `PrecisionTimer` uses `Stopwatch` + `Timer.periodic(16ms)`, supports speed multipliers 1×–10×

---

## 1v1 Matchmaking System

### Firestore Collections

**`matchmaking_queue/{uid}`** — one doc per queued player:
```json
{
  "uid": "string",
  "displayName": "string",
  "modeId": "string",
  "targetMs": 6700,
  "acceptSpeedUp": false,
  "rematchRound": 0,
  "createdAt": "serverTimestamp"
}
```

**`matches/{matchId}`** — match document (auto-ID):
```json
{
  "modeId": "string",
  "targetMs": 6700,
  "speedMultiplier": 1.0,
  "status": "countdown|playing|finished|cancelled",
  "player1": { "uid": "", "displayName": "", "stoppedAtMs": null, "deviationMs": null, "score": null },
  "player2": { "uid": "", "displayName": "", "stoppedAtMs": null, "deviationMs": null, "score": null },
  "createdAt": "serverTimestamp"
}
```

### Flow
1. `startMatchmaking()` → `joinQueue()` (Firestore transaction):
   - Looks for preferred opponent (rematch) or any opponent in queue
   - If found: creates match doc, deletes both queue entries, returns matchId
   - If not found: adds self to queue, returns null
2. If queued: `listenForMatch()` watches `matches` collection for docs containing caller's UID
3. **7-second timeout** → retry once → show "Play vs Bot" option
4. Match subscription drives screen transitions: countdown → playing → finished/cancelled
5. `submitResult()` writes player's score; when both submitted, match becomes `finished`
6. **Rematch:** remembers opponent UID + round; speed increase (+0.2× per round, cap 3×) only if both players accept
7. **Bot match:** fully local, no Firestore — bot deviation is random 20–150ms

### Firestore Security Rules

```
matchmaking_queue/{uid}:
  read: any authenticated user
  create/update: only owner (auth.uid == uid)
  delete: any authenticated user (needed: opponent deletes your queue doc on match)

matches/{matchId}:
  read: any authenticated user
  create: any authenticated user
  update: only player1 or player2 (checked via resource.data.playerN.uid)
```

**Important:** The `joinQueue()` transaction deletes the opponent's queue doc, so `matchmaking_queue` delete permission must be open to any authenticated user.

---

## Other Firestore Collections

```
users/{uid}           — read: authenticated; write: owner only
leaderboard/{modeId}/scores/{uid}  — read: public; write: owner, score can only increase
leaderboard/{modeId}/meta/{doc}    — read: public; write: authenticated
tournaments/{weekId}/scores/{uid}  — read: public; write: owner, score can only increase
tournaments/{weekId}/meta/{doc}    — read: public; write: authenticated
```

---

## Localization

- **Languages:** English (en), Russian (ru), Hebrew (he — RTL)
- **System:** `l10n.yaml` → `flutter gen-l10n` → generates `app_localizations*.dart`
- **Template:** `app_en.arb`
- **RTL:** `LanguageState.isRTL` → wraps screens in `Directionality(TextDirection.rtl)` for Hebrew
- **Rule:** All user-facing strings must have keys in all 3 ARB files
- **Generated files** (`app_localizations.dart`, `app_localizations_en.dart`, etc.) are auto-generated — do NOT rely on editing them directly; they may be overwritten by `flutter gen-l10n`

---

## Sound System

`SoundService` handles two audio channels:
- **TTS** (`FlutterTts`): voice feedback per rating tier ("Perfect!", "Great!", etc.)
- **AudioPlayer** (`audioplayers`): plays asset sounds:
  - `winner` → `sounds/Victory.mp3`
  - `loser` → `sounds/Loser.mp3`
  - `sixtyseven` → `sounds/67-kid.mp3` (on perfect/excellent)

`cleanup()` stops both TTS and AudioPlayer — called on rematch and return-to-menu.

---

## Theme

**Dark-only** design with Material 3:
- Backgrounds: deep blacks/purples (`#07070F`, `#180828`, `#1A1A2E`)
- Accent: orange (`#FF6B35`) for CTAs
- Gold (`#FFD700`) for coins, ranks, highlights
- Cyan (`#00DDFF`) for secondary accents
- Text: white primary, gray secondary, muted disabled

---

## Dependencies (Key)

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Local persistence |
| `firebase_core/auth/cloud_firestore` | Backend |
| `firebase_remote_config` | Force-update |
| `google_sign_in` | OAuth |
| `google_mobile_ads` | Ads (disabled) |
| `purchases_flutter` | RevenueCat (stub) |
| `flutter_tts` | Voice feedback |
| `audioplayers` | Sound effects |
| `haptic_feedback` | Vibration |
| `share_plus` | Share results |
| `wakelock_plus` | Screen awake during play |
| `url_launcher` | Open Play Store |
| `package_info_plus` | Version checks |

---

## Development Notes

### Building APK
```bash
cd stop_at_67
flutter build apk --release   # signed release APK
flutter build apk --debug     # unsigned debug APK (larger, no keystore needed)
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Running on Device
```bash
flutter devices              # list connected devices
flutter run -d <device_id>   # run with hot reload (press 'r')
flutter install -d <device_id> # install without debug session
```

### Hot Reload
Run with `flutter run`, then press `r` in terminal for hot reload (preserves state) or `R` for hot restart (resets state).

### Localization
After editing `.arb` files:
```bash
flutter gen-l10n
```
This regenerates `lib/l10n/app_localizations*.dart` files.

### Common Patterns
- All services are created in `main.dart` and injected via constructor into state classes
- Screen navigation: set `_screen` enum value in `GameState` and call `notifyListeners()`
- 1v1 match state is driven by Firestore snapshot listeners — UI reacts to status changes
- Bot matches are fully local (no network) — `MatchData` is constructed in memory
- W/L/T series record is tracked locally in `GameState` (not persisted) — resets on new opponent or return to menu
