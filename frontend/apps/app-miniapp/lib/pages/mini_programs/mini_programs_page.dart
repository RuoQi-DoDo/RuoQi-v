import 'package:flutter/material.dart';

import '../../localization.dart';
import '../../miniapp/common/miniapp_localizations.dart';
import '../../miniapp/launcher/miniapp_catalog.dart';
import '../../miniapp/launcher/miniapp_launcher_item.dart';
import '../common/page_theme.dart';

/// Public mini-program directory shared by the Discover page and other routes.
class MiniProgramsPage extends StatefulWidget {
  const MiniProgramsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MiniProgramsPage());

  @override
  State<MiniProgramsPage> createState() => _MiniProgramsPageState();
}

class _MiniProgramsPageState extends State<MiniProgramsPage> {
  final _searchController = TextEditingController();
  String? _openingId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
  }

  void _refreshSearch() => setState(() {});

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _open(MiniProgramLauncherItem item) async {
    if (_openingId != null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _openingId = item.id);
    try {
      await openMiniProgram(context, item);
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: sharedPageTheme(context),
    child: Builder(builder: _buildDirectory),
  );

  Widget _buildDirectory(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final items = availableMiniPrograms.where((item) {
      final terms = [
        item.id,
        item.label,
        localizeMiniProgramLabel(context, item.label),
        ...item.searchTerms,
      ].join(' ').toLowerCase();
      return terms.contains(query);
    }).toList();

    return Scaffold(
      key: const Key('mini-programs-page'),
      appBar: AppBar(title: Text(l10n.text('小程序', 'Mini-programs'))),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('mini-programs-search'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.text('搜索小程序', 'Search mini-programs'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('mini-programs-search-clear'),
                          tooltip: l10n.text('清空搜索', 'Clear search'),
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      key: const Key('mini-programs-empty'),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.text(
                            '未找到相关小程序，请尝试其他名称',
                            'No mini-programs found. Try another name.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const Key('mini-programs-list'),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            key: Key('mini-program-entry-${item.id}'),
                            enabled: _openingId == null,
                            contentPadding: const EdgeInsets.all(12),
                            leading: MiniProgramLauncherIcon(
                              item: item,
                              size: 44,
                            ),
                            title: Text(
                              localizeMiniProgramLabel(context, item.label),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _open(item),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
