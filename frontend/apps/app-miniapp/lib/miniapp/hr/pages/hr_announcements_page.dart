part of 'profile_pages.dart';

class HrAnnouncementsPage extends StatelessWidget {
  const HrAnnouncementsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: HrColors.resolve(context, HrColors.brand),
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '公司公告',
                  style: HrText.resolve(
                    context,
                    HrText.appBarTitle,
                  ).copyWith(fontSize: 25),
                ),
              ),
              if (controller.unreadAnnouncementCount > 0)
                HrStatusChip(
                  label: '${controller.unreadAnnouncementCount} 条未读',
                  background: HrColors.resolve(context, HrColors.brandTint),
                  foreground: HrColors.resolve(context, HrColors.brand),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text('公司政策、员工关怀与重要通知。', style: HrText.resolve(context, HrText.meta)),
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
                      color: item.unread
                          ? HrColors.brand
                          : HrColors.resolve(context, HrColors.readDot),
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
                              background: HrColors.resolve(
                                context,
                                HrColors.bg2,
                              ),
                              foreground: HrColors.resolve(
                                context,
                                HrColors.ink3,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              hrRelative(item.createdAt),
                              style: HrText.resolve(context, HrText.meta)
                                  .copyWith(
                                    color: HrColors.resolve(
                                      context,
                                      HrColors.ink4,
                                    ),
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: HrText.resolve(context, HrText.cardTitle)
                              .copyWith(
                                fontSize: 15,
                                color: item.unread
                                    ? HrColors.resolve(context, HrColors.ink)
                                    : HrColors.resolve(context, HrColors.ink2),
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: HrText.resolve(context, HrText.body).copyWith(
                            color: HrColors.resolve(context, HrColors.ink3),
                          ),
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
