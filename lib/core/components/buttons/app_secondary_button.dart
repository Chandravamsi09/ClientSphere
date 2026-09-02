import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Medium-emphasis secondary/outlined action button for ClientSphere CRM.
///
/// Suitable for secondary workflows (e.g. Cancel, Save as Draft, Export,
/// Reassign) with consistent border styling, loading feedback, and disabled state.
class AppSecondaryButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// Callback when the button is tapped. When null, the button is disabled.
  final VoidCallback? onPressed;

  /// Whether a loading spinner should be displayed instead of the action icon/text.
  final bool isLoading;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// Whether the button should expand to fill the full horizontal width.
  final bool isFullWidth;

  /// Custom height for the button. Defaults to 48.0 for accessible touch targets.
  final double height;

  /// Custom accessibility label for screen readers.
  final String? semanticLabel;

  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.height = 48.0,
    this.semanticLabel,
  });

  bool get _isInteractive => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveOnPressed = _isInteractive ? onPressed : null;

    final labelWidget = Text(
      text,
      style: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: _isInteractive
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
    );

    final Widget content;
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            colorScheme.primary,
          ),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: _isInteractive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          AppSpacing.gapW8,
          labelWidget,
        ],
      );
    } else {
      content = labelWidget;
    }

    final buttonWidget = OutlinedButton(
      onPressed: effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        side: BorderSide(
          color: _isInteractive
              ? colorScheme.outline
              : colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1.5,
        ),
        minimumSize: Size(isFullWidth ? double.infinity : 64.0, height),
        padding: AppSpacing.paddingHLg,
        shape: AppRadius.shapeMd,
      ),
      child: content,
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticLabel ?? text,
      child: isFullWidth ? buttonWidget : IntrinsicWidth(child: buttonWidget),
    );
  }
}
