import 'package:client_sphere/core/navigation/navigation.dart';
import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapShell({
  required NavigationController controller,
  Map<CrmDestination, WidgetBuilder>? moduleBuilders,
  Size surfaceSize = const Size(400, 800),
}) {
  final themeController = ThemeController(ThemeMode.light);
  return ThemeScope(
    controller: themeController,
    child: MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: AppShell(
          controller: controller,
          moduleBuilders: moduleBuilders,
        ),
      ),
    ),
  );
}

void main() {
  group('NavigationController Unit Tests', () {
    test('initial destination defaults to dashboard', () {
      final controller = NavigationController();
      expect(controller.currentDestination, CrmDestination.dashboard);
    });

    test('navigateTo updates state and notifies listeners', () {
      final controller = NavigationController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.navigateTo(CrmDestination.leads);
      expect(controller.currentDestination, CrmDestination.leads);
      expect(notified, isTrue);
    });

    test('badge count management works correctly', () {
      final controller = NavigationController();
      expect(controller.getBadgeCount(CrmDestination.notifications), 0);

      controller.setBadgeCount(CrmDestination.notifications, 5);
      expect(controller.getBadgeCount(CrmDestination.notifications), 5);

      controller.clearBadgeCount(CrmDestination.notifications);
      expect(controller.getBadgeCount(CrmDestination.notifications), 0);
    });
  });

  group('CrmDestination Enum Tests', () {
    test('defines all 10 planned CRM modules', () {
      expect(CrmDestination.values.length, 10);
      expect(CrmDestination.primaryMobileDestinations.length, 4);
      expect(CrmDestination.secondaryMobileDestinations.length, 6);
    });
  });

  group('AppShell Mobile Widget Tests', () {
    testWidgets('renders BottomNavigationBar and switches destinations on mobile', (
      tester,
    ) async {
      final controller = NavigationController(CrmDestination.dashboard);

      await tester.pumpWidget(_wrapShell(
        controller: controller,
        surfaceSize: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      // Verify bottom navigation bar on mobile
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Leads'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Deals'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Tap Leads tab
      await tester.tap(find.text('Leads'));
      await tester.pumpAndSettle();

      expect(controller.currentDestination, CrmDestination.leads);
      expect(find.text('Leads Module'), findsOneWidget);

      // Tap Deals tab
      await tester.tap(find.text('Deals'));
      await tester.pumpAndSettle();

      expect(controller.currentDestination, CrmDestination.deals);
      expect(find.text('Deals Module'), findsOneWidget);
    });

    testWidgets('opens More bottom sheet and navigates to secondary modules', (
      tester,
    ) async {
      final controller = NavigationController(CrmDestination.dashboard);

      await tester.pumpWidget(_wrapShell(
        controller: controller,
        surfaceSize: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      // Tap More tab
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('More CRM Modules'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);

      // Tap Tasks chip in bottom sheet
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      expect(controller.currentDestination, CrmDestination.tasks);
      expect(find.text('Tasks Module'), findsOneWidget);
    });
  });

  group('AppShell Tablet/Desktop Widget Tests', () {
    testWidgets('renders NavigationRail on wide screen and hides bottom bar', (
      tester,
    ) async {
      final controller = NavigationController(CrmDestination.dashboard);

      await tester.pumpWidget(_wrapShell(
        controller: controller,
        surfaceSize: const Size(900, 700),
      ));
      await tester.pumpAndSettle();

      // Wide screens use NavigationRail
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Tap Leads on NavigationRail
      await tester.tap(find.text('Leads'));
      await tester.pumpAndSettle();

      expect(controller.currentDestination, CrmDestination.leads);
      expect(find.text('Leads Module'), findsOneWidget);
    });
  });

  group('AppTopBar Tests', () {
    testWidgets('displays active title, badge counter, and handles search tap', (
      tester,
    ) async {
      final controller = NavigationController(CrmDestination.customers);
      final themeController = ThemeController(ThemeMode.light);
      controller.setBadgeCount(CrmDestination.notifications, 3);

      await tester.pumpWidget(ThemeScope(
        controller: themeController,
        child: MaterialApp(
          theme: AppTheme.light,
          home: NavigationScope(
            controller: controller,
            child: const Scaffold(
              appBar: AppTopBar(),
              body: SizedBox(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Tap search icon button
      final searchButton = find.byTooltip('Search CRM');
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      expect(controller.currentDestination, CrmDestination.search);
    });
  });
}
