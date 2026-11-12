part of 'company_pages.dart';

class AtsPositionsPage extends StatefulWidget {
  const AtsPositionsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsPositionsPage> createState() => _AtsPositionsPageState();
}

class _AtsPositionsPageState extends State<AtsPositionsPage> {
  int _tab = 0;
  final _offline = <String>{};

  @override
  Widget build(BuildContext context) {
    final tabs = ['招聘中', '待审核', '已下线', '全部'];
    final jobs = switch (_tab) {
      1 => <AtsJob>[],
      2 => atsJobs.where((job) => _offline.contains(job.id)).toList(),
      3 => atsJobs.take(3).toList(),
      _ => atsJobs.take(3).where((job) => !_offline.contains(job.id)).toList(),
    };
    return Column(
      children: [
        Container(
          color: AtsColors.resolve(context, AtsColors.surface),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: _tab == i
                                ? AtsColors.resolve(context, AtsColors.primary)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          color: _tab == i
                              ? AtsColors.resolve(context, AtsColors.primary)
                              : AtsColors.resolve(
                                  context,
                                  AtsColors.textSecondary,
                                ),
                          fontSize: 13,
                          fontWeight: _tab == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: jobs.isEmpty
              ? AtsEmptyState(
                  icon: Icons.post_add_outlined,
                  title: _tab == 1 ? '暂无待审核职位' : '暂无下线职位',
                  subtitle: '发布新职位后将在这里展示',
                  action: AtsPrimaryButton(
                    label: '发布新职位',
                    onPressed: () =>
                        widget.controller.open(AtsRoute.positionEdit),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    AtsCard(
                      color: AtsColors.resolve(context, AtsColors.mint),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            color: AtsColors.resolve(
                              context,
                              AtsColors.primary,
                            ),
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '今日职位曝光 328 次，收到 6 份新简历',
                              style: TextStyle(
                                color: AtsColors.resolve(
                                  context,
                                  AtsColors.primaryDark,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                widget.controller.open(AtsRoute.resumeList),
                            child: const Text('查看'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final job in jobs)
                      _ManagedJobCard(
                        job: job,
                        offline: _offline.contains(job.id),
                        onEdit: () =>
                            widget.controller.open(AtsRoute.positionEdit),
                        onToggle: () {
                          setState(() {
                            if (!_offline.add(job.id)) {
                              _offline.remove(job.id);
                            }
                          });
                          atsToast(
                            context,
                            _offline.contains(job.id) ? '职位已下线' : '职位已上线',
                          );
                        },
                      ),
                  ],
                ),
        ),
        Container(
          color: AtsColors.resolve(context, AtsColors.surface),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          child: AtsPrimaryButton(
            label: '发布新职位',
            icon: Icons.add,
            onPressed: () => widget.controller.open(AtsRoute.positionEdit),
          ),
        ),
      ],
    );
  }
}

class _ManagedJobCard extends StatelessWidget {
  const _ManagedJobCard({
    required this.job,
    required this.offline,
    required this.onEdit,
    required this.onToggle,
  });

  final AtsJob job;
  final bool offline;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AtsTag(
                offline ? '已下线' : '招聘中',
                foreground: offline
                    ? AtsColors.resolve(context, AtsColors.textMuted)
                    : AtsColors.resolve(context, AtsColors.primary),
                background: offline
                    ? AtsColors.resolve(context, AtsColors.background)
                    : AtsColors.resolve(context, AtsColors.mint),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${job.salary} · ${job.location} · ${job.experience}',
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textMuted),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 13),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(
            children: [
              _JobStat(value: '328', label: '曝光'),
              _JobStat(value: '26', label: '浏览'),
              _JobStat(value: '6', label: '简历'),
              const Spacer(),
              TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  foregroundColor: AtsColors.resolve(
                    context,
                    AtsColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(offline ? '上线' : '下线'),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AtsColors.resolve(
                    context,
                    AtsColors.primary,
                  ),
                  side: BorderSide(
                    color: AtsColors.resolve(context, AtsColors.primary),
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Text('编辑'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobStat extends StatelessWidget {
  const _JobStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textMuted),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
