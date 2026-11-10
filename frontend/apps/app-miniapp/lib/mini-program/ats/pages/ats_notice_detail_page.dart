part of 'message_pages.dart';

class AtsNoticeDetailPage extends StatelessWidget {
  const AtsNoticeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notice = atsNotices.first;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${notice.time} · 企业直聘',
                style: const TextStyle(
                  color: AtsColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),
              Text(
                notice.content,
                style: const TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 14,
                  height: 1.85,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AtsColors.mint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 17,
                      color: AtsColors.primary,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '如需调整面试时间，请直接在消息中与招聘方沟通。',
                        style: TextStyle(
                          color: AtsColors.primaryDark,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
