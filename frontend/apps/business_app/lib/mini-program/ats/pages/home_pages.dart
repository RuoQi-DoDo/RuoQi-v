import 'package:flutter/material.dart';

import '../ats_models.dart';
import '../ats_routes.dart';
import '../ats_style.dart';

const _banners = <_BannerData>[
  _BannerData(
    eyebrow: '金秋招聘季',
    title: '好工作，不等待',
    subtitle: '精选高薪岗位 · 快速反馈',
    colors: [Color(0xFF0D9F7A), Color(0xFF25C49B)],
    icon: Icons.rocket_launch_outlined,
  ),
  _BannerData(
    eyebrow: '名企直招',
    title: '和优秀的人一起',
    subtitle: '3000+ 认证企业在线招聘',
    colors: [Color(0xFF2F6FED), Color(0xFF63A4FF)],
    icon: Icons.apartment_rounded,
  ),
  _BannerData(
    eyebrow: '人才推荐',
    title: '让机会主动找到你',
    subtitle: '完善简历，获得更多曝光',
    colors: [Color(0xFFF0793B), Color(0xFFFFAE68)],
    icon: Icons.auto_awesome_outlined,
  ),
];

class AtsHomePage extends StatefulWidget {
  const AtsHomePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsHomePage> createState() => _AtsHomePageState();
}

class _AtsHomePageState extends State<AtsHomePage> {
  late final PageController _bannerController;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.93);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isRecruiter = controller.role == AtsUserRole.recruiter;
    return RefreshIndicator(
      color: AtsColors.primary,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!context.mounted) {
          return;
        }
        atsToast(context, '已为你刷新最新内容');
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AtsColors.primary,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: () => controller.open(AtsRoute.search),
                borderRadius: BorderRadius.circular(22),
                child: const SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      SizedBox(width: 14),
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AtsColors.textMuted,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '搜索岗位或关键词',
                        style: TextStyle(
                          color: AtsColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Column(
              children: [
                _BannerCarousel(
                  index: _bannerIndex,
                  controller: _bannerController,
                  onChanged: (value) => setState(() => _bannerIndex = value),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _HomeGridItem(
                        icon: Icons.new_releases_outlined,
                        label: '最新发布',
                        onTap: () => controller.open(AtsRoute.jobList),
                      ),
                      _HomeGridItem(
                        icon: Icons.grid_view_rounded,
                        label: '全部职位',
                        onTap: () => controller.switchTab(1),
                      ),
                      _HomeGridItem(
                        icon: Icons.paid_outlined,
                        label: '高薪优选',
                        onTap: () => controller.open(AtsRoute.jobList),
                      ),
                      _HomeGridItem(
                        icon: isRecruiter
                            ? Icons.description_outlined
                            : Icons.business_outlined,
                        label: isRecruiter ? '简历列表' : '热门公司',
                        onTap: () => controller.open(
                          isRecruiter
                              ? AtsRoute.resumeList
                              : AtsRoute.companyList,
                        ),
                      ),
                    ],
                  ),
                ),
                AtsCard(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  onTap: () => controller.open(AtsRoute.jobDetail),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 18,
                        color: AtsColors.orange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '北京世佳科技',
                                style: TextStyle(
                                  color: AtsColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' 正在招聘 '),
                              TextSpan(
                                text: '项目经理',
                                style: TextStyle(
                                  color: AtsColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' 职位'),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AtsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AtsColors.textMuted,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '热门岗位',
                        style: TextStyle(
                          color: AtsColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: atsHotPosts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisExtent: 34,
                              crossAxisSpacing: 7,
                              mainAxisSpacing: 7,
                            ),
                        itemBuilder: (context, index) {
                          return Material(
                            color: index.isEven
                                ? AtsColors.mint
                                : AtsColors.background,
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              onTap: () => controller.open(AtsRoute.post),
                              borderRadius: BorderRadius.circular(6),
                              child: Center(
                                child: Text(
                                  atsHotPosts[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: index.isEven
                                        ? AtsColors.primary
                                        : AtsColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => controller.open(AtsRoute.post),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '查看全部职位',
                                style: TextStyle(
                                  color: AtsColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AtsColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AtsSectionHeader(
                  title: isRecruiter ? '推荐简历' : '热门工作',
                  action: '更多',
                  onAction: () => controller.open(
                    isRecruiter ? AtsRoute.resumeList : AtsRoute.jobList,
                  ),
                ),
                if (isRecruiter)
                  for (final resume in atsResumes)
                    AtsResumeCard(
                      resume: resume,
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      onTap: () => controller.open(AtsRoute.resumeDetail),
                    )
                else
                  for (final job in atsJobs.take(3))
                    AtsJobCard(
                      job: job,
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      onTap: () => controller.open(AtsRoute.jobDetail),
                    ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Divider(color: AtsColors.divider),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '已经到底啦',
                          style: TextStyle(
                            color: AtsColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        child: Divider(color: AtsColors.divider),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({
    required this.index,
    required this.controller,
    required this.onChanged,
  });

  final int index;
  final PageController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _banners.length,
            onPageChanged: onChanged,
            padEnds: false,
            controller: controller,
            itemBuilder: (context, i) {
              final banner = _banners[i];
              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 12 : 6,
                  right: i == _banners.length - 1 ? 12 : 6,
                  top: 10,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: banner.colors),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: banner.colors.last.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -5,
                        bottom: -12,
                        child: Icon(
                          banner.icon,
                          size: 102,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.eyebrow,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            banner.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '立即查看  →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 24,
            bottom: 10,
            child: Row(
              children: [
                for (var i = 0; i < _banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == index ? 12 : 4,
                    height: 4,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: i == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeGridItem extends StatelessWidget {
  const _HomeGridItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AtsColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AtsColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(color: AtsColors.text, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      color: AtsColors.background,
      child: Column(
        children: [
          Container(
            color: Colors.white,
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
                    foregroundColor: AtsColors.primary,
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
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 19,
                              color: AtsColors.textMuted,
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
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: AtsColors.divider,
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
                              backgroundColor: AtsColors.mint,
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

class AtsJobListPage extends StatefulWidget {
  const AtsJobListPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsJobListPage> createState() => _AtsJobListPageState();
}

class _AtsJobListPageState extends State<AtsJobListPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final filtered = switch (_filter) {
      1 => atsJobs.take(3).toList(),
      2 => atsJobs.reversed.take(3).toList(),
      _ => atsJobs,
    };
    return Container(
      color: AtsColors.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 96,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AtsColors.primary, Color(0xFF42C7A5)],
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '发现适合你的好工作',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '智能匹配 · 高回复率 · 认证企业',
                          style: TextStyle(
                            color: Color(0xDFFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.work_history_outlined,
                    size: 60,
                    color: Color(0x38FFFFFF),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = i),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _filter == i
                                  ? AtsColors.mint
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              ['综合排序', '最新发布', '高薪优选'][i],
                              style: TextStyle(
                                color: _filter == i
                                    ? AtsColors.primary
                                    : AtsColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _filter == i
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (i != 2)
                        Container(
                          width: 1,
                          height: 12,
                          color: AtsColors.divider,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => AtsJobCard(
                job: filtered[index],
                onTap: () => widget.controller.open(AtsRoute.jobDetail),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                '没有更多了',
                textAlign: TextAlign.center,
                style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}

class AtsJobDetailPage extends StatelessWidget {
  const AtsJobDetailPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final job = atsJobs.first;
    final isFavorite = controller.favorites.contains(job.id);
    final isApplied = controller.applications.contains(job.id);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              AtsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              color: AtsColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          job.salary,
                          style: const TextStyle(
                            color: AtsColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        AtsTag(job.experience),
                        AtsTag(job.education),
                        AtsTag(job.location),
                        AtsTag(
                          '刚刚活跃',
                          foreground: AtsColors.primary,
                          background: AtsColors.mint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    AtsCard(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      onTap: () => controller.open(AtsRoute.companyDetail),
                      child: Row(
                        children: [
                          const AtsAvatar(
                            label: '李',
                            size: 44,
                            color: AtsColors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.publisher,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${job.company} · 招聘经理',
                                  style: const TextStyle(
                                    color: AtsColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AtsColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '职位要求',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job.description,
                      style: const TextStyle(
                        color: AtsColors.textSecondary,
                        fontSize: 13,
                        height: 1.75,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [for (final tag in job.tags) AtsTag(tag)],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                onTap: () => controller.open(AtsRoute.companyDetail),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AtsColors.mint,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Text(
                            '世',
                            style: TextStyle(
                              color: AtsColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.company,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${job.industry} · ${job.staffSize}',
                                style: const TextStyle(
                                  color: AtsColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AtsColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AtsColors.textMuted,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '上海市浦东新区张江路 88 号世佳中心',
                            style: TextStyle(
                              color: AtsColors.textSecondary,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                color: const Color(0xFFFFFAF4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 17,
                          color: AtsColors.orange,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '安全提示',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '该公司承诺名下所有职位不向您收费，如有不实，'),
                          TextSpan(
                            text: '请立即举报',
                            style: TextStyle(
                              color: AtsColors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: AtsColors.textSecondary,
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const AtsSectionHeader(title: '该公司其他岗位'),
              for (final other in atsJobs.skip(1).take(2))
                AtsJobCard(
                  job: other,
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () => controller.open(AtsRoute.jobDetail),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AtsColors.divider)),
          ),
          child: Row(
            children: [
              _BottomIcon(
                icon: isFavorite ? Icons.star : Icons.star_border,
                active: isFavorite,
                label: isFavorite ? '已收藏' : '收藏',
                onTap: () {
                  controller.toggleFavorite(job.id);
                  atsToast(context, isFavorite ? '已取消收藏' : '已收藏该职位');
                },
              ),
              const SizedBox(width: 4),
              _BottomIcon(
                icon: Icons.chat_bubble_outline,
                label: '聊一聊',
                onTap: () => controller.open(AtsRoute.privateChat),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AtsPrimaryButton(
                  label: isApplied ? '已投递' : '立即投递',
                  icon: isApplied ? Icons.check : Icons.send_outlined,
                  onPressed: () {
                    controller.toggleApplication(job.id);
                    atsToast(context, isApplied ? '已取消投递' : '简历投递成功');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: active ? AtsColors.orange : AtsColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AtsColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class AtsCompanyListPage extends StatelessWidget {
  const AtsCompanyListPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3779E8), Color(0xFF73ADFF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '热门公司',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '发现值得加入的团队',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.domain_rounded, size: 58, color: Color(0x3DFFFFFF)),
            ],
          ),
        ),
        const AtsSectionHeader(title: '精选认证企业'),
        for (final company in atsCompanies)
          AtsCompanyCard(
            company: company,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.companyDetail),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class AtsCompanyDetailPage extends StatelessWidget {
  const AtsCompanyDetailPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final company = atsCompanies.first;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AtsColors.primary, Color(0xFF54CFAD)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '世',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${company.industry} · ${company.staffSize}',
                      style: const TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const AtsTag(
                      '已认证',
                      foreground: AtsColors.primary,
                      background: AtsColors.mint,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '工作信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 13),
              _InfoLine(
                icon: Icons.schedule,
                label: '工作时间',
                value: company.workTime,
              ),
              const SizedBox(height: 10),
              _InfoLine(
                icon: Icons.weekend_outlined,
                label: '休息时间',
                value: company.restTime,
              ),
              const SizedBox(height: 10),
              _InfoLine(
                icon: Icons.timelapse,
                label: '加班情况',
                value: company.overtime,
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final item in company.welfare)
                    AtsTag(
                      item,
                      foreground: AtsColors.primary,
                      background: AtsColors.mint,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '公司地址',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AtsColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      company.address,
                      style: const TextStyle(
                        color: AtsColors.textSecondary,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => atsToast(context, '正在打开地图导航'),
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    label: const Text('导航'),
                    style: TextButton.styleFrom(
                      foregroundColor: AtsColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '公司介绍',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                company.introduce,
                style: const TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 13,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '招聘岗位'),
        for (final job in atsJobs.take(3))
          AtsJobCard(
            job: job,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.jobDetail),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AtsColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AtsColors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AtsColors.text, fontSize: 12),
        ),
      ],
    );
  }
}

class AtsResumeListPage extends StatelessWidget {
  const AtsResumeListPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF07A3B), Color(0xFFFFB071)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '推荐人才',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '为你匹配 12 位优质候选人',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.people_alt_outlined,
                size: 52,
                color: Color(0x3DFFFFFF),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '最新简历'),
        for (final resume in atsResumes)
          AtsResumeCard(
            resume: resume,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.resumeDetail),
          ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class AtsCategoryPage extends StatefulWidget {
  const AtsCategoryPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsCategoryPage> createState() => _AtsCategoryPageState();
}

class _AtsCategoryPageState extends State<AtsCategoryPage> {
  int _selected = 0;
  final _categories = <String>[
    '全部职位',
    '互联网',
    '销售',
    '设计',
    '运营',
    '产品',
    '人事/行政',
    '金融',
    '教育培训',
    '制造业',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 92,
          color: const Color(0xFFF0F1F2),
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final selected = index == _selected;
              return InkWell(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        width: 3,
                        color: selected
                            ? AtsColors.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: selected
                          ? AtsColors.primary
                          : AtsColors.textSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '精选职位',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => widget.controller.open(AtsRoute.post),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('筛选'),
                    style: TextButton.styleFrom(
                      foregroundColor: AtsColors.textSecondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final tag in const ['不限经验', '不限学历', '薪资优先']) AtsTag(tag),
                ],
              ),
              const SizedBox(height: 10),
              for (final job in atsJobs.skip(_selected % 2).take(5))
                AtsJobCard(
                  job: job,
                  margin: const EdgeInsets.only(bottom: 9),
                  showBorder: false,
                  onTap: () => widget.controller.open(AtsRoute.jobDetail),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
}
