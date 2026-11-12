part of 'profile_pages.dart';

class HrAnnouncementDetailPage extends StatelessWidget {
  const HrAnnouncementDetailPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final item = controller.selectedAnnouncement;
    if (item == null) {
      return const Center(child: Text('公告不存在'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(
          children: [
            HrStatusChip(
              label: item.category,
              background: HrColors.resolve(context, HrColors.brandTint),
              foreground: HrColors.resolve(context, HrColors.brand),
            ),
            const Spacer(),
            Text(
              hrRelative(item.createdAt),
              style: HrText.resolve(context, HrText.meta),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.title,
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25, height: 1.3),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            HrAvatar(name: item.author, size: 32, index: item.id),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.author,
                  style: HrText.resolve(
                    context,
                    HrText.cardTitle,
                  ).copyWith(fontSize: 11.5),
                ),
                Text(
                  '${hrDate(item.createdAt, withYear: true)} · 人力资源部',
                  style: HrText.resolve(
                    context,
                    HrText.meta,
                  ).copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.summary,
                style: HrText.resolve(context, HrText.body).copyWith(
                  color: HrColors.resolve(context, HrColors.ink),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Divider(
                height: 1,
                color: HrColors.resolve(context, HrColors.line2),
              ),
              const SizedBox(height: 15),
              for (var i = 0; i < item.content.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    item.content[i],
                    style: _isHeading(item.content[i])
                        ? HrText.resolve(context, HrText.cardTitle).copyWith(
                            fontSize: 14,
                            color: HrColors.resolve(context, HrColors.ink),
                          )
                        : HrText.resolve(
                            context,
                            HrText.body,
                          ).copyWith(fontSize: 13.5, height: 1.65),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          padding: const EdgeInsets.all(14),
          background: HrColors.resolve(context, HrColors.bg),
          borderColor: HrColors.resolve(context, HrColors.line2),
          shadow: false,
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: HrColors.resolve(context, HrColors.success),
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '此公告面向全体员工发布，阅读状态已同步。',
                  style: HrText.resolve(context, HrText.meta),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isHeading(String text) =>
      text.startsWith('一、') ||
      text.startsWith('二、') ||
      text.startsWith('三、') ||
      text.startsWith('四、');
}
