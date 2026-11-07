import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../console_content_theme.dart';
import 'wms_rule_models.dart';
import 'wms_rule_page.dart';

/// WMS管理主体。可直接嵌入页面，也可由 [WmsConsoleDialog] 放在弹窗中。
class WmsRuleSettingsPage extends StatefulWidget {
  const WmsRuleSettingsPage({super.key});

  @override
  State<WmsRuleSettingsPage> createState() => _WmsRuleSettingsPageState();
}

class _WmsRuleSettingsPageState extends State<WmsRuleSettingsPage> {
  late final Map<String, List<WmsRule>> _rules;
  String _selectedPageId = 'constraint';

  @override
  void initState() {
    super.initState();
    _rules = {
      for (final page in wmsRulePages) page.id: [...page.initialRules],
    };
  }

  WmsRulePageDefinition get _selectedPage => wmsRulePageById(_selectedPageId);

  @override
  Widget build(BuildContext context) {
    final page = _selectedPage;
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WmsRuleSidebar(
            selectedPageId: page.id,
            onSelected: (selected) {
              setState(() => _selectedPageId = selected.id);
            },
          ),
          Expanded(
            child: ConsoleContentTheme(
              child: WmsRulePage(
                key: ValueKey(page.id),
                page: page,
                rules: _rules[page.id] ?? const [],
                onRulesChanged: (rules) {
                  setState(() => _rules[page.id] = rules);
                },
                onNotify: _notify,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _notify(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class WmsRuleSidebar extends StatefulWidget {
  const WmsRuleSidebar({
    super.key,
    required this.selectedPageId,
    required this.onSelected,
  });

  final String selectedPageId;
  final ValueChanged<WmsRulePageDefinition> onSelected;

  @override
  State<WmsRuleSidebar> createState() => _WmsRuleSidebarState();
}

class _WmsRuleSidebarState extends State<WmsRuleSidebar> {
  String _query = '';
  final Set<String> _collapsed = {};

  String get _selectedCategoryId =>
      wmsRulePageById(widget.selectedPageId).categoryId;

  @override
  void didUpdateWidget(covariant WmsRuleSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPageId != widget.selectedPageId) {
      _collapsed.remove(_selectedCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedQuery = _query.trim();
    final categories = [
      for (final category in wmsRuleCategories)
        if (normalizedQuery.isEmpty ||
            category.label.contains(normalizedQuery) ||
            category.pages.any((page) => page.label.contains(normalizedQuery)))
          (
            category,
            [
              for (final summaryPage in category.pages)
                if (normalizedQuery.isEmpty ||
                    category.label.contains(normalizedQuery) ||
                    wmsRulePageById(
                      summaryPage.id,
                    ).label.contains(normalizedQuery))
                  wmsRulePageById(summaryPage.id),
            ],
          ),
    ];
    return Container(
      width: 268,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.lg,
              RuQiSpacing.md,
              RuQiSpacing.lg,
              RuQiSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warehouse_outlined,
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: RuQiSpacing.xs),
                Expanded(
                  child: Text(
                    '规则设置',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
            child: RuQiSearchField(
              hintText: '搜索规则',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      '无匹配规则',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: RuQiSpacing.xs,
                    ),
                    children: [
                      for (final entry in categories)
                        ..._categoryRows(
                          entry.$1,
                          entry.$2,
                          forceExpanded: normalizedQuery.isNotEmpty,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _categoryRows(
    WmsRuleCategory category,
    List<WmsRulePageDefinition> pages, {
    required bool forceExpanded,
  }) {
    final theme = Theme.of(context);
    final expanded =
        forceExpanded ||
        (!_collapsed.contains(category.id) &&
            (_selectedCategoryId == category.id ||
                !wmsRuleCategories.any(
                  (item) => item.id == _selectedCategoryId,
                )));
    return [
      InkWell(
        onTap: () {
          setState(() {
            if (expanded && !forceExpanded) {
              _collapsed.add(category.id);
            } else {
              _collapsed.remove(category.id);
            }
          });
          if (pages.isNotEmpty &&
              wmsRulePageById(widget.selectedPageId).categoryId !=
                  category.id) {
            widget.onSelected(pages.first);
          }
        },
        child: SizedBox(
          height: 42,
          child: Row(
            children: [
              const SizedBox(width: RuQiSpacing.md),
              Icon(
                switch (category.id) {
                  'basic' => Icons.tune,
                  'inbound' => Icons.input,
                  'inventory' => Icons.inventory_2_outlined,
                  _ => Icons.output,
                },
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RuQiSpacing.xs),
              Expanded(
                child: Text(
                  category.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RuQiSpacing.sm),
            ],
          ),
        ),
      ),
      if (expanded)
        for (final page in pages)
          _SidebarPageItem(
            label: page.label,
            selected: page.id == widget.selectedPageId,
            onTap: () => widget.onSelected(page),
          ),
    ];
  }
}

class _SidebarPageItem extends StatelessWidget {
  const _SidebarPageItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(
          left: RuQiSpacing.xxl,
          right: RuQiSpacing.sm,
        ),
        color: selected ? theme.colorScheme.primaryContainer : null,
        alignment: Alignment.centerLeft,
        child: Text(
          label,
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
    );
  }
}
