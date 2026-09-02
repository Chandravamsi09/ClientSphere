import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../cards/app_card.dart';

/// Standard form section container for grouping related fields in CRM forms.
///
/// Used across Contacts, Companies, Leads, Deals, and Tasks to create
/// structured, accessible form layouts.
class AppFormSection extends StatelessWidget {
  /// Section title (e.g. "Basic Details", "Financials", "Billing Address").
  final String title;

  /// Optional secondary instruction or context.
  final String? subtitle;

  /// Optional leading section icon.
  final IconData? icon;

  /// Form field widgets contained within this section.
  final List<Widget> children;

  /// Outer padding. Defaults to [AppSpacing.paddingVMd].
  final EdgeInsetsGeometry padding;

  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
    this.padding = AppSpacing.paddingVMd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: padding,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  AppSpacing.gapW8,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        AppSpacing.gapH2,
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
              ],
            ),
            AppSpacing.gapH16,
            ..._buildSpacedChildren(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpacedChildren() {
    if (children.isEmpty) return const [];
    final spaced = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1) {
        spaced.add(AppSpacing.gapH12);
      }
    }
    return spaced;
  }
}
