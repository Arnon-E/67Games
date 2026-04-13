import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';
import '../widgets/game_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  bool _showGuestForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSignInSuccess(GameState gs) async {
    final resumedInvite = await gs.continuePendingFightInviteAfterAuth();
    if (resumedInvite) return;

    if (gs.authReturnScreen == AppScreen.matchmaking) {
      await gs.startMatchmaking();
    } else {
      gs.setScreen(gs.authReturnScreen);
    }
  }

  Future<void> _signInGoogle() async {
    final ok = await context.read<AuthState>().signInWithGoogle();
    if (ok && mounted) {
      await _onSignInSuccess(context.read<GameState>());
    }
  }

  Future<void> _signInGuest() async {
    final ok = await context.read<AuthState>().signInAnonymous(_nameController.text);
    if (ok && mounted) {
      await _onSignInSuccess(context.read<GameState>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: l10n.authSignIn,
                onBack: () => gs.setScreen(AppScreen.menu),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      const Icon(Icons.emoji_events_outlined,
                          color: AppColors.orange, size: 64),
                      const SizedBox(height: 24),
                      Text(
                        l10n.authCompeteGlobally,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authSubtitle,
                        style: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      if (auth.error != null) ...[
                        Text(auth.error!,
                            style: const TextStyle(
                                color: AppColors.orange, fontSize: 13)),
                        const SizedBox(height: 16),
                      ],

                      if (!_showGuestForm) ...[
                        // Google sign-in
                        GameButton(
                          label: auth.isLoading ? l10n.authSigningIn : l10n.authContinueWithGoogle,
                          onPressed: auth.isLoading ? null : _signInGoogle,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        // Or play as guest
                        GestureDetector(
                          onTap: () => setState(() => _showGuestForm = true),
                          child: Text(
                            l10n.authPlayAsGuest,
                            style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textDisabled),
                          ),
                        ),
                      ] else ...[
                        // Guest name form
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.orange.withValues(alpha: 0.3)),
                          ),
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            maxLength: 20,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.authEnterDisplayName,
                              hintStyle: const TextStyle(color: AppColors.textDisabled),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GameButton(
                          label: auth.isLoading ? l10n.authSigningIn : l10n.authPlayAsGuest,
                          onPressed: auth.isLoading ? null : _signInGuest,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => _showGuestForm = false),
                          child: Text(
                            l10n.commonBack,
                            style: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
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
