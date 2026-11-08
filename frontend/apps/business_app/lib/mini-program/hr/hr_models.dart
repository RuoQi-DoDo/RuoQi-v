enum HrUserRole {
  candidate('求职者'),
  recruiter('招聘者');

  const HrUserRole(this.label);

  final String label;
}

class HrJob {
  const HrJob({
    required this.id,
    required this.title,
    required this.salary,
    required this.company,
    required this.companyId,
    required this.industry,
    required this.staffSize,
    required this.experience,
    required this.education,
    required this.location,
    required this.publisher,
    required this.tags,
    required this.description,
    this.partTime = false,
  });

  final String id;
  final String title;
  final String salary;
  final String company;
  final String companyId;
  final String industry;
  final String staffSize;
  final String experience;
  final String education;
  final String location;
  final String publisher;
  final List<String> tags;
  final String description;
  final bool partTime;
}

class HrResume {
  const HrResume({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.education,
    required this.experience,
    required this.salary,
    required this.jobStatus,
    required this.intent,
    required this.skill,
  });

  final String id;
  final String name;
  final String gender;
  final int age;
  final String education;
  final String experience;
  final String salary;
  final String jobStatus;
  final String intent;
  final String skill;
}

class HrCompany {
  const HrCompany({
    required this.id,
    required this.name,
    required this.industry,
    required this.staffSize,
    required this.address,
    required this.workTime,
    required this.restTime,
    required this.overtime,
    required this.welfare,
    required this.introduce,
  });

  final String id;
  final String name;
  final String industry;
  final String staffSize;
  final String address;
  final String workTime;
  final String restTime;
  final String overtime;
  final List<String> welfare;
  final String introduce;
}

class HrConversation {
  const HrConversation({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.job,
  });

  final String name;
  final String preview;
  final String time;
  final int unread;
  final String job;
}

class HrNotice {
  const HrNotice({
    required this.title,
    required this.preview,
    required this.time,
    required this.content,
    required this.unread,
  });

  final String title;
  final String preview;
  final String time;
  final String content;
  final bool unread;
}

const hrJobs = <HrJob>[
  HrJob(
    id: 'job-flutter',
    title: 'Flutter 开发工程师',
    salary: '20-35K·14薪',
    company: '上海世佳科技有限公司',
    companyId: 'company-shijia',
    industry: '互联网',
    staffSize: '500-999人',
    experience: '3-5年',
    education: '本科',
    location: '上海·浦东新区',
    publisher: '李经理',
    tags: ['Flutter', 'Dart', '五险一金'],
    description:
        '负责公司移动端产品的架构设计与核心功能研发，参与 Flutter 工程体系、性能和组件库建设。'
        '希望你熟悉 Dart 与移动端原生能力，有完整上线项目经验，具备良好的产品意识和团队协作能力。',
  ),
  HrJob(
    id: 'job-product',
    title: '产品经理',
    salary: '18-28K·13薪',
    company: '北京云帆数字科技',
    companyId: 'company-yunfan',
    industry: '企业服务',
    staffSize: '100-499人',
    experience: '3-5年',
    education: '本科',
    location: '北京·朝阳区',
    publisher: '王女士',
    tags: ['B端产品', '数据分析', '双休'],
    description: '负责招聘 SaaS 产品规划与迭代，深入理解客户业务，完成需求洞察、方案设计、项目推进与数据复盘。',
  ),
  HrJob(
    id: 'job-design',
    title: 'UI / 交互设计师',
    salary: '15-24K',
    company: '杭州拾光创意有限公司',
    companyId: 'company-shiguang',
    industry: '广告营销',
    staffSize: '50-99人',
    experience: '1-3年',
    education: '本科',
    location: '杭州·滨江区',
    publisher: '陈老师',
    tags: ['移动端设计', 'Figma', '设计系统'],
    description: '负责移动端产品视觉与交互设计，完善设计规范，与产品和研发协作推动高质量交付。',
  ),
  HrJob(
    id: 'job-recruiter',
    title: '招聘专员',
    salary: '8-12K',
    company: '深圳向新人力资源有限公司',
    companyId: 'company-xiangxin',
    industry: '人力资源',
    staffSize: '20-49人',
    experience: '1-3年',
    education: '大专',
    location: '深圳·南山区',
    publisher: '赵女士',
    tags: ['招聘', '沟通能力', '周末双休'],
    description: '负责岗位需求分析、渠道运营、候选人沟通和面试安排，维护良好的雇主品牌体验。',
  ),
  HrJob(
    id: 'job-marketing',
    title: '新媒体运营',
    salary: '9-15K',
    company: '广州好物文化传媒',
    companyId: 'company-haowu',
    industry: '文化传媒',
    staffSize: '100-499人',
    experience: '1-3年',
    education: '大专',
    location: '广州·天河区',
    publisher: '周主管',
    tags: ['内容运营', '短视频', '绩效奖金'],
    description: '负责小红书、抖音等平台内容策划与账号运营，跟踪热点并持续优化内容数据。',
  ),
  HrJob(
    id: 'job-backend',
    title: 'Java 后端开发工程师',
    salary: '22-38K·15薪',
    company: '南京星链网络科技',
    companyId: 'company-xinglian',
    industry: '互联网',
    staffSize: '1000-9999人',
    experience: '3-5年',
    education: '本科',
    location: '南京·雨花台区',
    publisher: '孙先生',
    tags: ['Java', 'Spring Boot', '高并发'],
    description: '参与交易核心链路研发，负责服务治理、性能优化和技术方案设计，保障系统稳定可靠。',
  ),
];

const hrResumes = <HrResume>[
  HrResume(
    id: 'resume-lin',
    name: '林小满',
    gender: '女',
    age: 26,
    education: '本科',
    experience: '4年',
    salary: '20-30K',
    jobStatus: '离职-随时到岗',
    intent: 'Flutter 开发工程师',
    skill: '4年移动端研发经验，主导过两款百万用户级 App，熟悉 Flutter、Dart、Android 及性能优化。',
  ),
  HrResume(
    id: 'resume-chen',
    name: '陈一鸣',
    gender: '男',
    age: 29,
    education: '硕士',
    experience: '6年',
    salary: '25-35K',
    jobStatus: '在职-月内到岗',
    intent: 'Java 后端开发工程师',
    skill: '长期从事交易系统与高并发服务研发，具备架构设计、服务治理和团队协作经验。',
  ),
  HrResume(
    id: 'resume-zhou',
    name: '周予安',
    gender: '女',
    age: 24,
    education: '本科',
    experience: '2年',
    salary: '12-18K',
    jobStatus: '在职-考虑机会',
    intent: 'UI / 交互设计师',
    skill: '擅长移动端界面设计与设计系统建设，能够独立完成从需求分析到视觉交付的完整流程。',
  ),
];

const hrCompanies = <HrCompany>[
  HrCompany(
    id: 'company-shijia',
    name: '上海世佳科技有限公司',
    industry: '互联网',
    staffSize: '500-999人',
    address: '上海市浦东新区张江路 88 号世佳中心',
    workTime: '09:00 - 18:00',
    restTime: '周末双休',
    overtime: '弹性工作',
    welfare: ['五险一金', '年终奖', '餐补', '年度体检'],
    introduce:
        '世佳科技专注于人才科技与数字化服务，以技术连接人和机会。公司拥有完善的产品、研发和运营团队，'
        '为超过 3000 家企业提供招聘数字化解决方案。',
  ),
  HrCompany(
    id: 'company-yunfan',
    name: '北京云帆数字科技',
    industry: '企业服务',
    staffSize: '100-499人',
    address: '北京市朝阳区望京 SOHO T2',
    workTime: '10:00 - 19:00',
    restTime: '周末双休',
    overtime: '结果导向',
    welfare: ['六险一金', '带薪年假', '团建', '股票期权'],
    introduce: '云帆数字科技聚焦组织效率与人才数据，帮助成长型企业构建更敏捷的人力资源体系。',
  ),
  HrCompany(
    id: 'company-shiguang',
    name: '杭州拾光创意有限公司',
    industry: '广告营销',
    staffSize: '50-99人',
    address: '杭州市滨江区江南大道 1888 号',
    workTime: '09:30 - 18:30',
    restTime: '周末双休',
    overtime: '调休',
    welfare: ['五险一金', '下午茶', '创意奖金'],
    introduce: '拾光创意是一支年轻的设计与品牌团队，服务消费、科技和生活方式领域的创新品牌。',
  ),
];

const hrConversations = <HrConversation>[
  HrConversation(
    name: '李经理',
    preview: '你好，方便发一份最新简历吗？',
    time: '刚刚',
    unread: 2,
    job: 'Flutter 开发工程师',
  ),
  HrConversation(
    name: '王女士',
    preview: '我们想约你明天下午聊聊',
    time: '10:32',
    unread: 0,
    job: '产品经理',
  ),
  HrConversation(
    name: '陈老师',
    preview: '作品集已经收到，谢谢',
    time: '昨天',
    unread: 0,
    job: 'UI / 交互设计师',
  ),
];

const hrNotices = <HrNotice>[
  HrNotice(
    title: '面试邀请',
    preview: '上海世佳科技邀请你参加面试',
    time: '今天 09:20',
    content:
        '你好，你的经历与 Flutter 开发工程师岗位非常匹配，邀请你参加线上面试。'
        '面试时间：11 月 10 日 14:00，面试方式：视频会议。如时间合适，请在消息中回复确认。',
    unread: true,
  ),
  HrNotice(
    title: '简历投递成功',
    preview: '你已成功投递“产品经理”岗位',
    time: '昨天 16:45',
    content: '你的简历已送达北京云帆数字科技，招聘方将在 3 个工作日内查看。',
    unread: false,
  ),
  HrNotice(
    title: '隐私政策更新',
    preview: '企业直聘隐私政策已更新',
    time: '11月01日',
    content: '为了向你提供更清晰的服务说明，我们更新了隐私政策。点击可查看完整内容。',
    unread: false,
  ),
];

const hrHotPosts = <String>[
  '销售',
  '技工/普工',
  '餐饮',
  '后端开发',
  '市场/营销',
  '地产中介',
  '助教',
  '产品经理',
  '工程造价',
  '证券/基金',
  '律师顾问',
  '影视媒体',
];

const hrIndustries = <String>[
  '互联网',
  '企业服务',
  '广告营销',
  '文化传媒',
  '人力资源',
  '金融',
  '教育培训',
  '医疗健康',
];

const hrPositions = <String>[
  'Flutter 开发工程师',
  '产品经理',
  'UI / 交互设计师',
  'Java 后端开发工程师',
  '招聘专员',
  '新媒体运营',
];
