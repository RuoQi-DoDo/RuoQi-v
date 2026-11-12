part of 'profile_pages.dart';

class AtsCollectPage extends StatelessWidget {
  const AtsCollectPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final jobs = atsJobs
        .where((job) => controller.favorites.contains(job.id))
        .toList();
    final displayJobs = jobs.isEmpty ? atsJobs.take(1).toList() : jobs;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final job in displayJobs)
          AtsJobCard(
            job: job,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.jobDetail),
          ),
        if (jobs.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '以上为推荐收藏，点击职位详情可收藏更多岗位',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AtsColors.resolve(context, AtsColors.textMuted),
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
