import 'package:flutter/material.dart';
import '../engine/types.dart';

/// Precache all 18 wrestler PNGs (6 skins × idle/punch/knocked).
/// Call this once when entering fight mode so images are decoded before
/// the lobby appears and there is no visible stall.
Future<void> precacheWrestlerImages(BuildContext context) async {
  const prefixes = ['classic', 'ROBOT', 'Ninja', 'INFERNO', 'GLACIER', 'Champion'];
  final futures = <Future<void>>[];
  for (final p in prefixes) {
    final idle    = p == 'classic' ? 'assets/wrestlers/classic_Idle.png'        : 'assets/wrestlers/${p}_Idle.png';
    final punch   = p == 'classic' ? 'assets/wrestlers/classic_Punching.png'    : 'assets/wrestlers/${p}_Punching.png';
    final knocked = p == 'classic' ? 'assets/wrestlers/classic_knocked_out.png' : 'assets/wrestlers/${p}_Knocked_out.png';
    futures.add(precacheImage(AssetImage(idle),    context));
    futures.add(precacheImage(AssetImage(punch),   context));
    futures.add(precacheImage(AssetImage(knocked), context));
  }
  await Future.wait(futures, eagerError: false);
}

/// Maps skin ID → asset filename prefix.
const _kSkinPrefix = {
  'wrestler_default': 'classic',
  'wrestler_robot':   'ROBOT',
  'wrestler_ninja':   'Ninja',
  'wrestler_fire':    'INFERNO',
  'wrestler_ice':     'GLACIER',
  'wrestler_gold':    'Champion',
};

String? _assetPath(String skinId, {required bool isKnocked, required bool isPunching}) {
  final prefix = _kSkinPrefix[skinId];
  if (prefix == null) return null;
  if (isKnocked) {
    return prefix == 'classic'
        ? 'assets/wrestlers/classic_knocked_out.png'
        : 'assets/wrestlers/${prefix}_Knocked_out.png';
  }
  if (isPunching)  return 'assets/wrestlers/${prefix}_Punching.png';
  return 'assets/wrestlers/${prefix}_Idle.png';
}

/// Displays a wrestler character.
/// For skins with image assets (classic, robot) uses PNG/JPG files.
/// For all other skins falls back to the CustomPainter implementation.
/// [mirrored] flips the character horizontally (used for the opponent).
/// [punchProgress] 0.0–1.0 animates the right arm extending into a punch.
/// [isKnocked] shows dazed expression (X eyes, open mouth).
class WrestlerAvatar extends StatelessWidget {
  final WrestlerSkin skin;
  final double size;
  final bool mirrored;
  final double punchProgress;
  final bool isKnocked;

  const WrestlerAvatar({
    super.key,
    required this.skin,
    this.size = 90,
    this.mirrored = false,
    this.punchProgress = 0.0,
    this.isKnocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = _assetPath(
      skin.id,
      isKnocked: isKnocked,
      isPunching: punchProgress > 0.5,
    );

    if (path != null) {
      Widget image = Image.asset(
        path,
        width: size,
        height: size * 1.1,
        fit: BoxFit.contain,
      );
      if (mirrored) {
        image = Transform.scale(scaleX: -1, child: image);
      }
      return image;
    }

    // Fallback: CustomPainter for skins without image assets
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(
        painter: _WrestlerPainter(
          skin: skin,
          mirrored: mirrored,
          punchProgress: punchProgress,
          isKnocked: isKnocked,
        ),
      ),
    );
  }
}

class _WrestlerPainter extends CustomPainter {
  final WrestlerSkin skin;
  final bool mirrored;
  final double punchProgress;
  final bool isKnocked;

  const _WrestlerPainter({
    required this.skin,
    this.mirrored = false,
    this.punchProgress = 0.0,
    this.isKnocked = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final cx = size.width / 2;
    // Use height as the layout unit so proportions stay consistent
    final h = size.height;

    final bodyPaint   = Paint()..color = skin.bodyColor;
    final accentPaint = Paint()..color = skin.accentColor;
    final skinPaint   = Paint()..color = skin.skinColor;
    final darkPaint   = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // ── Legs (shorts section is part of torso, legs continue below) ──
    _rrect(canvas, bodyPaint,   cx - 0.17*h, 0.57*h, cx - 0.03*h, 0.82*h, 6);
    _rrect(canvas, bodyPaint,   cx + 0.03*h, 0.57*h, cx + 0.17*h, 0.82*h, 6);

    // Boots
    _rrect(canvas, accentPaint, cx - 0.18*h, 0.78*h, cx - 0.02*h, 0.94*h, 6);
    _rrect(canvas, accentPaint, cx + 0.02*h, 0.78*h, cx + 0.18*h, 0.94*h, 6);

    // ── Torso ──
    _rrect(canvas, bodyPaint, cx - 0.19*h, 0.30*h, cx + 0.19*h, 0.60*h, 9);

    // Chest stripe
    _rrect(canvas, accentPaint, cx - 0.05*h, 0.31*h, cx + 0.05*h, 0.59*h, 4);

    // ── Left arm (upper + forearm) ──
    _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.11*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
      cx - 0.19*h, 0.38*h, cx - 0.29*h, 0.26*h);
    _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.10*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
      cx - 0.29*h, 0.26*h, cx - 0.21*h, 0.16*h);
    // Left glove
    canvas.drawCircle(Offset(cx - 0.21*h, 0.13*h), 0.075*h,
        Paint()..color = skin.accentColor);

    // ── Right arm (animated punch if punchProgress > 0) ──
    if (punchProgress > 0) {
      final t = punchProgress;
      // Shoulder stays at (cx+0.19, 0.38)
      // Elbow: from (cx+0.29, 0.26) → (cx+0.43, 0.33) when fully punching
      final elbowX = cx + (_lerp(0.29, 0.43, t)) * h;
      final elbowY = _lerp(0.26, 0.33, t) * h;
      // Glove: from (cx+0.21, 0.13) → (cx+0.54, 0.28)
      final gloveX = cx + _lerp(0.21, 0.54, t) * h;
      final gloveY = _lerp(0.13, 0.28, t) * h;

      _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.11*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
        cx + 0.19*h, 0.38*h, elbowX, elbowY);
      _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.10*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
        elbowX, elbowY, gloveX, gloveY);
      canvas.drawCircle(Offset(gloveX, gloveY), 0.075*h,
          Paint()..color = skin.accentColor);
    } else {
      _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.11*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
        cx + 0.19*h, 0.38*h, cx + 0.29*h, 0.26*h);
      _line(canvas, Paint()..color = skin.skinColor..strokeWidth = 0.10*h..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
        cx + 0.29*h, 0.26*h, cx + 0.21*h, 0.16*h);
      canvas.drawCircle(Offset(cx + 0.21*h, 0.13*h), 0.075*h,
          Paint()..color = skin.accentColor);
    }

    // ── Head ──
    canvas.drawCircle(Offset(cx, 0.17*h), 0.145*h, skinPaint);

    if (isKnocked) {
      // X eyes (dazed)
      final xp = Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      _line(canvas, xp, cx-0.085*h, 0.115*h, cx-0.025*h, 0.165*h);
      _line(canvas, xp, cx-0.025*h, 0.115*h, cx-0.085*h, 0.165*h);
      _line(canvas, xp, cx+0.025*h, 0.115*h, cx+0.085*h, 0.165*h);
      _line(canvas, xp, cx+0.085*h, 0.115*h, cx+0.025*h, 0.165*h);
      // Open dazed mouth
      _rrect(canvas, darkPaint, cx-0.045*h, 0.205*h, cx+0.045*h, 0.235*h, 4);
    } else {
      // Normal eyes
      canvas.drawCircle(Offset(cx - 0.055*h, 0.14*h), 0.025*h, darkPaint);
      canvas.drawCircle(Offset(cx + 0.055*h, 0.14*h), 0.025*h, darkPaint);
      // Determined mouth (straight line)
      _line(canvas,
        Paint()..color = Colors.black.withValues(alpha: 0.45)
               ..strokeWidth = 1.8
               ..strokeCap = StrokeCap.round
               ..style = PaintingStyle.stroke,
        cx - 0.05*h, 0.215*h,
        cx + 0.05*h, 0.215*h,
      );
    }

    // ── Accessory ──
    _drawAccessory(canvas, cx, h);
  }

  void _drawAccessory(Canvas canvas, double cx, double h) {
    final ap = Paint()..color = skin.accentColor;

    switch (skin.accessoryType) {
      case 'headband':
        _rrect(canvas, ap, cx - 0.15*h, 0.07*h, cx + 0.15*h, 0.12*h, 4);
        break;

      case 'mask':
        // Lower face mask
        _rrect(canvas, ap, cx - 0.13*h, 0.17*h, cx + 0.13*h, 0.27*h, 5);
        // Eye cutouts
        final ep = Paint()..color = skin.bodyColor;
        _rrect(canvas, ep, cx - 0.115*h, 0.17*h, cx - 0.03*h, 0.205*h, 3);
        _rrect(canvas, ep, cx + 0.03*h,  0.17*h, cx + 0.115*h, 0.205*h, 3);
        break;

      case 'visor':
        _rrect(canvas, ap, cx - 0.14*h, 0.095*h, cx + 0.14*h, 0.175*h, 4);
        // Glowing scan-line
        _line(canvas,
          Paint()..color = const Color(0xFF00DDFF).withValues(alpha: 0.85)
                 ..strokeWidth = 2.0
                 ..strokeCap = StrokeCap.round
                 ..style = PaintingStyle.stroke,
          cx - 0.10*h, 0.135*h,
          cx + 0.10*h, 0.135*h,
        );
        break;

      case 'crown':
        final path = Path()
          ..moveTo(cx - 0.13*h, 0.085*h)
          ..lineTo(cx - 0.13*h, 0.015*h)
          ..lineTo(cx - 0.04*h, 0.055*h)
          ..lineTo(cx,          0.0)
          ..lineTo(cx + 0.04*h, 0.055*h)
          ..lineTo(cx + 0.13*h, 0.015*h)
          ..lineTo(cx + 0.13*h, 0.085*h)
          ..close();
        canvas.drawPath(path, ap);
        break;

      case 'flare':
        _drawFlames(canvas, cx, h);
        break;

      case 'belt':
        _rrect(canvas, ap, cx - 0.19*h, 0.555*h, cx + 0.19*h, 0.625*h, 4);
        // Buckle
        _rrect(canvas,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
          cx - 0.055*h, 0.56*h, cx + 0.055*h, 0.62*h, 3,
        );
        break;
    }
  }

  void _drawFlames(Canvas canvas, double cx, double h) {
    final color = skin.accentColor;

    // Left small flame
    final left = Path()
      ..moveTo(cx - 0.08*h, 0.025*h)
      ..quadraticBezierTo(cx - 0.115*h, -0.025*h, cx - 0.065*h, -0.075*h)
      ..quadraticBezierTo(cx - 0.04*h,  -0.025*h, cx - 0.03*h,   0.025*h)
      ..close();
    canvas.drawPath(left, Paint()..color = color.withValues(alpha: 0.7));

    // Center tall flame
    final center = Path()
      ..moveTo(cx - 0.045*h, 0.025*h)
      ..quadraticBezierTo(cx - 0.08*h, -0.06*h, cx,            -0.12*h)
      ..quadraticBezierTo(cx + 0.08*h, -0.06*h, cx + 0.045*h,  0.025*h)
      ..close();
    canvas.drawPath(center, Paint()..color = color);

    // Right small flame
    final right = Path()
      ..moveTo(cx + 0.03*h,  0.025*h)
      ..quadraticBezierTo(cx + 0.04*h,  -0.025*h, cx + 0.065*h, -0.075*h)
      ..quadraticBezierTo(cx + 0.115*h, -0.025*h, cx + 0.08*h,   0.025*h)
      ..close();
    canvas.drawPath(right, Paint()..color = color.withValues(alpha: 0.7));
  }

  // ── Helpers ──────────────────────────────────────────────────

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _rrect(Canvas canvas, Paint paint,
      double l, double t, double r, double b, double radius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(l, t, r, b), Radius.circular(radius)),
      paint,
    );
  }

  void _line(Canvas canvas, Paint paint, double x1, double y1, double x2, double y2) {
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(_WrestlerPainter old) =>
      old.skin.id != skin.id ||
      old.mirrored != mirrored ||
      old.punchProgress != punchProgress ||
      old.isKnocked != isKnocked;
}
