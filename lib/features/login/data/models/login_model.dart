import 'package:supabase_flutter/supabase_flutter.dart'; // السطر المطلوب لحل الخطأ

class LoginModel {
  String? token;
  String? userEmail;
  String? userNicename;
  String? userDisplayName;

  LoginModel({
    this.token,
    this.userEmail,
    this.userNicename,
    this.userDisplayName,
  });

  // الآن AuthResponse ستعمل بدون مشاكل
  factory LoginModel.fromSupabase(AuthResponse response) {
    final user = response.user;
    final session = response.session;

    return LoginModel(
      token: session?.accessToken,
      userEmail: user?.email,
      // نأخذ الاسم من Metadata أو نستخدم الجزء الأول من الإيميل كاسم مستخدم
      userNicename: user?.userMetadata?['full_name'] ?? user?.email?.split('@')[0],
      userDisplayName: user?.userMetadata?['display_name'] ?? "User",
    );
  }

  LoginModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userEmail = json['user_email'];
    userNicename = json['user_nicename'];
    userDisplayName = json['user_display_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['user_email'] = userEmail;
    data['user_nicename'] = userNicename;
    data['user_display_name'] = userDisplayName;
    return data;
  }
}