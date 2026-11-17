import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

Future<bool> showTospinoCancelOrderFlow(
  BuildContext context,
  TospinoAppController controller,
  TospinoOrder order,
) async {
  final reason = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _CancelOrderSheet(controller: controller, order: order),
  );
  if (reason == null || !context.mounted) return false;
  try {
    await controller.cancelOrder(order, reason);
    if (context.mounted) showTospinoToast(context, '订单已取消');
    return true;
  } catch (error) {
    if (context.mounted) showTospinoToast(context, error.toString());
    return false;
  }
}

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet({required this.controller, required this.order});

  final TospinoAppController controller;
  final TospinoOrder order;

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  late Future<List<TospinoCancelReason>> _reasons;
  TospinoCancelReason? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reasons = widget.controller.fetchCancelOrderReasons();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return FractionallySizedBox(
      heightFactor: 0.76,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.lineStrong,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizeMiniProgramLabel(context, '取消订单的原因'),
                            style: TospinoText.pageTitle(
                              context,
                            ).copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizeMiniProgramLabel(
                              context,
                              '订单取消后无法恢复，请选择取消原因。',
                            ),
                            style: TospinoText.meta(context),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('tospino-cancel-order-close'),
                      tooltip: localizeMiniProgramLabel(context, '关闭'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<TospinoCancelReason>>(
                  future: _reasons,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                setState(_load);
                              },
                              child: Text(
                                localizeMiniProgramLabel(context, '重试'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final reasons = snapshot.data ?? const [];
                    return ListView.separated(
                      key: const Key('tospino-cancel-reason-list'),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: reasons.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final reason = reasons[index];
                        final selected = identical(_selected, reason);
                        return Material(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.surface,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            key: Key('tospino-cancel-reason-${reason.id}'),
                            onTap: () => setState(() => _selected = reason),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 21,
                                    color: selected
                                        ? TospinoColors.solidBrand(context)
                                        : TospinoColors.resolve(
                                            context,
                                            TospinoColors.hint,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      localizeMiniProgramLabel(
                                        context,
                                        reason.reason,
                                      ),
                                      style: TospinoText.body(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(context, TospinoColors.surface),
                  border: Border(
                    top: BorderSide(
                      color: TospinoColors.resolve(context, TospinoColors.line),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: TospinoGradientButton(
                    key: const Key('tospino-cancel-order-confirm'),
                    label: '确认取消订单',
                    onPressed: _selected == null
                        ? null
                        : () => Navigator.of(context).pop(_selected!.reason),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
