# Cosmetics & Monetization Reference

## Cosmetics System Overview

Cosmetics are purely visual — they never affect gameplay scores.

**Equipment slots (`PlayerLoadout`):**
```dart
timerSkin   // visual style of the countdown timer display
background  // screen background theme
soundPack   // tap/game sound effects
celebration // particle effect on excellent+ result
wrestlerSkin // wrestler character in Fight Mode
```

**Ownership:** All owned cosmetic IDs stored in `stop_at_67_owned_cosmetics` (SharedPreferences list). Defaults always included.

**Purchasing:** `purchaseCosmetic(id, price)` in `game_state.dart` — deducts coins, adds to owned list.

**Equipping:** `equipCosmetic(type, id)` — validates ownership, updates loadout, persists.

---

## All Cosmetic Items

### Timer Skins (`timerSkin`)

| ID | Name | Price | Description |
|----|------|-------|-------------|
| `timer_skin_default` | Default | **Free** | Standard white display |
| `timer_skin_neon` | Neon | 12,000 coins | Glowing cyan digits |
| `timer_skin_gold` | Gold | 24,000 coins | Luxurious gold display |
| `timer_skin_matrix` | Matrix | 20,000 coins | Green digital rain |
| `timer_skin_midnight` | Midnight | 28,000 coins | Cool blue midnight |

### Backgrounds (`background`)

| ID | Name | Price | Description |
|----|------|-------|-------------|
| `bg_default` | Default | **Free** | Dark purple gradient |
| `bg_purple` | Purple Haze | 18,000 coins | Deep purple theme |
| `bg_ocean` | Ocean Deep | 18,000 coins | Dark ocean blue |
| `bg_ember` | Ember Night | 22,000 coins | Fiery orange night |
| `bg_arctic` | Arctic Mist | 22,000 coins | Icy pale blue |
| `bg_crimson` | Crimson Dusk | 25,000 coins | Deep crimson twilight |

### Sound Packs (`soundPack`)

| ID | Name | Price | Description |
|----|------|-------|-------------|
| `sound_default` | Default | **Free** | TTS voice + audio effects |

*More sound packs planned.*

### Celebrations (`celebration`)

| ID | Name | Price | Description |
|----|------|-------|-------------|
| `celebration_default` | Default | **Free** | Standard pulse animation |
| `celebration_fireworks` | Fireworks | 30,000 coins | Explosive particle burst |

### Wrestler Skins (`wrestlerSkin`) — NEW

Used exclusively in Fight Mode. Drawn with `CustomPainter` in `widgets/wrestler_avatar.dart`.

| ID | Name | Price | Body Color | Accessory |
|----|------|-------|------------|-----------|
| `wrestler_default` | Classic | **Free** | Orange (#FF6B35) | Headband |
| `wrestler_ninja` | Ninja | 500 coins | Dark Purple | Face mask + eye slits |
| `wrestler_robot` | Robot | 800 coins | Steel Blue | Visor + cyan scan-line |
| `wrestler_fire` | Inferno | 600 coins | Crimson Red | Flame hair |
| `wrestler_ice` | Glacier | 600 coins | Ice Blue (#00B4D8) | Crown |
| `wrestler_gold` | Champion | 1,200 coins | Gold (#FFD700) | Championship belt |

**To add a new wrestler skin:**
1. Add `WrestlerSkin(...)` entry to `kWrestlerSkins` list in `constants.dart`
2. Implement visual in `_WrestlerPainter._drawAccessory()` in `wrestler_avatar.dart`
3. Add shop item strings to all 6 l10n files

**To use AI-generated art instead of CustomPainter:**
1. Generate PNG at 200×220px, transparent background, character in fighting stance
2. Place at `assets/wrestlers/<skinId>.png`
3. Update `pubspec.yaml` to include `assets/wrestlers/` directory
4. Modify `WrestlerAvatar.build()` to use `Image.asset('assets/wrestlers/${skin.id}.png')`

---

## Coin Economy

### Earning Coins

| Source | Amount | Notes |
|--------|--------|-------|
| Daily login reward | Scales with streak | Day 1: ~1 coin, grows with streak |
| Weekly mission: Play 10 games | 300 coins | Resets each Monday |
| Weekly mission: 3 Perfects | 5,000 coins | Hardest, highest reward |
| Weekly mission: 3 different modes | 400 coins | |
| Weekly mission: Score 900+ | 350 coins | |
| Weekly mission: Streak of 5 | 250 coins | |

### Spending Coins

| Item | Cost |
|------|------|
| Fortune Wheel spin | 500 coins |
| Fortune Wheel re-spin | 100 coins |
| Ninja wrestler skin | 500 coins |
| Inferno wrestler skin | 600 coins |
| Glacier wrestler skin | 600 coins |
| Robot wrestler skin | 800 coins |
| Champion wrestler skin | 1,200 coins |
| Timer skins | 12,000–28,000 coins |
| Backgrounds | 18,000–25,000 coins |
| Fireworks celebration | 30,000 coins |

**Balance insight:** Wrestler skins are intentionally cheap (easily reachable with a few weeks of missions) to drive engagement with Fight Mode. Larger cosmetics require grinding.

---

## Advertising (AdMob)

**Current status:** **DISABLED** (`adsEnabled = false` in `ads_service.dart`)
- AdMob account suspended until **April 18, 2026**
- Test IDs currently configured (safe for development)

### Ad Placements

| Ad Type | Trigger | Test Unit ID |
|---------|---------|-------------|
| Interstitial | Every 5th game start | `ca-app-pub-3940256099942544/1033173712` |
| Rewarded | Pressure mode retry | `ca-app-pub-3940256099942544/5224354917` |

**To re-enable ads:**
1. Set `adsEnabled = true` in `ads_service.dart`
2. Replace test IDs with real AdMob unit IDs on lines 13 and 17
3. Test with test IDs first

**Ad Frequency:**
- Interstitials: shown before countdown (every 5 games)
- `_gamesAtLastAd` tracks when last ad was shown

---

## Subscriptions (RevenueCat) — STUBBED

**Current status:** Complete no-op implementation in `subscription_service.dart`.

**Planned subscription features (not yet implemented):**
- No ads
- 2× XP multiplier  
- Exclusive cosmetics
- Priority Support

**To implement:**
1. Replace stub methods in `subscription_service.dart` with real RevenueCat calls
2. Wire up `SubscriptionState` to actually reflect purchase state
3. Apply benefits in `game_state.dart` (skip ad logic, apply 2× XP)

---

## Shop Screen Integration

The Shop screen (`shop_screen.dart`) shows these categories:
- Timer Skins
- Backgrounds
- Sound Packs
- Celebrations
- **Wrestler Skins** ← added, fully live

### Wrestler Skins in Shop
`_WrestlerSkinCard` widget (bottom of `shop_screen.dart`):
- Shows `WrestlerAvatar` (50px) as a live preview
- Free skins (`priceCoin == 0`) show "Owned" badge and can't be unequipped
- Paid skins: buy with `purchaseCosmetic(skin.id, skin.priceCoin)`, equip/unequip via `equipCosmetic`/`unequipCosmetic`
- Equipped skin shown with colored border + "EQUIPPED" badge inline with name

---

*Last updated: 2026-04-08 — Wrestler skins added to shop; KO animation added.*
