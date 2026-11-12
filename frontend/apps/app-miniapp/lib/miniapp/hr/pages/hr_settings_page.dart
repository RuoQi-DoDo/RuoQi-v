part of 'profile_pages.dart';

class HrSettingsPage extends StatelessWidget {
  const HrSettingsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          localizeMiniProgramLabel(context, '设置'),
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        SizedBox(height: 5),
        Text(
          localizeMiniProgramLabel(context, '消息、安全与数据偏好。'),
          style: HrText.resolve(context, HrText.meta),
        ),
        SizedBox(height: 17),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.security_outlined),
                title: Text(localizeMiniProgramLabel(context, '账号安全')),
                trailing: Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    Navigator.of(context).push(AccountSecurityPage.route()),
              ),
              ListTile(
                leading: Icon(Icons.display_settings_outlined),
                title: Text(localizeMiniProgramLabel(context, '界面与显示')),
                trailing: Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => DisplaySettingsPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: controller.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
                activeTrackColor: HrColors.resolve(context, HrColors.brand),
                title: Text(
                  localizeMiniProgramLabel(context, '消息通知'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  localizeMiniProgramLabel(context, '审批、考勤与公告提醒'),
                  style: HrText.resolve(context, HrText.meta),
                ),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.resolve(context, HrColors.line2),
              ),
              SwitchListTile.adaptive(
                value: controller.biometricEnabled,
                onChanged: controller.setBiometricEnabled,
                activeTrackColor: HrColors.resolve(context, HrColors.brand),
                title: Text(
                  localizeMiniProgramLabel(context, '生物识别解锁'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  localizeMiniProgramLabel(context, '使用指纹或面容快速进入'),
                  style: HrText.resolve(context, HrText.meta),
                ),
              ),
            ],
          ),
        ),
        HrSectionHeader(title: '数据与存储'),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: HrColors.resolve(context, HrColors.ink3),
                  size: 20,
                ),
                title: Text(
                  localizeMiniProgramLabel(context, '清理缓存'),
                  style: HrText.resolve(context, HrText.cardTitle),
                ),
                subtitle: Text(
                  localizeMiniProgramLabel(context, '12.6 MB'),
                  style: HrText.resolve(context, HrText.meta),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: HrColors.resolve(context, HrColors.ink4),
                ),
                onTap: () => hrToast(context, '缓存已清理'),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.resolve(context, HrColors.line2),
              ),
              ListTile(
                leading: Icon(
                  Icons.cloud_outlined,
                  color: HrColors.resolve(context, HrColors.ink3),
                  size: 20,
                ),
                title: Text(
                  localizeMiniProgramLabel(context, '数据来源'),
                  style: HrText.resolve(context, HrText.cardTitle),
                ),
                subtitle: Text(
                  controller.useMockData ? '静态模拟数据' : 'Horilla API',
                  style: HrText.resolve(context, HrText.meta),
                ),
              ),
            ],
          ),
        ),
        HrSectionHeader(title: '关于'),
        HrCard(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrLogoMark(size: 48),
              SizedBox(height: 12),
              Text(
                localizeMiniProgramLabel(context, 'RuoQi 人事'),
                style: HrText.resolve(context, HrText.cardTitle),
              ),
              SizedBox(height: 4),
              Text(
                localizeMiniProgramLabel(
                  context,
                  '参考 Horilla HR Mobile 信息架构实现的人事小程序页面。当前默认使用静态模拟数据，真实 API 适配层已保留。',
                ),
                style: HrText.resolve(context, HrText.body),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
