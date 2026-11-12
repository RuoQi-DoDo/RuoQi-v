part of 'home_pages.dart';

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
          color: AtsColors.resolve(context, AtsColors.background),
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final selected = index == _selected;
              return InkWell(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? AtsColors.resolve(context, AtsColors.surface)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        width: 3,
                        color: selected
                            ? AtsColors.resolve(context, AtsColors.primary)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: selected
                          ? AtsColors.resolve(context, AtsColors.primary)
                          : AtsColors.resolve(context, AtsColors.textSecondary),
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
                      foregroundColor: AtsColors.resolve(
                        context,
                        AtsColors.textSecondary,
                      ),
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
