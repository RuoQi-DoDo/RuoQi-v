import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoCouponsPage extends StatefulWidget {
  const TospinoCouponsPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoCouponsPage> createState() => _TospinoCouponsPageState();
}

class _TospinoCouponsPageState extends State<TospinoCouponsPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.controller.user?.couponCount ?? 0;
    const tabs = ['全部', '店铺券', '平台券'];
    return ColoredBox(
      key: const Key('tospino-coupons-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          ColoredBox(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            child: Row(
              children: [
                for (var index = 0; index < tabs.length; index++)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selected = index),
                      child: SizedBox(
                        height: 46,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              localizeMiniProgramLabel(context, tabs[index]),
                              style: TextStyle(
                                color: index == _selected
                                    ? TospinoColors.solidBrand(context)
                                    : TospinoColors.resolve(
                                        context,
                                        TospinoColors.ink,
                                      ),
                                fontSize: 16,
                                fontWeight: index == _selected
                                    ? TospinoText.emphasis
                                    : TospinoText.regular,
                              ),
                            ),
                            const SizedBox(height: 9),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: index == _selected ? 24 : 0,
                              height: 2,
                              color: TospinoColors.solidBrand(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          Expanded(
            child: count == 0
                ? _CouponEmptyState(
                    onCenter: () => showTospinoToast(context, '领券中心即将开放'),
                  )
                : Center(
                    child: Text(
                      localizeMiniProgramLabel(context, '优惠券加载中'),
                      style: TospinoText.meta(context),
                    ),
                  ),
          ),
          Container(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showTospinoToast(context, '暂无领券历史'),
                      child: Text(localizeMiniProgramLabel(context, '领券记录')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TospinoGradientButton(
                      key: const Key('tospino-coupon-center'),
                      label: '领券中心',
                      onPressed: () => showTospinoToast(context, '领券中心即将开放'),
                      height: 42,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponEmptyState extends StatelessWidget {
  const _CouponEmptyState({required this.onCenter});

  final VoidCallback onCenter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: TospinoColors.resolve(
                context,
                TospinoColors.brandPale,
              ).withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 54,
              color: TospinoColors.brand,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            localizeMiniProgramLabel(context, '暂无可用优惠券'),
            style: TospinoText.section(context),
          ),
          const SizedBox(height: 8),
          Text(
            localizeMiniProgramLabel(context, '去领券中心看看有哪些优惠'),
            style: TospinoText.hint(context),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onCenter,
            child: Text(localizeMiniProgramLabel(context, '去领券')),
          ),
        ],
      ),
    );
  }
}
