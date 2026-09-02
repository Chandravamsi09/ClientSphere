import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'app_top_bar.dart';
import 'crm_destination.dart';
import 'module_container.dart';
import 'navigation_controller.dart';
import 'responsive_layout.dart';

/// The responsive CRM application shell for ClientSphere.
///
/// Automatically adapts navigation structure between Mobile (Bottom Navigation Bar
/// with 'More' drawer) and Tablet/Desktop (Side Navigation Rail).
class AppShell extends StatelessWidget {
  /// Navigation controller managing active destination and badges.
  final NavigationController controller;

  /// Optional module screen builders registered by feature modules.
  final Map<CrmDestination, WidgetBuilder>? moduleBuilders;

  /// Optional custom top bar. Defaults to [AppTopBar].
  final PreferredSizeWidget? customTopBar;

  const AppShell({
    super.key,
    required this.controller,
    this.moduleBuilders,
    this.customTopBar,
  });

  Widget _buildBody(BuildContext context, CrmDestination destination) {
    final builder = moduleBuilders?[destination];
    if (builder != null) {
      return KeyedSubtree(
        key: ValueKey(destination),
        child: builder(context),
      );
    }

    return KeyedSubtree(
      key: ValueKey(destination),
      child: ModuleContainer(destination: destination),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: AppRadius.shapeLg,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More CRM Modules',
                  style: Theme.of(bottomSheetContext).textTheme.titleMedium,
                ),
                AppSpacing.gapH12,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: CrmDestination.secondaryMobileDestinations.map((dest) {
                    final isSelected = controller.currentDestination == dest;
                    return ActionChip(
                      avatar: Icon(
                        isSelected ? dest.selectedIcon : dest.icon,
                        size: 18,
                      ),
                      label: Text(dest.label),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        controller.navigateTo(dest);
                      },
                    );
                  }).toList(),
                ),
                AppSpacing.gapH16,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final isCompact = ResponsiveBreakpoints.isCompact(context);
          final currentDest = controller.currentDestination;

          if (isCompact) {
            // --- Mobile Phone Shell (< 600dp) ---
            final primaryDestinations = CrmDestination.primaryMobileDestinations;
            final isPrimarySelected = primaryDestinations.contains(currentDest);

            final selectedIndex = isPrimarySelected
                ? primaryDestinations.indexOf(currentDest)
                : primaryDestinations.length; // 'More' is last index

            return Scaffold(
              appBar: customTopBar ?? const AppTopBar(),
              body: _buildBody(context, currentDest),
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  if (index < primaryDestinations.length) {
                    controller.navigateTo(primaryDestinations[index]);
                  } else {
                    _showMoreMenu(context);
                  }
                },
                destinations: [
                  ...primaryDestinations.map((dest) {
                    final badgeCount = controller.getBadgeCount(dest);
                    final iconWidget = Icon(dest.icon);
                    final selectedIconWidget = Icon(dest.selectedIcon);

                    return NavigationDestination(
                      icon: badgeCount > 0
                          ? Badge(label: Text('$badgeCount'), child: iconWidget)
                          : iconWidget,
                      selectedIcon: badgeCount > 0
                          ? Badge(
                              label: Text('$badgeCount'),
                              child: selectedIconWidget,
                            )
                          : selectedIconWidget,
                      label: dest.label,
                    );
                  }),
                  const NavigationDestination(
                    icon: Icon(Icons.more_horiz_rounded),
                    selectedIcon: Icon(Icons.more_horiz_rounded),
                    label: 'More',
                  ),
                ],
              ),
            );
          }

          // --- Tablet / Desktop Shell (>= 600dp) ---
          final allDestinations = CrmDestination.values;
          final railIndex = allDestinations.indexOf(currentDest);

          return Scaffold(
            appBar: customTopBar ?? const AppTopBar(),
            body: Row(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            selectedIndex: railIndex,
                            onDestinationSelected: (index) {
                              controller.navigateTo(allDestinations[index]);
                            },
                            labelType: NavigationRailLabelType.all,
                            leading: Padding(
                              padding: AppSpacing.paddingVSm,
                              child: Icon(
                                Icons.hub_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            destinations: allDestinations.map((dest) {
                              final badgeCount = controller.getBadgeCount(dest);
                              final iconWidget = Icon(dest.icon);
                              final selectedIconWidget = Icon(dest.selectedIcon);

                              return NavigationRailDestination(
                                icon: badgeCount > 0
                                    ? Badge(
                                        label: Text('$badgeCount'),
                                        child: iconWidget,
                                      )
                                    : iconWidget,
                                selectedIcon: badgeCount > 0
                                    ? Badge(
                                        label: Text('$badgeCount'),
                                        child: selectedIconWidget,
                                      )
                                    : selectedIconWidget,
                                label: Text(dest.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: _buildBody(context, currentDest),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
