import 'package:client_sphere/core/components/components.dart';
import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppPrimaryButton Tests', () {
    testWidgets('renders label and handles tap event', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppPrimaryButton(
          text: 'Save Lead',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Save Lead'), findsOneWidget);
      await tester.tap(find.text('Save Lead'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppPrimaryButton(
          text: 'Disabled Action',
          onPressed: null,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator and suppresses tap when isLoading is true', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppPrimaryButton(
          text: 'Submit Deal',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Deal'), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });

    testWidgets('renders leading icon when specified', (tester) async {
      await tester.pumpWidget(_wrap(
        AppPrimaryButton(
          text: 'Create Task',
          icon: Icons.add,
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Create Task'), findsOneWidget);
    });
  });

  group('AppSecondaryButton Tests', () {
    testWidgets('renders label and fires tap event', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppSecondaryButton(
          text: 'Cancel',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      expect(tapped, isTrue);
    });

    testWidgets('renders loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSecondaryButton(
          text: 'Export CSV',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Export CSV'), findsNothing);
    });
  });

  group('AppIconButton Tests', () {
    testWidgets('fires tap and renders tooltip', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppIconButton(
          icon: Icons.phone,
          tooltip: 'Call lead',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byTooltip('Call lead'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.phone));
      expect(tapped, isTrue);
    });

    testWidgets('renders loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        AppIconButton(
          icon: Icons.refresh,
          tooltip: 'Syncing',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('supports standard, filled, and outlined variants', (tester) async {
      await tester.pumpWidget(_wrap(
        Column(
          children: [
            AppIconButton(
              icon: Icons.filter_list,
              tooltip: 'Standard',
              variant: AppIconButtonVariant.standard,
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.save,
              tooltip: 'Filled',
              variant: AppIconButtonVariant.filled,
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.share,
              tooltip: 'Outlined',
              variant: AppIconButtonVariant.outlined,
              onPressed: () {},
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });
}
