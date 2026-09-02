import 'package:client_sphere/core/components/components.dart';
import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppCard Tests', () {
    testWidgets('renders child content and applies default styling', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppCard(
          child: Text('Card Content'),
        ),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap interaction when onTap is provided', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppCard(
          onTap: () => tapped = true,
          child: const Text('Interactive Card'),
        ),
      ));

      await tester.tap(find.text('Interactive Card'));
      expect(tapped, isTrue);
    });

    testWidgets('applies custom background and border overrides', (
      tester,
    ) async {
      const customBg = Color(0xFFF1F5F9);
      const customBorder = Color(0xFF94A3B8);

      await tester.pumpWidget(_wrap(
        const AppCard(
          backgroundColor: customBg,
          borderColor: customBorder,
          child: Text('Custom Styled Card'),
        ),
      ));

      final materialWidget = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ),
      );
      expect(materialWidget.color, customBg);
    });
  });

  group('AppMetricCard Tests', () {
    testWidgets('renders title, value, subtitle, and icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppMetricCard(
          title: 'Total Pipeline',
          value: '\$450,000',
          subtitle: 'Active Q3 Deals',
          icon: Icons.monetization_on_outlined,
        ),
      ));

      expect(find.text('Total Pipeline'), findsOneWidget);
      expect(find.text('\$450,000'), findsOneWidget);
      expect(find.text('Active Q3 Deals'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_outlined), findsOneWidget);
    });

    testWidgets('renders positive trend badge with up arrow and success color', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppMetricCard(
          title: 'Won Deals',
          value: '34',
          trendLabel: '+18.5%',
          trend: MetricTrend.positive,
        ),
      ));

      expect(find.text('+18.5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('renders negative trend badge with down arrow and error color', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppMetricCard(
          title: 'Churn Rate',
          value: '4.2%',
          trendLabel: '-2.1%',
          trend: MetricTrend.negative,
        ),
      ));

      expect(find.text('-2.1%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap callback when metric card is tapped', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppMetricCard(
          title: 'Lead Conversion',
          value: '28%',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Lead Conversion'));
      expect(tapped, isTrue);
    });
  });
}
