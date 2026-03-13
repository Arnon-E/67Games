import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The gold orb STOP button shown on the playing screen.
/// Pulses with a radial glow matching the promo art.
class StopButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool disabled;

  const StopButton({super.key, this.onTap, this.disabled = false});

  @override
  State<StopButton> createState() => _StopButtonState();
}

class _StopButtonState extends State<StopButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _buildOrb(glowIntensity: 0.5, scale: 1.0);
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => _buildOrb(
        glowIntensity: _glow.value,
        scale: _scale.value,
      ),
    );
  }

  Widget _buildOrb({required double glowIntensity, required double scale}) {
    return GestureDetector(
      onTap: widget.disabled ? null : widget.onTap,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange
                          .withValues(alpha: 0.35 + glowIntensity * 0.3),
                      blurRadius: 30 + glowIntensity * 30,
                      spreadRadius: 4 + glowIntensity * 10,
                    ),
                    BoxShadow(
                      color: AppColors.gold
                          .withValues(alpha: 0.2 + glowIntensity * 0.2),
                      blurRadius: 50 + glowIntensity * 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              // Orb body with 3-D gradient
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orange, // fallback if gradient fails
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.goldWarm,
                      AppColors.orange,
                      AppColors.goldDark,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Specular highlight (top-left crescent)
              Positioned(
                top: 22,
                left: 26,
                child: Container(
                  width: 34,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white24,
                  ),
                ),
              ),
              // STOP label
              const Text(
                'STOP',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
