part of 'team_pages.dart';

class HrDirectoryPage extends StatefulWidget {
  const HrDirectoryPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrDirectoryPage> createState() => _HrDirectoryPageState();
}

class _HrDirectoryPageState extends State<HrDirectoryPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final entries = widget.controller.directory.where((entry) {
      if (query.isEmpty) {
        return true;
      }
      return entry.name.toLowerCase().contains(query) ||
          entry.department.toLowerCase().contains(query) ||
          entry.position.toLowerCase().contains(query);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('企业通讯录', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        Text(
          '共 ${widget.controller.directory.length} 位同事 · '
          '可直接查看联系方式',
          style: HrText.meta,
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: '搜索姓名、部门或职位',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const HrEmptyState(
            icon: Icons.search_off_rounded,
            title: '没有找到同事',
            message: '试试搜索姓名、部门或职位关键词。',
          )
        else
          HrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: HrColors.line2,
                    ),
                  InkWell(
                    onTap: () => _showContact(entries[i], i),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 13, 12),
                      child: Row(
                        children: [
                          HrAvatar(
                            name: entries[i].name,
                            index: entries[i].id,
                            size: 42,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].name,
                                  style: HrText.cardTitle.copyWith(
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entries[i].department} · ${entries[i].position}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HrText.meta,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: HrColors.ink4,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showContact(HrDirectoryEntry entry, int index) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: HrColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              HrAvatar(name: entry.name, index: entry.id, size: 64),
              const SizedBox(height: 10),
              Text(
                entry.name,
                style: HrText.appBarTitle.copyWith(fontSize: 21),
              ),
              const SizedBox(height: 3),
              Text(
                '${entry.department} · ${entry.position}',
                style: HrText.meta,
              ),
              const SizedBox(height: 18),
              HrCard(
                shadow: false,
                background: HrColors.bg,
                child: Column(
                  children: [
                    _ContactRow(
                      icon: Icons.mail_outline_rounded,
                      label: entry.email,
                    ),
                    const SizedBox(height: 12),
                    _ContactRow(icon: Icons.phone_outlined, label: entry.phone),
                    if (entry.extension != null) ...[
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.dialpad_rounded,
                        label: '分机 ${entry.extension}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: HrOutlineButton(
                      label: '发送邮件',
                      icon: Icons.mail_outline,
                      onPressed: () {
                        Navigator.of(context).pop();
                        hrToast(this.context, '邮件入口已模拟');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HrPrimaryButton(
                      label: '发起沟通',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        hrToast(this.context, '已向 ${entry.name} 发起沟通');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HrColors.brand),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: HrText.body)),
      ],
    );
  }
}
