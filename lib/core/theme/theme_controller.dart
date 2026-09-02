import 'package:flutter/material.dart';

/// Lightweight, zero-dependency controller for managing application [ThemeMode].
///
/// Built on Flutter's native [ValueNotifier] to enable instantaneous theme
/// switching without introducing external state management packages.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.initialMode = ThemeMode.system]);

  /// Updates the theme mode to [mode].
  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
    }
  }

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark].
  void toggleTheme() {
    if (value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Determines whether dark mode is active for the current context.
  bool isDark(BuildContext context) {
    if (value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return value == ThemeMode.dark;
  }
}

/// An [InheritedNotifier] that exposes [ThemeController] down the widget tree.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Retrieves the nearest [ThemeController] from the widget tree, or null if none is found.
  static ThemeController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    return scope?.notifier;
  }

  /// Retrieves the nearest [ThemeController] from the widget tree.
  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}
