import 'package:flutter/material.dart';

import '../common/page_localizations.dart';
import '../common/page_theme.dart';
import '../common/page_widgets.dart';

const demoContactNames = [
  'Annie',
  '阿杰',
  '安然',
  '白露',
  '蔡七七',
  '陈晨',
  '程一鸣',
  '韩梅',
  '何川',
  '林小满',
  '刘洋',
  '王佳',
  '吴桐',
  '张一诺',
  '周舟',
];

class ContactsPage extends StatelessWidget {
  const ContactsPage({
    super.key,
    this.onTap,
    this.onContactSelected,
    this.embedded = false,
    this.selectionMode = false,
    this.title = '通讯录',
  });

  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onContactSelected;
  final bool embedded;
  final bool selectionMode;
  final String title;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ContactsPage());

  @override
  Widget build(BuildContext context) {
    final handleTap = onTap ?? (message) => showPageMessage(context, message);
    return SharedPageFrame(
      embedded: embedded,
      title: title,
      actions: [
        IconButton(
          tooltip: '搜索',
          onPressed: () => handleTap('搜索功能为模拟入口'),
          icon: const Icon(Icons.search_rounded),
        ),
        if (!selectionMode)
          IconButton(
            tooltip: '发起',
            onPressed: () => handleTap('发起功能为模拟入口'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        const SizedBox(width: 6),
      ],
      builder: _buildContent,
    );
  }

  Widget _buildContent(BuildContext context) {
    final onTap = this.onTap ?? (message) => showPageMessage(context, message);
    final onContactSelected =
        this.onContactSelected ?? (name) => onTap('$name 的联系人详情为模拟入口');

    return Stack(
      children: [
        ListView(
          key: const Key('contacts-page'),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (!selectionMode)
              PageListGroup(
                children: [
                  PageListRow(
                    icon: Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF07C160),
                    title: '新的朋友',
                    onTap: () => onTap('新的朋友为模拟入口'),
                  ),
                  PageListRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFFF0A52D),
                    title: '仅聊天的朋友',
                    onTap: () => onTap('仅聊天的朋友为模拟入口'),
                  ),
                  PageListRow(
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF07C160),
                    title: '群聊',
                    onTap: () => onTap('群聊为模拟入口'),
                  ),
                  PageListRow(
                    icon: Icons.sell_outlined,
                    color: const Color(0xFF2F88FF),
                    title: '标签',
                    onTap: () => onTap('标签为模拟入口'),
                  ),
                  PageListRow(
                    icon: Icons.article_outlined,
                    color: const Color(0xFF2F88FF),
                    title: '公众号',
                    onTap: () => onTap('公众号为模拟入口'),
                  ),
                  PageListRow(
                    icon: Icons.business_center_outlined,
                    color: const Color(0xFF2F88FF),
                    title: '服务号',
                    onTap: () => onTap('服务号为模拟入口'),
                  ),
                ],
              ),
            const _ContactsLetterHeader('A'),
            for (final name in ['Annie', '阿杰', '安然'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
            const _ContactsLetterHeader('B'),
            _ContactsPersonRow(
              name: '白露',
              onTap: () => onContactSelected('白露'),
            ),
            const _ContactsLetterHeader('C'),
            for (final name in ['蔡七七', '陈晨', '程一鸣'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
            const _ContactsLetterHeader('H'),
            for (final name in ['韩梅', '何川'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
            const _ContactsLetterHeader('L'),
            for (final name in ['林小满', '刘洋'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
            const _ContactsLetterHeader('W'),
            for (final name in ['王佳', '吴桐'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
            const _ContactsLetterHeader('Z'),
            for (final name in ['张一诺', '周舟'])
              _ContactsPersonRow(
                name: name,
                onTap: () => onContactSelected(name),
              ),
          ],
        ),
        const Positioned(
          right: 3,
          top: 260,
          bottom: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _ContactsAlphabetIndex(),
          ),
        ),
      ],
    );
  }
}

class _ContactsAlphabetIndex extends StatelessWidget {
  const _ContactsAlphabetIndex();

  static const _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: pageLabel(context, '通讯录字母索引'),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final letter in _letters)
              SizedBox(
                height: 10,
                width: 16,
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactsLetterHeader extends StatelessWidget {
  const _ContactsLetterHeader(this.letter);

  final String letter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: 18),
      alignment: Alignment.centerLeft,
      color: theme.colorScheme.surface,
      child: Text(
        letter,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactsPersonRow extends StatelessWidget {
  const _ContactsPersonRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          margin: const EdgeInsets.only(left: 18),
          padding: const EdgeInsets.only(right: 18),
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
                radius: 23,
                backgroundColor: scheme.surfaceContainerHigh,
                child: Text(
                  name.characters.first,
                  style: TextStyle(color: scheme.onSurface),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: HostTypography.listTitle,
                  fontWeight: HostTypography.regular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
