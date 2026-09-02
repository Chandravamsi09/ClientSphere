import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Reusable section header for CRM list screens, dashboards, and detail views.
///
/// Features count badge support, subtitle, and an optional action button
/// (e.g. "View All", "Filter", or "+ Add").
class AppSectionHeader extends StatelessWidget {
  /// Section title.
  final String title;

  /// Optional descriptive subtitle.
  final String? subtitle;

  /// Optional entity count shown as a pill badge next to the title.
  final int? count;

  /// Label for the trailing action button.
  final String? actionLabel;

  /// Callback when trailing action is tapped.
  final VoidCallback? onAction;

  /// Optional custom trailing widget slot.
  final Widget? trailing;

  /// Outer padding. Defaults to [AppSpacing.paddingVSm].
  final EdgeInsetsGeometry padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding = AppSpacing.paddingVSm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget? actionWidget = trailing;
    if (actionWidget == null && actionLabel != null && onAction != null) {
      actionWidget = TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          padding: AppSpacing.paddingHSm,
          minimumSize: const Size(40, 32),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(
          actionLabel!,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (count != null) ...[
                      AppSpacing.gapW8,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: AppRadius.allPill,
                        ),
                        child: Text(
                          '$count',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  AppSpacing.gapH4,
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionWidget != null) ...[
            AppSpacing.gapW8,
            actionWidget,
          ],
        ],
      ),
    );
  }
}
