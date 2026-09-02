import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'app_card.dart';

/// Trend direction for [AppMetricCard].
enum MetricTrend {
  /// Upward/favorable performance trend (rendered with success styling).
  positive,

  /// Downward/unfavorable performance trend (rendered with error styling).
  negative,

  /// Flat or informational trend (rendered with neutral styling).
  neutral,
}

/// Reusable KPI and metric presentation card for CRM dashboards and summaries.
class AppMetricCard extends StatelessWidget {
  /// Metric title or label (e.g. "Total Revenue", "Won Deals", "Active Leads").
  final String title;

  /// Primary metric value display (e.g. "$124,500", "42", "98.4%").
  final String value;

  /// Optional secondary descriptive label (e.g. "vs last quarter", "this week").
  final String? subtitle;

  /// Optional decorative/contextual icon.
  final IconData? icon;

  /// Optional trend badge text (e.g. "+12.4%", "-3.1%").
  final String? trendLabel;

  /// Trend classification for styling the badge.
  final MetricTrend trend;

  /// Optional tap callback for drilling down into the metric details.
  final VoidCallback? onTap;

  /// Accessibility label override.
  final String? semanticLabel;

  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trendLabel,
    this.trend = MetricTrend.neutral,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final Color trendColor;
    final IconData trendIcon;

    switch (trend) {
      case MetricTrend.positive:
        trendColor = AppColors.success;
        trendIcon = Icons.trending_up_rounded;
        break;
      case MetricTrend.negative:
        trendColor = AppColors.error;
        trendIcon = Icons.trending_down_rounded;
        break;
      case MetricTrend.neutral:
        trendColor = colorScheme.onSurfaceVariant;
        trendIcon = Icons.trending_flat_rounded;
        break;
    }

    final effectiveSemanticLabel = semanticLabel ??
        '$title: $value'
        '${trendLabel != null ? ', Trend: $trendLabel' : ''}'
        '${subtitle != null ? ', $subtitle' : ''}';

    return AppCard(
      onTap: onTap,
      semanticLabel: effectiveSemanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Title + Optional Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                AppSpacing.gapW8,
                Container(
                  padding: AppSpacing.paddingAllXs,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.allSm,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.gapH8,

          // Middle: High-impact Metric Value
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Bottom Row: Trend Badge + Subtitle
          if (trendLabel != null || subtitle != null) ...[
            AppSpacing.gapH8,
            Row(
              children: [
                if (trendLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.allPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendIcon,
                          size: 14,
                          color: trendColor,
                        ),
                        AppSpacing.gapW4,
                        Text(
                          trendLabel!,
                          style: textTheme.labelSmall?.copyWith(
                            color: trendColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null) AppSpacing.gapW8,
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
