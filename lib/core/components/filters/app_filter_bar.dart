import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Reusable horizontal filter bar for CRM list views (Leads, Accounts, Deals).
///
/// Supports filter chips with badge counts, active state highlight, and
/// optional sort or clear actions.
class AppFilterBar extends StatelessWidget {
  /// Filter option labels (e.g. ["All", "Hot", "Warm", "Cold", "Archived"]).
  final List<String> filters;

  /// Currently selected filter string.
  final String selectedFilter;

  /// Callback when a filter chip is tapped.
  final ValueChanged<String> onFilterSelected;

  /// Optional badge counts per filter label (e.g. {"Hot": 12, "Warm": 45}).
  final Map<String, int>? filterCounts;

  /// Optional trailing action widget (e.g. Sort button).
  final Widget? trailing;

  /// Outer padding. Defaults to [AppSpacing.paddingVSm].
  final EdgeInsetsGeometry padding;

  const AppFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.filterCounts,
    this.trailing,
    this.padding = AppSpacing.paddingVSm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = filter == selectedFilter;
                  final count = filterCounts?[filter];

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) => onFilterSelected(filter),
                      avatar: count != null
                          ? Container(
                              padding: const EdgeInsets.all(AppSpacing.xxs),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.onPrimary.withValues(alpha: 0.2)
                                    : colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : null,
                      label: Text(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.gapW8,
            trailing!,
          ],
        ],
      ),
    );
  }
}
