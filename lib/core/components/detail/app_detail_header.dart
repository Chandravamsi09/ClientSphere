import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../cards/app_card.dart';

/// Reusable hero header for CRM entity detail views (Lead, Deal, Contact, Task).
///
/// Features prominent record title, avatar, status pill, primary valuation/metric,
/// and quick-action icon buttons (Call, Email, Edit, Delete).
class AppDetailHeader extends StatelessWidget {
  /// Record title (e.g. customer name, deal headline).
  final String title;

  /// Optional subtitle or organization name.
  final String? subtitle;

  /// Optional status badge label (e.g. "In Progress", "Closed-Won").
  final String? statusLabel;

  /// Color for the status badge. Defaults to primary.
  final Color? statusColor;

  /// Prominent value or amount (e.g. "$125,000", "98% Health").
  final String? value;

  /// Initials displayed in avatar.
  final String? avatarInitials;

  /// Avatar icon override.
  final IconData? avatarIcon;

  /// Quick-action widgets (e.g. [AppIconButton]s for Call, Email, More).
  final List<Widget>? actions;

  const AppDetailHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.statusLabel,
    this.statusColor,
    this.value,
    this.avatarInitials,
    this.avatarIcon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveStatusColor = statusColor ?? colorScheme.primary;

    Widget? avatarWidget;
    if (avatarInitials != null) {
      avatarWidget = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: AppRadius.allLg,
        ),
        alignment: Alignment.center,
        child: Text(
          avatarInitials!.toUpperCase(),
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (avatarIcon != null) {
      avatarWidget = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: AppRadius.allLg,
        ),
        alignment: Alignment.center,
        child: Icon(
          avatarIcon,
          size: 26,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    return AppCard(
      padding: AppSpacing.paddingAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (avatarWidget != null) ...[
                avatarWidget,
                AppSpacing.gapW16,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.gapH4,
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                AppSpacing.gapW12,
                Text(
                  value!,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          if (statusLabel != null || (actions != null && actions!.isNotEmpty)) ...[
            AppSpacing.gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (statusLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveStatusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.allPill,
                      border: Border.all(
                        color: effectiveStatusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusLabel!,
                      style: textTheme.labelMedium?.copyWith(
                        color: effectiveStatusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (actions != null && actions!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
