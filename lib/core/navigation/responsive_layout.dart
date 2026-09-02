import 'package:flutter/material.dart';

/// Screen dimension breakpoints for adaptive phone, foldable, tablet, and desktop layouts.
abstract final class ResponsiveBreakpoints {
  /// Width threshold below which the device is treated as a phone/compact screen.
  static const double compactMax = 600.0;

  /// Width threshold above which the device is treated as desktop/expanded.
  static const double mediumMax = 840.0;

  /// Whether current width is compact (< 600dp, typically mobile phones).
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactMax;
  }

  /// Whether current width is medium (600dp to 839dp, tablets portrait or unfolded foldables).
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactMax && width < mediumMax;
  }

  /// Whether current width is expanded (>= 840dp, tablets landscape and desktop).
  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= mediumMax;
  }
}

/// Adaptive widget builder switching layout based on available constraints or media size.
class ResponsiveBuilder extends StatelessWidget {
  /// Builder invoked for compact/phone screen widths.
  final WidgetBuilder compact;

  /// Builder invoked for medium/tablet portrait widths.
  final WidgetBuilder? medium;

  /// Builder invoked for expanded/desktop widths.
  final WidgetBuilder? expanded;

  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= ResponsiveBreakpoints.mediumMax && expanded != null) {
      return expanded!(context);
    }

    if (width >= ResponsiveBreakpoints.compactMax && medium != null) {
      return medium!(context);
    }

    return compact(context);
  }
}
