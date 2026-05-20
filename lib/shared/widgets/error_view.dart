import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  /// Map the well-known English phrases thrown by `ApiClient` to localized
  /// strings. Anything else falls back to whatever the exception provided.
  String _message(BuildContext context) {
    if (error is ApiException) {
      final msg = (error as ApiException).message;
      switch (msg) {
        case 'No internet connection. Please check your network.':
          return AppStrings.of(context, 'no_internet');
        case 'The server took too long to respond.':
          return AppStrings.of(context, 'server_timeout');
        case 'Received an invalid response from the server.':
          return AppStrings.of(context, 'invalid_response');
        default:
          return msg;
      }
    }
    if (error == null) return AppStrings.of(context, 'something_went_wrong');
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              _message(context),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.of(context, 'retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
