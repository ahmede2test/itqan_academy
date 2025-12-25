import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel {
  // الحقول الأساسية التي سيتم تعبئتها مباشرة من Supabase Auth/DB
  int? id;
  String? email;
  String? name; // يستخدم لـ full_name من DB
  String? url; // يستخدم لـ avatar_url من DB

  // الحقول القديمة المحفوظة لتجنب كسر واجهة المستخدم (UI)
  String? username;
  String? firstName;
  String? lastName;
  String? description;
  String? link;
  String? locale;
  String? nickname;
  String? slug;
  List<String>? roles;
  String? registeredDate;
  Capabilities? capabilities;
  ExtraCapabilities? extraCapabilities;
  AvatarUrls? avatarUrls; // يتم تعبئته يدوياً
  bool? isSuperAdmin;
  WoocommerceMeta? woocommerceMeta;
  String? university;
  String? faculty;
  String? department;
  String? level;
  Links? lLinks;

  ProfileModel(
      {this.id,
      this.username,
      this.name,
      this.firstName,
      this.lastName,
      this.email,
      this.url,
      this.description,
      this.link,
      this.locale,
      this.nickname,
      this.slug,
      this.roles,
      this.registeredDate,
      this.capabilities,
      this.extraCapabilities,
      this.avatarUrls,
      this.isSuperAdmin,
      this.woocommerceMeta,
      this.university,
      this.faculty,
      this.department,
      this.level,
      this.lLinks});

  // 🔑 دالة fromJson المُعدَّلة لاستقبال بيانات Supabase
  ProfileModel.fromJson(Map<String, dynamic> json) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    // 1. بيانات Supabase Auth
    id = int.tryParse(
        currentUser?.id.substring(0, 8).replaceAll('-', '') ?? '0',
        radix: 16);
    email = currentUser?.email;

    // 2. بيانات Supabase DB (من جدول user_profiles) مع Fallback لبيانات Google/Auth
    name = (json['full_name'] as String?) ??
        currentUser?.userMetadata?['name'] ??
        currentUser?.userMetadata?['full_name'];
    url = (json['avatar_url'] as String?) ??
        currentUser?.userMetadata?['avatar_url'] ??
        currentUser?.userMetadata?['picture'];

    // 💡 تفكيك الاسم الكامل إلى اسم أول واسم أخير
    final nameParts = (name ?? '').split(' ');
    firstName = nameParts.isNotEmpty ? nameParts.first : null;
    lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    // 3. تعبئة الحقول القديمة للتوافق
    avatarUrls = AvatarUrls(s96: url);
    username = null;
    description = null;
    link = null;
    locale = null;
    nickname = null;
    slug = null;
    roles = null;
    registeredDate = null;
    capabilities = null;
    extraCapabilities = null;
    isSuperAdmin = false;
    woocommerceMeta = null;
    university = null;
    faculty = null;
    department = null;
    level = null;
    lLinks = null;
  }

  // ✅ دالة copyWith
  ProfileModel copyWith({
    int? id,
    String? email,
    String? name,
    String? url,
    String? username,
    String? firstName,
    String? lastName,
    String? description,
    String? link,
    String? locale,
    String? nickname,
    String? slug,
    List<String>? roles,
    String? registeredDate,
    Capabilities? capabilities,
    ExtraCapabilities? extraCapabilities,
    AvatarUrls? avatarUrls,
    bool? isSuperAdmin,
    WoocommerceMeta? woocommerceMeta,
    String? university,
    String? faculty,
    String? department,
    String? level,
    Links? lLinks,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      description: description ?? this.description,
      link: link ?? this.link,
      locale: locale ?? this.locale,
      nickname: nickname ?? this.nickname,
      slug: slug ?? this.slug,
      roles: roles ?? this.roles,
      registeredDate: registeredDate ?? this.registeredDate,
      capabilities: capabilities ?? this.capabilities,
      extraCapabilities: extraCapabilities ?? this.extraCapabilities,
      avatarUrls: avatarUrls ?? this.avatarUrls,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      woocommerceMeta: woocommerceMeta ?? this.woocommerceMeta,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      level: level ?? this.level,
      lLinks: lLinks ?? this.lLinks,
    );
  }

  // دالة toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['url'] = url;
    data['description'] = description;
    data['link'] = link;
    data['locale'] = locale;
    data['nickname'] = nickname;
    data['slug'] = slug;
    data['roles'] = roles;
    data['registered_date'] = registeredDate;
    if (capabilities != null) {
      data['capabilities'] = capabilities!.toJson();
    }
    if (extraCapabilities != null) {
      data['extra_capabilities'] = extraCapabilities!.toJson();
    }
    if (avatarUrls != null) {
      data['avatar_urls'] = avatarUrls!.toJson();
    }
    data['is_super_admin'] = isSuperAdmin;
    if (woocommerceMeta != null) {
      data['woocommerce_meta'] = woocommerceMeta!.toJson();
    }
    data['university'] = university;
    data['faculty'] = faculty;
    data['department'] = department;
    data['level'] = level;
    if (lLinks != null) {
      data['_links'] = lLinks!.toJson();
    }
    return data;
  }
}

// -------------------------------------------------------------------
// الكلاسات الفرعية (Sub-classes)
// -------------------------------------------------------------------

class Capabilities {
  bool? read;
  bool? level0;
  bool? subscriber;

  Capabilities({this.read, this.level0, this.subscriber});

  Capabilities.fromJson(Map<String, dynamic> json) {
    read = json['read'];
    level0 = json['level_0'];
    subscriber = json['subscriber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['read'] = read;
    data['level_0'] = level0;
    data['subscriber'] = subscriber;
    return data;
  }
}

class ExtraCapabilities {
  bool? subscriber;

  ExtraCapabilities({this.subscriber});

  ExtraCapabilities.fromJson(Map<String, dynamic> json) {
    subscriber = json['subscriber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscriber'] = subscriber;
    return data;
  }
}

class AvatarUrls {
  String? s24;
  String? s48;
  String? s96;

  AvatarUrls({this.s24, this.s48, this.s96});

  AvatarUrls.fromJson(Map<String, dynamic> json) {
    s24 = json['24'];
    s48 = json['48'];
    s96 = json['96'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['24'] = s24;
    data['48'] = s48;
    data['96'] = s96;
    return data;
  }
}

class WoocommerceMeta {
  String? variableProductTourShown;
  String? activityPanelInboxLastRead;
  String? activityPanelReviewsLastRead;
  String? categoriesReportColumns;
  String? couponsReportColumns;
  String? customersReportColumns;
  String? ordersReportColumns;
  String? productsReportColumns;
  String? revenueReportColumns;
  String? taxesReportColumns;
  String? variationsReportColumns;
  String? dashboardSections;
  String? dashboardChartType;
  String? dashboardChartInterval;
  String? dashboardLeaderboardRows;
  String? orderAttributionInstallBannerDismissed;
  String? homepageLayout;
  String? homepageStats;
  String? taskListTrackedStartedTasks;
  String? androidAppBannerDismissed;
  String? launchYourStoreTourHidden;
  String? comingSoonBannerDismissed;

  WoocommerceMeta(
      {this.variableProductTourShown,
      this.activityPanelInboxLastRead,
      this.activityPanelReviewsLastRead,
      this.categoriesReportColumns,
      this.couponsReportColumns,
      this.customersReportColumns,
      this.ordersReportColumns,
      this.productsReportColumns,
      this.revenueReportColumns,
      this.taxesReportColumns,
      this.variationsReportColumns,
      this.dashboardSections,
      this.dashboardChartType,
      this.dashboardChartInterval,
      this.dashboardLeaderboardRows,
      this.orderAttributionInstallBannerDismissed,
      this.homepageLayout,
      this.homepageStats,
      this.taskListTrackedStartedTasks,
      this.androidAppBannerDismissed,
      this.launchYourStoreTourHidden,
      this.comingSoonBannerDismissed});

  WoocommerceMeta.fromJson(Map<String, dynamic> json) {
    variableProductTourShown = json['variable_product_tour_shown'];
    activityPanelInboxLastRead = json['activity_panel_inbox_last_read'];
    activityPanelReviewsLastRead = json['activity_panel_reviews_last_read'];
    categoriesReportColumns = json['categories_report_columns'];
    couponsReportColumns = json['coupons_report_columns'];
    customersReportColumns = json['customers_report_columns'];
    ordersReportColumns = json['orders_report_columns'];
    productsReportColumns = json['products_report_columns'];
    revenueReportColumns = json['revenue_report_columns'];
    taxesReportColumns = json['taxes_report_columns'];
    variationsReportColumns = json['variations_report_columns'];
    dashboardSections = json['dashboard_sections'];
    dashboardChartType = json['dashboard_chart_type'];
    dashboardChartInterval = json['dashboard_chart_interval'];
    dashboardLeaderboardRows = json['dashboard_leaderboard_rows'];
    orderAttributionInstallBannerDismissed =
        json['order_attribution_install_banner_dismissed'];
    homepageLayout = json['homepage_layout'];
    homepageStats = json['homepage_stats'];
    taskListTrackedStartedTasks = json['task_list_tracked_started_tasks'];
    androidAppBannerDismissed = json['android_app_banner_dismissed'];
    launchYourStoreTourHidden = json['launch_your_store_tour_hidden'];
    comingSoonBannerDismissed = json['coming_soon_banner_dismissed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variable_product_tour_shown'] = variableProductTourShown;
    data['activity_panel_inbox_last_read'] = activityPanelInboxLastRead;
    data['activity_panel_reviews_last_read'] = activityPanelReviewsLastRead;
    data['categories_report_columns'] = categoriesReportColumns;
    data['coupons_report_columns'] = couponsReportColumns;
    data['customers_report_columns'] = customersReportColumns;
    data['orders_report_columns'] = ordersReportColumns;
    data['products_report_columns'] = productsReportColumns;
    data['revenue_report_columns'] = revenueReportColumns;
    data['taxes_report_columns'] = taxesReportColumns;
    data['variations_report_columns'] = variationsReportColumns;
    data['dashboard_sections'] = dashboardSections;
    data['dashboard_chart_type'] = dashboardChartType;
    data['dashboard_chart_interval'] = dashboardChartInterval;
    data['dashboard_leaderboard_rows'] = dashboardLeaderboardRows;
    data['order_attribution_install_banner_dismissed'] =
        orderAttributionInstallBannerDismissed;
    data['homepage_layout'] = homepageLayout;
    data['homepage_stats'] = homepageStats;
    data['task_list_tracked_started_tasks'] = taskListTrackedStartedTasks;
    data['android_app_banner_dismissed'] = androidAppBannerDismissed;
    data['launch_your_store_tour_hidden'] = launchYourStoreTourHidden;
    data['coming_soon_banner_dismissed'] = comingSoonBannerDismissed;
    return data;
  }
}

class Links {
  List<Self>? self;
  List<Collection>? collection;

  Links({this.self, this.collection});

  Links.fromJson(Map<String, dynamic> json) {
    if (json['self'] != null) {
      self = <Self>[];
      json['self'].forEach((v) {
        self!.add(Self.fromJson(v));
      });
    }
    if (json['collection'] != null) {
      collection = <Collection>[];
      json['collection'].forEach((v) {
        collection!.add(Collection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.map((v) => v.toJson()).toList();
    }
    if (collection != null) {
      data['collection'] = collection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Self {
  String? href;
  TargetHints? targetHints;

  Self({this.href, this.targetHints});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    targetHints = json['targetHints'] != null
        ? TargetHints.fromJson(json['targetHints'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    if (targetHints != null) {
      data['targetHints'] = targetHints!.toJson();
    }
    return data;
  }
}

class TargetHints {
  List<String>? allow;

  TargetHints({this.allow});

  TargetHints.fromJson(Map<String, dynamic> json) {
    allow = json['allow'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allow'] = allow;
    return data;
  }
}

class Collection {
  String? href;

  Collection({this.href});

  Collection.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    return data;
  }
}
