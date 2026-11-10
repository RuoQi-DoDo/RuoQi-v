import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'rule_models.dart';

/// WMS 新建/编辑规则子视图。
///
/// 该视图直接占用控制台右侧内容区，不额外叠加弹窗；侧栏保持可见。
class WmsRuleEditorView extends StatefulWidget {
  const WmsRuleEditorView({
    super.key,
    required this.page,
    required this.onCancel,
    required this.onSaved,
    this.rule,
  });

  final WmsRulePageDefinition page;
  final WmsRule? rule;
  final VoidCallback onCancel;
  final ValueChanged<WmsRuleDraft> onSaved;

  @override
  State<WmsRuleEditorView> createState() => _WmsRuleEditorViewState();
}

class _WmsRuleEditorViewState extends State<WmsRuleEditorView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _priority;
  late final TextEditingController _description;
  late final TextEditingController _note;
  final Map<String, TextEditingController> _secondaryFields = {};
  final List<_BuilderRowModel> _conditionRows = [];
  final List<_BuilderRowModel> _actionRows = [];
  final Map<String, bool> _toggles = {};

  late String _warehouse;
  late String _owner;
  late WmsRuleStatus _status;
  late bool _isDefault;

  int _qualityPosition = 0;
  int _packingMode = 0;
  int _outboundDecision = 0;
  int _pickingDecision = 0;
  int _reviewDecision = 0;
  String _ruleType = '最少任务优先';
  String _serialCharset = '[0-9] 仅数字';
  String _batchCodeRule = '请选择';
  String _inspectionPlan = '全部质检';
  String _containerType = '纸箱';
  String _purchaseMode = '依据每日销量自动刷新';
  String _purchaseBase = '警戒库存';
  String _growthMode = '固定';
  String _replenishmentPolicy = 'ROP补到警戒';
  String _zeroSalesPolicy = '不建议';

  List<String> get _conditions => switch (widget.page.editorKind) {
    WmsEditorKind.randomInventory => ['随机盘点维度', '随机盘点类型', '商品数量'],
    WmsEditorKind.outboundWave => ['收货市', '商品数量', '请选择字段'],
    WmsEditorKind.crossDocking => ['入库单类型', '商品编号'],
    _ => ['商品类别', '商品编号', '供应商', '入库单类型', '出库单类型'],
  };

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _name = TextEditingController(text: rule?.name ?? '');
    _priority = TextEditingController(text: '${rule?.priority ?? 0}');
    _description = TextEditingController(text: rule?.description ?? '');
    _note = TextEditingController(text: rule?.note ?? '');
    _warehouse = rule?.warehouse ?? '全部';
    _owner = rule?.owner ?? '全部';
    _status = rule?.status ?? WmsRuleStatus.enabled;
    _isDefault = rule?.isDefault ?? false;

    _conditionRows.addAll(_initialConditionRows());
    _actionRows.addAll(_initialActionRows());
    _toggles.addAll({
      'auto_quality': true,
      'allow_over_quantity': true,
      'weight_alert': true,
      'shelf_life': false,
      'production_alert': false,
      'pallet_sync': false,
      'auto_batch': false,
      'auto_unique': false,
      'empty_container': false,
      'empty_project': false,
      'auto_rack': true,
      'merge_rack': true,
      'auto_pallet': false,
      'pallet_quantity': false,
      'pallet_as_slot': false,
      'refresh_warning_stock': true,
      'sales_window_today': true,
      'restock_refresh': true,
      'check_empty_slot': true,
      'check_frozen_stock': true,
      'check_repeat': true,
      'generate_wcs': false,
      'wave_split_by_location': false,
      'wave_assign_picker': true,
      'packing_barcode': true,
      'packing_material': false,
      'packing_multi_material': false,
      'cross_batch': true,
      'cross_project': true,
      'cross_production_date': true,
      'cross_pallet': true,
      'cross_container': true,
      'order_partial_release': true,
      'line_partial_release': true,
      'print_shipping': false,
      'print_outbound': false,
      'print_picking': false,
      'print_box_label': false,
      'print_box_number': false,
      'diff_absolute': true,
      'diff_latest_batch': false,
      'diff_earliest_batch': false,
      'loss_absolute': true,
      'loss_latest_batch': false,
      'loss_earliest_batch': false,
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _priority.dispose();
    _description.dispose();
    _note.dispose();
    for (final controller in _secondaryFields.values) {
      controller.dispose();
    }
    for (final row in _conditionRows) {
      row.dispose();
    }
    for (final row in _actionRows) {
      row.dispose();
    }
    super.dispose();
  }

  List<_BuilderRowModel> _initialConditionRows() {
    return switch (widget.page.editorKind) {
      WmsEditorKind.randomInventory => [
        _BuilderRowModel('随机盘点维度', '包含', '库区'),
        _BuilderRowModel('随机盘点类型', '等于', '人工随机盘点'),
        _BuilderRowModel('商品数量', '等于', '1'),
      ],
      WmsEditorKind.outboundWave => [
        _BuilderRowModel('收货市', '等于', 'Accra'),
        _BuilderRowModel('商品数量', '等于', '1'),
        _BuilderRowModel('请选择字段', '等于', ''),
      ],
      WmsEditorKind.assignment => [_BuilderRowModel('出库单类型', '包含', '')],
      WmsEditorKind.packing ||
      WmsEditorKind.coding ||
      WmsEditorKind.purchaseSuggestion => const [],
      _ => [
        _BuilderRowModel('商品类别', '包含', 'Food'),
        _BuilderRowModel('商品编号', '等于', ''),
      ],
    };
  }

  List<_BuilderRowModel> _initialActionRows() {
    final action = switch (widget.page.id) {
      'constraint' => '必须SN扫描入库',
      'taboo' => '不允许相邻货位',
      'analysis' => '只允许入阴凉库区',
      'slot_recommend' => '未使用的货位',
      'outbound_allocation' => '按入库时间早优先',
      'slot_match' => '未使用的货位',
      'restock' => '高于低于量的整箱数',
      _ => '执行规则',
    };
    return switch (widget.page.editorKind) {
      WmsEditorKind.conditionAction || WmsEditorKind.restock => [
        _BuilderRowModel(
          widget.page.id == 'slot_recommend' || widget.page.id == 'slot_match'
              ? '货位优先级'
              : '执行约束',
          '等于',
          action,
        ),
      ],
      _ => [],
    };
  }

  TextEditingController _text(String key, [String initial = '']) {
    return _secondaryFields.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  bool _toggle(String key) => _toggles[key] ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.rule != null;

    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.sm,
              RuQiSpacing.sm,
              RuQiSpacing.lg,
              RuQiSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: '返回规则列表',
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: RuQiSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        editing
                            ? '编辑${widget.page.label}'
                            : '新建${widget.page.label}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '规则设置 / ${widget.page.categoryLabel} / '
                        '${widget.page.label}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(RuQiSpacing.lg),
                children: [
                  ..._basicSection(),
                  const SizedBox(height: RuQiSpacing.lg),
                  ..._conditionSection(),
                  if (_hasActionSection) ...[
                    const SizedBox(height: RuQiSpacing.lg),
                    ..._actionSection(),
                  ],
                  const SizedBox(height: RuQiSpacing.lg),
                  ..._specificSections(),
                  const SizedBox(height: RuQiSpacing.lg),
                  ..._otherSection(),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(RuQiSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: RuQiButtonStyles.secondary(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: RuQiSpacing.sm),
                FilledButton(
                  onPressed: _save,
                  style: RuQiButtonStyles.primary(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActionSection =>
      widget.page.editorKind == WmsEditorKind.conditionAction ||
      widget.page.editorKind == WmsEditorKind.restock;

  bool get _hasConditionSection =>
      widget.page.editorKind != WmsEditorKind.coding &&
      widget.page.editorKind != WmsEditorKind.packing &&
      widget.page.editorKind != WmsEditorKind.purchaseSuggestion;

  List<Widget> _basicSection() {
    return [
      _EditorSection(
        title: '基础信息',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              children: [
                TextFormField(
                  key: const ValueKey('wms-rule-name'),
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '规则名称 *',
                    hintText: '请输入规则名称',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入规则名称';
                    }
                    return null;
                  },
                ),
                _DropdownField(
                  label: '仓库名称',
                  value: _warehouse,
                  options: const ['全部', 'Delzoa Accra', 'Accra 主仓'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _warehouse = value);
                    }
                  },
                ),
                _DropdownField(
                  label: '货主名称',
                  value: _owner,
                  options: const ['全部', '自营货主', 'A公司'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _owner = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _priority,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '优先级',
                    helperText: '数字越小优先级越高',
                  ),
                ),
                TextFormField(
                  initialValue: widget.page.label,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '规则类型'),
                ),
                DropdownButtonFormField<WmsRuleStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: '规则状态'),
                  items: [
                    for (final status in WmsRuleStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextFormField(
              controller: _description,
              maxLength: 512,
              decoration: const InputDecoration(
                labelText: '规则描述',
                hintText: '请输入规则描述信息...',
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _conditionSection() {
    if (!_hasConditionSection) {
      return const [];
    }
    return [
      _EditorSection(
        title: '规则条件设置',
        caption: '多个条件默认为“且”关系；满足全部条件后执行规则动作。',
        child: _BuilderRows(
          rows: _conditionRows,
          fields: _conditions,
          operators: const ['等于', '包含', '大于', '小于', '不等于'],
          onChanged: () => setState(() {}),
          onAdd: () => setState(() {
            _conditionRows.add(_BuilderRowModel('商品类别', '等于', ''));
          }),
          onRemove: (index) => setState(() {
            _conditionRows.removeAt(index).dispose();
          }),
        ),
      ),
    ];
  }

  List<Widget> _actionSection() {
    final isRestock = widget.page.editorKind == WmsEditorKind.restock;
    return [
      _EditorSection(
        title: isRestock ? '补货数量设置' : '规则动作设置',
        caption: isRestock ? '按库存下限或整箱数计算建议补货数量。' : null,
        child: _BuilderRows(
          rows: _actionRows,
          fields: isRestock
              ? const ['库存下限补货', '整箱补货', '固定数量补货']
              : const ['执行约束', '货位优先级', '配货位优先级', '分配优先级', '库存策略'],
          operators: const ['等于', '包含', '大于', '小于'],
          onChanged: () => setState(() {}),
          onAdd: () => setState(() {
            _actionRows.add(
              _BuilderRowModel(isRestock ? '库存下限补货' : '执行约束', '等于', ''),
            );
          }),
          onRemove: (index) => setState(() {
            _actionRows.removeAt(index).dispose();
          }),
        ),
      ),
    ];
  }

  List<Widget> _specificSections() {
    return switch (widget.page.editorKind) {
      WmsEditorKind.coding => _codingSections(),
      WmsEditorKind.assignment => _assignmentSections(),
      WmsEditorKind.serialParsing => _serialParsingSections(),
      WmsEditorKind.qualityCheck => _qualityCheckSections(),
      WmsEditorKind.receiveVerification => _receiveVerificationSections(),
      WmsEditorKind.advanceReceipt => _advanceReceiptSections(),
      WmsEditorKind.purchaseSuggestion => _purchaseSuggestionSections(),
      WmsEditorKind.restock => _restockSections(),
      WmsEditorKind.inventoryCheck => _inventoryCheckSections(),
      WmsEditorKind.inventoryDifference => _inventoryDifferenceSections(),
      WmsEditorKind.randomInventory => const [],
      WmsEditorKind.outboundWave => _outboundWaveSections(),
      WmsEditorKind.outboundVerification => _outboundVerificationSections(),
      WmsEditorKind.packing => _packingSections(),
      WmsEditorKind.boxRecommendation => _boxRecommendationSections(),
      WmsEditorKind.crossDocking => _crossDockingSections(),
      WmsEditorKind.outboundOrder => _outboundOrderSections(),
      WmsEditorKind.conditionAction => const [],
    };
  }

  List<Widget> _codingSections() {
    return [
      _EditorSection(
        title: '编码设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              columns: 2,
              children: [
                TextFormField(
                  controller: _text(
                    'coding_code',
                    widget.rule == null ? '' : 'EXPRESS_MANAGEMENT',
                  ),
                  decoration: const InputDecoration(
                    labelText: '规则编码',
                    hintText: '英文标识，可选',
                  ),
                ),
                _DropdownField(
                  label: '流水号字符集',
                  value: _serialCharset,
                  options: const [
                    '[0-9] 仅数字',
                    '[A-Z] 仅大写字母',
                    '[a-z] 仅小写字母',
                    '[0-9A-Z] 数字 + 大写字母',
                    '[0-9a-zA-Z] 数字 + 字母（常用）',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _serialCharset = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _text(
                    'coding_module',
                    widget.rule == null ? '' : '232',
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '模块菜单ID',
                    helperText: '与业务菜单关联，用于取号。',
                  ),
                ),
                TextFormField(
                  controller: _text('coding_sort', '0'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '排序号'),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _assignmentSections() {
    return [
      _EditorSection(
        title: '分配设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              columns: 2,
              children: [
                _DropdownField(
                  label: '分配策略',
                  value: _ruleType,
                  options: const ['最少任务优先', '随机分配', '指定人员'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _ruleType = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _text('assignment_timeout', '30'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '任务超时时间（分钟）',
                    helperText: '0 表示不限制',
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('设为默认规则'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            Text(
              '操作人员配置明细',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: RuQiSpacing.lg,
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                columns: const [
                  DataColumn(label: Text('工号')),
                  DataColumn(label: Text('姓名')),
                  DataColumn(label: Text('最大并发任务')),
                  DataColumn(label: Text('每日最大任务数')),
                  DataColumn(label: Text('生效开始时间')),
                  DataColumn(label: Text('生效结束时间')),
                ],
                rows: const [
                  DataRow(
                    cells: [
                      DataCell(Text('WMS01')),
                      DataCell(Text('拣货员1号')),
                      DataCell(Text('5')),
                      DataCell(Text('50')),
                      DataCell(Text('—')),
                      DataCell(Text('—')),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _showLocalHint('已打开操作人员选择面板'),
                style: RuQiButtonStyles.secondary(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加人员'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _serialParsingSections() {
    return [
      _EditorSection(
        title: '序列号位数解析设置',
        child: _ResponsiveFieldGrid(
          columns: 3,
          children: [
            TextFormField(
              controller: _text('serial_barcode'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '商品条码范围位数'),
            ),
            TextFormField(
              controller: _text('serial_spec'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '商品规格范围位数'),
            ),
            TextFormField(
              controller: _text('serial_weight'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '商品重量范围位数'),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _qualityCheckSections() {
    return [
      _EditorSection(
        title: '质检设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChoiceRow<int>(
              label: '质检位置',
              value: _qualityPosition,
              options: const [(0, '收货前'), (1, '收货后上架前')],
              onChanged: (value) => setState(() => _qualityPosition = value),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _ResponsiveFieldGrid(
              columns: 2,
              children: [
                _DropdownField(
                  label: '质检方案',
                  value: _inspectionPlan,
                  options: const ['全部质检', '按比例抽检', '免检'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _inspectionPlan = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _text('quality_ratio'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '质检比例（%）'),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('自动生成质检单'),
              value: _toggle('auto_quality'),
              onChanged: (value) => _setToggle('auto_quality', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _receiveVerificationSections() {
    return [
      _EditorSection(
        title: '执行规则设置',
        child: Column(
          children: [
            _SwitchSetting(
              label: '入库时允许超收',
              value: _toggle('allow_over_quantity'),
              onChanged: (value) => _setToggle('allow_over_quantity', value),
              trailing: SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _text('receive_quantity_ratio'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: '%'),
                ),
              ),
            ),
            _SwitchSetting(
              label: '重量超收预警',
              value: _toggle('weight_alert'),
              onChanged: (value) => _setToggle('weight_alert', value),
              trailing: SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _text('receive_weight_ratio'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: '%'),
                ),
              ),
            ),
            _SwitchSetting(
              label: '入库时启用禁收日期',
              description: '入库商品时效小于等于商品信息中设置的禁收天数时拦截。',
              value: _toggle('shelf_life'),
              onChanged: (value) => _setToggle('shelf_life', value),
            ),
            _SwitchSetting(
              label: '生产日期预警',
              description: '发现早于以前批次的商品时进行预警。',
              value: _toggle('production_alert'),
              onChanged: (value) => _setToggle('production_alert', value),
            ),
            _SwitchSetting(
              label: '拍号同步',
              description: '开启后将托盘号同步到库存关联码中。',
              value: _toggle('pallet_sync'),
              onChanged: (value) => _setToggle('pallet_sync', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _advanceReceiptSections() {
    return [
      _EditorSection(
        title: '规则执行',
        child: Column(
          children: [
            _ResponsiveFieldGrid(
              columns: 2,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('预到货单明细自动生成批次号'),
                  value: _toggle('auto_batch'),
                  onChanged: (value) => _setToggle('auto_batch', value),
                ),
                _DropdownField(
                  label: '批次编码规则',
                  value: _batchCodeRule,
                  options: const ['请选择', '日期 + 流水号', '固定批次编码'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _batchCodeRule = value);
                    }
                  },
                ),
              ],
            ),
            _SwitchSetting(
              label: '预到货单明细自动生成唯一码',
              value: _toggle('auto_unique'),
              onChanged: (value) => _setToggle('auto_unique', value),
            ),
            _SwitchSetting(
              label: '集装箱号为空时默认预到货单号',
              value: _toggle('empty_container'),
              onChanged: (value) => _setToggle('empty_container', value),
            ),
            _SwitchSetting(
              label: '项目号为空时默认预到货单号',
              value: _toggle('empty_project'),
              onChanged: (value) => _setToggle('empty_project', value),
            ),
            _SwitchSetting(
              label: '扫描入库时间时生成上架单',
              value: _toggle('auto_rack'),
              onChanged: (value) => _setToggle('auto_rack', value),
            ),
            _SwitchSetting(
              label: '扫描入库时合并生成上架单',
              description: '同一预到货单分多次收货时，合并到首次收货生成的上架单。',
              value: _toggle('merge_rack'),
              onChanged: (value) => _setToggle('merge_rack', value),
            ),
            _SwitchSetting(
              label: '生成托盘号',
              value: _toggle('auto_pallet'),
              onChanged: (value) => _setToggle('auto_pallet', value),
            ),
            _SwitchSetting(
              label: '生成托盘数',
              value: _toggle('pallet_quantity'),
              onChanged: (value) => _setToggle('pallet_quantity', value),
            ),
            _SwitchSetting(
              label: '托盘号默认为货位号',
              value: _toggle('pallet_as_slot'),
              onChanged: (value) => _setToggle('pallet_as_slot', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _purchaseSuggestionSections() {
    return [
      _EditorSection(
        title: '警戒库存',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              columns: 3,
              children: [
                _DropdownField(
                  label: '警戒模式',
                  value: _purchaseMode,
                  options: const ['依据每日销量自动刷新', '固定警戒库存', '按历史峰值刷新'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _purchaseMode = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _text('sales_window_days', '7'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '销量窗口天数'),
                ),
                TextFormField(
                  controller: _text('warning_days', '15'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '警戒天数'),
                ),
                TextFormField(
                  controller: _text('max_warning_days', '30'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '最大警戒天数'),
                ),
                TextFormField(
                  controller: _text('growth_rate', '1'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '增长率'),
                ),
                _DropdownField(
                  label: '增长率模式',
                  value: _growthMode,
                  options: const ['固定', '按周计算', '按月计算'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _growthMode = value);
                    }
                  },
                ),
              ],
            ),
            _SwitchSetting(
              label: '刷新警戒库存',
              value: _toggle('refresh_warning_stock'),
              onChanged: (value) => _setToggle('refresh_warning_stock', value),
            ),
            _SwitchSetting(
              label: '销量窗口含当天',
              value: _toggle('sales_window_today'),
              onChanged: (value) => _setToggle('sales_window_today', value),
            ),
          ],
        ),
      ),
      _EditorSection(
        title: '采购量 = 比较基准 - 有效库存',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DropdownField(
              label: '比较基准',
              value: _purchaseBase,
              options: const ['警戒库存', '最低库存', '安全库存'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _purchaseBase = value);
                }
              },
            ),
            const SizedBox(height: RuQiSpacing.md),
            Wrap(
              spacing: RuQiSpacing.lg,
              runSpacing: RuQiSpacing.xs,
              children: [
                for (final label in const [
                  '+采购在途量',
                  '+调拨在途量',
                  '+生产在途量',
                  '+销售退货在途',
                  '+待采购量',
                  '-待审核量',
                  '-锁定量',
                  '-待发货量',
                ])
                  SizedBox(
                    width: 180,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(label),
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      _EditorSection(
        title: '补充规则',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              columns: 3,
              children: [
                TextFormField(
                  controller: _text('purchase_lead_time'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '采购提前期（天）'),
                ),
                TextFormField(
                  controller: _text('safety_buffer_days', '0'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '安全缓冲天数'),
                ),
                TextFormField(
                  controller: _text('minimum_order'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '最小起订量 MOQ'),
                ),
                TextFormField(
                  controller: _text('order_multiple'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '订货倍数 / 箱规'),
                ),
                TextFormField(
                  controller: _text('max_stock'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '最高库存封顶'),
                ),
                TextFormField(
                  controller: _text('suggestion_min'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '建议量下限'),
                ),
                _DropdownField(
                  label: '补货政策',
                  value: _replenishmentPolicy,
                  options: const ['ROP补到警戒', '按 MOQ 补货', '固定周期补货'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _replenishmentPolicy = value);
                    }
                  },
                ),
                _DropdownField(
                  label: '零销量策略',
                  value: _zeroSalesPolicy,
                  options: const ['不建议', '按安全库存建议', '保持上次建议'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _zeroSalesPolicy = value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _restockSections() {
    return [
      _EditorSection(
        title: '自动生成补货单设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SwitchSetting(
              label: '启用自动生成补货单',
              value: _toggle('restock_refresh'),
              onChanged: (value) => _setToggle('restock_refresh', value),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _ResponsiveFieldGrid(
              columns: 3,
              children: [
                TextFormField(
                  controller: _text('restock_start', '08:00'),
                  decoration: const InputDecoration(labelText: '开始时间'),
                ),
                TextFormField(
                  controller: _text('restock_end', '18:00'),
                  decoration: const InputDecoration(labelText: '结束时间'),
                ),
                TextFormField(
                  controller: _text('restock_interval', '2'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '生成间隔时长（小时）'),
                ),
              ],
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Text(
              '间隔时长为距离上一次成功生成补货单的时长；'
              '时段外不会发起新的补货任务。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _inventoryCheckSections() {
    return [
      _EditorSection(
        title: '规则动作设置',
        child: Column(
          children: [
            _SwitchSetting(
              label: '盘点空货位',
              value: _toggle('check_empty_slot'),
              onChanged: (value) => _setToggle('check_empty_slot', value),
            ),
            _SwitchSetting(
              label: '盘点冻结库存',
              value: _toggle('check_frozen_stock'),
              onChanged: (value) => _setToggle('check_frozen_stock', value),
            ),
            _SwitchSetting(
              label: '差异要求复盘',
              value: _toggle('check_repeat'),
              onChanged: (value) => _setToggle('check_repeat', value),
            ),
            _SwitchSetting(
              label: '生成 WCS 任务',
              value: _toggle('generate_wcs'),
              onChanged: (value) => _setToggle('generate_wcs', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _inventoryDifferenceSections() {
    return [
      _EditorSection(
        title: '盘盈设置',
        child: Column(
          children: [
            // ignore: prefer_const_constructors
            _CheckSetting(
              label: '绝对匹配',
              description: '按盘点库存信息生成库存数据',
              value: _toggle('diff_absolute'),
              onChanged: (value) => _setToggle('diff_absolute', value),
            ),
            _CheckSetting(
              label: '最新批次增加',
              description: '按最新批次生成库存数据',
              value: _toggle('diff_latest_batch'),
              onChanged: (value) => _setToggle('diff_latest_batch', value),
            ),
            _CheckSetting(
              label: '最早批次增加',
              description: '按最早批次生成库存数据',
              value: _toggle('diff_earliest_batch'),
              onChanged: (value) => _setToggle('diff_earliest_batch', value),
            ),
          ],
        ),
      ),
      _EditorSection(
        title: '盘亏设置',
        child: Column(
          children: [
            _CheckSetting(
              label: '绝对匹配消减',
              description: '按盘点库存信息消减库存数据',
              value: _toggle('loss_absolute'),
              onChanged: (value) => _setToggle('loss_absolute', value),
            ),
            _CheckSetting(
              label: '最新批次消减',
              description: '按最新批次消减库存数据',
              value: _toggle('loss_latest_batch'),
              onChanged: (value) => _setToggle('loss_latest_batch', value),
            ),
            _CheckSetting(
              label: '最早批次消减',
              description: '按最早批次消减库存数据',
              value: _toggle('loss_earliest_batch'),
              onChanged: (value) => _setToggle('loss_earliest_batch', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _outboundWaveSections() {
    return [
      _EditorSection(
        title: '自动生成波次设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFieldGrid(
              columns: 3,
              children: [
                TextFormField(
                  controller: _text('wave_start', '00:00'),
                  decoration: const InputDecoration(labelText: '生成波次开始时间'),
                ),
                TextFormField(
                  controller: _text('wave_end', '23:59'),
                  decoration: const InputDecoration(labelText: '生成波次结束时间'),
                ),
                TextFormField(
                  controller: _text('wave_interval', '0'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '生成波次间隔时长',
                    suffixText: '小时',
                  ),
                ),
                TextFormField(
                  controller: _text('wave_orders', '1'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '每波次订单数'),
                ),
              ],
            ),
            _SwitchSetting(
              label: '按库区生成子波次',
              value: _toggle('wave_split_by_location'),
              onChanged: (value) => _setToggle('wave_split_by_location', value),
            ),
            _SwitchSetting(
              label: '按拣货人规则分配拣货人',
              value: _toggle('wave_assign_picker'),
              onChanged: (value) => _setToggle('wave_assign_picker', value),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Text(
              '定时任务会在配置的时间窗口内执行；设置为 0 表示不限制间隔。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _outboundVerificationSections() {
    return [
      _EditorSection(
        title: '出库验证动作',
        child: Column(
          children: [
            _ChoiceRow<int>(
              label: '出库',
              value: _outboundDecision,
              options: const [(0, '允许'), (1, '禁止'), (2, '仅提醒')],
              onChanged: (value) => setState(() => _outboundDecision = value),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _ChoiceRow<int>(
              label: '拣货',
              value: _pickingDecision,
              options: const [(0, '允许'), (1, '禁止'), (2, '仅提醒')],
              onChanged: (value) => setState(() => _pickingDecision = value),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _ChoiceRow<int>(
              label: '打包复核',
              value: _reviewDecision,
              options: const [(0, '允许'), (1, '禁止'), (2, '仅提醒')],
              onChanged: (value) => setState(() => _reviewDecision = value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _packingSections() {
    return [
      _EditorSection(
        title: '规则设置',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SwitchSetting(
              label: '商品校验',
              description: '开启后复核装箱页面将显示商品条码扫描框。',
              value: _toggle('packing_barcode'),
              onChanged: (value) => _setToggle('packing_barcode', value),
            ),
            _SwitchSetting(
              label: '开启包材',
              description: '开启后复核装箱页面将显示出库包材扫描框。',
              value: _toggle('packing_material'),
              onChanged: (value) => _setToggle('packing_material', value),
            ),
            _SwitchSetting(
              label: '开启多包材',
              description: '开启后复核装箱页面可扫描多个包材。',
              value: _toggle('packing_multi_material'),
              onChanged: (value) => _setToggle('packing_multi_material', value),
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ChoiceRow<int>(
              label: '装箱模式',
              value: _packingMode,
              options: const [
                (0, '未开启'),
                (1, '一品一箱'),
                (2, '多品一箱'),
                (3, '多单一箱'),
              ],
              onChanged: (value) => setState(() => _packingMode = value),
            ),
            const SizedBox(height: RuQiSpacing.md),
            Text(
              '打印单据',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Wrap(
              spacing: RuQiSpacing.lg,
              runSpacing: RuQiSpacing.xs,
              children: [
                for (final entry in const [
                  ('print_shipping', '打印物流面单'),
                  ('print_outbound', '打印出库清单'),
                  ('print_picking', '打印装箱清单'),
                  ('print_box_label', '打印箱标签'),
                  ('print_box_number', '打印箱号'),
                ])
                  SizedBox(
                    width: 190,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(entry.$2),
                      value: _toggle(entry.$1),
                      onChanged: (value) =>
                          _setToggle(entry.$1, value ?? false),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: RuQiSpacing.md),
            Text(
              '打印模板设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Container(
              padding: const EdgeInsets.all(RuQiSpacing.lg),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('暂未关联打印模板')),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _boxRecommendationSections() {
    return [
      _EditorSection(
        title: '规则动作设置',
        child: _ResponsiveFieldGrid(
          columns: 3,
          children: [
            _DropdownField(
              label: '容器类型',
              value: _containerType,
              options: const ['纸箱', '周转箱', '快递袋'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _containerType = value);
                }
              },
            ),
            TextFormField(
              controller: _text('container_code'),
              decoration: const InputDecoration(labelText: '容器编号'),
            ),
            TextFormField(
              controller: _text('container_volume'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '容器体积'),
            ),
            TextFormField(
              controller: _text('container_length'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '容器长'),
            ),
            TextFormField(
              controller: _text('container_width'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '容器宽'),
            ),
            TextFormField(
              controller: _text('container_height'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '容器高'),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _crossDockingSections() {
    return [
      _EditorSection(
        title: '规则动作设置',
        caption: '开启后，越库计划匹配预到货单数据时增加对应字段匹配。',
        child: Column(
          children: [
            _SwitchSetting(
              label: '按批次号匹配',
              value: _toggle('cross_batch'),
              onChanged: (value) => _setToggle('cross_batch', value),
            ),
            _SwitchSetting(
              label: '按项目号匹配',
              value: _toggle('cross_project'),
              onChanged: (value) => _setToggle('cross_project', value),
            ),
            _SwitchSetting(
              label: '按生产日期匹配',
              value: _toggle('cross_production_date'),
              onChanged: (value) => _setToggle('cross_production_date', value),
            ),
            _SwitchSetting(
              label: '按托盘号匹配',
              value: _toggle('cross_pallet'),
              onChanged: (value) => _setToggle('cross_pallet', value),
            ),
            _SwitchSetting(
              label: '按箱号匹配',
              value: _toggle('cross_container'),
              onChanged: (value) => _setToggle('cross_container', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _outboundOrderSections() {
    return [
      _EditorSection(
        title: '规则执行',
        child: Column(
          children: [
            _SwitchSetting(
              label: '订单部分分配时取消占位',
              value: _toggle('order_partial_release'),
              onChanged: (value) => _setToggle('order_partial_release', value),
            ),
            _SwitchSetting(
              label: '明细部分分配时取消占位',
              value: _toggle('line_partial_release'),
              onChanged: (value) => _setToggle('line_partial_release', value),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _otherSection() {
    return [
      _EditorSection(
        title: '其他信息',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _note,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ResponsiveFieldGrid(
              columns: 3,
              children: [
                TextFormField(
                  initialValue: widget.rule?.creator ?? '创建后自动写入',
                  enabled: false,
                  decoration: const InputDecoration(labelText: '创建人'),
                ),
                TextFormField(
                  initialValue: widget.rule?.createdAt ?? '创建后自动写入',
                  enabled: false,
                  decoration: const InputDecoration(labelText: '创建时间'),
                ),
                TextFormField(
                  initialValue: widget.rule?.updatedAt ?? '创建后自动写入',
                  enabled: false,
                  decoration: const InputDecoration(labelText: '修改时间'),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  void _setToggle(String key, bool value) {
    setState(() => _toggles[key] = value);
  }

  void _showLocalHint(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    widget.onSaved(
      WmsRuleDraft(
        name: _name.text.trim(),
        warehouse: _warehouse,
        owner: _owner,
        priority: int.tryParse(_priority.text.trim()) ?? 0,
        status: _status,
        isDefault: _isDefault,
        description: _description.text.trim(),
        note: _note.text.trim(),
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({
    required this.title,
    required this.child,
    this.caption,
  });

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: RuQiSpacing.xs),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: RuQiSpacing.sm),
            Expanded(
              child: Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: RuQiSpacing.xs),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: RuQiSpacing.md),
        child,
      ],
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.children, this.columns});

  final List<Widget> children;
  final int? columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedColumns =
            columns ?? (constraints.maxWidth >= 760 ? 3 : 2);
        final columnCount = math.max(
          1,
          math.min(resolvedColumns, children.length),
        );
        const gap = RuQiSpacing.md;
        final width =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : options.first,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final optionWidgets = [
          for (final option in options) _neutralChoice(option, context),
        ];
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: RuQiSpacing.xs),
              Wrap(spacing: RuQiSpacing.xs, children: optionWidgets),
            ],
          );
        }
        return Row(
          children: [
            SizedBox(width: 120, child: Text(label)),
            Expanded(
              child: Wrap(
                spacing: RuQiSpacing.xs,
                runSpacing: RuQiSpacing.xs,
                children: optionWidgets,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _neutralChoice((T, String) option, BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == option.$1;
    return ChoiceChip(
      label: Text(option.$2),
      selected: selected,
      showCheckmark: false,
      selectedColor: theme.colorScheme.surfaceContainerHigh,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: selected
            ? theme.colorScheme.outline
            : theme.colorScheme.outlineVariant,
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      onSelected: (_) => onChanged(option.$1),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.trailing,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: RuQiSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                if (description != null)
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: RuQiSpacing.sm),
          ],
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CheckSetting extends StatelessWidget {
  const _CheckSetting({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
    );
  }
}

class _BuilderRows extends StatelessWidget {
  const _BuilderRows({
    required this.rows,
    required this.fields,
    required this.operators,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_BuilderRowModel> rows;
  final List<String> fields;
  final List<String> operators;
  final VoidCallback onChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          Row(
            key: ObjectKey(rows[index]),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    index == 0 ? '当' : '且',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.drag_indicator,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RuQiSpacing.xs),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  initialValue: fields.contains(rows[index].field)
                      ? rows[index].field
                      : fields.first,
                  isDense: true,
                  isExpanded: true,
                  items: [
                    for (final field in fields)
                      DropdownMenuItem(value: field, child: Text(field)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      rows[index].field = value;
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: RuQiSpacing.xs),
              SizedBox(
                width: 108,
                child: DropdownButtonFormField<String>(
                  initialValue: rows[index].operator,
                  isDense: true,
                  isExpanded: true,
                  items: [
                    for (final operator in operators)
                      DropdownMenuItem(value: operator, child: Text(operator)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      rows[index].operator = value;
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: RuQiSpacing.xs),
              Expanded(
                child: TextField(
                  controller: rows[index].value,
                  decoration: const InputDecoration(
                    hintText: '请输入或选择值',
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                tooltip: '删除条件',
                onPressed: rows.length == 1 ? null : () => onRemove(index),
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
            ],
          ),
          if (index != rows.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 1,
                  height: 12,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
        ],
        const SizedBox(height: RuQiSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            style: RuQiButtonStyles.link(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加条件'),
          ),
        ),
      ],
    );
  }
}

class _BuilderRowModel {
  _BuilderRowModel(this.field, this.operator, String value)
    : value = TextEditingController(text: value);

  String field;
  String operator;
  final TextEditingController value;

  void dispose() => value.dispose();
}
