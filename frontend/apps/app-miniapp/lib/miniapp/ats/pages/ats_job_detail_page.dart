part of 'home_pages.dart';

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
