part of 'home_pages.dart';

class AtsSearchPage extends StatefulWidget {
  const AtsSearchPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsSearchPage> createState() => _AtsSearchPageState();
}

class _AtsSearchPageState extends State<AtsSearchPage> {
  final _searchController = TextEditingController();
  bool _searched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search([String? value]) {
    final query = (value ?? _searchController.text).trim();
    if (query.isEmpty) {
      atsToast(context, '请输入搜索关键词');
      return;
    }
    _searchController.text = query;
    widget.controller.addSearchHistory(query);
    setState(() => _searched = true);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final results = atsJobs
        .where(
          (job) =>
              job.title.contains(_searchController.text) ||
              job.company.contains(_searchController.text) ||
              job.tags.any((tag) => tag.contains(_searchController.text)),
        )
        .toList();
    return Container(
      color: AtsColors.resolve(context, AtsColors.background),
      child: Column(
        children: [
          Container(
            color: AtsColors.resolve(context, AtsColors.surface),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _search,
                      decoration: const InputDecoration(
                        hintText: '搜索职位、公司或技能',
                        prefixIcon: Icon(Icons.search, size: 19),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 9),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _search(),
                  style: TextButton.styleFrom(
                    foregroundColor: AtsColors.resolve(
                      context,
                      AtsColors.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searched
                ? ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text(
                        '找到 ${results.length} 个相关职位',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 9),
                      for (final job in results)
                        AtsJobCard(
                          job: job,
                          margin: const EdgeInsets.only(bottom: 10),
                          onTap: () =>
                              widget.controller.open(AtsRoute.jobDetail),
                        ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Text(
                            '搜索历史',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.controller.clearSearchHistory,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 19,
                              color: AtsColors.resolve(
                                context,
                                AtsColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.controller.searchHistory.isEmpty)
                        const AtsEmptyState(
                          icon: Icons.history,
                          title: '暂无搜索历史',
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in widget.controller.searchHistory)
                              ActionChip(
                                onPressed: () => _search(item),
                                label: Text(item),
                                backgroundColor: AtsColors.resolve(
                                  context,
                                  AtsColors.surface,
                                ),
                                side: BorderSide(
                                  color: AtsColors.resolve(
                                    context,
                                    AtsColors.divider,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 26),
                      const Text(
                        '热门搜索',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in brHotSearches)
                            ActionChip(
                              onPressed: () => _search(item),
                              label: Text(item),
                              backgroundColor: AtsColors.resolve(
                                context,
                                AtsColors.mint,
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

const brHotSearches = <String>[
  'Flutter',
  '产品经理',
  'Java',
  'UI设计',
  '新媒体运营',
  '周末双休',
  '应届生',
];
