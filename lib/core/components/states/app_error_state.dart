import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../buttons/app_primary_button.dart';

/// Reusable error state presentation for failed CRM operations.
///
/// Presents a user-friendly error headline and explanation with an optional
/// retry action button. Protects against leaking sensitive technical details,
/// stack traces, or credentials to end users.
class AppErrorState extends StatelessWidget {
  /// Error headline. Defaults to 'Unable to Load Data'.
  final String title;

  /// User-safe message explaining the issue and recovery options.
  final String message;

  /// Optional callback to re-trigger the failed data operation.
  final VoidCallback? onRetry;

  /// Label on the retry action button. Defaults to 'Try Again'.
  final String retryText;

  /// Contextual error icon. Defaults to [Icons.error_outline_rounded].
  final IconData icon;

  /// Custom accessibility label for screen readers.
  final String? semanticLabel;

  const AppErrorState({
    super.key,
    this.title = 'Unable to Load Data',
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
    this.icon = Icons.error_outline_rounded,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveSemanticLabel = semanticLabel ?? '$title. $message';

    return Semantics(
      liveRegion: true,
      container: true,
      label: effectiveSemanticLabel,
      child: Center(
        child: Padding(
          padding: AppSpacing.paddingAllXl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon Container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppColors.error,
                  ),
                ),
                AppSpacing.gapH24,

                // Title
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapH8,

                // Message
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Retry Button
                if (onRetry != null) ...[
                  AppSpacing.gapH24,
                  AppPrimaryButton(
                    text: retryText,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                    isFullWidth: false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
