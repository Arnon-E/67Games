import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

/// Matchmaking screen — shows a searching animation while waiting for an opponent.
/// After 7 seconds with no match, displays a "Play vs Bot" option.
class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
  }

  void _loadBanner() {
    if (!mounted) return;
    final ads = context.read<GameState>().ads;
    _bannerAd = ads.createMatchmakingBanner(
      onLoaded: (_) { if (mounted) setState(() => _bannerLoaded = true); },
      onFailedToLoad: (_, __) { if (mounted) setState(() => _bannerLoaded = false); },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final auth = context.watch<AuthState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.matchmakingTitle,
                onBack: () => gs.cancelMatchmaking(),
              ),
              const Spacer(),
              // Searching animation
              const _SearchingIndicator(),
              const SizedBox(height: 32),
              Text(
                l10n.matchmakingSearching,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gs.matchTimedOut
                    ? l10n.matchmakingTimedOut
                    : l10n.matchmakingWaiting,
                style: TextStyle(
                  fontSize: 14,
                  color: gs.matchTimedOut
                      ? AppColors.gold
                      : AppColors.textDisabled,
                ),
              ),

              // "Play vs Bot" button — appears after timeout
              if (gs.matchTimedOut) ...[
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => gs.playAgainstBot(),
                      icon: const Text('🤖', style: TextStyle(fontSize: 20)),
                      label: Text(
                        l10n.matchmakingPlayBot,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Banner ad — shown while waiting for opponent
              if (_bannerLoaded && _bannerAd != null) ...[
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
                const SizedBox(height: 12),
              ],

              // Player identity bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.orange, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.matchmakingClassicMode,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated pulsing search ring.
class _SearchingIndicator extends StatefulWidget {
  const _SearchingIndicator();

  @override
  State<_SearchingIndicator> createState() => _SearchingIndicatorState();
}

class _SearchingIndicatorState extends State<_SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.orange.withValues(alpha: 1.0 - t),
              width: 3 + t * 20,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.search,
              color: AppColors.orange.withValues(alpha: 0.8),
              size: 48,
            ),
          ),
        );
      },
    );
  }
}
