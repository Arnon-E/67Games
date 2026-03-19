import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  Future<void> _openStore() async {
    final uri = Uri.parse(UpdateService.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🚀',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A new version of Stop at 67 is available. Update now for the latest improvements and features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _openStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: const Text(
                'UPDATE NOW',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Later',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
