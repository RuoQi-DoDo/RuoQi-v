part of 'home_pages.dart';

class AtsResumeListPage extends StatelessWidget {
  const AtsResumeListPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF07A3B), Color(0xFFFFB071)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '推荐人才',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '为你匹配 12 位优质候选人',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.people_alt_outlined,
                size: 52,
                color: Color(0x3DFFFFFF),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '最新简历'),
        for (final resume in atsResumes)
          AtsResumeCard(
            resume: resume,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.resumeDetail),
          ),
        const SizedBox(height: 18),
      ],
    );
  }
}
