part of 'profile_pages.dart';

class HrAnnouncementsPage extends StatelessWidget {
  const HrAnnouncementsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: HrColors.brand,
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '公司公告',
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              if (controller.unreadAnnouncementCount > 0)
                HrStatusChip(
                  label: '${controller.unreadAnnouncementCount} 条未读',
                  background: HrColors.brandTint,
                  foreground: HrColors.brand,
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('公司政策、员工关怀与重要通知。', style: HrText.meta),
          const SizedBox(height: 16),
          for (final item in controller.announcements) ...[
            HrCard(
              key: Key('hr-announcement-${item.id}'),
              onTap: () => controller.openAnnouncement(item.id),
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.unread ? HrColors.brand : HrColors.readDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HrStatusChip(
                              label: item.category,
                              background: HrColors.bg2,
                              foreground: HrColors.ink3,
                            ),
                            const Spacer(),
                            Text(
                              hrRelative(item.createdAt),
                              style: HrText.meta.copyWith(
                                color: HrColors.ink4,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: HrText.cardTitle.copyWith(
                            fontSize: 15,
                            color: item.unread ? HrColors.ink : HrColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: HrText.body.copyWith(color: HrColors.ink3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
