# Architecture Reference

## Screen Map

| AppScreen enum | File | Widget | Purpose |
|---------------|------|---------|---------|
| `menu` | `menu_screen.dart` | `MenuScreen` | Main hub: stats, daily reward, session info, mode/1v1 buttons |
| `modeSelect` | `mode_select_screen.dart` | `ModeSelectScreen` | Grid of all 13 unlockable modes |
| `fortuneWheel` | `fortune_wheel_screen.dart` | `FortuneWheelScreen` | Spin for random mode + score multiplier (costs 500 coins) |
| `countdown` | `countdown_screen.dart` | `CountdownScreen` | 3-2-1 GET READY sequence |
| `playing` | `playing_screen.dart` | `PlayingScreen` | Main game timer with tap zone |
| `results` | `results_screen.dart` | `ResultsScreen` | Score breakdown, XP, achievements, next-game options |
| `settings` | `settings_screen.dart` | `SettingsScreen` | Sound, language, account, legal links |
| `leaderboard` | `leaderboard_screen.dart` | `LeaderboardScreen` | All-time + weekly tournament per mode |
| `profile` | `profile_screen.dart` | `ProfileScreen` | Player stats, best scores, unlocked achievements |
| `shop` | `shop_screen.dart` | `ShopScreen` | Buy cosmetics with coins |
| `auth` | `auth_screen.dart` | `AuthScreen` | Google Sign-In (required for leaderboard/multiplayer) |
| `matchmaking` | `matchmaking_screen.dart` | `MatchmakingScreen` | Queue for 1v1; bot fallback after 7s timeout |
| `matchLobby` | `match_lobby_screen.dart` | `MatchLobbyScreen` | Pre-game VS screen with countdown; shows wrestlers in Fight Mode |
| `matchPlaying` | `match_playing_screen.dart` | `MatchPlayingScreen` | Live 1v1 timer; HP bars in Fight Mode |
| `matchResults` | `match_results_screen.dart` | `MatchResultsScreen` | Round result + KO screen in Fight Mode; rematch dialog otherwise |

### Back Navigation (`_backTarget()` in `app.dart`)

```
playing → menu
results → menu
matchPlaying → (blocked, canPop: false)
matchLobby → (blocked)
matchResults → menu (via matchReturnToMenu())
matchmaking → menu (via cancelMatchmaking())
everything else → menu
```

---

## State Management

### Provider Tree (`main.dart`)
```
MultiProvider
├── ChangeNotifierProvider(AuthState)
├── ChangeNotifierProvider(LanguageState)
├── ChangeNotifierProvider(SubscriptionState)
└── ChangeNotifierProxyProvider<AuthState, GameState>
    └── GameState(storage, sound, ads, authState, leaderboard, matchmaking)
```

### `game_state.dart` — The Single Source of Truth

**Navigation state:**
- `AppScreen _screen` — current screen, changed by GameState methods
- `setScreen(AppScreen)` — generic navigation

**Game session state:**
```dart
GameMode? _currentMode
TimerState _timerState          // isRunning, elapsedMs, displayTime, speedMultiplier
ScoreResult? _lastResult
int _countdownValue
bool _isBlindMode
PrecisionTimer? _precisionTimer
```

**Player persistence:**
```dart
PlayerStats _stats
List<String> _achievements
PlayerLoadout _loadout
int _coins
List<String> _ownedCosmetics    // IDs of everything owned
DailyRewardState _dailyRewards
WeeklyMissionsState _weeklyMissions
SessionStats _sessionStats
```

**Multiplayer:**
```dart
MatchData? _currentMatch
bool _matchSearching, _matchPlayerStopped, _matchTimedOut, _isBotMatch
String? _rematchOpponentUid
int _rematchRound
double _matchSpeedMultiplier    // 1.0 + (round-1) × 0.2, capped 3.0
int _matchSeriesWins/Losses/Ties
```

**Fight Mode (new):**
```dart
static const int kFightMaxHp = 3
bool _fightModeActive
int _myFightHp, _opponentFightHp   // 0–3
int _fightRound                     // increments after each round
int _lastRoundMyDamage              // damage I dealt (if I won)
int _lastRoundOpponentDamage        // damage taken (if I lost)
bool get isFightOver                // true when any HP ≤ 0
```

**Mode-specific state:**
```dart
// Surge/Accelerate
int _surgeGamesInSession, _surgeFailStreak, _surgeLives (starts 3)
int _surgeCumulativeScore
double _surgeSpeedMultiplier

// Double Tap
int _doubleTapPhase  // 0=inactive, 1=waiting mid-tap, 2=waiting stop
int _doubleTapMidMs

// Moving Target
int _movingTargetCurrentTarget

// Calibration
List<ScoreResult> _calibrationResults  // 5 rounds

// Pressure
int _pressureTolerance  // starts 50ms, -10ms per success, min 10ms
int _pressureRoundsSucceeded, _pressureFailAttempts
bool _pressureLastRoundSuccess, _pressurePendingAdRetry, _pressureGameOver
```

### Core Flow

```
selectMode(modeId)
  → startCountdown()
    → tickCountdown() × 3
      → _startPrecisionTimer()
        [player taps]
        → stopGame()
          → _calculateResult()
          → _updateStats()
          → _advanceMissions()
          → _checkAchievements()
          → _tryShowAd()
          → screen = results
```

### Multiplayer Flow

```
startMatchmaking() / startFightMatchmaking()
  → joinQueue() [Firestore transaction]
    → matched immediately → _subscribeToMatch()
    OR queued → listenForMatch() callback → _subscribeToMatch()
    OR timeout (7s) → bot option
  
_subscribeToMatch() listener:
  countdown → screen = matchLobby + _startHeartbeat()
  playing   → screen = matchPlaying + startPrecisionTimer()
  finished  → _processFightRound() [fight mode] + screen = matchResults
  cancelled → _cancelMultiplayer() + _stopHeartbeat()

stopMatchGame()
  → submit result to Firestore
  OR _completeBotMatch() if isBotMatch
```

### Lobby Countdown & Game-Start Latency

- Match lobby countdown tick interval: **600 ms** (3 ticks = 1.8 s total)
- Fight rematches (round 2+): countdown starts at **1** → game starts after a single 600 ms tick
- `matchCountdownComplete()` transitions to `matchPlaying` **immediately** (no Firestore round-trip);
  `startMatch()` is called fire-and-forget in the background so the opponent still picks up the
  `playing` status if their own countdown hasn't fired yet

### Heartbeat / Disconnect Detection
- Each client calls `sendHeartbeat(matchId, isPlayer1)` every **10 seconds** (`_heartbeatInterval`)
- `_opponentGone(match, myUid)` returns `true` if opponent's heartbeat timestamp is **> 30 seconds old** (`_heartbeatTimeout`)
- Grace period: if opponent never sent a heartbeat AND match is < 30s old, they are not considered gone
- Heartbeat is stopped in `_stopHeartbeat()` called on cancel / return to menu
- Constants defined in both `game_state.dart` and `matchmaking_service.dart` — keep in sync if changing

### Match Document Lifecycle & Cleanup
- Match docs are created on match and deleted when either player calls `matchReturnToMenu()` or `_cancelMultiplayer()`
- `MatchmakingService.deleteMatch(matchId)` — idempotent, both players can call it safely
- Bot matches (`isBotMatch = true`) are purely local and never written to Firestore
- Rationale: deleting docs keeps `listenForMatch` queries small and avoids Firestore cost accumulation

### Wrestler Image Precaching
- All 18 wrestler PNGs (6 skins × idle/punch/knocked) are decoded in the background via `precacheWrestlerImages(context)` in `wrestler_avatar.dart`
- Called when the user taps "Fight Mode" in the menu, before the lobby loads
- Without this, first render of match lobby/results would stall while Flutter decodes ~5MB of images

### Speed Negotiation
- In the match lobby, either player can request a speed-up
- A "Speed Challenge" dialog (`matchLobbySpeedNegotiateTitle/Body` l10n) appears on both sides
- Both must accept for the speed multiplier to increase; one decline keeps it the same
- `startMatchmaking(acceptSpeedUp: bool)` and `rematchBot(increaseSpeed: bool)` carry the flag forward

---

## Firebase Collections

### `matchmaking_queue/{uid}`
```json
{
  "uid": "string",
  "displayName": "string",
  "modeId": "classic",
  "targetMs": 6700,
  "acceptSpeedUp": false,
  "rematchRound": 1,
  "createdAt": "timestamp"
}
```

### `matches/{matchId}`
```json
{
  "modeId": "classic",
  "targetMs": 6700,
  "speedMultiplier": 1.0,
  "status": "waiting|countdown|playing|finished|cancelled",
  "playerUids": ["uid1", "uid2"],
  "player1": { "uid": "", "displayName": "", "stoppedAtMs": null, "deviationMs": null, "score": null },
  "player2": { "uid": "", "displayName": "", "stoppedAtMs": null, "deviationMs": null, "score": null },
  "createdAt": "timestamp"
}
```

### `leaderboard/{modeId}/scores/{uid}`
```json
{ "score": 0, "displayName": "", "uid": "", "timestamp": "" }
```

### `tournaments/{weekId}/scores/{uid}`
Same structure as leaderboard. `weekId` format: `2026-W11` (ISO week).

---

## Timer Engine (`timer_engine.dart`)

`PrecisionTimer` class:
- Uses `Stopwatch` + `Timer.periodic(Duration(milliseconds: 16))` for ~60fps ticks
- `setSpeedMultiplier(double)` — timer counts faster (e.g., 1.4× for rematches/surge)
- `start()` / `stop()` → returns elapsed milliseconds
- `getStoppedValue(elapsedMs)` → virtual elapsed at stop (accounts for multiplier)
- In countdown mode: counts down from `countdownFrom` in ms

---

## Scoring Engine (`scoring.dart`, `progression.dart`)

```dart
// Raw score (0–1000)
int calculateRawScore(int deviationMs) =>
    (1000 * exp(-0.00326 * deviationMs)).round().clamp(0, 1000);

// Rating tier
ScoreRating getRating(int deviationMs)
  // 0ms → perfect, ≤10ms → incredible, ≤50ms → excellent,
  // ≤100ms → great, ≤250ms → good, ≤500ms → ok, else → miss

// XP
int calculateXp(int finalScore) => finalScore ~/ 10;

// Level from XP (base 100, 1.5× per level, max 100)
int calculateLevel(int totalXp)
```

---

## Localization System

**Files:**
```
lib/l10n/
  app_localizations.dart          ← abstract base + delegate (edit to add abstract methods)
  app_localizations_en.dart       ← English implementations (edit to add @override methods)
  app_localizations_he.dart       ← Hebrew implementations
  app_localizations_ru.dart       ← Russian implementations
  app_en.arb                      ← Source of truth for EN strings
  app_he.arb                      ← Hebrew strings
  app_ru.arb                      ← Russian strings
```

**Note:** The generated `.dart` files are committed (not gitignored). When adding strings, manually update ALL 6 files (3 .arb + abstract dart + 3 concrete dart).

**String with placeholder example:**
```dart
// In .arb:
"fightRoundLabel": "ROUND {round}",
"@fightRoundLabel": { "placeholders": { "round": { "type": "int" } } }

// In app_localizations.dart:
String fightRoundLabel(int round);

// In app_localizations_en.dart:
@override
String fightRoundLabel(int round) => 'ROUND $round';
```

**RTL (Hebrew):** Handled by `LanguageState.isRTL`. The `MaterialApp` in `app.dart` sets locale based on `LanguageState`.

---

## Sound Service

Available sound keys (call `_sound.play('key')` in GameState):
- `'perfect'` — TTS "Perrrrfect!" (pitch 1.2)
- `'excellent'` — plays `67-kid.mp3`
- `'great'` — TTS "Great"
- `'good'` — TTS "Good"
- `'ok'` — TTS "Ok"
- `'miss'` — TTS "Miss"
- `'winner'` — `Victory.mp3` + TTS "Victory"
- `'loser'` — `Loser.mp3`
- `'levelUp'` — TTS "Level Up!"
- `'achievement'` — TTS "Achievement unlocked!"

Sound is disabled entirely when `_sound.isEnabled == false` (user toggle in Settings).

---

## Widgets Catalogue

| Widget | File | Purpose |
|--------|------|---------|
| `AppGradientBackground` | `app_gradient_background.dart` | Dark purple gradient backdrop |
| `TimerDisplay` | `timer_display.dart` | Large monospace timer (skin-aware) |
| `StopButton` | `stop_button.dart` | Big tap target; disabled state |
| `GameButton` | `game_button.dart` | Primary/secondary CTA button |
| `ScreenHeader` | `screen_header.dart` | Back arrow + title row |
| `WrestlerAvatar` | `wrestler_avatar.dart` | CustomPainter fighter; `punchProgress` animates punch, `isKnocked` shows X-eyes |
| `_KOFightScene` | `match_results_screen.dart` | 2.2s KO punch animation (Mortal Kombat-style), plays once on fight-over screen |
| `CoinFlyAnimation` | `coin_fly_animation.dart` | Coin particle animation on earn |
| `DailyRewardModal` | `daily_reward_modal.dart` | Login reward bottom sheet |

---

*Last updated: 2026-04-08 — Wrestler skins in shop; KO punch animation; WrestlerAvatar punch/knocked states.*
