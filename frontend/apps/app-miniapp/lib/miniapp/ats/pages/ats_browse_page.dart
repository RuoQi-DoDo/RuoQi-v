part of 'profile_pages.dart';

class AtsBrowsePage extends StatelessWidget {
  const AtsBrowsePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 9),
          child: Text(
            '今天',
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AtsCard(
          margin: const EdgeInsets.only(bottom: 10),
          onTap: () => controller.open(AtsRoute.jobDetail),
          child: Row(
            children: [
              _TimelineIcon(icon: Icons.work_outline),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atsJobs.first.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${atsJobs.first.company} · 14:32',
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
                size: 19,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 10, 2, 9),
          child: Text(
            '昨天',
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AtsCard(
          onTap: () => controller.open(AtsRoute.companyDetail),
          child: Row(
            children: [
              _TimelineIcon(
                icon: Icons.business_outlined,
                color: AtsColors.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atsCompanies.first.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '公司主页 · 18:05',
                      style: TextStyle(
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
                size: 19,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineIcon extends StatelessWidget {
  const _TimelineIcon({required this.icon, this.color = AtsColors.primary});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
