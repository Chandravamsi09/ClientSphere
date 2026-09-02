import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Reusable key-value row for entity detail screens (email, phone, stage, owner).
class AppInfoRow extends StatelessWidget {
  /// Field label (e.g. "Work Email", "Owner", "Expected Close Date").
  final String label;

  /// Field value (e.g. "sarah@acme.com", "Sarah Miller", "Oct 15, 2026").
  final String value;

  /// Optional contextual icon (e.g. [Icons.email_outlined], [Icons.phone_outlined]).
  final IconData? icon;

  /// Optional tap callback (e.g. dial phone, open mail, copy value).
  final VoidCallback? onTap;

  /// Trailing widget slot (e.g. copy icon, status badge).
  final Widget? trailing;

  /// Outer padding. Defaults to [AppSpacing.paddingVSm].
  final EdgeInsetsGeometry padding;

  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.trailing,
    this.padding = AppSpacing.paddingVSm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final content = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            AppSpacing.gapW12,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.gapH2,
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: onTap != null
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: content,
      );
    }

    return content;
  }
}
