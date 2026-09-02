import 'package:client_sphere/core/components/components.dart';
import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('AppLoadingIndicator Tests', () {
    testWidgets('renders centered spinner and status message in standard mode', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppLoadingIndicator(
          message: 'Loading CRM pipeline...',
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading CRM pipeline...'), findsOneWidget);
    });

    testWidgets('renders inline compact presentation when isCompact is true', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppLoadingIndicator(
          isCompact: true,
          message: 'Saving...',
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving...'), findsOneWidget);
    });
  });

  group('AppEmptyState Tests', () {
    testWidgets('renders title, description, and custom icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppEmptyState(
          title: 'No Deals in Pipeline',
          description: 'Create your first deal to begin tracking pipeline revenue.',
          icon: Icons.assignment_outlined,
        ),
      ));

      expect(find.text('No Deals in Pipeline'), findsOneWidget);
      expect(
        find.text('Create your first deal to begin tracking pipeline revenue.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('renders call-to-action button and triggers callback', (
      tester,
    ) async {
      var actionTriggered = false;
      await tester.pumpWidget(_wrap(
        AppEmptyState(
          title: 'No Customers Found',
          actionText: 'Add Customer',
          onAction: () => actionTriggered = true,
        ),
      ));

      expect(find.text('Add Customer'), findsOneWidget);
      await tester.tap(find.text('Add Customer'));
      expect(actionTriggered, isTrue);
    });
  });

  group('AppErrorState Tests', () {
    testWidgets('renders title, safe message, and retry button', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(
        AppErrorState(
          title: 'Connection Issue',
          message: 'Could not connect to the server. Please check your network.',
          onRetry: () => retried = true,
          retryText: 'Retry Fetch',
        ),
      ));

      expect(find.text('Connection Issue'), findsOneWidget);
      expect(
        find.text('Could not connect to the server. Please check your network.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Retry Fetch'), findsOneWidget);

      await tester.tap(find.text('Retry Fetch'));
      expect(retried, isTrue);
    });
  });
}
