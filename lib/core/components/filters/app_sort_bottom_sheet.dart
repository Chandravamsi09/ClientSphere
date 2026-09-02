import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Data class representing a sorting criteria option in CRM lists.
class AppSortOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppSortOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Reusable modal bottom sheet allowing users to sort CRM list records.
class AppSortBottomSheet<T> extends StatelessWidget {
  /// Header title. Defaults to "Sort By".
  final String title;

  /// Available sort criteria options.
  final List<AppSortOption<T>> options;

  /// Currently active sorting value.
  final T selectedValue;

  /// Callback when a new sort criteria is chosen.
  final ValueChanged<T> onSelected;

  const AppSortBottomSheet({
    super.key,
    this.title = 'Sort By',
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  /// Convenient static helper to present this sort sheet modally.
  static Future<T?> show<T>({
    required BuildContext context,
    String title = 'Sort By',
    required List<AppSortOption<T>> options,
    required T selectedValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: AppRadius.shapeLg,
      showDragHandle: true,
      builder: (sheetContext) {
        return AppSortBottomSheet<T>(
          title: title,
          options: options,
          selectedValue: selectedValue,
          onSelected: (newValue) {
            Navigator.of(sheetContext).pop(newValue);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            AppSpacing.gapH8,
            ...options.map((option) {
              final isSelected = option.value == selectedValue;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: option.icon != null
                    ? Icon(
                        option.icon,
                        size: 20,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      )
                    : null,
                title: Text(
                  option.label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : null,
                onTap: () => onSelected(option.value),
              );
            }),
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }
}
