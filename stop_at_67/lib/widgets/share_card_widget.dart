import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../engine/scoring.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';

// ── Public API ───────────────────────────────────────────────

/// Shows a bottom sheet with a beautiful share card and an option to share
/// as image or plain text.
Future<void> showShareCard({
  required BuildContext context,
  required ScoreResult result,
  required String modeName,
  required String playerName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ShareCardSheet(
      result: result,
      modeName: modeName,
      playerName: playerName,
    ),
  );
}

// ── Bottom sheet ─────────────────────────────────────────────

class _ShareCardSheet extends StatefulWidget {
  final ScoreResult result;
  final String modeName;
  final String playerName;

  const _ShareCardSheet({
    required this.result,
    required this.modeName,
    required this.playerName,
  });

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/stop67_result.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: _buildShareText(),
      );
    } catch (_) {
      // Fallback to text share
      await Share.share(_buildShareText());
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAsText() async {
    await Share.share(_buildShareText());
  }

  String _buildShareText() {
    final deviation = widget.result.deviationMs;
    final score = widget.result.finalScore;
    final stoppedAt = widget.result.stoppedAtMs / 1000;
    final rating = widget.result.rating.label.toUpperCase();

    final deviationStr = deviation == 0
        ? 'PERFECT — 0ms off!'
        : '${deviation}ms off target';

    return '🎯 I scored $score ($rating) in Stop at 67!\n'
        '⏱ Stopped at ${stoppedAt.toStringAsFixed(3)}s — $deviationStr\n'
        '🎮 Mode: ${widget.modeName}\n\n'
        'Think you can beat me? Download Stop at 67!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // The shareable card (captured by RepaintBoundary)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RepaintBoundary(
                key: _repaintKey,
                child: _ShareCard(
                  result: widget.result,
                  modeName: widget.modeName,
                  playerName: widget.playerName,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Share buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareAsImage,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Icon(Icons.image_outlined, size: 18),
                      label: const Text('Share Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : _shareAsText,
                      icon: const Icon(Icons.text_snippet_outlined, size: 18),
                      label: const Text('Share Text'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.darkElevated),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── The card itself ──────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final ScoreResult result;
  final String modeName;
  final String playerName;

  const _ShareCard({
    required this.result,
    required this.modeName,
    required this.playerName,
  });

  Color get _ratingColor {
    return switch (result.rating.tier) {
      'perfect' => AppColors.gold,
      'incredible' => const Color(0xFF00DDFF),
      'excellent' => const Color(0xFF00FF88),
      'great' => AppColors.orange,
      'good' => const Color(0xFF88AAFF),
      _ => AppColors.textDisabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final deviation = result.deviationMs;
    final isPerfect = deviation == 0;
    final stoppedAt = result.stoppedAtMs / 1000;
    final ratingColor = _ratingColor;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0a0a2f), Color(0xFF1a0545), Color(0xFF0a1a3f)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ratingColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ratingColor.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STOP AT 67',
                style: TextStyle(
                  color: ratingColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ratingColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  modeName.toUpperCase(),
                  style: TextStyle(
                    color: ratingColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rating emoji
          Text(result.rating.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),

          // Rating label
          Text(
            result.rating.label.toUpperCase(),
            style: TextStyle(
              color: ratingColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 16),

          // Score (big)
          Text(
            formatScore(result.finalScore),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 56,
              fontWeight: FontWeight.w100,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'pts',
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: AppColors.textHint.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statCol(
                'STOPPED AT',
                '${stoppedAt.toStringAsFixed(3)}s',
                AppColors.textSecondary,
              ),
              Container(width: 1, height: 32, color: AppColors.textHint.withValues(alpha: 0.2)),
              _statCol(
                'DEVIATION',
                isPerfect ? 'PERFECT' : '${deviation}ms',
                isPerfect ? AppColors.gold : AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Player name + CTA
          Text(
            playerName.isNotEmpty ? playerName : 'Can you beat this?',
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'play Stop at 67',
            style: TextStyle(
              color: ratingColor.withValues(alpha: 0.7),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
