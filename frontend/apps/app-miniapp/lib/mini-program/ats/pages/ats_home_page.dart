part of 'home_pages.dart';

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
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
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
                          const SizedBox(height: 2),
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
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
                              vertical: 4,
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
