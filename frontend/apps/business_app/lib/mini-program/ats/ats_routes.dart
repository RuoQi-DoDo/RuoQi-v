import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ats_models.dart';

enum AtsRoute {
  home(path: '/pages/main/main', title: '企业直聘', tabIndex: 0),
  search(path: '/pages/main/search', title: '搜索'),
  jobList(path: '/pages/position/list', title: '岗位列表'),
  jobDetail(path: '/pages/position/detail', title: '职位详情'),
  companyList(path: '/pages/company/list', title: '公司列表'),
  resumeList(path: '/pages/company/resumeList', title: '简历列表'),
  companyDetail(path: '/pages/company/detail', title: '公司详情'),
  category(path: '/pages/type/type', title: '分类', tabIndex: 1),
  messages(path: '/pages/chat/chat', title: '消息', tabIndex: 2),
  privateChat(path: '/pages/chat/privateChat', title: '聊天'),
  notices(path: '/pages/chat/notice/notices', title: '系统消息'),
  noticeDetail(path: '/pages/chat/notice/noticeDetail', title: '消息详情'),
  profile(path: '/pages/user/user', title: '我的', tabIndex: 3),
  aboutUs(path: '/pages/user/aboutUs', title: '关于我们'),
  terms(path: '/pages/user/terms', title: '用户协议'),
  privacy(path: '/pages/user/privacy', title: '隐私政策'),
  help(path: '/pages/user/help', title: '帮助中心'),
  helpDetail(path: '/pages/user/helpcenterDetails', title: '帮助详情'),
  settings(path: '/pages/user/settings', title: '系统设置'),
  hideSetting(path: '/pages/user/hideSetting', title: '隐私设置'),
  applications(path: '/pages/user/apply', title: '我的投递'),
  connected(path: '/pages/user/connected', title: '谁看过我'),
  browse(path: '/pages/user/browse', title: '浏览记录'),
  robot(path: '/pages/user/robot', title: '在线客服'),
  contactUs(path: '/pages/user/contactUs', title: '联系我们'),
  promoCode(path: '/pages/user/promoCode', title: '我的推广码'),
  userInfo(path: '/pages/user/userInfo', title: '基本信息'),
  collect(path: '/pages/user/collect', title: '我的收藏'),
  login(path: '/pages/login/login', title: '登录'),
  loginIndex(path: '/pages/login/index', title: '推荐注册'),
  register(path: '/pages/login/reg', title: '注册'),
  registerSuccess(path: '/pages/login/success', title: '提交成功'),
  bindPhone(path: '/pages/login/bindphone', title: '绑定手机号'),
  industry(path: '/pages/common/industry', title: '行业选择'),
  post(path: '/pages/common/post', title: '岗位选择'),
  resume(path: '/pages/user/person/resume', title: '个人简历'),
  resumeDetail(path: '/pages/user/person/resumeDetail', title: '个人简历'),
  editEducation(path: '/pages/user/person/edit-edu', title: '添加教育经历'),
  editExpectation(path: '/pages/user/person/edit-expect', title: '添加求职期望'),
  editProject(path: '/pages/user/person/edit-pro', title: '添加项目经历'),
  editProjectContent(
    path: '/pages/user/person/edit-pro-content',
    title: '编辑项目内容',
  ),
  editSkill(path: '/pages/user/person/edit-skill', title: '添加个人优势'),
  editWork(path: '/pages/user/person/edit-work', title: '添加工作经历'),
  editWorkContent(path: '/pages/user/person/edit-work-content', title: '工作内容'),
  companyEdit(path: '/pages/user/company/company', title: '编辑公司信息'),
  companyEnter(path: '/pages/user/company/enter', title: '公司入驻'),
  positions(path: '/pages/user/company/positions', title: '职位管理'),
  positionEdit(path: '/pages/user/company/position-edit', title: '新增职位'),
  companyAuth(path: '/pages/user/company/auth', title: '公司认证');

  const AtsRoute({required this.path, required this.title, this.tabIndex});

  final String path;
  final String title;
  final int? tabIndex;

  bool get isTabRoot => tabIndex != null;
}

class AtsAppController extends ChangeNotifier {
  AtsAppController({
    AtsUserRole initialRole = AtsUserRole.candidate,
    bool initialLoggedIn = false,
  }) : _role = initialRole,
       _loggedIn = initialLoggedIn;

  final List<AtsRoute> _history = [AtsRoute.home];
  final Set<String> favorites = <String>{};
  final Set<String> applications = <String>{};
  final List<String> searchHistory = <String>['Flutter', '产品经理', '设计师'];
  final List<String> hiddenCompanies = <String>['某未认证企业'];

  AtsUserRole _role;
  AtsRoute _route = AtsRoute.home;
  int _tabIndex = 0;
  bool _loggedIn;
  bool _forward = true;
  String _userName = '林小满';

  AtsRoute get route => _route;
  AtsUserRole get role => _role;
  int get tabIndex => _tabIndex;
  bool get loggedIn => _loggedIn;
  bool get forward => _forward;
  bool get canGoBack => _history.length > 1;
  String get userName => _userName;
  List<AtsRoute> get history => List.unmodifiable(_history);

  void open(AtsRoute route) {
    if (route == _route) {
      return;
    }
    _forward = true;
    _route = route;
    _history.add(route);
    notifyListeners();
  }

  void back() {
    if (!canGoBack) {
      return;
    }
    _forward = false;
    _history.removeLast();
    _route = _history.last;
    final tab = _route.tabIndex;
    if (tab != null) {
      _tabIndex = tab;
    }
    notifyListeners();
  }

  void switchTab(int index) {
    final route = switch (index) {
      0 => AtsRoute.home,
      1 => AtsRoute.category,
      2 => AtsRoute.messages,
      _ => AtsRoute.profile,
    };
    _forward = index >= _tabIndex;
    _tabIndex = index;
    _history
      ..clear()
      ..add(route);
    _route = route;
    notifyListeners();
  }

  void toggleRole() {
    _role = _role == AtsUserRole.candidate
        ? AtsUserRole.recruiter
        : AtsUserRole.candidate;
    if (_role == AtsUserRole.recruiter && _route == AtsRoute.profile) {
      _history
        ..clear()
        ..add(AtsRoute.profile);
    }
    notifyListeners();
  }

  void setRole(AtsUserRole role) {
    if (_role == role) {
      return;
    }
    _role = role;
    notifyListeners();
  }

  void login() {
    _loggedIn = true;
    _history
      ..clear()
      ..add(AtsRoute.home);
    _route = AtsRoute.home;
    _tabIndex = 0;
    _forward = false;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _history
      ..clear()
      ..add(AtsRoute.login);
    _route = AtsRoute.login;
    _tabIndex = 0;
    _forward = true;
    notifyListeners();
  }

  void setUserName(String value) {
    if (value.trim().isEmpty) {
      return;
    }
    _userName = value.trim();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!favorites.add(id)) {
      favorites.remove(id);
    }
    notifyListeners();
  }

  void toggleApplication(String id) {
    if (!applications.add(id)) {
      applications.remove(id);
    }
    notifyListeners();
  }

  void addSearchHistory(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      return;
    }
    searchHistory
      ..remove(query)
      ..insert(0, query);
    if (searchHistory.length > 8) {
      searchHistory.removeLast();
    }
    notifyListeners();
  }

  void clearSearchHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  void removeHiddenCompany(String company) {
    hiddenCompanies.remove(company);
    notifyListeners();
  }
}

extension AtsRouteColors on AtsRoute {
  bool get usesGreenNavigation => isTabRoot || this == AtsRoute.login;
}
