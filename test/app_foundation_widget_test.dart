import 'package:client_sphere/core/theme/theme.dart';
import 'package:client_sphere/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ClientSphereApp boots, toggles themes, and operates form components', (
    WidgetTester tester,
  ) async {
    final controller = ThemeController(ThemeMode.light);

    await tester.pumpWidget(ClientSphereApp(themeController: controller));
    await tester.pumpAndSettle();

    // Verify main foundation screen and initial controls are loaded
    expect(find.text('ClientSphere Foundation'), findsOneWidget);
    expect(find.text('Theme Controls'), findsOneWidget);
    expect(find.text('Active Mode: LIGHT'), findsOneWidget);
    expect(find.text('Pipeline Revenue'), findsOneWidget);
    expect(find.text('At-Risk Deals'), findsOneWidget);

    // 1. Select Dark chip
    final darkChip = find.widgetWithText(ChoiceChip, 'Dark');
    expect(darkChip, findsOneWidget);
    await tester.tap(darkChip);
    await tester.pumpAndSettle();

    expect(controller.value, ThemeMode.dark);
    expect(find.text('Active Mode: DARK'), findsOneWidget);

    // 2. Tap AppBar theme toggle button (switches Dark -> Light)
    final toggleButton = find.byTooltip('Toggle Theme');
    expect(toggleButton, findsOneWidget);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(controller.value, ThemeMode.light);
    expect(find.text('Active Mode: LIGHT'), findsOneWidget);

    // 3. Scroll down slightly to center interactive form components
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Core Interactive Components'), findsOneWidget);
    expect(find.text('Lead Full Name'), findsOneWidget);

    // Tap Save Lead button to toggle loading state
    final saveButton = find.text('Save Lead to Pipeline');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Toggle button loading back off
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // 4. Scroll down further to verify CRM state views
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CRM State Views'), findsOneWidget);
    expect(find.text('No Closed Deals'), findsOneWidget);

    // Switch to Error State view
    final errorChip = find.widgetWithText(ChoiceChip, 'Error State');
    await tester.tap(errorChip);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sync Failed'), findsOneWidget);

    // 5. Scroll further down to verify CRM semantic tokens card
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Won Deal'), findsOneWidget);
    expect(find.text('Lost Deal'), findsOneWidget);
  });
}
