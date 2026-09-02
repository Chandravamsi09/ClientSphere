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
  group('AppTextField Tests', () {
    testWidgets('renders label with required asterisk and accepts text', (
      tester,
    ) async {
      String? enteredValue;
      await tester.pumpWidget(_wrap(
        AppTextField(
          label: 'Contact Email',
          isRequired: true,
          hint: 'user@example.com',
          onChanged: (val) => enteredValue = val,
        ),
      ));

      expect(find.text('Contact Email'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'client@elevateiq.com');
      expect(enteredValue, 'client@elevateiq.com');
    });

    testWidgets('displays validation error text when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTextField(
          label: 'Deal Amount',
          errorText: 'Amount must be greater than zero',
        ),
      ));

      expect(find.text('Amount must be greater than zero'), findsOneWidget);
    });

    testWidgets('toggles password obscuring when eye icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppTextField(
          label: 'Password',
          obscureText: true,
          enablePasswordToggle: true,
        ),
      ));

      final fieldFinder = find.byType(EditableText);
      expect(fieldFinder, findsOneWidget);

      EditableText editable = tester.widget<EditableText>(fieldFinder);
      expect(editable.obscureText, isTrue);

      // Tap toggle button
      final toggleIcon = find.byTooltip('Show password');
      expect(toggleIcon, findsOneWidget);
      await tester.tap(toggleIcon);
      await tester.pumpAndSettle();

      editable = tester.widget<EditableText>(fieldFinder);
      expect(editable.obscureText, isFalse);
    });
  });

  group('AppSearchField Tests', () {
    testWidgets('debounces search query callback using native Timer', (
      tester,
    ) async {
      String? searchQuery;
      await tester.pumpWidget(_wrap(
        AppSearchField(
          hint: 'Search accounts...',
          debounceDuration: const Duration(milliseconds: 200),
          onChanged: (val) => searchQuery = val,
        ),
      ));

      expect(find.text('Search accounts...'), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Acme');
      await tester.pump(const Duration(milliseconds: 50));
      // Not yet fired due to debounce
      expect(searchQuery, isNull);

      // Advance past debounce duration
      await tester.pump(const Duration(milliseconds: 250));
      expect(searchQuery, 'Acme');
    });

    testWidgets('shows clear button and clears input on tap', (tester) async {
      var cleared = false;
      String? lastChanged;

      await tester.pumpWidget(_wrap(
        AppSearchField(
          debounceDuration: const Duration(milliseconds: 100),
          onChanged: (val) => lastChanged = val,
          onClear: () => cleared = true,
        ),
      ));

      // Initially no clear button
      expect(find.byTooltip('Clear search'), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Elevate');
      await tester.pumpAndSettle();

      // Clear button is now visible
      final clearButton = find.byTooltip('Clear search');
      expect(clearButton, findsOneWidget);

      // Tap clear
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
      expect(lastChanged, '');
      expect(find.text('Elevate'), findsNothing);
    });

    testWidgets('fires onSubmitted callback immediately upon keyboard submit', (
      tester,
    ) async {
      String? submittedValue;
      await tester.pumpWidget(_wrap(
        AppSearchField(
          onSubmitted: (val) => submittedValue = val,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Deals 2026');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedValue, 'Deals 2026');
    });
  });
}
