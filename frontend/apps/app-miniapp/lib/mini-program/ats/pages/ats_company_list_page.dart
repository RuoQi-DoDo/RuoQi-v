part of 'home_pages.dart';

class AtsCompanyListPage extends StatelessWidget {
  const AtsCompanyListPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3779E8), Color(0xFF73ADFF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '热门公司',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '发现值得加入的团队',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.domain_rounded, size: 58, color: Color(0x3DFFFFFF)),
            ],
          ),
        ),
        const AtsSectionHeader(title: '精选认证企业'),
        for (final company in atsCompanies)
          AtsCompanyCard(
            company: company,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.companyDetail),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
