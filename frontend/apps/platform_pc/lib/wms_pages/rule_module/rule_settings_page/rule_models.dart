/// 规则设置页的展示方式。
enum WmsRuleDisplayMode { cards, table }

/// 不同规则类型使用的编辑表单差异。
enum WmsEditorKind {
  conditionAction,
  coding,
  assignment,
  serialParsing,
  qualityCheck,
  receiveVerification,
  advanceReceipt,
  purchaseSuggestion,
  restock,
  inventoryCheck,
  inventoryDifference,
  randomInventory,
  outboundWave,
  outboundVerification,
  packing,
  boxRecommendation,
  crossDocking,
  outboundOrder,
}

enum WmsRuleStatus { enabled, disabled, testing }

extension WmsRuleStatusLabel on WmsRuleStatus {
  String get label => switch (this) {
    WmsRuleStatus.enabled => '启用',
    WmsRuleStatus.disabled => '停用',
    WmsRuleStatus.testing => '测试中',
  };
}

/// 单条 WMS 规则。当前页面使用本地状态模拟配置，后续接接口时可直接复用字段。
class WmsRule {
  const WmsRule({
    required this.ruleId,
    required this.name,
    required this.typeLabel,
    required this.typeCode,
    required this.shortLabel,
    required this.warehouse,
    required this.owner,
    required this.priority,
    required this.status,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    this.businessGroup = '未分类',
    this.isDefault = false,
    this.description = '',
    this.note = '',
  });

  final String ruleId;
  final String name;
  final String typeLabel;
  final String typeCode;
  final String shortLabel;
  final String warehouse;
  final String owner;
  final int priority;
  final WmsRuleStatus status;
  final bool isDefault;
  final String creator;
  final String createdAt;
  final String updatedAt;
  final String businessGroup;
  final String description;
  final String note;

  WmsRule copyWith({
    String? ruleId,
    String? name,
    String? typeLabel,
    String? typeCode,
    String? shortLabel,
    String? warehouse,
    String? owner,
    int? priority,
    WmsRuleStatus? status,
    bool? isDefault,
    String? creator,
    String? createdAt,
    String? updatedAt,
    String? businessGroup,
    String? description,
    String? note,
  }) {
    final dynamic currentGroup = this.businessGroup;
    return WmsRule(
      ruleId: ruleId ?? this.ruleId,
      name: name ?? this.name,
      typeLabel: typeLabel ?? this.typeLabel,
      typeCode: typeCode ?? this.typeCode,
      shortLabel: shortLabel ?? this.shortLabel,
      warehouse: warehouse ?? this.warehouse,
      owner: owner ?? this.owner,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      creator: creator ?? this.creator,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessGroup:
          businessGroup ??
          (currentGroup is String && currentGroup.trim().isNotEmpty
              ? currentGroup
              : '未分类'),
      description: description ?? this.description,
      note: note ?? this.note,
    );
  }
}

/// 规则编辑弹层保存的基础字段。
class WmsRuleDraft {
  const WmsRuleDraft({
    required this.name,
    required this.warehouse,
    required this.owner,
    required this.priority,
    required this.status,
    required this.isDefault,
    required this.description,
    required this.note,
  });

  final String name;
  final String warehouse;
  final String owner;
  final int priority;
  final WmsRuleStatus status;
  final bool isDefault;
  final String description;
  final String note;
}

class WmsRulePageDefinition {
  const WmsRulePageDefinition({
    required this.id,
    required this.categoryId,
    required this.categoryLabel,
    required this.label,
    required this.description,
    required this.editorKind,
    this.displayMode = WmsRuleDisplayMode.cards,
    this.initialRules = const [],
  });

  final String id;
  final String categoryId;
  final String categoryLabel;
  final String label;
  final String description;
  final WmsEditorKind editorKind;
  final WmsRuleDisplayMode displayMode;
  final List<WmsRule> initialRules;
}

class WmsRuleCategory {
  const WmsRuleCategory({
    required this.id,
    required this.label,
    required this.pageIds,
  });

  final String id;
  final String label;
  final List<String> pageIds;

  List<WmsRulePageDefinition> get pages => [
    for (final pageId in pageIds) wmsRulePageById(pageId),
  ];
}

const _commonWarehouse = '全部';
const _commonOwner = '全部';
const _commonCreator = '超级管理员';

const _codingDocumentSeeds = <({String id, String name, String group})>[
  (id: '6001', name: '供应商合同编码规则', group: '基础信息'),
  (id: '6002', name: '发货人编码规则', group: '基础信息'),
  (id: '6003', name: '收货人编码格式', group: '基础信息'),
  (id: '6004', name: '发货人单据规则', group: '基础信息'),
  (id: '6005', name: '供应商信息', group: '基础信息'),
  (id: '6006', name: '商品基础信息', group: '基础信息'),
  (id: '6623', name: '快递管理', group: '基础信息'),
  (id: '6007', name: '拍号号码编码规则', group: '基础信息'),
  (id: '6008', name: '货主信息', group: '基础信息'),
  (id: '6009', name: '提货单位', group: '基础信息'),
  (id: '6010', name: '仓库编码规则', group: '基础信息'),
  (id: '6011', name: '货主合同编码规则', group: '基础信息'),
  (id: '6012', name: '区域管理', group: '基础信息'),
  (id: '6013', name: '消息模板设置', group: '基础信息'),
  (id: '6014', name: '码头管理', group: '基础信息'),
  (id: '6015', name: '设备基础信息', group: '基础信息'),
  (id: '6016', name: '客户合同管理', group: '基础信息'),
  (id: '6101', name: '采购收货单编码', group: '收货管理'),
  (id: '6102', name: '预到货单编码', group: '收货管理'),
  (id: '6103', name: '质检单编码', group: '收货管理'),
  (id: '6104', name: '上架单编码', group: '收货管理'),
  (id: '6201', name: '销售出库单编码', group: '出库管理'),
  (id: '6202', name: '波次号编码', group: '出库管理'),
  (id: '6203', name: '拣货任务编码', group: '出库管理'),
  (id: '6204', name: '复核装箱单编码', group: '出库管理'),
  (id: '6301', name: '盘点单编码', group: '库存管理'),
  (id: '6302', name: '补货单编码', group: '库存管理'),
  (id: '6303', name: '移库单编码', group: '库存管理'),
  (id: '6401', name: '快递单编码', group: '快递物流'),
  (id: '6402', name: '装箱单编码', group: '快递物流'),
  (id: '6501', name: '应收单编码', group: '财务管理'),
  (id: '6502', name: '应付单编码', group: '财务管理'),
  (id: '6601', name: 'ERP采购订单号', group: 'ERP'),
  (id: '6602', name: 'ERP发货单号', group: 'ERP'),
  (id: '6701', name: '生产工单号', group: 'MES'),
  (id: '6801', name: 'APP预约单号', group: 'APP'),
];

List<WmsRule> _buildCodingRules() {
  return [
    for (final seed in _codingDocumentSeeds)
      WmsRule(
        ruleId: seed.id,
        name: seed.name,
        typeLabel: '单据编码规则',
        typeCode: 'DOCUMENT_CODING_RULE',
        shortLabel: '编码',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 0,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:36:26',
        updatedAt: seed.id == '6623'
            ? '2026-05-21 12:27:42'
            : '2026-05-21 10:36:26',
        businessGroup: seed.group,
        description: '${seed.name}的编码配置。',
      ),
  ];
}

final wmsRulePages = <WmsRulePageDefinition>[
  WmsRulePageDefinition(
    id: 'coding',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '单据编码',
    description: '维护各业务单据的编码格式、流水号字符集与模块绑定关系。',
    editorKind: WmsEditorKind.coding,
    displayMode: WmsRuleDisplayMode.table,
    initialRules: _buildCodingRules(),
  ),
  WmsRulePageDefinition(
    id: 'wave_picker',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '波次拣货人分配',
    description: '按仓库、库区和任务量，为波次自动分配拣货人员。',
    editorKind: WmsEditorKind.assignment,
    displayMode: WmsRuleDisplayMode.table,
    initialRules: [
      WmsRule(
        ruleId: '101',
        name: '指定人员拣货规则',
        typeLabel: '最少任务优先',
        typeCode: 'WAVE_PICKER_ALLOCATION_RULE',
        shortLabel: '拣货',
        warehouse: 'Delzoa Accra',
        owner: '全部',
        priority: 0,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-10-21 10:38:14',
        updatedAt: '2026-10-21 10:38:14',
        description: '优先分配当前任务量最少的拣货员。',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'task_operator',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '出库任务操作人',
    description: '配置出库任务的执行人员分配方式与生效条件。',
    editorKind: WmsEditorKind.assignment,
    displayMode: WmsRuleDisplayMode.table,
    initialRules: [
      WmsRule(
        ruleId: '102',
        name: '出库任务操作人规则',
        typeLabel: '随机分配',
        typeCode: 'OUTBOUND_OPERATOR_RULE',
        shortLabel: '操作',
        warehouse: 'Delzoa Accra',
        owner: '全部',
        priority: 0,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-10-21 10:39:53',
        updatedAt: '2026-10-21 10:39:53',
        description: '在可用操作人中随机分配出库任务。',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'exact_fields',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '搜索精确匹配字段',
    description: '配置业务搜索中优先执行的精确匹配字段。',
    editorKind: WmsEditorKind.conditionAction,
  ),
  WmsRulePageDefinition(
    id: 'serial_parser',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '序列号解析',
    description: '按商品属性与条码格式解析序列号中的关键信息。',
    editorKind: WmsEditorKind.serialParsing,
  ),
  WmsRulePageDefinition(
    id: 'constraint',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '约束设置',
    description: '为入库、出库等业务流程设置必须满足的前置约束。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '117',
        name: '约束设置',
        typeLabel: '约束规则',
        typeCode: 'CONSTRAINT_CONFIG',
        shortLabel: '约束',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:36:26',
        updatedAt: '2026-05-21 12:27:42',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'taboo',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '智能禁忌',
    description: '配置商品、货位和批次之间需要规避的组合。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '118',
        name: '智能禁忌设置',
        typeLabel: '禁忌规则',
        typeCode: 'SMART_FORBIDDEN_RULE',
        shortLabel: '智能',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:38:40',
        updatedAt: '2026-05-21 12:27:57',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'analysis',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '智能分析',
    description: '基于商品属性和业务条件生成智能分析动作。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '119',
        name: '智能分析规则',
        typeLabel: '分析规则',
        typeCode: 'SMART_ANALYSIS_RULE',
        shortLabel: '智能',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:40:26',
        updatedAt: '2026-05-21 12:28:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'external_erp',
    categoryId: 'basic',
    categoryLabel: '基础规则',
    label: '外部ERP',
    description: '维护与外部 ERP 系统之间的字段映射和同步约束。',
    editorKind: WmsEditorKind.conditionAction,
  ),
  WmsRulePageDefinition(
    id: 'slot_recommend',
    categoryId: 'inbound',
    categoryLabel: '入库规则',
    label: '货位推荐',
    description: '根据商品体积、库存与仓库属性推荐入库货位。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '107',
        name: '货位推荐规则',
        typeLabel: 'POSITION_RECOMMEND',
        typeCode: 'POSITION_RECOMMEND',
        shortLabel: '货位',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:19:55',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'quality_check',
    categoryId: 'inbound',
    categoryLabel: '入库规则',
    label: '质检',
    description: '定义入库商品的质检触发条件、方式与抽检比例。',
    editorKind: WmsEditorKind.qualityCheck,
    initialRules: [
      WmsRule(
        ruleId: '105',
        name: '入库质检',
        typeLabel: '质检规则',
        typeCode: 'IN_QUALITY_CHECK',
        shortLabel: '入库',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:15:51',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'receive_verify',
    categoryId: 'inbound',
    categoryLabel: '入库规则',
    label: '收货验证',
    description: '配置收货数量、重量与生产日期的校验策略。',
    editorKind: WmsEditorKind.receiveVerification,
    initialRules: [
      WmsRule(
        ruleId: '106',
        name: '收货验证',
        typeLabel: '收货验证规则',
        typeCode: 'IN_RECEIVE_VERIFY',
        shortLabel: '收货',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:17:38',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'advance_receipt',
    categoryId: 'inbound',
    categoryLabel: '入库规则',
    label: '预到货单',
    description: '控制预到货单生成批次、上架单和托盘数据的执行方式。',
    editorKind: WmsEditorKind.advanceReceipt,
    initialRules: [
      WmsRule(
        ruleId: '108',
        name: '预到货规则',
        typeLabel: '预到货单规则',
        typeCode: 'IN_RECEIVE_CONFIG',
        shortLabel: '预到',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:20:42',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'purchase_suggestion',
    categoryId: 'inbound',
    categoryLabel: '入库规则',
    label: '采购建议',
    description: '依据销量、库存与在途数据计算采购建议量。',
    editorKind: WmsEditorKind.purchaseSuggestion,
    displayMode: WmsRuleDisplayMode.table,
  ),
  WmsRulePageDefinition(
    id: 'restock',
    categoryId: 'inventory',
    categoryLabel: '库内操作',
    label: '补货',
    description: '根据库存下限和整箱数量自动生成补货任务。',
    editorKind: WmsEditorKind.restock,
    initialRules: [
      WmsRule(
        ruleId: '113',
        name: '补货规则',
        typeLabel: '补货规则',
        typeCode: 'INVENTORY_RESTOCK_CONFIG',
        shortLabel: '补货',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:30:36',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'inventory_check',
    categoryId: 'inventory',
    categoryLabel: '库内操作',
    label: '盘点',
    description: '配置盘点范围、冻结库存和差异复盘的执行策略。',
    editorKind: WmsEditorKind.inventoryCheck,
    initialRules: [
      WmsRule(
        ruleId: '114',
        name: '盘点规则',
        typeLabel: '盘点规则',
        typeCode: 'INVENTORY_CHECK_CONFIG',
        shortLabel: '盘点',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:31:46',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'inventory_difference',
    categoryId: 'inventory',
    categoryLabel: '库内操作',
    label: '盘点差异',
    description: '定义盘点差异按库存、批次和盘盈盘亏的处理方式。',
    editorKind: WmsEditorKind.inventoryDifference,
    initialRules: [
      WmsRule(
        ruleId: '115',
        name: '盘点差异规则',
        typeLabel: '盘点差异规则',
        typeCode: 'INVENTORY_CHECK_DIFF_CONFIG',
        shortLabel: '盘点',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:32:24',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'random_inventory',
    categoryId: 'inventory',
    categoryLabel: '库内操作',
    label: '随机盘点',
    description: '按库区、商品数量与随机维度生成随机盘点任务。',
    editorKind: WmsEditorKind.randomInventory,
    initialRules: [
      WmsRule(
        ruleId: '116',
        name: '随机盘点规则',
        typeLabel: '随机盘点规则',
        typeCode: 'INVENTORY_RANDOM_CHECK_CONFIG',
        shortLabel: '随机',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:33:40',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'outbound_allocation',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '出库分配',
    description: '按出库单类型、商品范围与库区优先级分配库存。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '122',
        name: '出库全局规则',
        typeLabel: '出库分配规则',
        typeCode: 'OUT_ALLOCATION_CONFIG',
        shortLabel: '出库',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 5,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-06-01 15:15:50',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'outbound_wave',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '波次生成',
    description: '配置订单合并、生成时段与波次拣货人分配方式。',
    editorKind: WmsEditorKind.outboundWave,
    initialRules: [
      WmsRule(
        ruleId: '103',
        name: 'tos01',
        typeLabel: '波次策略',
        typeCode: 'OUT_WAVE_STRATEGY_CONFIG',
        shortLabel: 'TO',
        warehouse: 'Delzoa Accra',
        owner: _commonOwner,
        priority: 0,
        status: WmsRuleStatus.disabled,
        creator: 'TTT',
        createdAt: '2026-05-06 16:11:10',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'outbound_verify',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '出库验证',
    description: '控制出库、拣货和打包复核环节的放行策略。',
    editorKind: WmsEditorKind.outboundVerification,
    initialRules: [
      WmsRule(
        ruleId: '110',
        name: '出库验证规则',
        typeLabel: '出库验证规则',
        typeCode: 'OUT_VERIFY_CONFIG',
        shortLabel: '出库',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:24:38',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'packing',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '复核装箱',
    description: '配置复核装箱校验、装箱模式与打印模板。',
    editorKind: WmsEditorKind.packing,
    initialRules: [
      WmsRule(
        ruleId: '111',
        name: '复合装箱规则',
        typeLabel: '复核装箱规则',
        typeCode: 'OUT_STOCKING_CONFIG',
        shortLabel: '复合',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:26:52',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'box_recommend',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '箱型推荐',
    description: '根据订单商品和容器尺寸推荐出库箱型。',
    editorKind: WmsEditorKind.boxRecommendation,
    initialRules: [
      WmsRule(
        ruleId: '112',
        name: '箱型推荐规则',
        typeLabel: '箱型推荐规则',
        typeCode: 'OUT_CONTAINER_RECOMMEND',
        shortLabel: '箱形',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-05-21 10:28:30',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
  WmsRulePageDefinition(
    id: 'cross_dock',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '越库匹配',
    description: '配置越库计划与预到货单数据之间的匹配字段。',
    editorKind: WmsEditorKind.crossDocking,
  ),
  WmsRulePageDefinition(
    id: 'outbound_order',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '出库单',
    description: '定义出库单来源范围与部分分配时的占位处理。',
    editorKind: WmsEditorKind.outboundOrder,
  ),
  WmsRulePageDefinition(
    id: 'slot_match',
    categoryId: 'outbound',
    categoryLabel: '出库规则',
    label: '配货位匹配',
    description: '按照货位状态和播种墙推荐配货位。',
    editorKind: WmsEditorKind.conditionAction,
    initialRules: [
      WmsRule(
        ruleId: '126',
        name: '兜底规则',
        typeLabel: 'SOW_SLOT_MATCH_RULE',
        typeCode: 'SOW_SLOT_MATCH_RULE',
        shortLabel: '兜底',
        warehouse: _commonWarehouse,
        owner: _commonOwner,
        priority: 1,
        status: WmsRuleStatus.enabled,
        creator: _commonCreator,
        createdAt: '2026-07-21 14:29:05',
        updatedAt: '2026-07-31 15:02:15',
      ),
    ],
  ),
];

const wmsRuleCategories = <WmsRuleCategory>[
  WmsRuleCategory(
    id: 'basic',
    label: '基础规则',
    pageIds: [
      'coding',
      'wave_picker',
      'task_operator',
      'exact_fields',
      'serial_parser',
      'constraint',
      'taboo',
      'analysis',
      'external_erp',
    ],
  ),
  WmsRuleCategory(
    id: 'inbound',
    label: '入库规则',
    pageIds: [
      'slot_recommend',
      'quality_check',
      'receive_verify',
      'advance_receipt',
      'purchase_suggestion',
    ],
  ),
  WmsRuleCategory(
    id: 'inventory',
    label: '库内操作',
    pageIds: [
      'restock',
      'inventory_check',
      'inventory_difference',
      'random_inventory',
    ],
  ),
  WmsRuleCategory(
    id: 'outbound',
    label: '出库规则',
    pageIds: [
      'outbound_allocation',
      'outbound_wave',
      'outbound_verify',
      'packing',
      'box_recommend',
      'cross_dock',
      'outbound_order',
      'slot_match',
    ],
  ),
];

WmsRulePageDefinition wmsRulePageById(String id) {
  return wmsRulePages.firstWhere((page) => page.id == id);
}
