import 'package:flutter/material.dart';
import '../../core/theme.dart';

// widget kondisi eror
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.canvasSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.inkMute,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Koneksi Bermasalah',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMute,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
