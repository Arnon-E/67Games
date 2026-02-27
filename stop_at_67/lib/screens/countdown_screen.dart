import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/countdown_display.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), _tick);
  }

  void _tick(Timer _) {
    if (!mounted) return;
    Haptics.vibrate(HapticsType.light).catchError((_) {});
    context.read<GameState>().tickCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdownValue = context.select<GameState, int>((s) => s.countdownValue);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.countdownGetReady,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 4,
                  color: Colors.white38,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 32),
              CountdownDisplay(value: countdownValue),
            ],
          ),
        ),
      ),
    );
  }
}
