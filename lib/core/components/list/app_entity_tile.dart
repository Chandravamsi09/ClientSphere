import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../cards/app_card.dart';

/// Reusable entity list tile for CRM modules (Leads, Customers, Deals, Tasks).
///
/// Standardizes avatar, title, subtitle, status badge, and trailing metadata
/// across all CRM records with Material 3 styling and accessible semantics.
class AppEntityTile extends StatelessWidget {
  /// Primary entity name (e.g. contact name, deal title, company name).
  final String title;

  /// Secondary metadata or contact detail (e.g. email, stage, organization).
  final String? subtitle;

  /// Initials displayed in the leading avatar when an icon is not used.
  final String? avatarInitials;

  /// Leading icon override (e.g. task checkbox, phone icon).
  final IconData? leadingIcon;

  /// Color for the leading avatar container.
  final Color? leadingColor;

  /// Optional CRM status badge text (e.g. "Qualified", "Won", "Overdue").
  final String? statusLabel;

  /// Status badge color (e.g. [AppColors.success], [AppColors.warning]).
  final Color? statusColor;

  /// Trailing metadata text (e.g. deal value "$45,000", timestamp "2h ago").
  final String? trailingText;

  /// Custom trailing widget (e.g. popup menu, action button).
  final Widget? trailing;

  /// Callback when the entity tile is tapped.
  final VoidCallback? onTap;

  /// Whether this tile is visually marked as selected.
  final bool isSelected;

  /// Custom accessibility label.
  final String? semanticLabel;

  const AppEntityTile({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarInitials,
    this.leadingIcon,
    this.leadingColor,
    this.statusLabel,
    this.statusColor,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveLeadingColor = leadingColor ?? colorScheme.primaryContainer;
    final effectiveLeadingTextColor = colorScheme.onPrimaryContainer;

    Widget? leadingWidget;
    if (avatarInitials != null) {
      leadingWidget = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: effectiveLeadingColor,
          borderRadius: AppRadius.allMd,
        ),
        alignment: Alignment.center,
        child: Text(
          avatarInitials!.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: effectiveLeadingTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (leadingIcon != null) {
      leadingWidget = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: effectiveLeadingColor,
          borderRadius: AppRadius.allMd,
        ),
        alignment: Alignment.center,
        child: Icon(
          leadingIcon,
          size: 20,
          color: effectiveLeadingTextColor,
        ),
      );
    }

    final effectiveStatusColor = statusColor ?? colorScheme.primary;

    final tileContent = Row(
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          AppSpacing.gapW12,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null || statusLabel != null) ...[
                AppSpacing.gapH4,
                Row(
                  children: [
                    if (statusLabel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: effectiveStatusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.allPill,
                          border: Border.all(
                            color: effectiveStatusColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: textTheme.labelSmall?.copyWith(
                            color: effectiveStatusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (subtitle != null) AppSpacing.gapW8,
                    ],
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (trailingText != null || trailing != null) ...[
          AppSpacing.gapW12,
          if (trailingText != null)
            Text(
              trailingText!,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ?trailing,
        ],
      ],
    );

    final effectiveBorder = isSelected
        ? colorScheme.primary
        : colorScheme.outline;

    return AppCard(
      onTap: onTap,
      borderColor: effectiveBorder,
      padding: AppSpacing.paddingAllMd,
      semanticLabel: semanticLabel ??
          '$title'
          '${subtitle != null ? ', $subtitle' : ''}'
          '${statusLabel != null ? ', Status: $statusLabel' : ''}',
      child: tileContent,
    );
  }
}
