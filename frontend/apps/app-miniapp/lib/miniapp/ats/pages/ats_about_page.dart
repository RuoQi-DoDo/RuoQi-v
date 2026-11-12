part of 'misc_pages.dart';

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AtsColors.resolve(context, AtsColors.primary),
                    Color(0xFF59D2B2),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AtsColors.resolve(
                      context,
                      AtsColors.primary,
                    ).withValues(alpha: 0.24),
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
          Text(
            '让每一份热爱都有回响',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textMuted),
              fontSize: 12,
            ),
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
                Text(
                  '企业直聘是一款面向求职者与招聘方的移动招聘平台。'
                  '我们通过真实、及时、高效的职位信息与沟通工具，帮助人才找到合适的机会，也帮助企业发现优秀伙伴。',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.textSecondary),
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
          Text(
            '© 2026 企业直聘 · 保留所有权利',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textMuted),
              fontSize: 9,
            ),
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
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.text),
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '更新日期：2026年11月1日  ·  生效日期：2026年11月8日',
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.textMuted),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 22),
        if (isTerms) ..._termsSections else ..._privacySections,
        const SizedBox(height: 30),
        Text(
          '如对本协议或隐私政策有任何疑问，可通过「我的 - 在线客服」联系我们。',
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.textMuted),
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
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.text),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textSecondary),
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
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.textMuted),
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.text),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
