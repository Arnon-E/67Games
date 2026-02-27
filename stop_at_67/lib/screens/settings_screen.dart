import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../state/language_state.dart';
import '../state/subscription_state.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final langState = context.watch<LanguageState>();
    final subState = context.watch<SubscriptionState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: l10n.settingsTitle,
                onBack: () => gs.setScreen(AppScreen.menu),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Subscription status
                    _section(l10n.settingsSubscriptionStatus),
                    _tile(
                      l10n.settingsPlan,
                      subState.isPremium ? l10n.settingsPlanPro : l10n.settingsPlanFree,
                    ),

                    const SizedBox(height: 24),

                    // Language
                    _section(l10n.settingsLanguage),
                    _languageSelector(context, langState, l10n),

                    const SizedBox(height: 24),

                    // Account
                    _section(l10n.settingsAccount),
                    _actionTile(
                      l10n.settingsRestorePurchases,
                      Icons.restore,
                      () async {
                        final restored = await subState.restorePurchases();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                restored
                                    ? l10n.alertsPurchasesRestored
                                    : l10n.alertsNoPurchasesFound,
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // Version
                    Center(
                      child: Text(
                        l10n.settingsVersion,
                        style: const TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          color: Colors.white38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _languageSelector(
      BuildContext context, LanguageState langState, AppLocalizations l10n) {
    final languages = [
      ('en', l10n.languagesEn),
      ('he', l10n.languagesHe),
      ('ru', l10n.languagesRu),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: languages.map((lang) {
          final isSelected = langState.currentLanguage == lang.$1;
          return ListTile(
            title: Text(
              lang.$2,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF6B35) : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: Color(0xFFFF6B35), size: 20)
                : null,
            onTap: () => langState.setLanguage(lang.$1),
          );
        }).toList(),
      ),
    );
  }
}
