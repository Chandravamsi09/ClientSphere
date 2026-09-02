import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Style variants for [AppIconButton].
enum AppIconButtonVariant {
  /// Transparent background with subtle hover/press state.
  standard,

  /// Filled background with high-contrast icon.
  filled,

  /// Outlined border with subtle background.
  outlined,
}

/// A compact, accessible icon button for toolbars, search fields, and card actions.
class AppIconButton extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback when tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Accessibility label and desktop hover tooltip.
  final String tooltip;

  /// Whether a compact loading indicator should be shown.
  final bool isLoading;

  /// The visual style variant of the button.
  final AppIconButtonVariant variant;

  /// Button width and height. Defaults to 40.0.
  final double size;

  /// The size of the inner icon. Defaults to 20.0.
  final double iconSize;

  /// Custom icon color override.
  final Color? color;

  /// Custom background color override.
  final Color? backgroundColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isLoading = false,
    this.variant = AppIconButtonVariant.standard,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.color,
    this.backgroundColor,
  });

  bool get _isInteractive => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveOnPressed = _isInteractive ? onPressed : null;

    final Color effectiveIconColor;
    final Color effectiveBgColor;
    final Border? effectiveBorder;

    switch (variant) {
      case AppIconButtonVariant.standard:
        effectiveIconColor = color ??
            (_isInteractive
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface.withValues(alpha: 0.38));
        effectiveBgColor = backgroundColor ?? Colors.transparent;
        effectiveBorder = null;
        break;

      case AppIconButtonVariant.filled:
        effectiveIconColor = color ??
            (_isInteractive
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.38));
        effectiveBgColor = backgroundColor ??
            (_isInteractive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.12));
        effectiveBorder = null;
        break;

      case AppIconButtonVariant.outlined:
        effectiveIconColor = color ??
            (_isInteractive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.38));
        effectiveBgColor = backgroundColor ?? Colors.transparent;
        effectiveBorder = Border.all(
          color: _isInteractive
              ? colorScheme.outline
              : colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1.0,
        );
        break;
    }

    final Widget content;
    if (isLoading) {
      content = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveIconColor),
        ),
      );
    } else {
      content = Icon(
        icon,
        size: iconSize,
        color: effectiveIconColor,
      );
    }

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: _isInteractive,
        label: tooltip,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: AppRadius.allMd,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: effectiveBgColor,
              borderRadius: AppRadius.allMd,
              border: effectiveBorder,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
