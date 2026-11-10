part of 'profile_pages.dart';

class AtsEditExpectationPage extends StatefulWidget {
  const AtsEditExpectationPage({super.key});

  @override
  State<AtsEditExpectationPage> createState() => _AtsEditExpectationPageState();
}

class _AtsEditExpectationPageState extends State<AtsEditExpectationPage> {
  String _jobType = '全职';
  String _position = 'Flutter 开发工程师';
  String _industry = '互联网';
  String _salary = '20-30K';

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '求职期望已保存'),
      children: [
        AtsCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              AtsFormRow(
                label: '求职类型',
                required: true,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '全职', label: Text('全职')),
                    ButtonSegment(value: '兼职', label: Text('兼职')),
                    ButtonSegment(value: '实习', label: Text('实习')),
                  ],
                  selected: {_jobType},
                  onSelectionChanged: (value) {
                    setState(() => _jobType = value.first);
                  },
                  showSelectedIcon: false,
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '期望职位',
                required: true,
                child: _DropdownValue(
                  value: _position,
                  values: atsPositions,
                  onChanged: (value) => setState(() => _position = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '期望行业',
                required: true,
                child: _DropdownValue(
                  value: _industry,
                  values: atsIndustries,
                  onChanged: (value) => setState(() => _industry = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '薪资要求',
                required: true,
                child: _DropdownValue(
                  value: _salary,
                  values: const [
                    '8-12K',
                    '12-20K',
                    '20-30K',
                    '30-40K',
                    '40K以上',
                  ],
                  onChanged: (value) => setState(() => _salary = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
