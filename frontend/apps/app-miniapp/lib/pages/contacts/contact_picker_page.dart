import 'package:flutter/material.dart';

import '../../localization.dart';
import '../common/page_theme.dart';
import '../common/page_widgets.dart';
import '../common/whatsapp_colors.dart';
import 'contacts_page.dart';

class ContactPickerPage extends StatefulWidget {
  const ContactPickerPage({super.key});

  static Route<String> route() {
    return MaterialPageRoute<String>(builder: (_) => const ContactPickerPage());
  }

  @override
  State<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends State<ContactPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contacts = demoContactNames
        .where(
          (name) => name.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList(growable: false);
    return Scaffold(
      key: const Key('contact-picker-page'),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? scheme.surfaceContainerHigh
                      : const Color(0xFFF3F4F3),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('contact-picker-back'),
                      tooltip: l10n.text('返回', 'Back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: TextField(
                        key: const Key('contact-picker-search'),
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: l10n.text(
                            '姓名、电话号码、@用户名',
                            'Name, phone number, @username',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.text('显示拨号键盘', 'Show dialpad'),
                      onPressed: () => showPageMessage(
                        context,
                        l10n.text('拨号键盘为模拟入口', 'Dialpad is a demo entry'),
                      ),
                      icon: const Icon(Icons.dialpad_rounded),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
              child: Text(
                l10n.text('选择一位联系人发起通话', 'Select a contact to call'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ),
            const Divider(height: 1),
            if (_query.isEmpty) ...[
              _ContactActionRow(
                icon: Icons.link_rounded,
                title: l10n.text('新通话链接', 'New call link'),
                onTap: () => showPageMessage(
                  context,
                  l10n.text('新通话链接为模拟入口', 'New call links are a demo entry'),
                ),
              ),
              _ContactActionRow(
                icon: Icons.dialpad_rounded,
                title: l10n.text('拨打电话号码', 'Dial a phone number'),
                onTap: () => showPageMessage(
                  context,
                  l10n.text('拨号为模拟入口', 'Dialing is a demo entry'),
                ),
              ),
              _ContactActionRow(
                icon: Icons.person_add_alt_1_rounded,
                title: l10n.text('添加联系人', 'Add contact'),
                trailing: Icons.qr_code_2_rounded,
                onTap: () => showPageMessage(
                  context,
                  l10n.text('添加联系人为模拟入口', 'Adding contacts is a demo entry'),
                ),
              ),
              _ContactActionRow(
                icon: Icons.calendar_month_rounded,
                title: l10n.text('预约通话', 'Schedule call'),
                onTap: () => showPageMessage(
                  context,
                  l10n.text('预约通话为模拟入口', 'Scheduled calls are a demo entry'),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.text('RuoQi 联系人', 'RuoQi contacts'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final name = contacts[index];
                  return _PickerContactRow(
                    name: name,
                    onTap: () => Navigator.of(context).pop(name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActionRow extends StatelessWidget {
  const _ContactActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            const SizedBox(width: 18),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: WhatsAppColors.brandStrong,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                color: theme.colorScheme.onSurfaceVariant,
                size: 25,
              ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

class _PickerContactRow extends StatelessWidget {
  const _PickerContactRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(left: 18),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: HostChromeStyle.dividerColor(context),
              width: HostChromeStyle.hairline(context),
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.surfaceContainerHigh,
              child: Icon(
                Icons.person_rounded,
                color: scheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.onSurfaceVariant, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
