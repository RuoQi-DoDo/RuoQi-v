part of 'home_pages.dart';

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
