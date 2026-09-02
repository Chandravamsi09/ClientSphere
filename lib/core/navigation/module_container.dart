import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'crm_destination.dart';

/// Clean initial module container for unmounted or upcoming CRM feature modules.
///
/// Provides a production-oriented empty/initial view describing the module
/// purpose and ready for subsequent domain/feature screen wiring without
/// injecting fake or placeholder mock data.
class ModuleContainer extends StatelessWidget {
  /// The destination module being presented.
  final CrmDestination destination;

  /// Optional custom action callback.
  final VoidCallback? onPrimaryAction;

  /// Optional label for the primary action.
  final String? primaryActionLabel;

  const ModuleContainer({
    super.key,
    required this.destination,
    this.onPrimaryAction,
    this.primaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        AppEmptyState(
          icon: destination.icon,
          title: '${destination.label} Module',
          description: destination.description,
          actionText: primaryActionLabel,
          onAction: onPrimaryAction,
        ),
      ],
    );
  }
}
