import 'package:flutter/material.dart';

import '../ats_models.dart';
import '../ats_routes.dart';
import '../ats_style.dart';

class AtsSettingsPage extends StatefulWidget {
  const AtsSettingsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsSettingsPage> createState() => _AtsSettingsPageState();
}

class _AtsSettingsPageState extends State<AtsSettingsPage> {
  bool _notifications = true;
  bool _recommendations = true;
  bool _wifiOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '消息通知',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '接收面试、投递和聊天消息提醒',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _recommendations,
                onChanged: (value) => setState(() => _recommendations = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '个性化推荐',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '根据简历和浏览记录推荐职位',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _wifiOnly,
                onChanged: (value) => setState(() => _wifiOnly = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '仅 Wi-Fi 下载',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '账号与偏好'),
        AtsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AtsListRow(
                icon: Icons.person_outline,
                title: '账号与安全',
                onTap: () => widget.controller.open(AtsRoute.userInfo),
              ),
              AtsListRow(
                icon: Icons.delete_outline,
                title: '清除缓存',
                trailing: const Text(
                  '28.6 MB',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
                ),
                onTap: () => _showClearCache(context),
              ),
              AtsListRow(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: () => widget.controller.open(AtsRoute.terms),
              ),
              AtsListRow(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () => widget.controller.open(AtsRoute.privacy),
              ),
              AtsListRow(
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: () => widget.controller.open(AtsRoute.aboutUs),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AtsPrimaryButton(
          label: '退出登录',
          backgroundColor: const Color(0xFFFFF0F0),
          foregroundColor: AtsColors.red,
          onPressed: () => _showLogout(context),
        ),
        const SizedBox(height: 22),
        const Text(
          '企业直聘 v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  void _showClearCache(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定清除图片和临时文件缓存吗？不会删除你的简历和投递记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              atsToast(context, '缓存已清除');
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('退出后仍可浏览职位，投递和聊天需要重新登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.logout();
            },
            style: TextButton.styleFrom(foregroundColor: AtsColors.red),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}

class AtsAboutPage extends StatelessWidget {
  const AtsAboutPage({
    super.key,
    this.controller,
    this.type = AtsAboutType.about,
  });

  final AtsAppController? controller;
  final AtsAboutType type;

  @override
  Widget build(BuildContext context) {
    if (type == AtsAboutType.about) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 36, 22, 24),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AtsColors.primary, Color(0xFF59D2B2)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AtsColors.primary.withValues(alpha: 0.24),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '企业直聘',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            '让每一份热爱都有回响',
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 34),
          AtsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '关于企业直聘',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  '企业直聘是一款面向求职者与招聘方的移动招聘平台。'
                  '我们通过真实、及时、高效的职位信息与沟通工具，帮助人才找到合适的机会，也帮助企业发现优秀伙伴。',
                  style: TextStyle(
                    color: AtsColors.textSecondary,
                    fontSize: 13,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 18),
                _AboutInfoRow(label: '当前版本', value: '1.0.0'),
                const SizedBox(height: 10),
                _AboutInfoRow(label: '客服邮箱', value: 'support@wuyoujobs.com'),
                const SizedBox(height: 10),
                _AboutInfoRow(label: '服务时间', value: '工作日 09:00-18:00'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AtsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AtsListRow(
                  icon: Icons.article_outlined,
                  title: '用户协议',
                  onTap: controller == null
                      ? null
                      : () => controller!.open(AtsRoute.terms),
                ),
                AtsListRow(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  onTap: controller == null
                      ? null
                      : () => controller!.open(AtsRoute.privacy),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            '© 2026 企业直聘 · 保留所有权利',
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.textMuted, fontSize: 9),
          ),
        ],
      );
    }
    return _LegalContent(type: type);
  }
}

enum AtsAboutType { about, terms, privacy }

class _LegalContent extends StatelessWidget {
  const _LegalContent({required this.type});

  final AtsAboutType type;

  @override
  Widget build(BuildContext context) {
    final isTerms = type == AtsAboutType.terms;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isTerms ? '企业直聘用户服务协议' : '企业直聘隐私政策',
          style: const TextStyle(
            color: AtsColors.text,
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '更新日期：2026年11月1日  ·  生效日期：2026年11月8日',
          style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 22),
        if (isTerms) ..._termsSections else ..._privacySections,
        const SizedBox(height: 30),
        const Text(
          '如对本协议或隐私政策有任何疑问，可通过「我的 - 在线客服」联系我们。',
          style: TextStyle(
            color: AtsColors.textMuted,
            fontSize: 12,
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

const _termsSections = <Widget>[
  _LegalSection(
    title: '一、服务说明',
    body:
        '企业直聘为用户提供职位浏览、简历管理、职位发布、在线沟通及相关人力资源信息服务。'
        '用户在使用服务前，应认真阅读并同意本协议。',
  ),
  _LegalSection(
    title: '二、账号注册与使用',
    body:
        '用户应使用真实、合法、有效的信息注册账号，并妥善保管账号和验证码。'
        '因用户主动泄露信息造成的损失，由用户自行承担；发现异常登录时应及时联系我们。',
  ),
  _LegalSection(
    title: '三、信息发布规范',
    body:
        '招聘方发布的信息应真实、准确，不得发布虚假招聘、收取费用、歧视性内容或其他违反法律法规的信息。'
        '平台有权对违规内容进行下架、限制账号功能或终止服务。',
  ),
  _LegalSection(
    title: '四、简历与沟通',
    body:
        '求职者应确保简历信息真实。双方在沟通过程中应遵守法律法规和公序良俗，'
        '不得利用平台从事骚扰、欺诈或其他不当行为。',
  ),
  _LegalSection(
    title: '五、知识产权',
    body:
        '平台界面、商标、文字、图形及相关内容的知识产权归平台或合法权利人所有。'
        '未经书面许可，任何主体不得复制、修改、传播或用于商业目的。',
  ),
  _LegalSection(
    title: '六、协议变更',
    body:
        '我们可能根据业务发展和法律法规变化更新本协议。更新后将通过站内通知等方式提示，'
        '继续使用服务即表示接受更新后的协议。',
  ),
];

const _privacySections = <Widget>[
  _LegalSection(
    title: '一、我们收集的信息',
    body:
        '为提供招聘服务，我们会收集你主动填写的账号、简历、求职期望、联系方式，'
        '以及使用服务过程中产生的浏览、收藏、投递和沟通记录。',
  ),
  _LegalSection(
    title: '二、信息的使用',
    body:
        '我们使用相关信息为你推荐职位、展示简历、完成招聘沟通、保障账号安全，'
        '并在取得授权后发送服务通知。不会将简历出售给第三方。',
  ),
  _LegalSection(
    title: '三、信息的共享',
    body:
        '仅在你投递职位、主动沟通或开启简历可见时，向相应招聘方展示必要信息。'
        '为完成基础服务，我们可能委托合规服务商处理数据，并要求其履行保密义务。',
  ),
  _LegalSection(
    title: '四、你的权利',
    body:
        '你可以在个人信息和隐私设置中查询、更正、删除资料，或调整简历可见范围。'
        '如需注销账号或导出个人信息，可通过客服联系我们。',
  ),
  _LegalSection(
    title: '五、信息安全',
    body:
        '我们采用访问控制、传输加密、数据备份等措施保护个人信息。'
        '互联网服务仍可能存在风险，请勿在公开聊天中泄露身份证、银行卡等敏感信息。',
  ),
];

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AtsColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AtsColors.textSecondary,
              fontSize: 13,
              height: 1.85,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutInfoRow extends StatelessWidget {
  const _AboutInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AtsColors.textMuted, fontSize: 11),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AtsColors.text, fontSize: 11),
        ),
      ],
    );
  }
}

class AtsHelpPage extends StatelessWidget {
  const AtsHelpPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    const groups = <String, List<String>>{
      '账号与登录': ['如何更换绑定手机号？', '忘记密码怎么办？', '如何切换求职/招聘身份？'],
      '简历与投递': ['如何提高简历曝光？', '投递后多久有反馈？', '如何撤回投递？'],
      '企业招聘': ['如何完成企业认证？', '职位审核需要多久？', '如何邀请候选人面试？'],
      '安全与隐私': ['如何屏蔽企业？', '收到收费信息怎么办？'],
    };
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AtsColors.primary, Color(0xFF58D2B2)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '有什么可以帮你？',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '查看常见问题，或联系在线客服',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.help_outline_rounded,
                size: 64,
                color: Color(0x35FFFFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AtsCard(
          color: AtsColors.mint,
          onTap: () => controller.open(AtsRoute.robot),
          child: const Row(
            children: [
              Icon(Icons.support_agent, color: AtsColors.primary, size: 26),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '在线客服',
                      style: TextStyle(
                        color: AtsColors.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '智能客服 7×24 小时在线',
                      style: TextStyle(color: AtsColors.primary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AtsColors.primary, size: 20),
            ],
          ),
        ),
        for (final entry in groups.entries) ...[
          AtsSectionHeader(title: entry.key),
          AtsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entry.value.length; i++)
                  AtsListRow(
                    icon: Icons.help_outline,
                    title: entry.value[i],
                    onTap: () => controller.open(AtsRoute.helpDetail),
                    showDivider: i != entry.value.length - 1,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class AtsHelpDetailPage extends StatelessWidget {
  const AtsHelpDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '如何提高简历曝光？',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '更新于 2026-11-01 · 约 2 分钟阅读',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),
              const Text(
                '一份完整、真实的简历更容易获得招聘方关注。建议你从以下方面完善：',
                style: TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 14),
              for (final item in const [
                ('补全基本信息', '填写年龄、学历、工作经验和求职状态。'),
                ('明确求职期望', '选择与经历匹配的岗位、行业和薪资范围。'),
                ('突出工作成果', '用数字说明你完成了什么、带来了什么变化。'),
                ('保持活跃', '定期更新求职状态，并在工作日及时回复消息。'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AtsColors.mint,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check,
                          color: AtsColors.primary,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: AtsColors.textSecondary,
                                fontSize: 12,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              AtsPrimaryButton(
                label: '去完善简历',
                onPressed: () => atsToast(context, '请从「我的 - 我的简历」进入'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AtsContactPage extends StatefulWidget {
  const AtsContactPage({super.key});

  @override
  State<AtsContactPage> createState() => _AtsContactPageState();
}

class _AtsContactPageState extends State<AtsContactPage> {
  final _content = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: AtsColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: AtsColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '企业直聘客服',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                '工作日 09:00 - 18:00',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              _ContactLine(
                icon: Icons.phone_outlined,
                label: '客服电话',
                value: '400-800-6688',
                onTap: () => atsToast(context, '正在拨号 400-800-6688'),
              ),
              const Divider(height: 1),
              _ContactLine(
                icon: Icons.mail_outline,
                label: '客服邮箱',
                value: 'support@wuyoujobs.com',
                onTap: () => atsToast(context, '邮箱地址已复制'),
              ),
              const Divider(height: 1),
              _ContactLine(
                icon: Icons.location_on_outlined,
                label: '公司地址',
                value: '上海市浦东新区张江路 88 号',
                onTap: () => atsToast(context, '正在打开地图导航'),
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
                '意见反馈',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              const Text(
                '你的建议会帮助我们做得更好',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                maxLines: 5,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: '请描述你遇到的问题或建议',
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              AtsPrimaryButton(
                label: '提交反馈',
                onPressed: () {
                  if (_content.text.trim().isEmpty) {
                    atsToast(context, '请输入反馈内容');
                    return;
                  }
                  _content.clear();
                  FocusScope.of(context).unfocus();
                  atsToast(context, '感谢反馈，我们会尽快处理');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: AtsColors.primary, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 68,
              child: Text(
                label,
                style: const TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AtsColors.text, fontSize: 12),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AtsColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class AtsLoginPage extends StatelessWidget {
  const AtsLoginPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF3FCF9)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 44, 28, 24),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AtsColors.primary, Color(0xFF5DD5B6)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AtsColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '欢迎来到企业直聘',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '登录后收藏职位、投递简历并与招聘方沟通',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 44),
          AtsPrimaryButton(
            label: '微信一键登录',
            icon: Icons.chat_bubble_outline,
            onPressed: () {
              controller.login();
              atsToast(context, '登录成功');
            },
          ),
          const SizedBox(height: 12),
          AtsOutlineButton(
            label: '手机号验证码登录',
            icon: Icons.phone_iphone,
            onPressed: () => controller.open(AtsRoute.bindPhone),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Divider(color: AtsColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '还没有账号？',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider(color: AtsColors.divider)),
            ],
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => controller.open(AtsRoute.loginIndex),
            style: TextButton.styleFrom(foregroundColor: AtsColors.primary),
            child: const Text('立即注册'),
          ),
          const SizedBox(height: 34),
          const Text(
            '登录即代表你已阅读并同意',
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 3),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '《用户协议》'),
                TextSpan(text: ' 和 '),
                TextSpan(text: '《隐私政策》'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.primary, fontSize: 9),
          ),
          const SizedBox(height: 22),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AtsColors.textMuted,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '信息安全保护中',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AtsLoginIndexPage extends StatelessWidget {
  const AtsLoginIndexPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    const benefits = [
      (Icons.bolt_outlined, '快速投递', '一键发送简历'),
      (Icons.notifications_active_outlined, '实时反馈', '进度及时提醒'),
      (Icons.security_outlined, '真实企业', '严格资质审核'),
      (Icons.support_agent, '专属客服', '全程贴心服务'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      children: [
        const Text(
          '找到更需要你的地方',
          style: TextStyle(
            color: AtsColors.text,
            fontSize: 25,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          '注册企业直聘，开启更好的职业旅程',
          style: TextStyle(color: AtsColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 28),
        Container(
          height: 148,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AtsColors.primary, Color(0xFF51CFAF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -18,
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 130,
                  color: Color(0x24FFFFFF),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '好机会，从这里开始',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '已有超过 120 万求职者加入',
                    style: TextStyle(color: Color(0xDFFFFFFF), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: benefits.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 116,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = benefits[index];
            return AtsCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$1, color: AtsColors.primary, size: 27),
                  const SizedBox(height: 8),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$3,
                    style: const TextStyle(
                      color: AtsColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        AtsPrimaryButton(
          label: '立即注册',
          onPressed: () => controller.open(AtsRoute.register),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => controller.back(),
          child: const Text('已有账号，去登录'),
        ),
      ],
    );
  }
}

class AtsRegisterPage extends StatefulWidget {
  const AtsRegisterPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsRegisterPage> createState() => _AtsRegisterPageState();
}

class _AtsRegisterPageState extends State<AtsRegisterPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = true;
  int _countdown = 0;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phone.text.trim().length != 11) {
      atsToast(context, '请输入 11 位手机号');
      return;
    }
    setState(() => _countdown = 60);
    while (_countdown > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdown--);
      }
    }
  }

  void _register() {
    if (_phone.text.trim().length != 11 ||
        _code.text.trim().isEmpty ||
        _password.text.length < 6) {
      atsToast(context, '请完整填写手机号、验证码和密码');
      return;
    }
    if (!_agreed) {
      atsToast(context, '请先同意用户协议和隐私政策');
      return;
    }
    widget.controller.open(AtsRoute.registerSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const Text(
                '创建账号',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              const Text(
                '注册完成后，可根据需要选择求职者或招聘者身份',
                style: TextStyle(
                  color: AtsColors.textMuted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone_iphone, size: 20),
                  counterText: '',
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '请输入验证码',
                        prefixIcon: Icon(Icons.shield_outlined, size: 20),
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 104,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _countdown == 0 ? _sendCode : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AtsColors.primary,
                        side: const BorderSide(color: AtsColors.primary),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _countdown == 0 ? '获取验证码' : '${_countdown}s',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '请设置登录密码（至少 6 位）',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                      activeColor: AtsColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '我已阅读并同意'),
                          TextSpan(
                            text: '《用户协议》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 10,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          color: Colors.white,
          child: AtsPrimaryButton(label: '注册', onPressed: _register),
        ),
      ],
    );
  }
}

class AtsRegisterSuccessPage extends StatelessWidget {
  const AtsRegisterSuccessPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AtsColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AtsColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '注册成功',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            const Text(
              '欢迎加入企业直聘。现在可以完善简历，\n让合适的机会更快找到你。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AtsColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: AtsPrimaryButton(
                label: '进入首页',
                onPressed: () {
                  controller.login();
                  atsToast(context, '欢迎来到企业直聘');
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              child: TextButton(
                onPressed: () {
                  controller.login();
                  controller.open(AtsRoute.resume);
                },
                child: const Text('去完善简历'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AtsBindPhonePage extends StatefulWidget {
  const AtsBindPhonePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsBindPhonePage> createState() => _AtsBindPhonePageState();
}

class _AtsBindPhonePageState extends State<AtsBindPhonePage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
      children: [
        const Icon(Icons.shield_outlined, color: AtsColors.primary, size: 46),
        const SizedBox(height: 14),
        const Text(
          '手机号快捷登录',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          '未注册的手机号验证后将自动创建账号',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 34),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: const InputDecoration(
            hintText: '请输入手机号',
            prefixText: '+86  ',
            counterText: '',
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '请输入验证码',
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  if (_phone.text.trim().length != 11) {
                    atsToast(context, '请输入 11 位手机号');
                    return;
                  }
                  atsToast(context, '验证码已发送');
                },
                child: const Text('获取验证码'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AtsPrimaryButton(
          label: '登录 / 注册',
          onPressed: () {
            widget.controller.login();
            atsToast(context, '登录成功');
          },
        ),
      ],
    );
  }
}

class AtsIndustryPage extends StatefulWidget {
  const AtsIndustryPage({super.key});

  @override
  State<AtsIndustryPage> createState() => _AtsIndustryPageState();
}

class _AtsIndustryPageState extends State<AtsIndustryPage> {
  String _selected = atsIndustries.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const AtsSectionHeader(title: '热门行业'),
              AtsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < atsIndustries.length; i++)
                      _SelectionRow(
                        label: atsIndustries[i],
                        selected: _selected == atsIndustries[i],
                        onTap: () =>
                            setState(() => _selected = atsIndustries[i]),
                        showDivider: i != atsIndustries.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          color: Colors.white,
          child: AtsPrimaryButton(
            label: '确认选择',
            onPressed: () {
              atsToast(context, '已选择：$_selected');
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ],
    );
  }
}

class AtsPostPage extends StatefulWidget {
  const AtsPostPage({super.key});

  @override
  State<AtsPostPage> createState() => _AtsPostPageState();
}

class _AtsPostPageState extends State<AtsPostPage> {
  String _selected = atsPositions.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const AtsSectionHeader(title: '热门岗位'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final position in atsPositions)
                    ChoiceChip(
                      label: Text(position),
                      selected: _selected == position,
                      onSelected: (_) => setState(() => _selected = position),
                      selectedColor: AtsColors.mint,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _selected == position
                            ? AtsColors.primary
                            : AtsColors.divider,
                      ),
                      labelStyle: TextStyle(
                        color: _selected == position
                            ? AtsColors.primary
                            : AtsColors.textSecondary,
                        fontSize: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const AtsSectionHeader(title: '全部岗位'),
              AtsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final position in atsHotPosts)
                      _SelectionRow(
                        label: position,
                        selected: _selected == position,
                        onTap: () => setState(() => _selected = position),
                        showDivider: position != atsHotPosts.last,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          color: Colors.white,
          child: AtsPrimaryButton(
            label: _selected.isEmpty ? '请选择岗位' : '搜索 “$_selected”',
            onPressed: () {
              atsToast(context, '正在搜索：$_selected');
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ],
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? AtsColors.primary : AtsColors.text,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check, color: AtsColors.primary, size: 19),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 14, endIndent: 14),
      ],
    );
  }
}
