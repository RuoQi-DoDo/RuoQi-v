part of 'home_pages.dart';

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
