import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
  });

  factory ErrorStateWidget.connection({required VoidCallback onRetry}) {
    return ErrorStateWidget(
      title: 'No connection',
      message: 'It seems you are offline. Please check your internet connection.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  factory ErrorStateWidget.endpoint({required VoidCallback onRetry}) {
    return ErrorStateWidget(
      title: 'Server unreachable',
      message: 'We can\'t connect to the CRM. Please verify the URL in settings.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Identify error type from message to show the correct icon if not provided
    IconData displayIcon = icon;
    if (message.contains('internet connection')) {
      displayIcon = Icons.wifi_off_rounded;
    } else if (message.contains('unreachable')) {
      displayIcon = Icons.cloud_off_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayIcon,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
