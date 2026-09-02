import 'package:flutter/material.dart';

/// Navigation destinations representing the planned CRM functional modules.
enum CrmDestination {
  dashboard(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    description: 'Executive overview, pipeline KPIs, and recent activities.',
  ),
  leads(
    label: 'Leads',
    icon: Icons.contact_mail_outlined,
    selectedIcon: Icons.contact_mail_rounded,
    description: 'Lead capture, qualification stages, and lead conversion.',
  ),
  customers(
    label: 'Customers',
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
    description: 'Account directory, contact management, and customer health.',
  ),
  deals(
    label: 'Deals',
    icon: Icons.monetization_on_outlined,
    selectedIcon: Icons.monetization_on_rounded,
    description: 'Sales pipeline stages, revenue forecasting, and won/lost deals.',
  ),
  tasks(
    label: 'Tasks',
    icon: Icons.task_alt_outlined,
    selectedIcon: Icons.task_alt_rounded,
    description: 'To-do lists, follow-ups, and scheduled action items.',
  ),
  activities(
    label: 'Activities',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history_rounded,
    description: 'Call logs, customer emails, meeting records, and audit timeline.',
  ),
  search(
    label: 'Search',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search_rounded,
    description: 'Global CRM search across leads, accounts, deals, and notes.',
  ),
  notifications(
    label: 'Notifications',
    icon: Icons.notifications_none_rounded,
    selectedIcon: Icons.notifications_rounded,
    description: 'System alerts, task reminders, and deal updates.',
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    description: 'Representative profile, quota performance, and preferences.',
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    description: 'Application configuration, team roles, and theme settings.',
  );

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String description;

  const CrmDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.description,
  });

  /// The 4 primary destinations shown in the mobile bottom navigation bar.
  static const List<CrmDestination> primaryMobileDestinations = [
    CrmDestination.dashboard,
    CrmDestination.leads,
    CrmDestination.customers,
    CrmDestination.deals,
  ];

  /// Secondary destinations accessible via the mobile 'More' menu.
  static const List<CrmDestination> secondaryMobileDestinations = [
    CrmDestination.tasks,
    CrmDestination.activities,
    CrmDestination.search,
    CrmDestination.notifications,
    CrmDestination.profile,
    CrmDestination.settings,
  ];
}
