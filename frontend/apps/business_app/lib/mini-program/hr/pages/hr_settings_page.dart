part of 'profile_pages.dart';

class HrSettingsPage extends StatelessWidget {
  const HrSettingsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('设置', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('消息、安全与数据偏好。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: controller.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
                activeTrackColor: HrColors.brand,
                title: const Text(
                  '消息通知',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('审批、考勤与公告提醒', style: HrText.meta),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              SwitchListTile.adaptive(
                value: controller.biometricEnabled,
                onChanged: controller.setBiometricEnabled,
                activeTrackColor: HrColors.brand,
                title: const Text(
                  '生物识别解锁',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('使用指纹或面容快速进入', style: HrText.meta),
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '数据与存储'),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.cleaning_services_outlined,
                  color: HrColors.ink3,
                  size: 20,
                ),
                title: const Text('清理缓存', style: HrText.cardTitle),
                subtitle: const Text('12.6 MB', style: HrText.meta),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: HrColors.ink4,
                ),
                onTap: () => hrToast(context, '缓存已清理'),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_outlined,
                  color: HrColors.ink3,
                  size: 20,
                ),
                title: const Text('数据来源', style: HrText.cardTitle),
                subtitle: Text(
                  controller.useMockData ? '静态模拟数据' : 'Horilla API',
                  style: HrText.meta,
                ),
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '关于'),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrLogoMark(size: 48),
              SizedBox(height: 12),
              Text('RuoQi 人事', style: HrText.cardTitle),
              SizedBox(height: 4),
              Text(
                '参考 Horilla HR Mobile 信息架构实现的人事小程序页面。当前默认使用静态模拟数据，真实 API 适配层已保留。',
                style: HrText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
