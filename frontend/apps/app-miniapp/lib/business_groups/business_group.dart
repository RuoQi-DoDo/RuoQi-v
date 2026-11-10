enum BusinessGroup {
  im('im', 'IM', 'IM 业务组'),
  ats('ats', 'ATS', '企业直聘业务组'),
  hr('hr', 'HR', '人事业务组'),
  merchant('merchant', 'Merchant', '商户业务组'),
  partner('partner', 'Partner', '伙伴业务组'),
  platform('platform', 'Platform', '平台管理业务组');

  const BusinessGroup(this.id, this.shortLabel, this.description);

  final String id;
  final String shortLabel;
  final String description;

  static BusinessGroup parse(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final group in values) {
      if (group.id == normalized) {
        return group;
      }
    }
    return BusinessGroup.im;
  }
}
