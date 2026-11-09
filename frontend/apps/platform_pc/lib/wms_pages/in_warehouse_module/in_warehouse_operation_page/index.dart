import 'package:flutter/material.dart';

import '../../shared/operation_overview_page.dart';

/// 仓内作业概览。
class WmsInWarehouseOperationPage extends StatelessWidget {
  const WmsInWarehouseOperationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WmsOperationOverviewPage(
      id: 'in-warehouse',
      label: '仓内作业',
      description: '集中管理盘点、补货与移库等仓内执行任务。',
      metrics: [
        WmsOperationMetric('待盘点', '4'),
        WmsOperationMetric('待补货', '7'),
        WmsOperationMetric('今日已移库', '18'),
      ],
      records: [
        WmsOperationRecord(
          'WH-20261108-0005',
          '循环盘点',
          '盘点中',
          'A 仓 / 库区 A-02',
          '2026-11-08 10:21',
        ),
        WmsOperationRecord(
          'WH-20261108-0004',
          '补货任务',
          '待补货',
          'A 仓 / 拣货区 01',
          '2026-11-08 10:02',
        ),
        WmsOperationRecord(
          'WH-20261108-0003',
          '库内移库',
          '已完成',
          'B 仓 / 库区 B-01',
          '2026-11-08 09:36',
        ),
      ],
    );
  }
}
