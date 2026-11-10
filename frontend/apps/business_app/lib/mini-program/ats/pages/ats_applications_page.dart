part of 'profile_pages.dart';

class AtsApplicationsPage extends StatefulWidget {
  const AtsApplicationsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsApplicationsPage> createState() => _AtsApplicationsPageState();
}

class _AtsApplicationsPageState extends State<AtsApplicationsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const statuses = ['全部', '已投递', '已查看', '面试邀请'];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              for (var i = 0; i < statuses.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tab == i ? AtsColors.mint : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        statuses[i],
                        style: TextStyle(
                          color: _tab == i
                              ? AtsColors.primary
                              : AtsColors.textSecondary,
                          fontSize: 12,
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
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (var i = 0; i < 2; i++)
                AtsCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () => widget.controller.open(AtsRoute.jobDetail),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              atsJobs[i].title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            atsJobs[i].salary,
                            style: const TextStyle(
                              color: AtsColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        atsJobs[i].company,
                        style: const TextStyle(
                          color: AtsColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          AtsTag(
                            i == 0 ? '已查看' : '已投递',
                            foreground: i == 0
                                ? AtsColors.primary
                                : AtsColors.blue,
                            background: i == 0
                                ? AtsColors.mint
                                : const Color(0xFFEEF4FF),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            i == 0 ? '今天 10:20' : '昨天 16:45',
                            style: const TextStyle(
                              color: AtsColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '查看详情',
                            style: TextStyle(
                              color: AtsColors.primary,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AtsColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
