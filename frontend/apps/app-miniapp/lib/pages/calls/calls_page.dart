import 'package:flutter/material.dart';

import '../../localization.dart';
import '../common/page_theme.dart';
import '../common/page_widgets.dart';
import '../common/whatsapp_colors.dart';
import '../contacts/contact_picker_page.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key, this.embedded = false});

  final bool embedded;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CallsPage());

  @override
  Widget build(BuildContext context) {
    return SharedPageFrame(
      embedded: embedded,
      title: '通话',
      builder: (context) {
        final calls = _callEntries(context);
        return Stack(
          children: [
            ListView.separated(
              key: const Key('calls-page'),
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: calls.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(left: 82),
                child: Divider(
                  height: HostChromeStyle.hairline(context),
                  thickness: HostChromeStyle.hairline(context),
                  color: HostChromeStyle.dividerColor(context),
                ),
              ),
              itemBuilder: (context, index) {
                final call = calls[index];
                return _CallRow(
                  call: call,
                  onTap: () => showPageMessage(
                    context,
                    AppLocalizations.of(context).text(
                      '${call.name}的通话详情为模拟入口',
                      'Call details for ${call.name} are a demo entry',
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: FloatingActionButton(
                key: const Key('new-call-button'),
                tooltip: AppLocalizations.of(context).text('发起通话', 'New call'),
                onPressed: () => _openContactsForCall(context),
                backgroundColor: WhatsAppColors.brandStrong,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add_call),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openContactsForCall(BuildContext context) async {
    final selected = await Navigator.of(
      context,
    ).push<String>(ContactPickerPage.route());
    if (!context.mounted || selected == null) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!context.mounted) {
      return;
    }
    showPageMessage(
      context,
      AppLocalizations.of(
        context,
      ).text('正在呼叫 $selected（模拟）', 'Calling $selected (demo)'),
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.call, required this.onTap});

  final _CallEntry call;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final missed = call.type == _CallType.missed;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.surfaceContainerHigh,
                foregroundColor: scheme.onSurfaceVariant,
                child: const Icon(Icons.person_rounded, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          missed
                              ? Icons.call_missed_rounded
                              : call.type == _CallType.outgoing
                              ? Icons.call_made_rounded
                              : Icons.call_received_rounded,
                          color: missed
                              ? theme.colorScheme.error
                              : WhatsAppColors.brandStrong,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${call.typeLabel(context)} · ${call.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: missed
                                  ? theme.colorScheme.error
                                  : scheme.onSurfaceVariant,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(
                  context,
                ).text('呼叫 ${call.name}', 'Call ${call.name}'),
                onPressed: onTap,
                icon: Icon(
                  Icons.call_outlined,
                  color: WhatsAppColors.brandStrong,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CallType { incoming, outgoing, missed }

class _CallEntry {
  const _CallEntry({
    required this.name,
    required this.type,
    required this.time,
  });

  final String name;
  final _CallType type;
  final String time;

  String typeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      _CallType.incoming => l10n.text('来电', 'Incoming'),
      _CallType.outgoing => l10n.text('去电', 'Outgoing'),
      _CallType.missed => l10n.text('未接来电', 'Missed'),
    };
  }
}

List<_CallEntry> _callEntries(BuildContext context) {
  final text = AppLocalizations.of(context);
  return [
    _CallEntry(
      name: text.text('佳佳', 'Jiajia'),
      type: _CallType.outgoing,
      time: text.text('今天 10:32', 'Today, 10:32'),
    ),
    _CallEntry(
      name: text.text('张老师', 'Teacher Zhang'),
      type: _CallType.incoming,
      time: text.text('昨天 18:20', 'Yesterday, 18:20'),
    ),
    _CallEntry(
      name: text.text('项目协作组', 'Project Team'),
      type: _CallType.missed,
      time: text.text('周一 14:05', 'Monday, 14:05'),
    ),
    _CallEntry(
      name: text.text('林小满', 'Lin Xiaoman'),
      type: _CallType.outgoing,
      time: '11/10',
    ),
    _CallEntry(
      name: text.text('RuoQi 助手', 'RuoQi Assistant'),
      type: _CallType.incoming,
      time: '11/08',
    ),
  ];
}
