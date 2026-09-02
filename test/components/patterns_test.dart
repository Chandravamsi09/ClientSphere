import 'package:client_sphere/core/components/components.dart';
import 'package:client_sphere/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('AppEntityTile Tests', () {
    testWidgets('renders title, subtitle, status badge, and avatar initials', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppEntityTile(
          title: 'Acme Deal',
          subtitle: 'Enterprise Software Tier',
          avatarInitials: 'AD',
          statusLabel: 'Proposal',
          trailingText: '\$50,000',
        ),
      ));

      expect(find.text('Acme Deal'), findsOneWidget);
      expect(find.text('Enterprise Software Tier'), findsOneWidget);
      expect(find.text('AD'), findsOneWidget);
      expect(find.text('Proposal'), findsOneWidget);
      expect(find.text('\$50,000'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppEntityTile(
          title: 'John Doe',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('John Doe'));
      expect(tapped, isTrue);
    });
  });

  group('AppSectionHeader Tests', () {
    testWidgets('renders title, count badge, subtitle, and action button', (
      tester,
    ) async {
      var actionTriggered = false;
      await tester.pumpWidget(_wrap(
        AppSectionHeader(
          title: 'Recent Leads',
          subtitle: 'Active prospects in discovery',
          count: 12,
          actionLabel: 'View All',
          onAction: () => actionTriggered = true,
        ),
      ));

      expect(find.text('Recent Leads'), findsOneWidget);
      expect(find.text('Active prospects in discovery'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      expect(actionTriggered, isTrue);
    });
  });

  group('AppFormSection Tests', () {
    testWidgets('renders title, icon, and contained form fields', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(
        const AppFormSection(
          title: 'Contact Details',
          subtitle: 'Direct telephone and email',
          icon: Icons.contact_mail_outlined,
          children: [
            Text('Field 1: Email Address'),
            Text('Field 2: Phone Number'),
          ],
        ),
      ));

      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Direct telephone and email'), findsOneWidget);
      expect(find.byIcon(Icons.contact_mail_outlined), findsOneWidget);
      expect(find.text('Field 1: Email Address'), findsOneWidget);
      expect(find.text('Field 2: Phone Number'), findsOneWidget);
    });
  });

  group('AppDetailHeader Tests', () {
    testWidgets('renders record title, value, status, and action widgets', (
      tester,
    ) async {
      var emailTapped = false;
      await tester.pumpWidget(_wrap(
        AppDetailHeader(
          title: 'Global Logistics Corp',
          subtitle: 'Key Account',
          value: '\$240,000',
          statusLabel: 'Active Contract',
          avatarInitials: 'GL',
          actions: [
            IconButton(
              icon: const Icon(Icons.email_outlined),
              onPressed: () => emailTapped = true,
            ),
          ],
        ),
      ));

      expect(find.text('Global Logistics Corp'), findsOneWidget);
      expect(find.text('Key Account'), findsOneWidget);
      expect(find.text('\$240,000'), findsOneWidget);
      expect(find.text('Active Contract'), findsOneWidget);
      expect(find.text('GL'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.email_outlined));
      expect(emailTapped, isTrue);
    });
  });

  group('AppInfoRow Tests', () {
    testWidgets('renders key-value data and triggers onTap', (tester) async {
      var rowTapped = false;
      await tester.pumpWidget(_wrap(
        AppInfoRow(
          label: 'Primary Phone',
          value: '+1 (555) 234-5678',
          icon: Icons.phone_outlined,
          onTap: () => rowTapped = true,
        ),
      ));

      expect(find.text('Primary Phone'), findsOneWidget);
      expect(find.text('+1 (555) 234-5678'), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);

      await tester.tap(find.text('+1 (555) 234-5678'));
      expect(rowTapped, isTrue);
    });
  });

  group('AppFilterBar Tests', () {
    testWidgets('renders filter chips and triggers selection', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        AppFilterBar(
          filters: const ['All', 'Hot', 'Warm', 'Cold'],
          selectedFilter: 'All',
          filterCounts: const {'Hot': 5, 'Warm': 12},
          onFilterSelected: (val) => selected = val,
        ),
      ));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Hot'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.text('Hot'));
      expect(selected, 'Hot');
    });
  });

  group('AppSortBottomSheet Tests', () {
    testWidgets('renders sort criteria options and selects value', (
      tester,
    ) async {
      String? chosen;
      await tester.pumpWidget(_wrap(
        AppSortBottomSheet<String>(
          options: const [
            AppSortOption(value: 'name_asc', label: 'Name (A to Z)'),
            AppSortOption(value: 'value_desc', label: 'Value (High to Low)'),
          ],
          selectedValue: 'name_asc',
          onSelected: (val) => chosen = val,
        ),
      ));

      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Name (A to Z)'), findsOneWidget);
      expect(find.text('Value (High to Low)'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.tap(find.text('Value (High to Low)'));
      expect(chosen, 'value_desc');
    });
  });
}
