import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../engine/constants.dart';
import '../engine/scoring.dart';
import '../engine/types.dart';
import '../services/leaderboard_service.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';
import '../widgets/game_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedModeId = 'classic';
  Future<List<LeaderboardEntry>>? _scoresFuture;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() {
    final leaderboard = context.read<LeaderboardService>();
    setState(() {
      _scoresFuture = leaderboard.getTopScores(_selectedModeId);
    });
  }

  void _selectMode(String modeId) {
    _selectedModeId = modeId;
    _loadScores();
  }

  String _modeName(String modeId, AppLocalizations l10n) {
    return switch (modeId) {
      'classic' => l10n.modeClassicName,
      'extended' => l10n.modeExtendedName,
      'blind' => l10n.modeBlindName,
      'reverse' => l10n.modeReverseName,
      'reverse100' => l10n.modeReverse100Name,
      'daily' => l10n.modeDailyName,
      'surge' => l10n.modeSurgeName,
      _ => modeId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final auth = context.watch<AuthState>();
    final l10n = AppLocalizations.of(context);
    final bestScores = gs.stats.bestScores;
    final currentUid = auth.user?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: l10n.leaderboardTitle,
                onBack: () => gs.setScreen(AppScreen.menu),
              ),

              // Mode tabs
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: kGameModes.values
                      .where((mode) => !const {'extended', 'reverse', 'reverse100'}.contains(mode.id))
                      .map((mode) {
                    final isSelected = _selectedModeId == mode.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _selectMode(mode.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF2a2a3e),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _modeName(mode.id, l10n),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Your best score card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFF6B35),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isSignedIn ? auth.userName : l10n.leaderboardYourBest,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            Text(
                              bestScores[_selectedModeId] != null
                                  ? formatScore(bestScores[_selectedModeId]!)
                                  : '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w200),
                            ),
                          ],
                        ),
                      ),
                      if (!auth.isSignedIn)
                        GameButton(
                          label: l10n.leaderboardSignInToCompete,
                          onPressed: () => gs.setScreen(AppScreen.auth),
                          primary: true,
                        )
                      else
                        GestureDetector(
                          onTap: () => auth.signOut(),
                          child: Text(l10n.leaderboardSignOut,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rankings list
              Expanded(
                child: auth.isSignedIn
                    ? FutureBuilder<List<LeaderboardEntry>>(
                        future: _scoresFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFFF6B35)));
                          }
                          final entries = snap.data ?? [];
                          if (entries.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.leaderboard_outlined,
                                      color: Colors.white24, size: 48),
                                  const SizedBox(height: 16),
                                  Text(l10n.leaderboardNoScores,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text(l10n.leaderboardBeFirst,
                                      style: const TextStyle(
                                          color: Colors.white24,
                                          fontSize: 13)),
                                ],
                              ),
                            );
                          }
                          return RefreshIndicator(
                            color: const Color(0xFFFF6B35),
                            onRefresh: () async => _loadScores(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              itemCount: entries.length,
                              itemBuilder: (ctx, i) {
                                final e = entries[i];
                                final isMe = e.uid == currentUid;
                                return _RankRow(entry: e, isMe: isMe);
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline,
                                color: Colors.white24, size: 48),
                            const SizedBox(height: 16),
                            Text(l10n.leaderboardSignInToSee,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(l10n.leaderboardScoresGlobal,
                                style: const TextStyle(
                                    color: Colors.white24, fontSize: 13)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  const _RankRow({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (entry.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFCCCCCC),
      3 => const Color(0xFFCD7F32),
      _ => Colors.white38,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFFFF6B35).withValues(alpha: 0.12)
            : const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                  color: rankColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.displayName,
              style: TextStyle(
                  color: isMe ? const Color(0xFFFF6B35) : Colors.white,
                  fontSize: 15,
                  fontWeight:
                      isMe ? FontWeight.w600 : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatScore(entry.score),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
