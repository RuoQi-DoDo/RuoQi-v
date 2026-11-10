part of 'profile_pages.dart';

class AtsResumePage extends StatelessWidget {
  const AtsResumePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final resume = atsResumes.first;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          onTap: () => controller.open(AtsRoute.userInfo),
          child: Row(
            children: [
              AtsAvatar(label: controller.userName, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          controller.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: AtsColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resume.age}岁 · ${resume.education} · '
                      '${resume.experience}工作经验',
                      style: const TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AtsColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '85%',
                      style: TextStyle(
                        color: AtsColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '完整度',
                      style: TextStyle(color: AtsColors.primary, fontSize: 8),
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
          action: '编辑',
          onAction: () => controller.open(AtsRoute.editSkill),
          child: Text(
            resume.skill,
            style: const TextStyle(
              color: AtsColors.textSecondary,
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '求职期望',
          action: '编辑',
          onAction: () => controller.open(AtsRoute.editExpectation),
          child: Column(
            children: [
              _ResumeInfoRow(label: '意向岗位', value: resume.intent),
              _ResumeInfoRow(label: '期望薪资', value: resume.salary),
              _ResumeInfoRow(label: '求职状态', value: resume.jobStatus),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '工作经历',
          action: '添加',
          onAction: () => controller.open(AtsRoute.editWork),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ExperienceHeader(
                title: '上海青禾网络科技',
                period: '2022.06 - 至今',
                role: 'Flutter 开发工程师',
              ),
              const SizedBox(height: 9),
              const Text(
                '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程，'
                '关键页面渲染性能提升 35%。',
                style: TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [AtsTag('Flutter'), AtsTag('Dart'), AtsTag('性能优化')],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '项目经历',
          action: '添加',
          onAction: () => controller.open(AtsRoute.editProject),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExperienceHeader(
                title: '招聘 App 跨端重构',
                period: '2023.03 - 2023.11',
                role: '项目负责人',
              ),
              SizedBox(height: 8),
              Text(
                '统一 iOS、Android 与 Web 三端研发链路，持续集成效率提升 40%。',
                style: TextStyle(
                  color: AtsColors.textSecondary,
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
          action: '添加',
          onAction: () => controller.open(AtsRoute.editEducation),
          child: const _ExperienceHeader(
            title: '江南大学',
            period: '2018.09 - 2022.06',
            role: '计算机科学与技术 · 本科',
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ResumeSection extends StatelessWidget {
  const _ResumeSection({
    required this.title,
    required this.child,
    this.action,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (action != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text(action!),
                  style: TextButton.styleFrom(
                    foregroundColor: AtsColors.primary,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ResumeInfoRow extends StatelessWidget {
  const _ResumeInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(color: AtsColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AtsColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceHeader extends StatelessWidget {
  const _ExperienceHeader({
    required this.title,
    required this.period,
    required this.role,
  });

  final String title;
  final String period;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AtsColors.mint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            title.contains('大学')
                ? Icons.school_outlined
                : title.contains('项目')
                ? Icons.folder_outlined
                : Icons.business_outlined,
            color: AtsColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$role · $period',
                style: const TextStyle(
                  color: AtsColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
