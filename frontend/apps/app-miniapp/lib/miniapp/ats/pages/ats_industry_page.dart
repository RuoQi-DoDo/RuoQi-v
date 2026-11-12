part of 'misc_pages.dart';

class AtsIndustryPage extends StatefulWidget {
  const AtsIndustryPage({super.key});

  @override
  State<AtsIndustryPage> createState() => _AtsIndustryPageState();
}

class _AtsIndustryPageState extends State<AtsIndustryPage> {
  String _selected = atsIndustries.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const AtsSectionHeader(title: '热门行业'),
              AtsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < atsIndustries.length; i++)
                      _SelectionRow(
                        label: atsIndustries[i],
                        selected: _selected == atsIndustries[i],
                        onTap: () =>
                            setState(() => _selected = atsIndustries[i]),
                        showDivider: i != atsIndustries.length - 1,
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
            label: '确认选择',
            onPressed: () {
              atsToast(context, '已选择：$_selected');
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ],
    );
  }
}
