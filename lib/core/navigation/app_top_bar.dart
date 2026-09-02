import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'crm_destination.dart';
import 'navigation_controller.dart';

/// Standard top application bar for ClientSphere CRM modules.
///
/// Provides module title, quick search, notification badges, theme toggle,
/// and profile navigation slots with consistent styling.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Custom title override. If null, displays active destination label.
  final String? title;

  /// Custom actions appended to the end of the top bar.
  final List<Widget>? customActions;

  /// Whether to display the quick search icon button.
  final bool showSearch;

  /// Whether to display the notification bell icon button.
  final bool showNotifications;

  /// Whether to display the theme toggle action button.
  final bool showThemeToggle;

  /// Whether to display the user profile avatar action.
  final bool showProfile;

  const AppTopBar({
    super.key,
    this.title,
    this.customActions,
    this.showSearch = true,
    this.showNotifications = true,
    this.showThemeToggle = true,
    this.showProfile = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nav = NavigationScope.of(context);
    final themeController = ThemeScope.maybeOf(context);

    final displayTitle = title ??
        (nav.currentDestination == CrmDestination.dashboard
            ? 'ClientSphere Foundation'
            : nav.currentDestination.label);
    final unreadNotifications = nav.getBadgeCount(CrmDestination.notifications);

    return AppBar(
      title: Text(displayTitle),
      actions: [
        if (showSearch)
          AppIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search CRM',
            onPressed: () => nav.navigateTo(CrmDestination.search),
          ),
        if (showNotifications) ...[
          AppSpacing.gapW4,
          Badge(
            isLabelVisible: unreadNotifications > 0,
            label: Text('$unreadNotifications'),
            child: AppIconButton(
              icon: unreadNotifications > 0
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_outlined,
              tooltip: 'Notifications',
              onPressed: () => nav.navigateTo(CrmDestination.notifications),
            ),
          ),
        ],
        if (showThemeToggle) ...[
          AppSpacing.gapW4,
          AppIconButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: 'Toggle Theme',
            onPressed: themeController?.toggleTheme,
          ),
        ],
        if (showProfile) ...[
          AppSpacing.gapW4,
          AppIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profile',
            onPressed: () => nav.navigateTo(CrmDestination.profile),
          ),
        ],
        ...?customActions,
        AppSpacing.gapW8,
      ],
    );
  }
}
