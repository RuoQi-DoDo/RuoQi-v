part of 'misc_pages.dart';

class AtsPostPage extends StatefulWidget {
  const AtsPostPage({super.key});

  @override
  State<AtsPostPage> createState() => _AtsPostPageState();
}

class _AtsPostPageState extends State<AtsPostPage> {
  String _selected = atsPositions.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const AtsSectionHeader(title: '热门岗位'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final position in atsPositions)
                    ChoiceChip(
                      label: Text(position),
                      selected: _selected == position,
                      onSelected: (_) => setState(() => _selected = position),
                      selectedColor: AtsColors.resolve(context, AtsColors.mint),
                      backgroundColor: AtsColors.resolve(
                        context,
                        AtsColors.surface,
                      ),
                      side: BorderSide(
                        color: _selected == position
                            ? AtsColors.resolve(context, AtsColors.primary)
                            : AtsColors.resolve(context, AtsColors.divider),
                      ),
                      labelStyle: TextStyle(
                        color: _selected == position
                            ? AtsColors.resolve(context, AtsColors.primary)
                            : AtsColors.resolve(
                                context,
                                AtsColors.textSecondary,
                              ),
                        fontSize: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const AtsSectionHeader(title: '全部岗位'),
              AtsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final position in atsHotPosts)
                      _SelectionRow(
                        label: position,
                        selected: _selected == position,
                        onTap: () => setState(() => _selected = position),
                        showDivider: position != atsHotPosts.last,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          color: AtsColors.resolve(context, AtsColors.surface),
          child: AtsPrimaryButton(
            label: _selected.isEmpty ? '请选择岗位' : '搜索 “$_selected”',
            onPressed: () {
              atsToast(context, '正在搜索：$_selected');
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ],
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AtsColors.resolve(context, AtsColors.primary)
                          : AtsColors.resolve(context, AtsColors.text),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check,
                    color: AtsColors.resolve(context, AtsColors.primary),
                    size: 19,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 14, endIndent: 14),
      ],
    );
  }
}
