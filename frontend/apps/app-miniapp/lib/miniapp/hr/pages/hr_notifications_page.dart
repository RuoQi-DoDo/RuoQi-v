part of 'profile_pages.dart';

class HrNotificationsPage extends StatelessWidget {
  const HrNotificationsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '消息通知',
                style: HrText.appBarTitle.copyWith(fontSize: 25),
              ),
            ),
            if (controller.unreadNotificationCount > 0)
              TextButton(
                onPressed: controller.markAllNotificationsRead,
                style: TextButton.styleFrom(foregroundColor: HrColors.brand),
                child: const Text(
                  '全部已读',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${controller.unreadNotificationCount} 条未读 · 共 ${controller.notifications.length} 条',
          style: HrText.meta,
        ),
        const SizedBox(height: 16),
        for (final item in controller.notifications) ...[
          HrCard(
            onTap: item.unread
                ? () => controller.markNotificationRead(item.id)
                : null,
            padding: const EdgeInsets.all(15),
            borderColor: item.unread ? HrColors.line : HrColors.line2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _notificationColor(item.icon),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _notificationIcon(item.icon),
                    color: _notificationInk(item.icon),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: HrText.cardTitle.copyWith(fontSize: 13),
                            ),
                          ),
                          if (item.unread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: HrColors.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: HrText.body.copyWith(color: HrColors.ink3),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hrRelative(item.createdAt),
                        style: HrText.meta.copyWith(
                          color: HrColors.ink4,
                          fontSize: 10,
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
    );
  }

  static IconData _notificationIcon(String name) => switch (name) {
    'calendar' => Icons.event_available_outlined,
    'approval' => Icons.approval_outlined,
    'payslip' => Icons.receipt_long_outlined,
    _ => Icons.schedule_outlined,
  };

  static Color _notificationInk(String name) => switch (name) {
    'calendar' => HrColors.success,
    'approval' => HrColors.warning,
    'payslip' => HrColors.info,
    _ => HrColors.brand,
  };

  static Color _notificationColor(String name) => switch (name) {
    'calendar' => HrColors.successBg,
    'approval' => HrColors.warningBg,
    'payslip' => HrColors.infoBg,
    _ => HrColors.brandTint,
  };
}
