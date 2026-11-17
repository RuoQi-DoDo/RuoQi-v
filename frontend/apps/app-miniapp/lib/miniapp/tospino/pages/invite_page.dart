import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoInvitePage extends StatelessWidget {
  const TospinoInvitePage({super.key, required this.controller});

  final TospinoAppController controller;

  Future<void> _copyCode(BuildContext context) async {
    final code = controller.inviteInfo?.promoteCode ?? '';
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      showTospinoToast(context, '邀请码已复制');
    }
  }

  Future<void> _share(BuildContext context) async {
    final renderBox = context.findRenderObject();
    final origin = renderBox is RenderBox && renderBox.hasSize
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : null;
    try {
      await controller.shareInviteContent(sharePositionOrigin: origin);
    } catch (error) {
      if (context.mounted) showTospinoToast(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = controller.inviteInfo;
    if (controller.loadingInvite && info == null) {
      return const Center(
        key: Key('tospino-invite-page'),
        child: CircularProgressIndicator(),
      );
    }
    if (controller.inviteError != null && info == null) {
      return Center(
        key: const Key('tospino-invite-page'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.inviteError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.loadInvite,
                child: Text(localizeMiniProgramLabel(context, '重试')),
              ),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      key: const Key('tospino-invite-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: RefreshIndicator(
        onRefresh: controller.loadInvite,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          children: [
            _InviteHero(
              info: info,
              onCopy: () => _copyCode(context),
              onShare: () => _share(context),
            ),
            const SizedBox(height: 10),
            _InviteRewardCard(
              amount: controller.inviteRewardAmount,
              onTap: controller.openInviteRewards,
            ),
            const SizedBox(height: 10),
            _InviteSteps(),
            const SizedBox(height: 10),
            _InviteFriendsSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _InviteHero extends StatelessWidget {
  const _InviteHero({
    required this.info,
    required this.onCopy,
    required this.onShare,
  });

  final TospinoInviteInfo? info;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D8A62), Color(0xFF15B781), Color(0xFFF1A534)],
          stops: [0, 0.68, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: TospinoColors.brand.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '邀请好友一起逛 Tospino'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: TospinoText.strong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizeMiniProgramLabel(context, '好友注册成功后，你可以获得邀请奖励'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeMiniProgramLabel(context, '我的邀请码'),
                        style: TospinoText.meta(context),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        info?.promoteCode.isNotEmpty == true
                            ? info!.promoteCode
                            : '--',
                        key: const Key('tospino-invite-code'),
                        style: TextStyle(
                          color: TospinoColors.solidBrand(context),
                          fontSize: 24,
                          fontWeight: TospinoText.strong,
                          letterSpacing: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: const Key('tospino-invite-copy-code'),
                  tooltip: localizeMiniProgramLabel(context, '复制邀请码'),
                  onPressed: info?.promoteCode.isNotEmpty == true
                      ? onCopy
                      : null,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('tospino-invite-share'),
              onPressed: info == null ? null : onShare,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TospinoColors.brandDeep,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 19),
              label: Text(
                localizeMiniProgramLabel(context, '分享邀请'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteRewardCard extends StatelessWidget {
  const _InviteRewardCard({required this.amount, required this.onTap});

  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('tospino-invite-rewards'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFD47B00),
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '我的邀请奖励'),
                      style: TospinoText.bodyStrong(context),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      localizeMiniProgramLabel(context, '查看奖励明细和邀请记录'),
                      style: TospinoText.meta(context),
                    ),
                  ],
                ),
              ),
              Text(
                'GH₵${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: TospinoColors.resolve(context, TospinoColors.price),
                  fontSize: 18,
                  fontWeight: TospinoText.strong,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: TospinoColors.resolve(context, TospinoColors.hint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', '分享邀请码', '把邀请码或邀请链接发给好友'),
      ('2', '好友注册', '好友注册时填写你的邀请码'),
      ('3', '获得奖励', '好友完成注册后奖励自动到账'),
    ];
    return TospinoSurface(
      radius: 16,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizeMiniProgramLabel(context, '如何邀请好友'),
            style: TospinoText.section(context),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.brandPale,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    steps[index].$1,
                    style: TextStyle(
                      color: TospinoColors.solidBrand(context),
                      fontSize: 12,
                      fontWeight: TospinoText.strong,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeMiniProgramLabel(context, steps[index].$2),
                        style: TospinoText.bodyStrong(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizeMiniProgramLabel(context, steps[index].$3),
                        style: TospinoText.meta(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != steps.length - 1) const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

class _InviteFriendsSection extends StatelessWidget {
  const _InviteFriendsSection({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final friends = controller.inviteFriends;
    return TospinoSurface(
      radius: 16,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                localizeMiniProgramLabel(context, '邀请记录'),
                style: TospinoText.section(context),
              ),
              const Spacer(),
              Text(
                '${localizeMiniProgramLabel(context, '累计邀请')} '
                '${controller.inviteFriendsTotal}',
                key: const Key('tospino-invite-total'),
                style: TospinoText.meta(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (friends.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  localizeMiniProgramLabel(context, '还没有邀请好友'),
                  style: TospinoText.secondary(context),
                ),
              ),
            )
          else
            for (var index = 0; index < friends.length; index++) ...[
              _InviteFriendRow(friend: friends[index]),
              if (index != friends.length - 1)
                Divider(
                  height: 21,
                  color: TospinoColors.resolve(context, TospinoColors.line),
                ),
            ],
          if (controller.hasMoreInviteFriends) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                key: const Key('tospino-invite-load-more'),
                onPressed: controller.loadingMoreInviteFriends
                    ? null
                    : controller.loadMoreInviteFriends,
                child: controller.loadingMoreInviteFriends
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(localizeMiniProgramLabel(context, '查看更多邀请记录')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteFriendRow extends StatelessWidget {
  const _InviteFriendRow({required this.friend});

  final TospinoInviteFriend friend;

  @override
  Widget build(BuildContext context) {
    final name = friend.displayName;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TospinoColors.resolve(context, TospinoColors.brandPale),
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: TextStyle(
              color: TospinoColors.solidBrand(context),
              fontWeight: TospinoText.strong,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.bodyStrong(context),
              ),
              if (friend.registrationTime.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '${localizeMiniProgramLabel(context, '注册时间')} '
                  '${friend.registrationTime}',
                  style: TospinoText.meta(context),
                ),
              ],
            ],
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: TospinoColors.solidBrand(context),
        ),
      ],
    );
  }
}
