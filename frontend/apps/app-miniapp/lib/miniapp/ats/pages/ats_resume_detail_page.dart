part of 'profile_pages.dart';

class AtsResumeDetailPage extends StatelessWidget {
  const AtsResumeDetailPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final resume = atsResumes.first;
    final favorite = controller.favorites.contains(resume.id);
    final invited = controller.applications.contains(resume.id);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              AtsCard(
                child: Row(
                  children: [
                    AtsAvatar(label: resume.name, size: 57),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${resume.gender} · ${resume.age}岁 · '
                            '${resume.education} · ${resume.experience}',
                            style: TextStyle(
                              color: AtsColors.resolve(
                                context,
                                AtsColors.textMuted,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 7),
                          AtsTag(
                            resume.jobStatus,
                            foreground: AtsColors.resolve(
                              context,
                              AtsColors.primary,
                            ),
                            background: AtsColors.resolve(
                              context,
                              AtsColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '个人优势',
                child: Text(
                  resume.skill,
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.textSecondary),
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '求职意向',
                child: Column(
                  children: [
                    _ResumeInfoRow(label: '期望岗位', value: resume.intent),
                    _ResumeInfoRow(label: '期望薪资', value: resume.salary),
                    _ResumeInfoRow(label: '求职状态', value: resume.jobStatus),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '工作经历',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExperienceHeader(
                      title: '上海青禾网络科技',
                      period: '2022.06 - 至今',
                      role: 'Flutter 开发工程师',
                    ),
                    SizedBox(height: 9),
                    Text(
                      '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程。',
                      style: TextStyle(
                        color: AtsColors.resolve(
                          context,
                          AtsColors.textSecondary,
                        ),
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '教育经历',
                child: const _ExperienceHeader(
                  title: '江南大学',
                  period: '2018.09 - 2022.06',
                  role: '计算机科学与技术 · 本科',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AtsColors.resolve(context, AtsColors.surface),
            border: Border(
              top: BorderSide(
                color: AtsColors.resolve(context, AtsColors.divider),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AtsOutlineButton(
                  label: favorite ? '取消收藏' : '收藏简历',
                  icon: favorite ? Icons.star : Icons.star_border,
                  foreground: favorite
                      ? AtsColors.resolve(context, AtsColors.orange)
                      : AtsColors.resolve(context, AtsColors.text),
                  onPressed: () {
                    controller.toggleFavorite(resume.id);
                    atsToast(context, favorite ? '已取消收藏' : '已收藏简历');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AtsPrimaryButton(
                  label: invited ? '取消邀请' : '面试邀请',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () {
                    controller.toggleApplication(resume.id);
                    atsToast(context, invited ? '已取消面试邀请' : '面试邀请已发送');
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
