import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../../admin_pages/shared/status_badge.dart';
import 'rule_models.dart';

/// 单据编码规则专用页面：左侧维护大量业务单据，右侧编辑当前单据编码。
class WmsCodingRulesPage extends StatefulWidget {
  const WmsCodingRulesPage({
    super.key,
    required this.rules,
    required this.onRulesChanged,
    required this.onNotify,
    this.customGroups = const [],
    this.onCustomGroupsChanged,
  });

  final List<WmsRule> rules;
  final ValueChanged<List<WmsRule>> onRulesChanged;
  final ValueChanged<String> onNotify;
  final List<String> customGroups;
  final ValueChanged<List<String>>? onCustomGroupsChanged;

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

  String? _selectedId;
  String _activeGroup = '基础信息';
  String _query = '';
  WmsRuleStatus _status = WmsRuleStatus.enabled;
  String _serialCharset = '[0-9] 仅数字';

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
    if (widget.rules.isNotEmpty) {
      final initial = widget.rules.firstWhere(
        (rule) => rule.name == '快递管理',
        orElse: () => widget.rules.first,
      );
      _loadRule(initial);
    } else {
      _moduleId.text = '232';
      _sort.text = '0';
    }
  }

  @override
  void didUpdateWidget(covariant WmsCodingRulesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _selectedRule;
    if (selected == null) {
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
      if (query.isNotEmpty &&
          !_documentDisplayName(rule.name).contains(query)) {
        continue;
      }
      result.putIfAbsent(_groupOf(rule), () => []).add(rule);
    }
    for (final group in widget.customGroups) {
      if (query.isEmpty || group.contains(query)) {
        result.putIfAbsent(group, () => []);
      }
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
          child: Column(
            key: const ValueKey('wms-coding-tree-actions'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showCreateDialog(group: _activeGroup),
                style: RuQiButtonStyles.secondary(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新增单据编码'),
              ),
              const SizedBox(height: RuQiSpacing.xs),
              OutlinedButton.icon(
                onPressed: _showAddGroupDialog,
                style: RuQiButtonStyles.secondary(context),
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: const Text('添加组'),
              ),
            ],
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
          _activeGroup = group;
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
    final selected = rule.ruleId == _selectedId;
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
                _documentDisplayName(rule.name),
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
    final title = rule == null ? _activeGroup : _documentDisplayName(rule.name);
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
                '规则设置 / 基础规则 / 单据编码',
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
                  if (rule != null)
                    StatusBadge(
                      label: rule.status.label,
                      tone: rule.status == WmsRuleStatus.enabled
                          ? StatusTone.success
                          : StatusTone.neutral,
                    ),
                ],
              ),
              if (rule != null) ...[
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
                      onPressed: _restoreDefault,
                      style: RuQiButtonStyles.secondary(context),
                      icon: const Icon(Icons.restart_alt, size: 17),
                      label: const Text('恢复默认'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _deleteRule,
                      style: RuQiButtonStyles.secondary(context),
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text('删除'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: rule == null
              ? _buildEmptyGroup(context)
              : Form(
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
                              _readOnlyRow(context, '规则ID', rule.ruleId),
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
                                    helperText:
                                        '与业务菜单关联，用于取号（DBUtils 按 menu_id 匹配）',
                                  ),
                                ),
                              ),
                              const SizedBox(height: RuQiSpacing.md),
                              _fieldRow(
                                context,
                                label: '是否启用',
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _CompactSwitch(
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

  Widget _buildEmptyGroup(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '“$_activeGroup”组暂无单据编码',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: RuQiSpacing.xxs),
          Text(
            '在该组下新增第一条单据编码规则。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          FilledButton.icon(
            onPressed: () => _showCreateDialog(group: _activeGroup),
            style: RuQiButtonStyles.primary(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新增单据编码'),
          ),
        ],
      ),
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

  void _changeSort(int delta) {
    final current = int.tryParse(_sort.text) ?? 0;
    setState(() => _sort.text = '${current + delta}');
  }

  void _loadRule(WmsRule rule) {
    final group = _groupOf(rule);
    _selectedId = rule.ruleId;
    _activeGroup = group;
    _expandedGroups.add(group);
    _name.text = rule.name;
    _code.text = rule.typeCode == 'DOCUMENT_CODING_RULE' ? '' : rule.typeCode;
    _description.text = rule.description;
    _moduleId.text = '232';
    _sort.text = '${rule.priority}';
    _status = rule.status;
    _serialCharset = '[0-9] 仅数字';
  }

  Future<void> _showCreateDialog({required String group}) async {
    final created = await showDialog<WmsRule>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => _WmsCodingRuleCreateDialog(group: group),
    );
    if (created == null || !mounted) {
      return;
    }
    widget.onRulesChanged([...widget.rules, created]);
    setState(() {
      _expandedGroups.add(_groupOf(created));
      _loadRule(created);
    });
    widget.onNotify('单据编码规则“${_documentDisplayName(created.name)}”已创建');
  }

  Future<void> _showAddGroupDialog() async {
    final existingGroups = _groupedRules.keys.toSet();
    final group = await showDialog<String>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => _AddCodingGroupDialog(existingGroups: existingGroups),
    );
    if (group == null || !mounted) {
      return;
    }
    widget.onCustomGroupsChanged?.call([...widget.customGroups, group]);
    setState(() {
      _expandedGroups.add(group);
      _activeGroup = group;
      _selectedId = null;
      _name.clear();
      _code.clear();
      _description.clear();
      _moduleId.text = '232';
      _sort.text = '0';
    });
    widget.onNotify('已添加单据编码组“$group”');
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final now = _formatNow();
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
    widget.onNotify('单据编码规则“${_documentDisplayName(updated.name)}”已保存');
  }

  Future<void> _restoreDefault() async {
    final current = _selectedRule;
    if (current == null) {
      return;
    }
    final defaultRule = _findCodingDefault(current.ruleId);
    if (defaultRule == null) {
      widget.onNotify('该规则没有可恢复的默认配置');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('恢复默认配置'),
        content: Text(
          '确定将“${_documentDisplayName(current.name)}”恢复为系统默认配置吗？当前修改将被覆盖。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: RuQiButtonStyles.tertiary(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: RuQiButtonStyles.primary(dialogContext),
            child: const Text('恢复默认'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final restored = defaultRule.copyWith(
      ruleId: current.ruleId,
      businessGroup: _groupOf(current),
      creator: current.creator,
      createdAt: current.createdAt,
      updatedAt: _formatNow(),
    );
    widget.onRulesChanged([
      for (final rule in widget.rules)
        if (rule.ruleId == restored.ruleId) restored else rule,
    ]);
    setState(() => _loadRule(restored));
    widget.onNotify('单据编码规则“${_documentDisplayName(restored.name)}”已恢复默认配置');
  }

  WmsRule? _findCodingDefault(String ruleId) {
    for (final page in wmsRulePages) {
      if (page.id != 'coding') {
        continue;
      }
      for (final rule in page.initialRules) {
        if (rule.ruleId == ruleId) {
          return rule;
        }
      }
    }
    return null;
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
        content: Text('确定删除“${_documentDisplayName(current.name)}”吗？此操作不可撤销。'),
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
        _selectedId = null;
        _name.clear();
        _code.clear();
        _description.clear();
        _moduleId.text = '232';
        _sort.text = '0';
      } else {
        _loadRule(remaining.first);
      }
    });
    widget.onNotify('已删除“${_documentDisplayName(current.name)}”');
  }

  String _documentDisplayName(String name) {
    final value = name.trim();
    if (!value.endsWith('规则') || value.length == 2) {
      return value;
    }
    final displayName = value.substring(0, value.length - 2).trimRight();
    return displayName.isEmpty ? value : displayName;
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

class _WmsCodingRuleCreateDialog extends StatefulWidget {
  const _WmsCodingRuleCreateDialog({required this.group});

  final String group;

  @override
  State<_WmsCodingRuleCreateDialog> createState() =>
      _WmsCodingRuleCreateDialogState();
}

class _WmsCodingRuleCreateDialogState
    extends State<_WmsCodingRuleCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _description;
  late final TextEditingController _moduleId;
  late final TextEditingController _sort;

  String _charset = '[0-9] 仅数字';
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _code = TextEditingController();
    _description = TextEditingController();
    _moduleId = TextEditingController(text: '232');
    _sort = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _moduleId.dispose();
    _sort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = (MediaQuery.sizeOf(context).width - 48).clamp(360.0, 720.0);
    final height = (MediaQuery.sizeOf(context).height - 48).clamp(480.0, 800.0);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: theme.colorScheme.surface,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RuQiSpacing.lg,
                RuQiSpacing.md,
                RuQiSpacing.sm,
                RuQiSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新增单据编码',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '所属分类：${widget.group}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
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
                    const _CodingDialogSectionTitle('基础信息'),
                    _fieldRow(
                      context,
                      label: '规则名称',
                      required: true,
                      child: TextFormField(
                        key: const ValueKey('wms-coding-create-name'),
                        controller: _name,
                        decoration: const InputDecoration(hintText: '请输入规则名称'),
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
                        key: const ValueKey('wms-coding-create-code'),
                        controller: _code,
                        decoration: const InputDecoration(hintText: '英文标识，可选'),
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
                        decoration: const InputDecoration(hintText: '请输入描述'),
                      ),
                    ),
                    const SizedBox(height: RuQiSpacing.lg),
                    const _CodingDialogSectionTitle('编码设置'),
                    _fieldRow(
                      context,
                      label: '流水号字符集',
                      required: true,
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey('wms-coding-create-charset'),
                        initialValue: _charset,
                        isExpanded: true,
                        items: [
                          for (final charset
                              in _WmsCodingRulesPageState._charsets)
                            DropdownMenuItem(
                              value: charset,
                              child: Text(charset),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _charset = value);
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
                          helperText: '与业务菜单关联，用于取号',
                        ),
                      ),
                    ),
                    const SizedBox(height: RuQiSpacing.md),
                    _fieldRow(
                      context,
                      label: '是否启用',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _CompactSwitch(
                          value: _enabled,
                          onChanged: (value) =>
                              setState(() => _enabled = value),
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
                              decoration: const InputDecoration(isDense: true),
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
                    onPressed: () => Navigator.of(context).pop(),
                    style: RuQiButtonStyles.secondary(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: RuQiSpacing.sm),
                  FilledButton(
                    onPressed: _submit,
                    style: RuQiButtonStyles.primary(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          width: 104,
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
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.sm),
        Expanded(child: child),
      ],
    );
  }

  void _changeSort(int delta) {
    final current = int.tryParse(_sort.text) ?? 0;
    setState(() => _sort.text = '${current + delta}');
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final now = _formatNow();
    Navigator.of(context).pop(
      WmsRule(
        ruleId: 'WMS-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        typeLabel: '单据编码规则',
        typeCode: _code.text.trim().isEmpty
            ? 'DOCUMENT_CODING_RULE'
            : _code.text.trim(),
        shortLabel: _shortLabel(_name.text),
        warehouse: '全部',
        owner: '全部',
        priority: int.tryParse(_sort.text) ?? 0,
        status: _enabled ? WmsRuleStatus.enabled : WmsRuleStatus.disabled,
        creator: '超级管理员',
        createdAt: now,
        updatedAt: now,
        businessGroup: widget.group,
        description: _description.text.trim(),
      ),
    );
  }

  String _shortLabel(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '编码' : trimmed.characters.take(2).toString();
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}

class _CodingDialogSectionTitle extends StatelessWidget {
  const _CodingDialogSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RuQiSpacing.sm),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: RuQiSpacing.sm),
          Expanded(
            child: Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}

class _CompactSwitch extends StatelessWidget {
  const _CompactSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '是否启用',
      toggled: value,
      button: true,
      child: Tooltip(
        message: value ? '点击停用' : '点击启用',
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(999),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              width: 44,
              height: 32,
              child: Center(
                child: AnimatedContainer(
                  duration: RuQiMotion.resolve(context, RuQiMotion.fast),
                  curve: RuQiMotion.easeOut,
                  width: 36,
                  height: 20,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: value
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: value
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: RuQiMotion.resolve(context, RuQiMotion.fast),
                    curve: RuQiMotion.easeOut,
                    alignment: value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCodingGroupDialog extends StatefulWidget {
  const _AddCodingGroupDialog({required this.existingGroups});

  final Set<String> existingGroups;

  @override
  State<_AddCodingGroupDialog> createState() => _AddCodingGroupDialogState();
}

class _AddCodingGroupDialogState extends State<_AddCodingGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加组'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: TextFormField(
            key: const ValueKey('wms-coding-group-name'),
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '组名称',
              hintText: '例如：出库管理',
            ),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) {
                return '请输入组名称';
              }
              if (widget.existingGroups.contains(name)) {
                return '该组已存在';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: RuQiButtonStyles.tertiary(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          style: RuQiButtonStyles.primary(context),
          child: const Text('确定'),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    Navigator.of(context).pop(_name.text.trim());
  }
}
