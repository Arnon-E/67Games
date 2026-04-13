import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

/// Host-side fight invite screen.
/// Displays the invite code and a share button. Watches Firestore for the
/// guest to join, then automatically starts the match.
class FightInviteScreen extends StatelessWidget {
  const FightInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final code = gs.fightInviteCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.fightInviteTitle,
                onBack: () => gs.cancelFightInvite(),
              ),
              const Spacer(),

              // Icon
              const Text('🥊', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),

              Text(
                l10n.fightInviteSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 32),

              if (code == null) ...[
                // Generating code…
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.orange,
                    strokeWidth: 2.5,
                  ),
                ),
              ] else ...[
                // Code display card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: _InviteCodeCard(code: code, l10n: l10n),
                ),
                const SizedBox(height: 24),

                // Share button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final shareText = l10n.fightInviteShareText(code);
                        Share.share(shareText);
                      },
                      icon: const Icon(Icons.share, size: 20),
                      label: Text(
                        l10n.fightInviteShareButton,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 6,
                        shadowColor: AppColors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Waiting indicator
                const _WaitingIndicator(),
                const SizedBox(height: 10),
                Text(
                  l10n.fightInviteWaiting,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.fightInviteExpiry,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],

              const Spacer(),

              // Cancel
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
                child: TextButton(
                  onPressed: () => gs.cancelFightInvite(),
                  child: Text(
                    l10n.fightInviteCancel,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 14,
                    ),
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

// ── Invite code card ────────────────────────────────────────────

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code, required this.l10n});

  final String code;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.fightInviteCodeLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDisabled,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Split code into spaced characters for readability
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((ch) => _CodeChar(char: ch)).toList(),
          ),
          const SizedBox(height: 14),
          // Tap to copy
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.fightInviteCopied),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.darkCard,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  l10n.fightInviteTapToCopy,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeChar extends StatelessWidget {
  const _CodeChar({required this.char});
  final String char;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 36,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.orange,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// ── Animated waiting indicator ──────────────────────────────────

class _WaitingIndicator extends StatefulWidget {
  const _WaitingIndicator();

  @override
  State<_WaitingIndicator> createState() => _WaitingIndicatorState();
}

class _WaitingIndicatorState extends State<_WaitingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.3 + phase * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Guest: join-by-code dialog ──────────────────────────────────

/// Shows a bottom sheet for the guest to enter an invite code.
/// Returns when the guest submits (game state handles the rest).
Future<void> showJoinFightDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.darkCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _JoinFightDialogContent(parentContext: context),
  );
}

class _JoinFightDialogContent extends StatefulWidget {
  const _JoinFightDialogContent({required this.parentContext});
  final BuildContext parentContext;

  @override
  State<_JoinFightDialogContent> createState() =>
      _JoinFightDialogContentState();
}

class _JoinFightDialogContentState extends State<_JoinFightDialogContent> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length < 6) {
      setState(() => _error = AppLocalizations.of(context).fightInviteJoinShort);
      return;
    }
    setState(() => _error = null);
    // Capture reference before dismissing (context invalid after pop)
    final gs = context.read<GameState>();
    Navigator.pop(context);
    // Delegate to game state — it will navigate to matchmaking when ready
    await gs.joinFightByCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l10n.fightInviteJoinTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.fightInviteJoinSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.orange,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textHint.withValues(alpha: 0.4),
                letterSpacing: 8,
              ),
              filled: true,
              fillColor: AppColors.orange.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.orange.withValues(alpha: 0.4), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.orange, width: 2),
              ),
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFFF4444),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (gs.fightInviteError == 'invalid_code') ...[
            const SizedBox(height: 8),
            Text(
              l10n.fightInviteJoinInvalid,
              style: const TextStyle(
                color: Color(0xFFFF4444),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: gs.fightInviteLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: gs.fightInviteLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Text(
                      l10n.fightInviteJoinButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
