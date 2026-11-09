import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../admin_pages/shared/status_badge.dart';
import '../../admin_pages/shared/table_card.dart';

/// 作业概览中的指标。
class WmsOperationMetric {
  const WmsOperationMetric(this.label, this.value);

  final String label;
  final String value;
}

/// 作业概览中的近期任务。
class WmsOperationRecord {
  const WmsOperationRecord(
    this.id,
    this.type,
    this.status,
    this.owner,
    this.updatedAt,
  );

  final String id;
  final String type;
  final String status;
  final String owner;
  final String updatedAt;
}

/// WMS 各作业页面共用的首屏结构。
class WmsOperationOverviewPage extends StatelessWidget {
  const WmsOperationOverviewPage({
    super.key,
    required this.id,
    required this.label,
    required this.description,
    required this.metrics,
    required this.records,
  });

  final String id;
  final String label;
  final String description;
  final List<WmsOperationMetric> metrics;
  final List<WmsOperationRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: ValueKey('wms-operation-page-$id'),
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          'WMS管理 / $label',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        Text(
          label,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Wrap(
          spacing: RuQiSpacing.sm,
          runSpacing: RuQiSpacing.sm,
          children: [
            for (final metric in metrics)
              SizedBox(width: 190, child: _OperationMetricCard(metric: metric)),
          ],
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Row(
          children: [
            Text(
              '近期作业',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '全部仓库',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.sm),
        TableCard(
          columns: const [
            (label: '作业单号', flex: 2),
            (label: '作业类型', flex: 2),
            (label: '作业状态', flex: 2),
            (label: '仓库 / 执行人', flex: 3),
            (label: '更新时间', flex: 2),
          ],
          rowCount: records.length,
          rowBuilder: (context, index) {
            final record = records[index];
            return [
              CellText(record.id, strong: true),
              CellText(record.type),
              StatusBadge(
                label: record.status,
                tone: record.status.contains('待')
                    ? StatusTone.neutral
                    : record.status.contains('完成')
                    ? StatusTone.success
                    : StatusTone.info,
              ),
              CellText(record.owner, muted: true),
              CellText(record.updatedAt, muted: true),
            ];
          },
        ),
      ],
    );
  }
}

class _OperationMetricCard extends StatelessWidget {
  const _OperationMetricCard({required this.metric});

  final WmsOperationMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(RuQiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: RuQiSpacing.xxs),
            Text(
              metric.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
