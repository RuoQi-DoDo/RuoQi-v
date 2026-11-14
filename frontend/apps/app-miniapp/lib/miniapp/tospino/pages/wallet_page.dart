import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoWalletPage extends StatefulWidget {
  const TospinoWalletPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoWalletPage> createState() => _TospinoWalletPageState();
}

class _TospinoWalletPageState extends State<TospinoWalletPage> {
  final _customAmount = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _customAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.controller.user?.balance ?? 0;
    return ColoredBox(
      key: const Key('tospino-wallet-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TospinoColors.solidBrand(context),
                  TospinoColors.brandDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizeMiniProgramLabel(context, '可用余额'),
                        style: const TextStyle(
                          color: Color(0xFFE8FFFC),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('tospino-wallet-balance-visibility'),
                      onPressed: () => setState(() => _visible = !_visible),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        _visible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  _visible ? 'GH₵ ${balance.toStringAsFixed(2)}' : '****',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: TospinoText.emphasis,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '余额可用于商城消费或提现',
                        style: TextStyle(
                          color: Color(0xFFD8F4F0),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => showTospinoToast(context, '提现功能即将开放'),
                      child: const Text(
                        '提现 ›',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: TospinoText.emphasis,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.24)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => showTospinoToast(context, '暂无收支明细'),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '收支明细',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: TospinoText.emphasis,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '查看收入、支出与账户余额变化',
                              style: TextStyle(
                                color: Color(0xFFD8F4F0),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizeMiniProgramLabel(context, '常用功能'),
            style: TospinoText.section(context),
          ),
          const SizedBox(height: 10),
          TospinoSurface(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                _WalletAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: '提现记录',
                  onTap: () => showTospinoToast(context, '暂无提现记录'),
                ),
                _WalletAction(
                  icon: Icons.receipt_long_outlined,
                  label: '钱包明细',
                  onTap: () => showTospinoToast(context, '暂无钱包明细'),
                ),
                _WalletAction(
                  icon: Icons.credit_card_outlined,
                  label: '卡包',
                  onTap: () => showTospinoToast(context, '暂无银行卡'),
                ),
                _WalletAction(
                  icon: Icons.add_card_outlined,
                  label: '添加支付方式',
                  onTap: () => showTospinoToast(context, '添加支付方式'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TospinoSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeMiniProgramLabel(context, '快捷充值'),
                  style: TospinoText.section(context),
                ),
                const SizedBox(height: 3),
                Text(
                  localizeMiniProgramLabel(context, '选择金额或输入自定义充值金额'),
                  style: TospinoText.hint(context),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.25,
                  children: [
                    for (final amount in const [50, 100, 200, 500, 1000, 2000])
                      OutlinedButton(
                        onPressed: () {
                          _customAmount.text = '$amount';
                        },
                        child: Text('GH₵ $amount'),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('tospino-wallet-custom-amount'),
                  controller: _customAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    hintText: localizeMiniProgramLabel(context, '输入其他充值金额'),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TospinoGradientButton(
                  key: const Key('tospino-wallet-recharge'),
                  label: '立即充值',
                  onPressed: (double.tryParse(_customAmount.text) ?? 0) > 0
                      ? () => showTospinoToast(context, '充值功能即将开放')
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.surfaceMuted,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.secondary,
                  ),
                  size: 23,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizeMiniProgramLabel(context, label),
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TospinoText.meta(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
