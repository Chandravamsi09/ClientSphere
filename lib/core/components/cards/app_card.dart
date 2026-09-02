import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Reusable content container card for ClientSphere CRM.
///
/// Standardizes elevation, borders, padding, and corner radii across
/// Light and Dark themes, with optional interactive ink feedback and semantics.
class AppCard extends StatelessWidget {
  /// The widget content inside the card.
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.cardPadding].
  final EdgeInsetsGeometry? padding;

  /// Outer margin. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? margin;

  /// Optional tap callback. When provided, enables Material 3 ink ripple feedback.
  final VoidCallback? onTap;

  /// Background color override. Defaults to theme surface color.
  final Color? backgroundColor;

  /// Border color override. Defaults to theme outline color.
  final Color? borderColor;

  /// Custom border radius. Defaults to [AppRadius.allLg].
  final BorderRadius? borderRadius;

  /// Surface elevation. Defaults to 0.0 (flat surface container).
  final double elevation;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation = 0.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBg = backgroundColor ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;
    final effectiveRadius = borderRadius ?? AppRadius.allLg;
    final effectivePadding = padding ?? AppSpacing.cardPadding;

    final shape = RoundedRectangleBorder(
      borderRadius: effectiveRadius,
      side: BorderSide(color: effectiveBorderColor, width: 1.0),
    );

    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: content,
      );
    }

    final cardWidget = Container(
      margin: margin,
      child: Material(
        color: effectiveBg,
        elevation: elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );

    if (semanticLabel != null || onTap != null) {
      return Semantics(
        button: onTap != null,
        container: true,
        label: semanticLabel,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
