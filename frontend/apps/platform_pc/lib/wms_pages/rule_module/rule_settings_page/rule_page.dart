import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../../admin_pages/shared/status_badge.dart';
import '../../../admin_pages/shared/table_card.dart';
import 'coding_rules_page.dart';
import 'rule_editor_view.dart';
import 'rule_models.dart';

class WmsRulePage extends StatefulWidget {
  const WmsRulePage({
    super.key,
    required this.page,
    required this.rules,
    required this.onRulesChanged,
    required this.onNotify,
    this.codingGroups = const [],
    this.onCodingGroupsChanged,
  });

  final WmsRulePageDefinition page;
  final List<WmsRule> rules;
  final ValueChanged<List<WmsRule>> onRulesChanged;
  final ValueChanged<String> onNotify;
  final List<String> codingGroups;
  final ValueChanged<List<String>>? onCodingGroupsChanged;

  @override
  State<WmsRulePage> createState() => _WmsRulePageState();
}

class _WmsRulePageState extends State<WmsRulePage> {
  String _query = '';
  String _warehouseFilter = '全部';
  WmsRuleStatus? _statusFilter;
  final Set<String> _selected = {};
  bool _showEditor = false;
  WmsRule? _editingRule;

  List<WmsRule> get _visibleRules {
    final query = _query.trim().toLowerCase();
    return widget.rules.where((rule) {
      final matchesQuery =
          query.isEmpty ||
          rule.name.toLowerCase().contains(query) ||
          rule.typeLabel.toLowerCase().contains(query) ||
          rule.warehouse.toLowerCase().contains(query) ||
          rule.creator.toLowerCase().contains(query);
      final matchesWarehouse =
          _warehouseFilter == '全部' || rule.warehouse == _warehouseFilter;
      final matchesStatus =
          _statusFilter == null || rule.status == _statusFilter;
      return matchesQuery && matchesWarehouse && matchesStatus;
    }).toList();
  }

  @override
  void didUpdateWidget(covariant WmsRulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id) {
      _query = '';
      _warehouseFilter = '全部';
      _statusFilter = null;
      _selected.clear();
      _showEditor = false;
      _editingRule = null;
      return;
    }
    final ids = widget.rules.map((rule) => rule.ruleId).toSet();
    _selected.removeWhere((id) => !ids.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.page.id == 'coding') {
      return WmsCodingRulesPage(
        rules: widget.rules,
        customGroups: widget.codingGroups,
        onCustomGroupsChanged: widget.onCodingGroupsChanged,
        onRulesChanged: widget.onRulesChanged,
        onNotify: widget.onNotify,
      );
    }
    if (_showEditor) {
      return WmsRuleEditorView(
        key: ValueKey('${widget.page.id}-${_editingRule?.ruleId ?? 'new'}'),
        page: widget.page,
        rule: _editingRule,
        onCancel: _closeEditor,
        onSaved: _saveRule,
      );
    }
    final theme = Theme.of(context);
    final visibleRules = _visibleRules;
    final hasRules = widget.rules.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '规则设置 / ${widget.page.categoryLabel} / ${widget.page.label}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        Text(
          widget.page.label,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          widget.page.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        _toolbar(context),
        const SizedBox(height: RuQiSpacing.md),
        if (!hasRules)
          _emptyState(context, filtered: false)
        else if (visibleRules.isEmpty)
          _emptyState(context, filtered: true)
        else if (widget.page.displayMode == WmsRuleDisplayMode.table)
          _table(context, visibleRules)
        else
          _cards(context, visibleRules),
        if (hasRules) ...[
          const SizedBox(height: RuQiSpacing.md),
          Row(
            children: [
              Text(
                '全选',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '1/1 共 ${visibleRules.length} 项',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _toolbar(BuildContext context) {
    final visibleRules = _visibleRules;
    final allSelected =
        visibleRules.isNotEmpty &&
        visibleRules.every((rule) => _selected.contains(rule.ruleId));
    final selectedVisibleCount = visibleRules
        .where((rule) => _selected.contains(rule.ruleId))
        .length;
    final anyFilter =
        _query.trim().isNotEmpty ||
        _warehouseFilter != '全部' ||
        _statusFilter != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bulk = <Widget>[
          Checkbox(
            value: allSelected,
            onChanged: visibleRules.isEmpty
                ? null
                : (checked) {
                    setState(() {
                      if (checked == true) {
                        _selected.addAll(
                          visibleRules.map((rule) => rule.ruleId),
                        );
                      } else {
                        _selected.clear();
                      }
                    });
                  },
          ),
          Text('全选', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: RuQiSpacing.sm),
          FilledButton.icon(
            onPressed: _openEditor,
            style: RuQiButtonStyles.primary(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新建'),
          ),
          const SizedBox(width: RuQiSpacing.xs),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _query = '';
                _warehouseFilter = '全部';
                _statusFilter = null;
              });
              widget.onNotify('已刷新规则列表');
            },
            style: RuQiButtonStyles.secondary(context),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新'),
          ),
          const SizedBox(width: RuQiSpacing.xs),
          OutlinedButton.icon(
            onPressed: _selected.isEmpty
                ? null
                : () => _deleteSelected(context),
            style: RuQiButtonStyles.secondary(context),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(
              selectedVisibleCount > 0 ? '删除 ($selectedVisibleCount)' : '删除',
            ),
          ),
        ];
        final filters = <Widget>[
          SizedBox(
            width: constraints.maxWidth < 760 ? constraints.maxWidth : 260,
            child: RuQiSearchField(
              hintText: '通过关键字搜索',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _query = '';
                _warehouseFilter = '全部';
                _statusFilter = null;
              });
            },
            style: RuQiButtonStyles.secondary(context),
            child: const Text('重置'),
          ),
          OutlinedButton.icon(
            onPressed: () => _openAdvancedFilter(context),
            style: RuQiButtonStyles.secondary(context),
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('高级筛选'),
          ),
          if (anyFilter)
            TextButton(
              onPressed: () {
                setState(() {
                  _query = '';
                  _warehouseFilter = '全部';
                  _statusFilter = null;
                });
              },
              style: RuQiButtonStyles.link(context),
              child: const Text('清除筛选'),
            ),
        ];

        if (constraints.maxWidth >= 1040) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...bulk,
              const Spacer(),
              for (var i = 0; i < filters.length; i++) ...[
                if (i > 0) const SizedBox(width: RuQiSpacing.xs),
                filters[i],
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: RuQiSpacing.xs,
              runSpacing: RuQiSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: bulk,
            ),
            const SizedBox(height: RuQiSpacing.sm),
            Wrap(
              spacing: RuQiSpacing.xs,
              runSpacing: RuQiSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: filters,
            ),
          ],
        );
      },
    );
  }

  Widget _cards(BuildContext context, List<WmsRule> rules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = RuQiSpacing.md;
        final columns = math.max(
          1,
          math.min(4, ((constraints.maxWidth + gap) / (400 + gap)).floor()),
        );
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final rule in rules)
              SizedBox(
                width: width,
                child: _RuleCard(
                  rule: rule,
                  selected: _selected.contains(rule.ruleId),
                  tone: _toneForPage(context),
                  onSelected: (checked) {
                    setState(() {
                      if (checked) {
                        _selected.add(rule.ruleId);
                      } else {
                        _selected.remove(rule.ruleId);
                      }
                    });
                  },
                  onEdit: () => _openEditor(rule: rule),
                  onEnable: () => _setStatus(rule, WmsRuleStatus.enabled),
                  onDisable: () => _setStatus(rule, WmsRuleStatus.disabled),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _table(BuildContext context, List<WmsRule> rules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, 1120),
            child: TableCard(
              rowCount: rules.length,
              columns: const [
                (label: '', flex: 4),
                (label: '规则名称', flex: 20),
                (label: '规则类型', flex: 14),
                (label: '仓库', flex: 14),
                (label: '优先级', flex: 8),
                (label: '状态', flex: 8),
                (label: '默认规则', flex: 8),
                (label: '创建人', flex: 10),
                (label: '创建时间', flex: 14),
                (label: '操作', flex: 14),
              ],
              rowBuilder: (context, index) {
                final rule = rules[index];
                return [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      value: _selected.contains(rule.ruleId),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(rule.ruleId);
                          } else {
                            _selected.remove(rule.ruleId);
                          }
                        });
                      },
                    ),
                  ),
                  CellText(rule.name, strong: true),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _TypeBadge(label: rule.typeLabel),
                  ),
                  CellText(rule.warehouse, muted: true),
                  CellText('${rule.priority}'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _statusBadge(rule.status),
                  ),
                  CellText(rule.isDefault ? '是' : '否', muted: !rule.isDefault),
                  CellText(rule.creator, muted: true),
                  CellText(rule.createdAt, muted: true),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: RuQiSpacing.xxs,
                      children: [
                        TextButton(
                          onPressed: () => _openEditor(rule: rule),
                          style: RuQiButtonStyles.link(context),
                          child: const Text('编辑'),
                        ),
                        TextButton(
                          onPressed: () => _deleteRules([rule]),
                          style: RuQiButtonStyles.linkDanger(context),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context, {required bool filtered}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: RuQiSpacing.xxl),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off : Icons.rule_folder_outlined,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            filtered ? '没有匹配的规则' : '暂无规则配置',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: RuQiSpacing.xxs),
          Text(
            filtered ? '请调整搜索词或高级筛选条件。' : '新建一条规则后，将在这里展示。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!filtered) ...[
            const SizedBox(height: RuQiSpacing.md),
            FilledButton.icon(
              onPressed: _openEditor,
              style: RuQiButtonStyles.primary(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建规则'),
            ),
          ],
        ],
      ),
    );
  }

  Color _toneForPage(BuildContext context) {
    final ext = Theme.of(context).extension<RuQiThemeExtension>();
    return switch (widget.page.categoryId) {
      'basic' => ext?.info ?? Theme.of(context).colorScheme.primary,
      'inbound' => ext?.success ?? Theme.of(context).colorScheme.primary,
      'inventory' => ext?.warning ?? Theme.of(context).colorScheme.primary,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  Widget _statusBadge(WmsRuleStatus status) {
    return StatusBadge(
      label: status.label,
      tone: switch (status) {
        WmsRuleStatus.enabled => StatusTone.success,
        WmsRuleStatus.disabled => StatusTone.neutral,
        WmsRuleStatus.testing => StatusTone.warning,
      },
    );
  }

  void _openEditor({WmsRule? rule}) {
    setState(() {
      _editingRule = rule;
      _showEditor = true;
    });
  }

  void _closeEditor() {
    setState(() {
      _showEditor = false;
      _editingRule = null;
    });
  }

  void _saveRule(WmsRuleDraft draft) {
    final rule = _editingRule;
    final now = _formatNow();
    if (rule == null) {
      final created = WmsRule(
        ruleId: 'WMS-${DateTime.now().millisecondsSinceEpoch}',
        name: draft.name,
        typeLabel: widget.page.label,
        typeCode: _typeCodeForPage(widget.page),
        shortLabel: _shortLabel(draft.name, widget.page.label),
        warehouse: draft.warehouse,
        owner: draft.owner,
        priority: draft.priority,
        status: draft.status,
        isDefault: draft.isDefault,
        creator: '超级管理员',
        createdAt: now,
        updatedAt: now,
        description: draft.description,
        note: draft.note,
      );
      _closeEditor();
      widget.onRulesChanged([...widget.rules, created]);
      widget.onNotify('规则“${created.name}”已创建');
    } else {
      final updated = rule.copyWith(
        name: draft.name,
        warehouse: draft.warehouse,
        owner: draft.owner,
        priority: draft.priority,
        status: draft.status,
        isDefault: draft.isDefault,
        description: draft.description,
        note: draft.note,
        updatedAt: now,
      );
      _closeEditor();
      widget.onRulesChanged([
        for (final item in widget.rules)
          if (item.ruleId == updated.ruleId) updated else item,
      ]);
      widget.onNotify('规则“${updated.name}”已更新');
    }
  }

  void _setStatus(WmsRule rule, WmsRuleStatus status) {
    final updated = rule.copyWith(status: status, updatedAt: _formatNow());
    widget.onRulesChanged([
      for (final item in widget.rules)
        if (item.ruleId == updated.ruleId) updated else item,
    ]);
    widget.onNotify('规则“${updated.name}”已${status.label}');
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final rules = widget.rules
        .where((rule) => _selected.contains(rule.ruleId))
        .toList();
    await _deleteRules(rules);
  }

  Future<void> _deleteRules(List<WmsRule> rules) async {
    if (rules.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除规则'),
        content: Text('确定删除选中的 ${rules.length} 条规则吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: RuQiButtonStyles.tertiary(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: RuQiButtonStyles.danger(dialogContext),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final ids = rules.map((rule) => rule.ruleId).toSet();
    widget.onRulesChanged([
      for (final rule in widget.rules)
        if (!ids.contains(rule.ruleId)) rule,
    ]);
    setState(() => _selected.removeAll(ids));
    widget.onNotify('已删除 ${rules.length} 条规则');
  }

  Future<void> _openAdvancedFilter(BuildContext context) async {
    final result = await showDialog<(String, WmsRuleStatus?)>(
      context: context,
      builder: (_) => _AdvancedRuleFilterDialog(
        warehouse: _warehouseFilter,
        status: _statusFilter,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _warehouseFilter = result.$1;
      _statusFilter = result.$2;
    });
  }

  String _typeCodeForPage(WmsRulePageDefinition page) {
    return switch (page.editorKind) {
      WmsEditorKind.coding => 'DOCUMENT_CODING_RULE',
      WmsEditorKind.assignment => 'WMS_ASSIGNMENT_RULE',
      WmsEditorKind.qualityCheck => 'IN_QUALITY_CHECK',
      WmsEditorKind.receiveVerification => 'IN_RECEIVE_VERIFY',
      WmsEditorKind.advanceReceipt => 'IN_RECEIVE_CONFIG',
      WmsEditorKind.purchaseSuggestion => 'PURCHASE_SUGGEST_RULE',
      WmsEditorKind.restock => 'INVENTORY_RESTOCK_CONFIG',
      WmsEditorKind.inventoryCheck => 'INVENTORY_CHECK_CONFIG',
      WmsEditorKind.inventoryDifference => 'INVENTORY_CHECK_DIFF_CONFIG',
      WmsEditorKind.randomInventory => 'INVENTORY_RANDOM_CHECK_CONFIG',
      WmsEditorKind.outboundWave => 'OUT_WAVE_STRATEGY_CONFIG',
      WmsEditorKind.outboundVerification => 'OUT_VERIFY_CONFIG',
      WmsEditorKind.packing => 'OUT_STOCKING_CONFIG',
      WmsEditorKind.boxRecommendation => 'OUT_CONTAINER_RECOMMEND',
      WmsEditorKind.crossDocking => 'ORDER_MATCHING_RULE',
      WmsEditorKind.outboundOrder => 'OUT_ORDER_CONFIG',
      WmsEditorKind.conditionAction ||
      WmsEditorKind.serialParsing => 'WMS_RULE_CONFIG',
    };
  }

  String _shortLabel(String name, String fallback) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return fallback.characters.take(2).toString();
    }
    return trimmed.characters.take(2).toString();
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.selected,
    required this.tone,
    required this.onSelected,
    required this.onEdit,
    required this.onEnable,
    required this.onDisable,
  });

  final WmsRule rule;
  final bool selected;
  final Color tone;
  final ValueChanged<bool> onSelected;
  final VoidCallback onEdit;
  final VoidCallback onEnable;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.md,
              RuQiSpacing.md,
              RuQiSpacing.xs,
              RuQiSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    rule.shortLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: RuQiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StatusBadge(
                        label: rule.status.label,
                        tone: switch (rule.status) {
                          WmsRuleStatus.enabled => StatusTone.success,
                          WmsRuleStatus.disabled => StatusTone.neutral,
                          WmsRuleStatus.testing => StatusTone.warning,
                        },
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: selected,
                  onChanged: (checked) => onSelected(checked ?? false),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
            child: _InfoBlock(
              title: '基础信息',
              children: [
                _KeyValue(label: '仓库名称', value: rule.warehouse),
                _KeyValue(label: '货主名称', value: rule.owner),
                _KeyValue(label: '优先级', value: '${rule.priority}'),
                _KeyValue(label: '规则类型', value: rule.typeLabel),
              ],
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
            child: _InfoBlock(
              title: '其他信息',
              children: [
                _KeyValue(label: '创建人', value: rule.creator),
                _KeyValue(label: '规则 ID', value: rule.ruleId),
                _KeyValue(label: '创建时间', value: rule.createdAt),
                _KeyValue(label: '修改时间', value: rule.updatedAt),
                _KeyValue(
                  label: '备注',
                  value: rule.note.isEmpty ? '—' : rule.note,
                ),
              ],
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _CardAction(
                    label: '启用',
                    onPressed: rule.status == WmsRuleStatus.enabled
                        ? null
                        : onEnable,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _CardAction(
                    label: '停用',
                    onPressed: rule.status == WmsRuleStatus.disabled
                        ? null
                        : onDisable,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _CardAction(label: '编辑', onPressed: onEdit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RuQiSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: RuQiSpacing.xxs),
          Text(
            title == '基础信息' ? '规则摘要' : '审计信息',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: RuQiSpacing.xs),
          for (var index = 0; index < children.length; index += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: RuQiSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[index]),
                  const SizedBox(width: RuQiSpacing.sm),
                  if (index + 1 < children.length)
                    Expanded(child: children[index + 1])
                  else
                    const Spacer(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label：',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: RuQiButtonStyles.link(context),
      child: Text(label),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _AdvancedRuleFilterDialog extends StatefulWidget {
  const _AdvancedRuleFilterDialog({
    required this.warehouse,
    required this.status,
  });

  final String warehouse;
  final WmsRuleStatus? status;

  @override
  State<_AdvancedRuleFilterDialog> createState() =>
      _AdvancedRuleFilterDialogState();
}

class _AdvancedRuleFilterDialogState extends State<_AdvancedRuleFilterDialog> {
  late String _warehouse = widget.warehouse;
  late String _status = widget.status?.name ?? 'all';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('高级筛选'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _warehouse,
              decoration: const InputDecoration(labelText: '仓库'),
              items: const [
                DropdownMenuItem(value: '全部', child: Text('全部')),
                DropdownMenuItem(
                  value: 'Delzoa Accra',
                  child: Text('Delzoa Accra'),
                ),
                DropdownMenuItem(value: 'Accra 主仓', child: Text('Accra 主仓')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _warehouse = value);
                }
              },
            ),
            const SizedBox(height: RuQiSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: '状态'),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('全部状态')),
                for (final status in WmsRuleStatus.values)
                  DropdownMenuItem(
                    value: status.name,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: RuQiButtonStyles.tertiary(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((
            _warehouse,
            _status == 'all' ? null : WmsRuleStatus.values.byName(_status),
          )),
          style: RuQiButtonStyles.primary(context),
          child: const Text('应用筛选'),
        ),
      ],
    );
  }
}
