import 'package:client_sphere/core/theme/theme.dart';
import 'package:client_sphere/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ClientSphereApp boots and toggles themes interactively', (
    WidgetTester tester,
  ) async {
    final controller = ThemeController(ThemeMode.light);

    await tester.pumpWidget(ClientSphereApp(themeController: controller));
    await tester.pumpAndSettle();

    // Verify main foundation screen loaded
    expect(find.text('ClientSphere Foundation'), findsOneWidget);
    expect(find.text('Theme Controls'), findsOneWidget);
    expect(find.text('Active Mode: LIGHT'), findsOneWidget);

    // Verify CRM semantic chips are present
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Won Deal'), findsOneWidget);
    expect(find.text('Lost Deal'), findsOneWidget);

    // Select Dark chip
    final darkChip = find.widgetWithText(ChoiceChip, 'Dark');
    expect(darkChip, findsOneWidget);
    await tester.tap(darkChip);
    await tester.pumpAndSettle();

    expect(controller.value, ThemeMode.dark);
    expect(find.text('Active Mode: DARK'), findsOneWidget);

    // Tap AppBar theme toggle button (switches Dark -> Light)
    final toggleButton = find.byTooltip('Toggle Theme');
    expect(toggleButton, findsOneWidget);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(controller.value, ThemeMode.light);
    expect(find.text('Active Mode: LIGHT'), findsOneWidget);
  });
}
