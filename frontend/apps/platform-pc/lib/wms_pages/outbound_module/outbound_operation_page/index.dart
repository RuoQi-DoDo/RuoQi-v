import 'package:flutter/material.dart';

import '../../shared/operation_overview_page.dart';

/// 出库作业概览。
class WmsOutboundOperationPage extends StatelessWidget {
  const WmsOutboundOperationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WmsOperationOverviewPage(
      id: 'outbound',
      label: '出库作业',
      description: '统一处理出库波次、拣货、复核装箱与发运任务。',
      metrics: [
        WmsOperationMetric('待处理', '8'),
        WmsOperationMetric('进行中', '12'),
        WmsOperationMetric('今日已完成', '36'),
      ],
      records: [
        WmsOperationRecord(
          'OUT-20261108-0012',
          '波次拣货',
          '拣货中',
          'A 仓 / 拣货员 01',
          '2026-11-08 10:32',
        ),
        WmsOperationRecord(
          'OUT-20261108-0011',
          '复核装箱',
          '待复核',
          'A 仓 / 复核台 02',
          '2026-11-08 10:18',
        ),
        WmsOperationRecord(
          'OUT-20261108-0010',
          '装车发运',
          '待发运',
          'B 仓 / 1 号月台',
          '2026-11-08 09:55',
        ),
      ],
    );
  }
}
