import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors Token Tests', () {
    test('brand colors are correctly assigned', () {
      expect(AppColors.primary, const Color(0xFF1E3A8A));
      expect(AppColors.secondary, const Color(0xFF0D9488));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
    });

    test('semantic status colors are distinct and valid', () {
      expect(AppColors.success, isNot(equals(AppColors.error)));
      expect(AppColors.warning, isNot(equals(AppColors.info)));
      expect(AppColors.stageWon, AppColors.success);
      expect(AppColors.stageLost, AppColors.error);
    });

    test('light and dark backgrounds are distinct', () {
      expect(AppColors.lightBackground, isNot(equals(AppColors.darkBackground)));
      expect(AppColors.lightSurface, isNot(equals(AppColors.darkSurface)));
    });
  });

  group('AppSpacing Token Tests', () {
    test('spacing increments follow 4dp/8dp mathematical scale', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
      expect(AppSpacing.xxxl, 48.0);

      expect(AppSpacing.xxs < AppSpacing.xs, isTrue);
      expect(AppSpacing.xs < AppSpacing.sm, isTrue);
      expect(AppSpacing.sm < AppSpacing.md, isTrue);
      expect(AppSpacing.md < AppSpacing.lg, isTrue);
      expect(AppSpacing.lg < AppSpacing.xl, isTrue);
      expect(AppSpacing.xl < AppSpacing.xxl, isTrue);
      expect(AppSpacing.xxl < AppSpacing.xxxl, isTrue);
    });

    test('insets match corresponding dimensional tokens', () {
      expect(AppSpacing.paddingAllLg, const EdgeInsets.all(16.0));
      expect(AppSpacing.paddingAllSm, const EdgeInsets.all(8.0));
      expect(
        AppSpacing.paddingHLg,
        const EdgeInsets.symmetric(horizontal: 16.0),
      );
    });
  });

  group('AppRadius Token Tests', () {
    test('radius tokens follow consistent scale', () {
      expect(AppRadius.none, 0.0);
      expect(AppRadius.xs, 4.0);
      expect(AppRadius.sm, 6.0);
      expect(AppRadius.md, 8.0);
      expect(AppRadius.lg, 12.0);
      expect(AppRadius.xl, 16.0);
      expect(AppRadius.pill, 999.0);

      expect(AppRadius.xs < AppRadius.sm, isTrue);
      expect(AppRadius.sm < AppRadius.md, isTrue);
      expect(AppRadius.md < AppRadius.lg, isTrue);
      expect(AppRadius.lg < AppRadius.xl, isTrue);
      expect(AppRadius.xl < AppRadius.pill, isTrue);
    });

    test('allMd applies md radius to all corners', () {
      expect(AppRadius.allMd.topLeft, const Radius.circular(8.0));
      expect(AppRadius.allMd.bottomRight, const Radius.circular(8.0));
    });
  });

  group('AppTypography Token Tests', () {
    test('lightTextTheme creates full Material 3 text hierarchy', () {
      final theme = AppTypography.lightTextTheme;
      expect(theme.displayLarge, isNotNull);
      expect(theme.headlineMedium, isNotNull);
      expect(theme.titleLarge, isNotNull);
      expect(theme.bodyMedium, isNotNull);
      expect(theme.labelSmall, isNotNull);

      expect(theme.displayLarge!.fontSize, 32);
      expect(theme.bodyMedium!.fontSize, 14);
      expect(theme.displayLarge!.color, AppColors.lightTextPrimary);
      expect(theme.bodyMedium!.color, AppColors.lightTextSecondary);
    });

    test('darkTextTheme uses dark text tokens', () {
      final theme = AppTypography.darkTextTheme;
      expect(theme.displayLarge!.color, AppColors.darkTextPrimary);
      expect(theme.bodyMedium!.color, AppColors.darkTextSecondary);
    });
  });

  group('AppTheme Factory Tests', () {
    test('light theme provides correct brightness and tokens', () {
      final lightTheme = AppTheme.light;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);
    });

    test('dark theme provides correct brightness and tokens', () {
      final darkTheme = AppTheme.dark;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.colorScheme.primary, AppColors.primaryLight);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
    });
  });

  group('ThemeController Unit Tests', () {
    test('initial mode is correctly assigned', () {
      final controller = ThemeController(ThemeMode.system);
      expect(controller.value, ThemeMode.system);
    });

    test('setThemeMode updates state and notifies listeners', () {
      final controller = ThemeController(ThemeMode.light);
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.value, ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('toggleTheme alternates between light and dark', () {
      final controller = ThemeController(ThemeMode.light);

      controller.toggleTheme();
      expect(controller.value, ThemeMode.dark);

      controller.toggleTheme();
      expect(controller.value, ThemeMode.light);
    });
  });
}
