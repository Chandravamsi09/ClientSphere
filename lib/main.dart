import 'package:flutter/material.dart';
import 'core/components/components.dart';
import 'core/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController(ThemeMode.system);
  runApp(ClientSphereApp(themeController: themeController));
}

/// Root widget for the ClientSphere CRM mobile application.
class ClientSphereApp extends StatelessWidget {
  final ThemeController themeController;

  const ClientSphereApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeController,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'ClientSphere CRM',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const FoundationShowcaseScreen(),
          );
        },
      ),
    );
  }
}

/// Mode selection for previewing CRM state views in the showcase.
enum _StatePreviewMode { empty, loading, error }

/// A functional preview and validation screen for UI foundation tokens, form components, and state views.
class FoundationShowcaseScreen extends StatefulWidget {
  const FoundationShowcaseScreen({super.key});

  @override
  State<FoundationShowcaseScreen> createState() =>
      _FoundationShowcaseScreenState();
}

class _FoundationShowcaseScreenState extends State<FoundationShowcaseScreen> {
  String _searchQuery = '';
  bool _isButtonLoading = false;
  bool _showInputError = false;
  _StatePreviewMode _statePreviewMode = _StatePreviewMode.empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = ThemeScope.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientSphere Foundation'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
            onPressed: themeController.toggleTheme,
          ),
          AppSpacing.gapW8,
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Theme Mode Switcher Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme Controls', style: theme.textTheme.titleMedium),
                AppSpacing.gapH8,
                Text(
                  'Active Mode: ${themeController.value.name.toUpperCase()}',
                  style: theme.textTheme.bodyMedium,
                ),
                AppSpacing.gapH12,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('System'),
                      selected: themeController.value == ThemeMode.system,
                      onSelected: (_) =>
                          themeController.setThemeMode(ThemeMode.system),
                    ),
                    ChoiceChip(
                      label: const Text('Light'),
                      selected: themeController.value == ThemeMode.light,
                      onSelected: (_) =>
                          themeController.setThemeMode(ThemeMode.light),
                    ),
                    ChoiceChip(
                      label: const Text('Dark'),
                      selected: themeController.value == ThemeMode.dark,
                      onSelected: (_) =>
                          themeController.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,

          // CRM Metric Cards (Micro-Slice 3)
          Text('CRM Metric Cards', style: theme.textTheme.titleMedium),
          AppSpacing.gapH8,
          Row(
            children: [
              Expanded(
                child: AppMetricCard(
                  title: 'Pipeline Revenue',
                  value: '\$342.5K',
                  subtitle: 'vs last month',
                  icon: Icons.trending_up_rounded,
                  trendLabel: '+14.2%',
                  trend: MetricTrend.positive,
                  onTap: () {},
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: AppMetricCard(
                  title: 'At-Risk Deals',
                  value: '4',
                  subtitle: 'Needs action',
                  icon: Icons.warning_amber_rounded,
                  trendLabel: '-2',
                  trend: MetricTrend.negative,
                  onTap: () {},
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,

          // Interactive Components Showcase (Micro-Slice 2)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Core Interactive Components',
                  style: theme.textTheme.titleMedium,
                ),
                AppSpacing.gapH16,

                // Search Field
                AppSearchField(
                  hint: 'Search CRM leads or contacts...',
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                if (_searchQuery.isNotEmpty) ...[
                  AppSpacing.gapH8,
                  Text(
                    'Search Query: "$_searchQuery"',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                AppSpacing.gapH16,

                // Form Inputs
                AppTextField(
                  label: 'Lead Full Name',
                  hint: 'e.g. John Doe',
                  isRequired: true,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  errorText: _showInputError ? 'Lead name is required' : null,
                ),
                AppSpacing.gapH12,

                AppTextField(
                  label: 'Portal Password',
                  hint: 'Enter client portal access key',
                  obscureText: true,
                  enablePasswordToggle: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
                AppSpacing.gapH16,

                // Interactive Buttons
                AppPrimaryButton(
                  text: 'Save Lead to Pipeline',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isButtonLoading,
                  onPressed: () {
                    setState(() {
                      _isButtonLoading = !_isButtonLoading;
                    });
                  },
                ),
                AppSpacing.gapH8,

                AppSecondaryButton(
                  text: 'Cancel / Reset Form',
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    setState(() {
                      _showInputError = !_showInputError;
                      _isButtonLoading = false;
                    });
                  },
                ),
                AppSpacing.gapH16,

                // Icon Buttons Row
                Row(
                  children: [
                    Text('Icon Actions:', style: theme.textTheme.labelMedium),
                    AppSpacing.gapW12,
                    AppIconButton(
                      icon: Icons.phone_outlined,
                      tooltip: 'Call contact',
                      onPressed: () {},
                    ),
                    AppSpacing.gapW8,
                    AppIconButton(
                      icon: Icons.email_outlined,
                      tooltip: 'Email contact',
                      variant: AppIconButtonVariant.filled,
                      onPressed: () {},
                    ),
                    AppSpacing.gapW8,
                    AppIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit record',
                      variant: AppIconButtonVariant.outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,

          // CRM State Views Showcase (Micro-Slice 3)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CRM State Views', style: theme.textTheme.titleMedium),
                AppSpacing.gapH8,
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Empty State'),
                      selected: _statePreviewMode == _StatePreviewMode.empty,
                      onSelected: (_) => setState(() {
                        _statePreviewMode = _StatePreviewMode.empty;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Loading State'),
                      selected: _statePreviewMode == _StatePreviewMode.loading,
                      onSelected: (_) => setState(() {
                        _statePreviewMode = _StatePreviewMode.loading;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Error State'),
                      selected: _statePreviewMode == _StatePreviewMode.error,
                      onSelected: (_) => setState(() {
                        _statePreviewMode = _StatePreviewMode.error;
                      }),
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                Container(
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: AppRadius.allMd,
                  ),
                  child: switch (_statePreviewMode) {
                    _StatePreviewMode.empty => const AppEmptyState(
                        title: 'No Closed Deals',
                        description: 'Closed-won deals will appear in this pipeline view.',
                        icon: Icons.assignment_outlined,
                        actionText: 'Create First Deal',
                        onAction: null,
                      ),
                    _StatePreviewMode.loading => const AppLoadingIndicator(
                        message: 'Synchronizing pipeline deals...',
                      ),
                    _StatePreviewMode.error => const AppErrorState(
                        title: 'Sync Failed',
                        message: 'Unable to reach the CRM server. Check network connection.',
                        onRetry: null,
                      ),
                  },
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,

          // CRM Pipeline & Status Tokens
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CRM Semantic Tokens', style: theme.textTheme.titleMedium),
                AppSpacing.gapH8,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: const [
                    _StatusPill(label: 'Success', color: AppColors.success),
                    _StatusPill(label: 'Warning', color: AppColors.warning),
                    _StatusPill(label: 'Error', color: AppColors.error),
                    _StatusPill(label: 'Info', color: AppColors.info),
                    _StatusPill(label: 'Lead', color: AppColors.stageLead),
                    _StatusPill(
                      label: 'Qualified',
                      color: AppColors.stageQualified,
                    ),
                    _StatusPill(
                      label: 'Proposal',
                      color: AppColors.stageProposal,
                    ),
                    _StatusPill(
                      label: 'Negotiation',
                      color: AppColors.stageNegotiation,
                    ),
                    _StatusPill(label: 'Won Deal', color: AppColors.stageWon),
                    _StatusPill(
                      label: 'Lost Deal',
                      color: AppColors.stageLost,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,

          // Typography Scale Showcase
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Typography Scale', style: theme.textTheme.titleMedium),
                AppSpacing.gapH12,
                Text('Display Small (24pt)', style: theme.textTheme.displaySmall),
                AppSpacing.gapH8,
                Text('Headline Medium (20pt)', style: theme.textTheme.headlineMedium),
                AppSpacing.gapH8,
                Text('Title Large (16pt)', style: theme.textTheme.titleLarge),
                AppSpacing.gapH8,
                Text(
                  'Body Medium (14pt) - Enterprise CRM records & client notes.',
                  style: theme.textTheme.bodyMedium,
                ),
                AppSpacing.gapH8,
                Text(
                  'Label Small (11pt) - Meta info & timestamps',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.chipPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.allPill,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapW4,
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
