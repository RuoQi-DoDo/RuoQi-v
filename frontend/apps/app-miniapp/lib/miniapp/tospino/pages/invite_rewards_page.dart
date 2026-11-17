import 'package:material_ui/material_ui.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoInviteRewardsPage extends StatelessWidget {
  const TospinoInviteRewardsPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final records = controller.inviteRewardRecords;
    if (controller.loadingInviteRewards && records.isEmpty) {
      return const Center(
        key: Key('tospino-invite-rewards-page'),
        child: CircularProgressIndicator(),
      );
    }
    if (controller.inviteRewardsError != null && records.isEmpty) {
      return Center(
        key: const Key('tospino-invite-rewards-page'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.inviteRewardsError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.loadInviteRewards,
                child: Text(localizeMiniProgramLabel(context, '重试')),
              ),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      key: const Key('tospino-invite-rewards-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: RefreshIndicator(
        onRefresh: controller.loadInviteRewards,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB347), Color(0xFFF18824)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        localizeMiniProgramLabel(context, '累计邀请奖励'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: TospinoText.strong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'GH₵${controller.inviteRewardAmount.toStringAsFixed(2)}',
                    key: const Key('tospino-invite-reward-total'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: TospinoText.strong,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${localizeMiniProgramLabel(context, '奖励记录')} '
                    '${controller.inviteRewardsTotal}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TospinoSurface(
              radius: 16,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeMiniProgramLabel(context, '奖励明细'),
                    style: TospinoText.section(context),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Center(
                        child: Text(
                          localizeMiniProgramLabel(context, '暂无邀请奖励'),
                          style: TospinoText.secondary(context),
                        ),
                      ),
                    )
                  else
                    for (var index = 0; index < records.length; index++) ...[
                      _RewardRow(record: records[index]),
                      if (index != records.length - 1)
                        Divider(
                          height: 22,
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.line,
                          ),
                        ),
                    ],
                  if (controller.hasMoreInviteRewards) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        key: const Key('tospino-invite-rewards-load-more'),
                        onPressed: controller.loadingMoreInviteRewards
                            ? null
                            : controller.loadMoreInviteRewards,
                        child: controller.loadingMoreInviteRewards
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                localizeMiniProgramLabel(context, '查看更多奖励记录'),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.record});

  final TospinoInviteRewardRecord record;

  @override
  Widget build(BuildContext context) {
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
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 20,
            color: TospinoColors.solidBrand(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.account.isEmpty
                    ? localizeMiniProgramLabel(context, '新好友')
                    : record.account,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.bodyStrong(context),
              ),
              const SizedBox(height: 2),
              Text(
                record.registerTime.isEmpty
                    ? localizeMiniProgramLabel(context, '好友注册奖励')
                    : '${localizeMiniProgramLabel(context, '注册时间')} '
                          '${record.registerTime}',
                style: TospinoText.meta(context),
              ),
            ],
          ),
        ),
        Text(
          '+GH₵${record.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: TospinoColors.resolve(context, TospinoColors.price),
            fontSize: 15,
            fontWeight: TospinoText.strong,
          ),
        ),
      ],
    );
  }
}
