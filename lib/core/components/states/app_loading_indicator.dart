import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Reusable, theme-aware loading indicator for ClientSphere CRM.
///
/// Supports both full-section centered presentation with status messages
/// and compact inline presentation for cards, table rows, and toolbars.
class AppLoadingIndicator extends StatelessWidget {
  /// Optional message explaining what is currently loading.
  final String? message;

  /// Whether to render a compact inline indicator instead of a full centered view.
  final bool isCompact;

  /// Diameter of the circular progress spinner.
  final double? size;

  /// Color override for the spinner. Defaults to theme primary.
  final Color? color;

  /// Custom accessibility label for screen readers.
  final String? semanticLabel;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.isCompact = false,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveColor = color ?? colorScheme.primary;
    final effectiveSize = size ?? (isCompact ? 20.0 : 36.0);
    final effectiveStrokeWidth = isCompact ? 2.2 : 3.0;

    final spinner = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CircularProgressIndicator(
        strokeWidth: effectiveStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    final effectiveLabel = semanticLabel ?? message ?? 'Loading content';

    if (isCompact) {
      if (message == null) {
        return Semantics(
          liveRegion: true,
          label: effectiveLabel,
          child: spinner,
        );
      }

      return Semantics(
        liveRegion: true,
        label: effectiveLabel,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinner,
            AppSpacing.gapW8,
            Text(
              message!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      label: effectiveLabel,
      child: Center(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              spinner,
              if (message != null) ...[
                AppSpacing.gapH16,
                Text(
                  message!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
