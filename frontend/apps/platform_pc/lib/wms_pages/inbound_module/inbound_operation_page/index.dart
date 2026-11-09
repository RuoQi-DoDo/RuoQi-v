import 'package:flutter/material.dart';

import '../../shared/operation_overview_page.dart';

/// 入库作业概览。
class WmsInboundOperationPage extends StatelessWidget {
  const WmsInboundOperationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WmsOperationOverviewPage(
      id: 'inbound',
      label: '入库作业',
      description: '跟踪收货、质检与上架任务，掌握入库作业进度。',
      metrics: [
        WmsOperationMetric('待到货', '6'),
        WmsOperationMetric('收货中', '9'),
        WmsOperationMetric('今日已上架', '24'),
      ],
      records: [
        WmsOperationRecord(
          'IN-20261108-0008',
          '采购收货',
          '收货中',
          'A 仓 / 收货口 03',
          '2026-11-08 10:26',
        ),
        WmsOperationRecord(
          'IN-20261108-0007',
          '入库质检',
          '待质检',
          'A 仓 / 质检台 01',
          '2026-11-08 10:05',
        ),
        WmsOperationRecord(
          'IN-20261108-0006',
          '上架任务',
          '待上架',
          'B 仓 / 上架组 02',
          '2026-11-08 09:48',
        ),
      ],
    );
  }
}
