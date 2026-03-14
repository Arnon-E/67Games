import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../state/language_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final langState = context.watch<LanguageState>();
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
                    // Language
                    _section(l10n.settingsLanguage),
                    _languageSelector(context, langState, l10n),

                    const SizedBox(height: 24),

                    const SizedBox(height: 32),

                    // Version
                    Center(
                      child: Text(
                        'Stop at 67 v${_version.isEmpty ? '…' : _version}',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
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
          color: AppColors.textDisabled,
          fontWeight: FontWeight.w600,
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
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: languages.map((lang) {
          final isSelected = langState.currentLanguage == lang.$1;
          return ListTile(
            title: Text(
              lang.$2,
              style: TextStyle(
                color: isSelected ? AppColors.orange : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.orange, size: 20)
                : null,
            onTap: () => langState.setLanguage(lang.$1),
          );
        }).toList(),
      ),
    );
  }
}
