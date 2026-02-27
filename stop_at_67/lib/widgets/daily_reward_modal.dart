import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class DailyRewardModal extends StatefulWidget {
  const DailyRewardModal({super.key});

  @override
  State<DailyRewardModal> createState() => _DailyRewardModalState();
}

class _DailyRewardModalState extends State<DailyRewardModal> {
  ({int coins, int streak})? _claimed;

  Future<void> _claim() async {
    final result = await context.read<GameState>().claimDailyReward();
    if (result != null && mounted) {
      setState(() => _claimed = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Reward',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          if (_claimed == null) ...[
            const Text(
              'Come back every day to claim your reward!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _claim,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('CLAIM REWARD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ] else ...[
            Text(
              '+${_claimed!.coins}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w200,
                color: Color(0xFFFFD700),
              ),
            ),
            Text(
              'coins  •  Day ${_claimed!.streak} streak',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a2a3e),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('CLOSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
