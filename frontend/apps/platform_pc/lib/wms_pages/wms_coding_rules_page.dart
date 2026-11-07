import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../admin_pages/shared/status_badge.dart';
import 'wms_rule_models.dart';

/// 单据编码规则专用页面：左侧维护大量业务单据，右侧编辑当前单据编码。
class WmsCodingRulesPage extends StatefulWidget {
  const WmsCodingRulesPage({
    super.key,
    required this.rules,
    required this.onRulesChanged,
    required this.onNotify,
  });

  final List<WmsRule> rules;
  final ValueChanged<List<WmsRule>> onRulesChanged;
  final ValueChanged<String> onNotify;

  @override
  State<WmsCodingRulesPage> createState() => _WmsCodingRulesPageState();
}

class _WmsCodingRulesPageState extends State<WmsCodingRulesPage> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _expandedGroups = {'基础信息'};

  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _description;
  late final TextEditingController _moduleId;
  late final TextEditingController _sort;
  late final TextEditingController _legacyConfig;

  String? _selectedId;
  String? _lastSelectedId;
  String _activeGroup = '基础信息';
  String _newRuleGroup = '基础信息';
  String _query = '';
  bool _isCreating = false;
  WmsRuleStatus _status = WmsRuleStatus.enabled;
  String _serialCharset = '[0-9] 仅数字';
  int _migrationMode = 0;

  static const _charsets = [
    '[0-9] 仅数字',
    '[A-Z] 仅大写字母',
    '[a-z] 仅小写字母',
    '[0-9A-Z] 数字 + 大写字母',
    '[0-9a-z] 数字 + 小写字母',
    '[0-9a-zA-Z] 数字 + 字母（常用）',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _code = TextEditingController();
    _description = TextEditingController();
    _moduleId = TextEditingController(text: '232');
    _sort = TextEditingController(text: '0');
    _legacyConfig = TextEditingController();
    if (widget.rules.isNotEmpty) {
      final initial = widget.rules.firstWhere(
        (rule) => rule.name == '快递管理',
        orElse: () => widget.rules.first,
      );
      _loadRule(initial);
    } else {
      _startCreate(group: '基础信息');
    }
  }

  @override
  void didUpdateWidget(covariant WmsCodingRulesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isCreating) {
      return;
    }
    final selected = _selectedRule;
    if (selected == null) {
      if (widget.rules.isNotEmpty) {
        _loadRule(widget.rules.first);
      }
      return;
    }
    final refreshed = widget.rules
        .where((rule) => rule.ruleId == selected.ruleId)
        .firstOrNull;
    if (refreshed == null && widget.rules.isNotEmpty) {
      _loadRule(widget.rules.first);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _moduleId.dispose();
    _sort.dispose();
    _legacyConfig.dispose();
    super.dispose();
  }

  WmsRule? get _selectedRule {
    final id = _selectedId;
    if (id == null) {
      return null;
    }
    for (final rule in widget.rules) {
      if (rule.ruleId == id) {
        return rule;
      }
    }
    return null;
  }

  Map<String, List<WmsRule>> get _groupedRules {
    final query = _query.trim();
    final result = <String, List<WmsRule>>{};
    for (final rule in widget.rules) {
      if (query.isNotEmpty && !rule.name.contains(query)) {
        continue;
      }
      result.putIfAbsent(_groupOf(rule), () => []).add(rule);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navigationWidth = constraints.maxWidth < 900 ? 246.0 : 292.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: navigationWidth,
                child: _buildDocumentNavigation(context),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(child: _buildEditorContent(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _groupedRules;
    final searchActive = _query.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RuQiSpacing.md,
            RuQiSpacing.md,
            RuQiSpacing.md,
            RuQiSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '单据清单',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${widget.rules.length} 个',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
          child: RuQiSearchField(
            hintText: '搜索单据名称',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: groups.isEmpty
              ? Center(
                  child: Text(
                    '没有匹配的单据',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.xs,
                    vertical: RuQiSpacing.xs,
                  ),
                  children: [
                    for (final entry in groups.entries) ...[
                      _buildGroupHeader(
                        context,
                        entry.key,
                        entry.value.length,
                        forceExpanded: searchActive,
                      ),
                      if (searchActive || _expandedGroups.contains(entry.key))
                        for (final rule in entry.value)
                          _buildDocumentItem(context, rule),
                    ],
                  ],
                ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.all(RuQiSpacing.sm),
          child: OutlinedButton.icon(
            onPressed: () => _startCreate(group: _activeGroup),
            style: RuQiButtonStyles.secondary(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新增单据编码'),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    String group,
    int count, {
    required bool forceExpanded,
  }) {
    final theme = Theme.of(context);
    final expanded = forceExpanded || _expandedGroups.contains(group);
    return InkWell(
      onTap: () {
        setState(() {
          if (forceExpanded) {
            return;
          }
          if (expanded) {
            _expandedGroups.remove(group);
          } else {
            _expandedGroups.add(group);
          }
        });
      },
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            const SizedBox(width: RuQiSpacing.xs),
            Icon(
              expanded ? Icons.expand_more : Icons.chevron_right,
              size: 17,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                group,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: RuQiSpacing.xs),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, WmsRule rule) {
    final theme = Theme.of(context);
    final selected = !_isCreating && rule.ruleId == _selectedId;
    return InkWell(
      onTap: () => setState(() => _loadRule(rule)),
      child: Container(
        height: 38,
        padding: const EdgeInsets.fromLTRB(
          RuQiSpacing.lg,
          RuQiSpacing.xxs,
          RuQiSpacing.xs,
          RuQiSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 16,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: RuQiSpacing.xs),
            Expanded(
              child: Text(
                rule.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorContent(BuildContext context) {
    final theme = Theme.of(context);
    final rule = _selectedRule;
    final title = _isCreating ? '新建单据编码规则' : rule?.name ?? '单据编码规则';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RuQiSpacing.lg,
            RuQiSpacing.md,
            RuQiSpacing.lg,
            RuQiSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '规则设置 / 基础规则 / 单据编码规则',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: RuQiSpacing.xxs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!_isCreating && rule != null)
                    StatusBadge(
                      label: rule.status.label,
                      tone: rule.status == WmsRuleStatus.enabled
                          ? StatusTone.success
                          : StatusTone.neutral,
                    ),
                ],
              ),
              const SizedBox(height: RuQiSpacing.xs),
              Wrap(
                spacing: RuQiSpacing.xs,
                runSpacing: RuQiSpacing.xs,
                children: [
                  FilledButton.icon(
                    onPressed: _save,
                    style: RuQiButtonStyles.primary(context),
                    icon: const Icon(Icons.save_outlined, size: 17),
                    label: const Text('保存'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _startCreate(group: _activeGroup),
                    style: RuQiButtonStyles.secondary(context),
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('添加同级'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final current = _selectedRule;
                      if (current != null) {
                        _startCreate(group: current.name);
                      }
                    },
                    style: RuQiButtonStyles.secondary(context),
                    icon: const Icon(Icons.subdirectory_arrow_right, size: 17),
                    label: const Text('添加下级'),
                  ),
                  OutlinedButton.icon(
                    onPressed: rule == null ? null : _copyRule,
                    style: RuQiButtonStyles.secondary(context),
                    icon: const Icon(Icons.copy_outlined, size: 17),
                    label: const Text('复制'),
                  ),
                  OutlinedButton.icon(
                    onPressed: rule == null ? null : _deleteRule,
                    style: RuQiButtonStyles.secondary(context),
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: const Text('删除'),
                  ),
                  if (_isCreating)
                    OutlinedButton(
                      onPressed: _cancelCreate,
                      style: RuQiButtonStyles.secondary(context),
                      child: const Text('取消'),
                    ),
                ],
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
                Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _readOnlyRow(context, '规则ID', rule?.ruleId ?? '保存后生成'),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '规则名称',
                          required: true,
                          child: TextFormField(
                            key: const ValueKey('wms-coding-name'),
                            controller: _name,
                            decoration: const InputDecoration(
                              hintText: '请输入规则名称',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入规则名称';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '规则编码',
                          child: TextField(
                            key: const ValueKey('wms-coding-code'),
                            controller: _code,
                            decoration: const InputDecoration(
                              hintText: '英文标识，可选',
                            ),
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '描述',
                          child: TextField(
                            controller: _description,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: '请输入描述',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '流水号字符集',
                          required: true,
                          child: DropdownButtonFormField<String>(
                            key: const ValueKey('wms-coding-charset'),
                            initialValue: _serialCharset,
                            isExpanded: true,
                            items: [
                              for (final charset in _charsets)
                                DropdownMenuItem(
                                  value: charset,
                                  child: Text(charset),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _serialCharset = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '模块菜单ID',
                          required: true,
                          child: TextField(
                            controller: _moduleId,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              helperText: '与业务菜单关联，用于取号（DBUtils 按 menu_id 匹配）',
                            ),
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '是否启用',
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Switch(
                              value: _status == WmsRuleStatus.enabled,
                              onChanged: (value) {
                                setState(() {
                                  _status = value
                                      ? WmsRuleStatus.enabled
                                      : WmsRuleStatus.disabled;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '排序号',
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: '减少排序号',
                                onPressed: () => _changeSort(-1),
                                icon: const Icon(Icons.remove, size: 18),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _sort,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: '增加排序号',
                                onPressed: () => _changeSort(1),
                                icon: const Icon(Icons.add, size: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.md),
                        _fieldRow(
                          context,
                          label: '迁移状态',
                          child: Wrap(
                            spacing: RuQiSpacing.xs,
                            runSpacing: RuQiSpacing.xs,
                            children: [
                              _migrationChoice(context, 0, '兼容旧模式（模式串+SQL）'),
                              _migrationChoice(context, 1, '分段规则'),
                            ],
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.lg),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: const Text('旧版：编码模式串（code）与取号 SQL'),
                          children: [
                            const SizedBox(height: RuQiSpacing.sm),
                            TextField(
                              controller: _legacyConfig,
                              minLines: 4,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                hintText: '兼容旧版编码规则时填写。',
                              ),
                            ),
                            const SizedBox(height: RuQiSpacing.sm),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldRow(
    BuildContext context, {
    required String label,
    required Widget child,
    bool required = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 124,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  if (required)
                    TextSpan(
                      text: '* ',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  TextSpan(text: label),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.sm),
        Expanded(child: child),
      ],
    );
  }

  Widget _readOnlyRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 124,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.sm),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _migrationChoice(BuildContext context, int value, String label) {
    final theme = Theme.of(context);
    final selected = _migrationMode == value;
    return ChoiceChip(
      label: Text(label),
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
      onSelected: (_) => setState(() => _migrationMode = value),
    );
  }

  void _changeSort(int delta) {
    final current = int.tryParse(_sort.text) ?? 0;
    setState(() => _sort.text = '${current + delta}');
  }

  void _loadRule(WmsRule rule) {
    final group = _groupOf(rule);
    _selectedId = rule.ruleId;
    _lastSelectedId = rule.ruleId;
    _isCreating = false;
    _activeGroup = group;
    _expandedGroups.add(group);
    _name.text = rule.name;
    _code.text = rule.typeCode == 'DOCUMENT_CODING_RULE' ? '' : rule.typeCode;
    _description.text = rule.description;
    _moduleId.text = '232';
    _sort.text = '${rule.priority}';
    _legacyConfig.clear();
    _status = rule.status;
    _serialCharset = '[0-9] 仅数字';
    _migrationMode = 0;
  }

  void _startCreate({required String group}) {
    setState(() {
      _lastSelectedId = _selectedId ?? _lastSelectedId;
      _isCreating = true;
      _selectedId = null;
      _activeGroup = group;
      _newRuleGroup = group;
      _expandedGroups.add(group);
      _name.clear();
      _code.clear();
      _description.clear();
      _moduleId.text = '232';
      _sort.text = '0';
      _legacyConfig.clear();
      _status = WmsRuleStatus.enabled;
      _serialCharset = '[0-9] 仅数字';
      _migrationMode = 0;
    });
  }

  void _cancelCreate() {
    final fallback = widget.rules
        .where((rule) => rule.ruleId == _lastSelectedId)
        .firstOrNull;
    if (fallback != null) {
      setState(() => _loadRule(fallback));
    } else if (widget.rules.isNotEmpty) {
      setState(() => _loadRule(widget.rules.first));
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final now = _formatNow();
    if (_isCreating) {
      final created = WmsRule(
        ruleId: 'WMS-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        typeLabel: '单据编码规则',
        typeCode: _code.text.trim().isEmpty
            ? 'DOCUMENT_CODING_RULE'
            : _code.text.trim(),
        shortLabel: _shortLabel(_name.text, '编码'),
        warehouse: '全部',
        owner: '全部',
        priority: int.tryParse(_sort.text) ?? 0,
        status: _status,
        creator: '超级管理员',
        createdAt: now,
        updatedAt: now,
        businessGroup: _newRuleGroup,
        description: _description.text.trim(),
      );
      widget.onRulesChanged([...widget.rules, created]);
      setState(() => _loadRule(created));
      widget.onNotify('单据编码规则“${created.name}”已创建');
      return;
    }
    final current = _selectedRule;
    if (current == null) {
      return;
    }
    final updated = current.copyWith(
      name: _name.text.trim(),
      typeCode: _code.text.trim().isEmpty
          ? 'DOCUMENT_CODING_RULE'
          : _code.text.trim(),
      shortLabel: _shortLabel(_name.text, '编码'),
      priority: int.tryParse(_sort.text) ?? 0,
      status: _status,
      updatedAt: now,
      description: _description.text.trim(),
    );
    widget.onRulesChanged([
      for (final rule in widget.rules)
        if (rule.ruleId == updated.ruleId) updated else rule,
    ]);
    setState(() => _loadRule(updated));
    widget.onNotify('单据编码规则“${updated.name}”已保存');
  }

  void _copyRule() {
    final current = _selectedRule;
    if (current == null) {
      return;
    }
    final now = _formatNow();
    final copy = current.copyWith(
      ruleId: 'WMS-${DateTime.now().millisecondsSinceEpoch}',
      name: '${current.name}副本',
      businessGroup: _groupOf(current),
      creator: '超级管理员',
      createdAt: now,
      updatedAt: now,
    );
    widget.onRulesChanged([...widget.rules, copy]);
    setState(() {
      _expandedGroups.add(_groupOf(copy));
      _loadRule(copy);
    });
    widget.onNotify('已复制“${current.name}”');
  }

  Future<void> _deleteRule() async {
    final current = _selectedRule;
    if (current == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除单据编码规则'),
        content: Text('确定删除“${current.name}”吗？此操作不可撤销。'),
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
    final remaining = [
      for (final rule in widget.rules)
        if (rule.ruleId != current.ruleId) rule,
    ];
    widget.onRulesChanged(remaining);
    setState(() {
      if (remaining.isEmpty) {
        _startCreate(group: _groupOf(current));
      } else {
        _loadRule(remaining.first);
      }
    });
    widget.onNotify('已删除“${current.name}”');
  }

  String _shortLabel(String name, String fallback) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    return trimmed.characters.take(2).toString();
  }

  String _groupOf(WmsRule rule) {
    final dynamic value = rule.businessGroup;
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return '未分类';
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}
