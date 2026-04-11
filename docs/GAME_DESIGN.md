# Game Design Reference

## Core Concept

Players tap a button to stop a running timer at exactly **6.700 seconds**. The closer to the target, the higher the score. Different modes vary the target time, add restrictions, or change the game structure.

---

## Game Modes (13 Total)

| ID | Name | Target | Key Mechanic | Unlock |
|----|------|--------|-------------|--------|
| `classic` | Classic | 6.700s | Standard — baseline mode | Free |
| `extended` | Extended | 67.000s | Ultra-long timing — patience and rhythm | Score 900+ in Classic |
| `blind` | Blind | 6.700s | Timer hides after 3s — rely on feel | Play 5 games |
| `reverse` | Reverse | 3.300s | Countdown from 10s, stop at 3.3s | Score 800+ in Extended |
| `reverse100` | Reverse 100 | 33.000s | Countdown from 100s, stop at 33s | Score 850+ in Reverse |
| `daily` | Daily Challenge | Variable | One attempt/day, global leaderboard entry | Play 1 game |
| `surge` | Accelerate | 6.700s | Timer speeds up after each game | Play 3 Blind games |
| `fortune` | Fortune | Variable | Spin wheel for random mode + multiplier | Play 3 games + 500 coins |
| `doubletap` | Double Tap | 6.700s | Tap at 3.35s AND stop at 6.7s | Play 3 games |
| `movingtarget` | Moving Target | 6.5s–9.0s | Target shifts every round (revealed each time) | Play 3 games |
| `calibration` | Calibration | 6.700s | 5 attempts averaged — consistency score | Play 5 games |
| `pressure` | Pressure | 6.700s | Tolerance window tightens 10ms each success | Score 800+ in Classic |

### Mode-Specific Rules

**Surge (Accelerate)**
- Speed multiplier = `1.0 + (gamesPlayed × 0.067)`, increases indefinitely
- Start with 3 lives
- Excellent+ (≤50ms) → +1 life (max uncapped)
- Good/OK/Miss → −1 life
- 0 lives → game over, ad to continue
- Score is cumulative across all rounds in session

**Pressure**
- Initial tolerance window: ±50ms around 6.700s
- Each success: tolerance tightens by 10ms
- Minimum tolerance: 10ms
- 3 failed attempts → game over
- Ad available for 1 extra retry after first failure

**Calibration**
- Exactly 5 attempts
- Score = average of all 5 deviations
- Shows per-attempt breakdown in results

**Double Tap**
- Phase 1: tap at 3.350s (±500ms tolerance or instant fail)
- Phase 2: tap to stop at 6.700s
- Final deviation = `(midDeviation + stopDeviation) ÷ 2`

**Moving Target**
- Each round: new target between 5,000ms–9,000ms in 100ms increments
- Target revealed before starting
- Standard scoring against that round's target

**Fortune Wheel**
- Costs **500 coins** to spin (100 to re-spin)
- 12 wheel segments with different mode + multiplier combos
- Score multiplier (1.5×–5.0×) applied on top of standard scoring
- Multiplier shown during gameplay

---

## Scoring System

### Core Formula
```
rawScore = 1000 × exp(−0.00326 × deviationMs)
           ↑ max 1000 pts, decays exponentially
```

Approximate values:
| Deviation | Raw Score |
|-----------|-----------|
| 0ms (Perfect) | 1000 |
| 10ms | ~968 |
| 50ms | ~849 |
| 100ms | ~719 |
| 250ms | ~443 |
| 500ms | ~196 |
| 1000ms | ~38 |

### Score Multipliers (applied in order)
1. **Perfect bonus** — ×3 if deviationMs == 0
2. **Streak multiplier** — `1.0 + (streak × 0.1)`, max 2.0×
3. **Fortune multiplier** — only in Fortune mode (1.5×–5.0×)
4. **Surge multiplier** — only in Surge mode
5. **Hot streak** — additional bonus for consecutive excellent+ results

### Deviation Rating Tiers

| Tier ID | Label | Max Deviation | Emoji | Color |
|---------|-------|------|-------|-------|
| `perfect` | PERFECT! | 0ms | 🏆 | Gold #FFD700 |
| `incredible` | INCREDIBLE | 10ms | ⚡ | Green #00FF88 |
| `excellent` | EXCELLENT | 50ms | 🔥 | Cyan #00DDFF |
| `great` | GREAT | 100ms | ✨ | Lime #88FF00 |
| `good` | GOOD | 250ms | 👍 | Orange #FFAA00 |
| `ok` | OK | 500ms | 😅 | Dark Orange #FF8800 |
| `miss` | MISS | ∞ | 💨 | Red #FF4444 |

---

## Streak System

- **Maintain** streak: deviation ≤ 50ms (excellent or better)
- **Break** streak: deviation > 50ms
- **Frozen zone** 50ms–500ms: streak stays the same (no advance, no break)
- **Max multiplier**: 2.0× (reached at streak 10)
- Tracked globally, reset on break, best streak preserved

---

## XP & Level Progression

```
xpEarned = finalScore ÷ 10

Level thresholds (exponential):
  Level 1: 0 XP
  Level 2: 100 XP
  Level 3: 250 XP
  Level N: 100 × (1.5^(N-1)) XP
  Max level: 100
```

---

## Fight Mode (1v1 Combat)

### Overview
A wrestling-themed combat system where 1v1 rounds deal HP damage until knockout.

### HP System
- Each player starts with **3 HP** (❤️❤️❤️)
- Win a round → deal damage to opponent
- Lose a round → take damage
- Tie → no damage

### Damage Calculation
```
damage = 1 (base)
       + 1 (if winnerDeviationMs == 0, i.e. Perfect stop → critical hit)
       + 1 (if speedMultiplier >= 2.0 → high-speed hit bonus)
       → clamped to max 2 per round
```

So:
- Normal win: **1 HP damage**
- Perfect stop win: **2 HP damage**
- Speed ≥ 2.0× normal win: **2 HP damage**
- Perfect stop at speed ≥ 2.0×: **2 HP damage** (cap)

### Round Progression
- Speed starts at 1.0×, increases **+0.2× per round**
- At round 6: 2.0×, rounds get significantly harder
- After each round: 3-second auto-continue countdown OR manual "Next Round"

### Outcomes
- Both reach 0 HP same round → tied KO (rare)
- One reaches 0 HP → KNOCKOUT screen
- KO screen shows both wrestlers, final HP, rounds fought
- "FIGHT AGAIN" restarts from round 1 with fresh HP

### Bot Opponent
- Bot deviation: random 20–150ms (reasonable challenge)
- Fight mode scales difficulty by increasing speed each round
- Bot doesn't get "perfect" stops (no 0ms hits from bot)

---

## Achievement System (16 total)

| ID | Name | Icon | Rarity | Condition |
|----|------|------|--------|-----------|
| `first_game` | First 67 | 🎮 | Common | Play 1 game |
| `ten_games` | Getting Started | 🚀 | Common | Play 10 games |
| `hundred_games` | Dedicated | 💪 | Rare | Play 100 games |
| `thousand_games` | Obsessed | 🤯 | Legendary | Play 1000 games |
| `sniper` | Sniper | 🎯 | Rare | Deviation ≤10ms in a single game |
| `perfect_stop` | Perfect | 💎 | Legendary | Deviation = 0ms |
| `triple_excellent` | Triple Excellent | 🌟 | Rare | 3 excellent+ in a row |
| `hot_streak` | Hot Streak | 🔥 | Common | 5 games ≤100ms in a row |
| `streak_lord` | Streak Lord | 👑 | Epic | 10 games ≤100ms in a row |
| `unstoppable` | Unstoppable | ⚡ | Legendary | 25 games ≤100ms in a row |
| `blind_master` | Blind Master | 🙈 | Epic | Score 900+ in Blind mode |
| `extended_excellence` | Extended Excellence | ⏱️ | Epic | Score 950+ in Extended mode |
| `reverse_master` | Reverse Master | 🔄 | Epic | Score 900+ in Reverse mode |
| `daily_player` | Daily Player | 📅 | Common | Complete 1 Daily Challenge |
| `daily_devotee` | Daily Devotee | 🗓️ | Epic | 7 consecutive Daily Challenges |
| `daily_champion` | Daily Champion | 🥇 | Legendary | Rank #1 in a Daily Challenge |

Rarity affects display styling (gold border for Legendary, etc.).

---

## Weekly Missions (5 per week, reset every Monday)

| ID | Name | Type | Target | Reward |
|----|------|------|--------|--------|
| `play_10` | Game Grinder | games | 10 games | 300 coins |
| `perfect_3` | Perfectionist | perfects | 3 perfect stops | 5,000 coins |
| `modes_3` | Explorer | modes | 3 different modes | 400 coins |
| `score_900` | Sharpshooter | score | 900+ in one game | 350 coins |
| `streak_5` | On Fire | streak | Streak of 5+ | 250 coins |

Week ID format: ISO week (`2026-W11`). Stored in SharedPreferences with progress per mission and claim status.

---

## Daily Rewards

- Claim once per 24h
- Reward amount scales with login streak (longer streak = more coins)
- Base: 1–30 coins scaling from a daily claim multiplier
- Login streak resets if a day is missed

---

## Daily Challenge

- One attempt per day per player
- Target time: chosen from a Remote Config seed (consistent globally)
- Score submitted to `tournaments/{weekId}` Firestore collection
- Top 10 weekly leaderboard refreshes every Monday
- Unlocked after playing 1 game

---

*Last updated: 2026-04-08*
