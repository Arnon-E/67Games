import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../engine/constants.dart';
import '../engine/scoring.dart';
import '../engine/types.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_colors.dart';
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
  bool _showTournament = false;
  Future<List<LeaderboardEntry>>? _scoresFuture;

  @override
  void initState() {
    super.initState();
    // Load scores immediately so the list appears right away,
    // then sync local bests in the background.
    _loadScores();
    _syncLocalBests();
  }

  /// Upload any local best scores that were never submitted to Firestore.
  /// Runs in the background — does not block the initial list load.
  /// Only refreshes the visible list if the current mode's score was updated.
  Future<void> _syncLocalBests() async {
    final auth = context.read<AuthState>();
    if (!auth.isSignedIn) return;
    final gs = context.read<GameState>();
    final leaderboard = context.read<LeaderboardService>();
    final uid = auth.user!.uid;
    final displayName = auth.userName;

    bool currentModeUpdated = false;
    final futures = gs.stats.bestScores.entries
        .where((e) => e.value > 0)
        .map((e) async {
          final improved = await leaderboard.submitScore(
            uid: uid,
            modeId: e.key,
            score: e.value,
            displayName: displayName,
          );
          if (improved && e.key == _selectedModeId) currentModeUpdated = true;
        })
        .toList();

    await Future.wait(futures);
    // Only re-render if the currently visible mode actually had a new best
    if (mounted && currentModeUpdated) _loadScores(forceRefresh: true);
  }

  void _loadScores({bool forceRefresh = false}) {
    final leaderboard = context.read<LeaderboardService>();
    if (forceRefresh) {
      leaderboard.invalidate(_selectedModeId);
      leaderboard.invalidate('tournament:${weekIdForDate(DateTime.now())}');
    }
    setState(() {
      _scoresFuture = _showTournament
          ? leaderboard.getTournamentTopScores()
          : leaderboard.getTopScores(_selectedModeId);
    });
  }

  void _selectMode(String modeId) {
    _selectedModeId = modeId;
    _loadScores();
  }

  void _toggleTournament(bool val) {
    _showTournament = val;
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
      'doubletap' => l10n.modeDoubleTapName,
      'movingtarget' => l10n.modeMovingTargetName,
      'calibration' => l10n.modeCalibrationName,
      'pressure' => l10n.modePressureName,
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

              // All Time / Tournament toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleTournament(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showTournament ? AppColors.orange : AppColors.darkElevated,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.leaderboardAllTime,
                            style: TextStyle(
                              color: !_showTournament ? AppColors.textPrimary : AppColors.textDisabled,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleTournament(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _showTournament ? AppColors.orange : AppColors.darkElevated,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.leaderboardThisWeek,
                                style: TextStyle(
                                  color: _showTournament ? AppColors.textPrimary : AppColors.textDisabled,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tournament countdown banner
              if (_showTournament) _TournamentCountdown(),
              if (_showTournament) const SizedBox(height: 4),

              // Mode tabs (only shown in All Time view)
              if (!_showTournament) SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: kGameModes.values
                      .where((mode) => !const {'extended', 'reverse', 'reverse100', 'daily', 'fortune'}.contains(mode.id))
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
                                ? AppColors.orange
                                : AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _modeName(mode.id, l10n),
                            style: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textDisabled,
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
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.orange,
                        child: Icon(Icons.person, color: AppColors.textPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isSignedIn ? auth.userName : l10n.leaderboardYourBest,
                              style: const TextStyle(
                                  color: AppColors.textDisabled, fontSize: 12),
                            ),
                            Text(
                              _showTournament
                                  ? (bestScores.isNotEmpty
                                      ? formatScore(bestScores.values.reduce((a, b) => a > b ? a : b))
                                      : '—')
                                  : (bestScores[_selectedModeId] != null
                                      ? formatScore(bestScores[_selectedModeId]!)
                                      : '—'),
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
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
                                  color: AppColors.textDisabled, fontSize: 12)),
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
                                    color: AppColors.orange));
                          }
                          final entries = snap.data ?? [];
                          if (entries.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.leaderboard_outlined,
                                      color: AppColors.textHint, size: 48),
                                  const SizedBox(height: 16),
                                  Text(l10n.leaderboardNoScores,
                                      style: const TextStyle(
                                          color: AppColors.textDisabled,
                                          fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text(l10n.leaderboardBeFirst,
                                      style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 13)),
                                ],
                              ),
                            );
                          }
                          return RefreshIndicator(
                            color: AppColors.orange,
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
                                color: AppColors.textHint, size: 48),
                            const SizedBox(height: 16),
                            Text(l10n.leaderboardSignInToSee,
                                style: const TextStyle(
                                    color: AppColors.textDisabled, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(l10n.leaderboardScoresGlobal,
                                style: const TextStyle(
                                    color: AppColors.textHint, fontSize: 13)),
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

// ── Tournament countdown widget ───────────────────────────────

class _TournamentCountdown extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _TournamentCountdown();

  /// Returns the time remaining until next Monday 00:00 UTC
  String _timeUntilReset() {
    final now = DateTime.now().toUtc();
    // weekday: 1=Mon … 7=Sun
    final daysUntilMonday = (8 - now.weekday) % 7;
    final nextMonday = DateTime.utc(now.year, now.month, now.day + daysUntilMonday);
    final diff = nextMonday.difference(now);
    if (diff.inDays > 1) {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.leaderboardWeeklyTournament,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.textHint, size: 14),
                const SizedBox(width: 4),
                Text(
                  l10n.leaderboardResetsIn(_timeUntilReset()),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ],
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
      1 => AppColors.gold,
      2 => const Color(0xFFCCCCCC),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textDisabled,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.orange.withValues(alpha: 0.12)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: AppColors.orange.withValues(alpha: 0.4))
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
                  color: isMe ? AppColors.orange : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatScore(entry.score),
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
