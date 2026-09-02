import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../buttons/app_primary_button.dart';

/// Reusable empty content presentation for CRM screens and data lists.
///
/// Displayed when a list, search query, or pipeline filter yields zero records
/// (e.g. "No Leads Found", "No Tasks Due"). Integrates with [AppPrimaryButton].
class AppEmptyState extends StatelessWidget {
  /// Primary headline message.
  final String title;

  /// Secondary explanatory description or guidance.
  final String? description;

  /// Illustrative icon. Defaults to [Icons.inbox_outlined].
  final IconData icon;

  /// Optional label for the call-to-action button.
  final String? actionText;

  /// Optional callback when the call-to-action button is pressed.
  final VoidCallback? onAction;

  /// Optional custom action widget override.
  final Widget? customAction;

  /// Custom accessibility label for screen readers.
  final String? semanticLabel;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.customAction,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveSemanticLabel = semanticLabel ??
        '$title'
        '${description != null ? '. $description' : ''}';

    Widget? actionWidget = customAction;
    if (actionWidget == null && actionText != null && onAction != null) {
      actionWidget = AppPrimaryButton(
        text: actionText!,
        onPressed: onAction,
        isFullWidth: false,
      );
    }

    return Semantics(
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
                // Icon Avatar Container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: colorScheme.onSurfaceVariant,
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

                // Description
                if (description != null) ...[
                  AppSpacing.gapH8,
                  Text(
                    description!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Action Call
                if (actionWidget != null) ...[
                  AppSpacing.gapH24,
                  actionWidget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
