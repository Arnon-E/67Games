import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../state/auth_state.dart';
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

  Future<void> _signInGoogle() async {
    final auth = context.read<AuthState>();
    final gs = context.read<GameState>();
    final ok = await auth.signInWithGoogle();
    if (ok && mounted) gs.setScreen(AppScreen.leaderboard);
  }

  Future<void> _signInGuest() async {
    final auth = context.read<AuthState>();
    final gs = context.read<GameState>();
    final ok = await auth.signInAnonymous(_nameController.text);
    if (ok && mounted) gs.setScreen(AppScreen.leaderboard);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final gs = context.watch<GameState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Sign In',
                onBack: () => gs.setScreen(AppScreen.leaderboard),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_outlined,
                          color: Color(0xFFFF6B35), size: 64),
                      const SizedBox(height: 24),
                      const Text(
                        'Compete Globally',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to appear on the leaderboard\nand track your rank worldwide.',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      if (auth.error != null) ...[
                        Text(auth.error!,
                            style: const TextStyle(
                                color: Color(0xFFFF6B35), fontSize: 13)),
                        const SizedBox(height: 16),
                      ],

                      if (!_showGuestForm) ...[
                        // Google sign-in
                        GameButton(
                          label: auth.isLoading ? 'Signing in…' : 'Continue with Google',
                          onPressed: auth.isLoading ? null : _signInGoogle,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        // Or play as guest
                        GestureDetector(
                          onTap: () => setState(() => _showGuestForm = true),
                          child: const Text(
                            'Play as Guest',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white54),
                          ),
                        ),
                      ] else ...[
                        // Guest name form
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1a2e),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                          ),
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            maxLength: 20,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter your display name',
                              hintStyle: TextStyle(color: Colors.white38),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GameButton(
                          label: auth.isLoading ? 'Signing in…' : 'Play as Guest',
                          onPressed: auth.isLoading ? null : _signInGuest,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => _showGuestForm = false),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ),
                      ],
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
