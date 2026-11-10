part of 'customer_home_page.dart';

class _ContactsPage extends StatelessWidget {
  const _ContactsPage({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          key: const Key('contacts-page'),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            _WeChatListGroup(
              children: [
                _WeChatListRow(
                  icon: Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF07C160),
                  title: '新的朋友',
                  onTap: () => onTap('新的朋友为模拟入口'),
                ),
                _WeChatListRow(
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF07C160),
                  title: '群聊',
                  onTap: () => onTap('群聊为模拟入口'),
                ),
                _WeChatListRow(
                  icon: Icons.sell_outlined,
                  color: const Color(0xFF2F88FF),
                  title: '标签',
                  onTap: () => onTap('标签为模拟入口'),
                ),
                _WeChatListRow(
                  icon: Icons.article_outlined,
                  color: const Color(0xFF2F88FF),
                  title: '公众号',
                  onTap: () => onTap('公众号为模拟入口'),
                ),
              ],
            ),
            const _ContactsLetterHeader('A'),
            for (final name in ['Annie', '阿杰', '安然'])
              _ContactsPersonRow(name: name, onTap: onTap),
            const _ContactsLetterHeader('B'),
            _ContactsPersonRow(name: '白露', onTap: onTap),
            const _ContactsLetterHeader('C'),
            for (final name in ['蔡七七', '陈晨', '程一鸣'])
              _ContactsPersonRow(name: name, onTap: onTap),
            const _ContactsLetterHeader('H'),
            for (final name in ['韩梅', '何川'])
              _ContactsPersonRow(name: name, onTap: onTap),
            const _ContactsLetterHeader('L'),
            for (final name in ['林小满', '刘洋'])
              _ContactsPersonRow(name: name, onTap: onTap),
            const _ContactsLetterHeader('W'),
            for (final name in ['王佳', '吴桐'])
              _ContactsPersonRow(name: name, onTap: onTap),
            const _ContactsLetterHeader('Z'),
            for (final name in ['张一诺', '周舟'])
              _ContactsPersonRow(name: name, onTap: onTap),
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
      label: '通讯录字母索引',
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
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => onTap('$name 的联系人详情为模拟入口'),
        child: Container(
          height: 62,
          margin: const EdgeInsets.only(left: 18),
          padding: const EdgeInsets.only(right: 18),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
