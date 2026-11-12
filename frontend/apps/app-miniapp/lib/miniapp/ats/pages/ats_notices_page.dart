part of 'message_pages.dart';

class AtsNoticesPage extends StatelessWidget {
  const AtsNoticesPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AtsColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: atsNotices.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final notice = atsNotices[index];
          return AtsCard(
            onTap: () => controller.open(AtsRoute.noticeDetail),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: notice.unread
                        ? AtsColors.mint
                        : AtsColors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    notice.title == '面试邀请'
                        ? Icons.event_available_outlined
                        : notice.title.contains('简历')
                        ? Icons.assignment_turned_in_outlined
                        : Icons.notifications_none,
                    color: AtsColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            notice.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (notice.unread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AtsColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            notice.time,
                            style: const TextStyle(
                              color: AtsColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notice.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AtsColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
