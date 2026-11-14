class PhoneCountry {
  const PhoneCountry({
    required this.code,
    required this.nameZh,
    required this.nameEn,
    required this.dialCode,
  });

  final String code;
  final String nameZh;
  final String nameEn;
  final String dialCode;
}

const phoneCountries = <PhoneCountry>[
  PhoneCountry(code: 'CN', nameZh: '中国', nameEn: 'China', dialCode: '+86'),
  PhoneCountry(
    code: 'HK',
    nameZh: '中国香港',
    nameEn: 'Hong Kong',
    dialCode: '+852',
  ),
  PhoneCountry(code: 'MO', nameZh: '中国澳门', nameEn: 'Macao', dialCode: '+853'),
  PhoneCountry(code: 'TW', nameZh: '中国台湾', nameEn: 'Taiwan', dialCode: '+886'),
  PhoneCountry(
    code: 'US',
    nameZh: '美国',
    nameEn: 'United States',
    dialCode: '+1',
  ),
  PhoneCountry(
    code: 'GB',
    nameZh: '英国',
    nameEn: 'United Kingdom',
    dialCode: '+44',
  ),
  PhoneCountry(code: 'CA', nameZh: '加拿大', nameEn: 'Canada', dialCode: '+1'),
  PhoneCountry(
    code: 'AU',
    nameZh: '澳大利亚',
    nameEn: 'Australia',
    dialCode: '+61',
  ),
  PhoneCountry(code: 'SG', nameZh: '新加坡', nameEn: 'Singapore', dialCode: '+65'),
  PhoneCountry(code: 'MY', nameZh: '马来西亚', nameEn: 'Malaysia', dialCode: '+60'),
  PhoneCountry(code: 'JP', nameZh: '日本', nameEn: 'Japan', dialCode: '+81'),
  PhoneCountry(
    code: 'KR',
    nameZh: '韩国',
    nameEn: 'South Korea',
    dialCode: '+82',
  ),
  PhoneCountry(code: 'IN', nameZh: '印度', nameEn: 'India', dialCode: '+91'),
  PhoneCountry(code: 'BR', nameZh: '巴西', nameEn: 'Brazil', dialCode: '+55'),
  PhoneCountry(code: 'GH', nameZh: '加纳', nameEn: 'Ghana', dialCode: '+233'),
  PhoneCountry(code: 'NG', nameZh: '尼日利亚', nameEn: 'Nigeria', dialCode: '+234'),
];
