# Stop at 67 — Design Brief for AI Art Generation

## What it is
A mobile game (Android + iOS) where players try to stop a running timer at exactly **6.700 seconds**. The closer to 6.7s you stop, the higher your score. It has 13 single-player modes (blind timer, countdown, speed escalation, etc.), live 1v1 multiplayer via Firebase, and a **wrestling Fight Mode** — the newest feature.

---

## Fight Mode (the most important thing to redesign)
Two players face off. Each has **3 HP hearts**. Win a round → your wrestler punches the opponent, dealing 1–2 HP damage. First to 0 HP loses by **KNOCKOUT**. Speed increases each round, making it harder.

The UI flow:
1. **Menu → "1v1 MATCH" → bottom sheet → "Fight Mode"** → choose vs Bot or vs Player
2. **Match Lobby** — two wrestler characters face each other, HP hearts shown, round badge
3. **Match Playing** — HP bar row at the top showing hearts + "ROUND X" label
4. **Round Results** — damage dealt this round, auto-advances to next round after 3s countdown
5. **KO Screen** — animated: winner punches, loser flies back with X-eyes (Mortal Kombat style)

---

## Current Art Style
- **Dark theme**, nearly black background (`#07070F`), dark cards (`#1A1A2E`)
- **Orange** (`#FF6B35`) = player 1 / primary CTA
- **Cyan** (`#00DDFF`) = player 2 / multiplayer
- **Gold** (`#FFD700`) = coins, rank 1, win highlights
- All wrestler characters are currently drawn with Flutter **CustomPainter** (code-drawn cartoon figures, no image files)
- No image assets at all currently — everything is code/emoji

---

## Wrestler Skins (6 characters to illustrate)

| ID | Name | Colors | Accessory | Personality |
|----|------|--------|-----------|-------------|
| `wrestler_default` | Classic | Orange body, white accents, peach skin | Headband | Energetic champion |
| `wrestler_ninja` | Ninja | Dark purple body, cyan accents, dark skin | Face mask with eye slits | Silent & deadly |
| `wrestler_robot` | Robot | Steel blue body, light blue accents, grey skin | Visor with cyan scan-line | Mechanical precision |
| `wrestler_fire` | Inferno | Dark red body, orange accents | Flames above head | Burning intensity |
| `wrestler_ice` | Glacier | Sky blue body, ice-white accents | Crown | Cold & regal |
| `wrestler_gold` | Champion | Gold body & accents | Championship belt with buckle | Ultimate fighter |

Character size target: **200×220px PNG**, transparent background, cartoon/comic style. They need to look good at small sizes (50–90px in shop cards) and medium (140px in fight lobby).

---

## Assets needed for each wrestler

- **Idle stance** — guard stance, fists up
- **Punch** — right arm fully extended forward
- **Knocked** — body tilted, X eyes, dazed mouth open, stars above head
- Optional: **Victory** pose — arms raised

---

## Other UI assets that would improve the game

### Buttons
- **Stop button** — the main tap target during gameplay, currently a plain circle. Should be a glowing red/orange pulsing circle, ~200px, transparent background
- **Primary CTA button** — orange gradient, rounded rect background, ~400×64px
- **Secondary button** — dark fill with subtle border, same dimensions

### KO Screen
- **"KNOCKOUT!" text treatment** — big, impactful, Mortal Kombat-style dripping or energy lettering
- **Impact burst** — star/shockwave explosion at punch contact point, ~120px
- **Dizzy stars** — small looping stars to orbit above a knocked-out character's head

### Match Playing screen
- **HP heart — full** — red/pink filled heart, ~24px
- **HP heart — empty** — grey outline heart, ~24px
- **Round badge** — small banner/label reading "ROUND" (text baked in or as a frame only)

### General
- **Coin icon** — gold circle with a symbol (₿-style or custom), used everywhere for in-game currency, ~32px and ~64px versions
- **Victory background** — dark-themed confetti or fireworks burst overlay (full screen, semi-transparent)
- **Timer display** — large digit style, like a glowing 7-segment display; digits 0–9 as individual assets OR as a font, ~120px tall per digit

---

## Technical constraints for asset replacement

The app uses Flutter. To replace a CustomPainter wrestler with an image:

1. Place PNG at `stop_at_67/assets/wrestlers/<id>.png`  
   Example: `stop_at_67/assets/wrestlers/wrestler_ninja.png`
2. Edit `lib/widgets/wrestler_avatar.dart` — swap `CustomPaint` to:
   ```dart
   Image.asset('assets/wrestlers/${skin.id}.png', width: size, height: size * 1.1)
   ```
3. Add the path to `stop_at_67/pubspec.yaml` under `flutter: assets:`:
   ```yaml
   flutter:
     assets:
       - assets/wrestlers/wrestler_default.png
       - assets/wrestlers/wrestler_ninja.png
       # ... etc
   ```

For other images, same pattern — place in `assets/images/` and add to pubspec.

**Formats:** PNG with transparency preferred. SVG also works for Flutter via `flutter_svg`.  
**Style:** Cartoon/comic, bold outlines, works on very dark (`#07070F`) backgrounds.

---

## What NOT to change
- The core timer gameplay mechanic
- The color tokens (orange / cyan / gold / dark) — these are the brand
- Text is localized (English, Hebrew RTL, Russian) — avoid baking text into images unless it's a standalone decorative asset like "KNOCKOUT!"

---

*Last updated: 2026-04-10*
