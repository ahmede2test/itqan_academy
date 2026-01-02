import 'package:flutter/material.dart';
import 'package:itqan_academy/core/utils/functions/logout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itqan_academy/features/login/presentation/views/widgets/auth_template.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';

class PendingActivationScreen extends StatelessWidget {
  const PendingActivationScreen({super.key});

  Future<void> _contactAdmin() async {
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ?? 'مستخدم جديد';
    final message =
        "أهلاً أكاديمية إتقان، قمت بالتسجيل وأرغب في تفعيل حسابي. بريدي الإلكتروني هو: $userEmail";
    final encodedMessage = Uri.encodeFull(message);

    final whatsappAlternative =
        "whatsapp://send?phone=201027451231&text=$encodedMessage";
    final waMeUrl = "https://wa.me/201027451231?text=$encodedMessage";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappAlternative))) {
        await launchUrl(Uri.parse(whatsappAlternative),
            mode: LaunchMode.externalApplication);
      } else {
        // Fallback for Web/Browser or if scheme fails
        await launchUrl(Uri.parse(waMeUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Final fallback to web if anything fails
      await launchUrl(Uri.parse(waMeUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'الحساب قيد التفعيل',
      subtitle: 'يرجى التواصل مع الإدارة لإتمام عملية التفعيل',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_clock_rounded,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 30),
          const Text(
            'حسابك بانتظار الموافقة',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'للوصول إلى محتوى الأكاديمية، يتوجب تفعيل اشتراكك أولاً. يمكنك التواصل معنا مباشرة عبر واتساب.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontFamily: 'Cairo',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          HoverEffect(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _contactAdmin,
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'تواصل معنا للتفعيل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => logOut(context),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
