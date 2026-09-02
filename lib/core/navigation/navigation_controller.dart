import 'package:flutter/material.dart';
import 'crm_destination.dart';

/// State controller managing active CRM navigation destinations and badges.
///
/// Implemented using pure Flutter [ChangeNotifier] without external router
/// or state management packages.
class NavigationController extends ChangeNotifier {
  CrmDestination _currentDestination;
  final Map<CrmDestination, int> _badgeCounts = {};

  NavigationController([CrmDestination initialDestination = CrmDestination.dashboard])
      : _currentDestination = initialDestination;

  /// Currently active CRM destination.
  CrmDestination get currentDestination => _currentDestination;

  /// Sets the active destination and notifies listeners if changed.
  void navigateTo(CrmDestination destination) {
    if (_currentDestination != destination) {
      _currentDestination = destination;
      notifyListeners();
    }
  }

  /// Returns the badge counter for a specific destination (e.g. unread notifications).
  int getBadgeCount(CrmDestination destination) {
    return _badgeCounts[destination] ?? 0;
  }

  /// Sets or updates the badge counter for a destination.
  void setBadgeCount(CrmDestination destination, int count) {
    if (_badgeCounts[destination] != count) {
      _badgeCounts[destination] = count;
      notifyListeners();
    }
  }

  /// Clears the badge counter for a destination.
  void clearBadgeCount(CrmDestination destination) {
    if (_badgeCounts.containsKey(destination) && _badgeCounts[destination] != 0) {
      _badgeCounts[destination] = 0;
      notifyListeners();
    }
  }
}

/// [InheritedNotifier] providing descendant access to [NavigationController].
class NavigationScope extends InheritedNotifier<NavigationController> {
  const NavigationScope({
    super.key,
    required NavigationController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Retrieves the nearest [NavigationController] from the widget tree.
  static NavigationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NavigationScope>();
    assert(scope != null, 'No NavigationScope found in context');
    return scope!.notifier!;
  }
}
