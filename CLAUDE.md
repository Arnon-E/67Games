# CLAUDE.md — Stop at 67 (67Games)

## Project Overview

**Stop at 67** is a Flutter mobile game where players try to stop a timer at exactly 6.7 seconds. It supports 13 single-player modes, live 1v1 multiplayer with Firestore, a wrestling-themed **Fight Mode** (most recent feature), a cosmetics shop, weekly missions, achievements, and leaderboards.

Platform: Android (primary) + iOS. Languages: English, Hebrew (RTL), Russian.

---

## Repository Structure

```
67Games/
├── CLAUDE.md                    ← you are here
├── docs/
│   ├── ARCHITECTURE.md          ← screens, state, Firebase, patterns
│   ├── GAME_DESIGN.md           ← modes, scoring, mechanics
│   └── COSMETICS_AND_MONETIZATION.md  ← all cosmetics, ads, coins
├── stop_at_67/                  ← main Flutter app
│   ├── lib/
│   │   ├── main.dart            ← Firebase init, app entry
│   │   ├── app.dart             ← root widget, screen router
│   │   ├── engine/
│   │   │   ├── constants.dart   ← ALL game constants (modes, skins, missions, achievements)
│   │   │   ├── types.dart       ← ALL data types (GameMode, MatchData, WrestlerSkin, etc.)
│   │   │   ├── scoring.dart     ← score/rating calculation
│   │   │   ├── progression.dart ← XP, levels, streaks, achievements
│   │   │   └── timer_engine.dart← PrecisionTimer class
│   │   ├── state/
│   │   │   ├── game_state.dart  ← MAIN STATE (~1700 lines) — all game logic lives here
│   │   │   ├── auth_state.dart  ← Firebase Auth / Google Sign-In
│   │   │   ├── language_state.dart
│   │   │   └── subscription_state.dart
│   │   ├── services/
│   │   │   ├── matchmaking_service.dart ← Firestore queue + match lifecycle
│   │   │   ├── leaderboard_service.dart
│   │   │   ├── storage_service.dart    ← SharedPreferences wrapper
│   │   │   ├── ads_service.dart        ← Google AdMob (currently disabled)
│   │   │   ├── sound_service.dart      ← TTS + audio playback
│   │   │   └── subscription_service.dart ← RevenueCat (currently stubbed)
│   │   ├── screens/             ← 15 screens (see ARCHITECTURE.md)
│   │   ├── widgets/
│   │   │   ├── wrestler_avatar.dart  ← NEW: CustomPainter wrestler character
│   │   │   └── ...                  ← other reusable widgets
│   │   ├── theme/app_colors.dart    ← centralized color tokens
│   │   └── l10n/                    ← localization (en/he/ru)
│   └── pubspec.yaml
└── hello_android/               ← minimal secondary app (ignore)
```

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | SDK ≥3.3.0 |
| Language | Dart | 3.3+ |
| State | Provider + ChangeNotifier | 6.1.2 |
| Backend | Firebase (Auth, Firestore, Remote Config) | Core 3.6.0 |
| Auth | Google Sign-In + Firebase Auth | 5.3.1 |
| Ads | Google Mobile Ads (AdMob) | 5.3.0 |
| IAP | RevenueCat (purchases_flutter) | 8.0.0 |
| Storage | SharedPreferences | 2.3.2 |
| Audio | audioplayers + flutter_tts | 6.1.0 / 4.2.0 |
| Haptics | haptic_feedback | 0.5.1+1 |
| Localization | flutter_localizations (intl) | 0.20.2 |

---

## Key Architecture Rules

1. **All game logic lives in `game_state.dart`** — screens only call methods and watch state.
2. **Screen routing is state-driven** — `AppScreen` enum in `game_state.dart`, rendered in `app.dart`.
3. **New strings need updating in 6 places**: `app_en.arb`, `app_he.arb`, `app_ru.arb` + the three `app_localizations_*.dart` generated files (and the abstract `app_localizations.dart`).
4. **New cosmetics**: add to `constants.dart` (kWrestlerSkins/kShopItems), add default to `_ownedCosmetics` in `game_state.dart`, add equipCosmetic/unequipCosmetic case.
5. **New game modes**: add to `kGameModes` in `constants.dart`, handle in `game_state.dart`'s `stopGame()`, add l10n strings.
6. **Multiplayer matches**: Never write directly to Firestore outside of `matchmaking_service.dart`. All match state flows through `_subscribeToMatch()` listener.

---

## Branch Strategy

- `main` — production
- `claude/<feature-name>` — feature branches for Claude's work
- Current active branch: `claude/add-1v1-sharing-ads-itHJR`

Always push to the assigned Claude branch. Do NOT push to `main`.

---

## Active Features (Recently Built)

### Fight Mode (commit `8719f46` on `claude/add-wrestling-combat-2aVCN`)

A wrestling-themed combat mode layered on top of 1v1 multiplayer:

**Entry:** Menu "1v1 MATCH" → bottom sheet → "Fight Mode" → "vs Bot" or "vs Player"

**Mechanics:**
- Each player starts with **3 HP**
- Win a round → deal damage: **1 HP** (normal), **2 HP** (perfect 0ms stop), **+1 HP if speed ≥ 2.0×**
- Speed auto-increases +0.2× each round
- First to 0 HP → KNOCKOUT

**Key state in `game_state.dart`:**
```dart
static const int kFightMaxHp = 3;
bool _fightModeActive
int _myFightHp, _opponentFightHp
int _fightRound
int _lastRoundMyDamage, _lastRoundOpponentDamage
bool get isFightOver  // true when any HP ≤ 0
```

**Key methods:**
- `startFightVsBot()` — reset HP, start bot match
- `startFightMatchmaking()` — reset HP, find real opponent
- `fightNextRound()` — auto-rematch with speed increase
- `_processFightRound(myScore, oppScore, myDeviationMs, oppDeviationMs)` — calc damage

**Wrestler Skins (`wrestler_avatar.dart`, `kWrestlerSkins` in `constants.dart`):**

| ID | Name | Price | Accessory |
|----|------|-------|-----------|
| `wrestler_default` | Classic | Free | Headband |
| `wrestler_ninja` | Ninja | 500 coins | Face mask |
| `wrestler_robot` | Robot | 800 coins | Visor |
| `wrestler_fire` | Inferno | 600 coins | Flames |
| `wrestler_ice` | Glacier | 600 coins | Crown |
| `wrestler_gold` | Champion | 1,200 coins | Belt |

Skins are drawn with `CustomPainter` (no image assets needed). To replace with AI-generated art: place 200×220px PNG at `assets/wrestlers/<id>.png` and switch `WrestlerAvatar` to `Image.asset`.

**WrestlerAvatar params (new):**
- `punchProgress` (0.0–1.0) — animates right arm into a punch
- `isKnocked` (bool) — X eyes + open dazed mouth

**KO screen animation (`_KOFightScene` widget, `match_results_screen.dart`):**
- Mortal Kombat-style: winner steps in → punch extends → white impact flash → loser knocked back with X eyes + stars
- 2.2s `AnimationController`, plays once on entry then holds final frame

---

## Scoring Quick Reference

```
rawScore = 1000 × exp(−0.00326 × deviationMs)
finalScore = rawScore × streakMultiplier × perfectBonus × modeMultiplier

Deviation tiers: Perfect(0ms) | Incredible(≤10ms) | Excellent(≤50ms) |
                 Great(≤100ms) | Good(≤250ms) | OK(≤500ms) | Miss(>500ms)

Streak: maintained if deviation ≤50ms, broken if >50ms, frozen between
Streak multiplier: 1.0 + (streak × 0.1), capped at 2.0×
Perfect bonus: 3× if deviationMs == 0
XP: finalScore ÷ 10
```

---

## Multiplayer Architecture

```
Firestore Collections:
  matchmaking_queue/{uid}  ← players waiting for opponent
  matches/{matchId}        ← live match documents

Match lifecycle: waiting → countdown → playing → finished/cancelled

Bot fallback: if no opponent in 7s → bot option appears
              bot results generated locally (20-150ms random deviation)

Heartbeat: each client writes a timestamp every 10s via sendHeartbeat()
           _opponentGone() returns true if opponent heartbeat > 30s stale
           handles disconnect detection without Firestore presence feature

Speed negotiation: lobby shows "Speed Challenge" dialog if one player
                   wants to speed up; both must accept for speed to apply

Fight mode: HP tracked in GameState (client-side), both clients
            calculate identically from same Firestore match results

Fight invite (friend challenge):
  fight_invites/{code}  ← 6-char code, status: waiting → accepted, TTL 10min
  Host creates → shares code → guest joins → both queue with preferOpponentUid
  FightInviteScreen (AppScreen.fightInvite) shows code + share sheet (share_plus)
  joinFightByCode(code) in game_state.dart — guest-side join flow
  createFightInvite() / cancelFightInvite() — host-side flow
```

---

## Monetization Status

| Component | Status | Notes |
|-----------|--------|-------|
| Ads (AdMob) | **DISABLED** | Suspended until Apr 18 2026 — test IDs in place |
| RevenueCat | **STUBBED** | All methods return false — ready to wire up |
| Coins (in-game) | **LIVE** | Daily rewards, missions, shop purchases |
| Wrestler skins | **LIVE** | Added to shop system, 500–1200 coins |
| Fight invite/share | **LIVE** | 6-char code share, Firestore rendezvous, share_plus |
| 1v1 banner ad | **READY** (disabled) | Matchmaking screen, loads while waiting for opponent |
| 1v1 interstitial | **READY** (disabled) | After KO + every 3 real matches on menu return |

---

## Storage Keys (SharedPreferences)

```
stop_at_67_stats              ← PlayerStats JSON
stop_at_67_achievements       ← List<String> unlocked IDs
stop_at_67_coins              ← int
stop_at_67_loadout            ← PlayerLoadout JSON (timerSkin/bg/sound/celebration/wrestlerSkin)
stop_at_67_owned_cosmetics    ← List<String> owned IDs
stop_at_67_daily_rewards      ← DailyRewardState JSON
stop_at_67_weekly_missions    ← WeeklyMissionsState JSON
stop_at_67_streak             ← streak data
stop_at_67_sound_enabled      ← bool
stop_at_67_language           ← 'en' | 'he' | 'ru'
```

---

## Adding New Features — Patterns

### New Game Mode
1. Add `GameMode(...)` to `kGameModes` in `constants.dart`
2. Handle mode-specific state in `game_state.dart` (new fields if needed)
3. Add case to `stopGame()` for result processing
4. Add l10n strings (`mode<Name>Name`, `mode<Name>Desc`)
5. Optionally: add unlock achievement or cosmetic

### New Cosmetic
1. Add skin/item definition to `constants.dart`
2. Add ID to `_ownedCosmetics` default list in `game_state.dart` if free
3. Add `equipType` case to `equipCosmetic()` and `unequipCosmetic()`
4. Add field to `PlayerLoadout.toJson()` / `fromJson()` / `copyWith()`
5. Add shop item strings to l10n files

### New Localization String
1. Add to `app_en.arb`, `app_he.arb`, `app_ru.arb`
2. Add abstract getter/method to `app_localizations.dart`
3. Add implementation to each `app_localizations_*.dart`
4. Use: `AppLocalizations.of(context).yourNewKey`

### New Screen
1. Create `lib/screens/<name>_screen.dart`
2. Add value to `AppScreen` enum in `game_state.dart`
3. Add case to screen router in `app.dart`
4. Add navigation method in `game_state.dart` (e.g., `setScreen(AppScreen.newScreen)`)
5. Handle back navigation in `_backTarget()` in `app.dart`

---

## Known Issues / TODOs

- [ ] Replace AdMob test IDs with production IDs (`ads_service.dart` lines 13, 17, **and new banner line ~20**)
- [ ] Implement RevenueCat (currently stubbed in `subscription_service.dart`)
- [x] Wrestler skins now shown in Shop with WrestlerAvatar preview — buy/equip/unequip live
- [ ] Fight Mode vs real player: opponent doesn't see fight UI unless they also chose Fight Mode
- [ ] Bot difficulty in Fight Mode could be tuned (currently 20–150ms random deviation)
- [ ] Consider adding Fight Mode to the weekly missions system
- [x] Fight Mode friend invite — 6-char share code + FightInviteScreen + join dialog
- [x] 1v1 ads — banner on matchmaking screen + interstitial after KO + every 3 real matches

---

## Sound Assets

```
assets/sounds/
  67-kid.mp3    ← plays on Excellent rating
  Victory.mp3   ← multiplayer win
  Loser.mp3     ← multiplayer loss

TTS feedback: perfect, great, good, ok, miss, winner, loser, levelUp, achievement
```

---

## Color Tokens (`app_colors.dart`)

```dart
AppColors.darkPrimary    // #07070F — main background
AppColors.darkCard       // #1A1A2E — card/dialog background
AppColors.orange         // #FF6B35 — primary CTA, player 1
AppColors.gold           // #FFD700 — coins, rank #1, win highlight
AppColors.cyan           // #00DDFF — multiplayer, player 2
AppColors.textPrimary    // white
AppColors.textSecondary  // #BFC3D9
AppColors.textDisabled   // #6C728A
```

---

*Last updated: 2026-04-08 — Fight Mode implemented.*
