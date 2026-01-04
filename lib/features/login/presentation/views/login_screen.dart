import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_cubit.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_state.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/cash_helper.dart';
import '../../../../core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';
import 'package:itqan_academy/features/home/presentation/views/home_screen_view.dart';
import 'package:app_links/app_links.dart';
import 'signup_screen.dart';
import 'package:itqan_academy/features/login/presentation/views/widgets/auth_template.dart';
import '../../../../core/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool _isGoogleLoading = false;

  final _formKey = GlobalKey<FormState>();

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _linkSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _setupAuthListener() {
    final supabase = Supabase.instance.client;

    // 1. Listen for session changes (OAuth success)
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          debugPrint("LoginScreen: Auth success detected via listener.");
          setState(() => _isGoogleLoading = false);

          CashHelper.setData('isLoggedIn', true);
          CashHelper.setData('token', session.accessToken);
          CashHelper.setData(
              'name',
              session.user.userMetadata?['full_name'] ??
                  session.user.email?.split('@')[0] ??
                  "User");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    });

    // 2. Process incoming deep links (needed only on Android/iOS)
    if (!kIsWeb) {
      _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
        if (uri.scheme == 'itqan' && uri.host == 'login-callback') {
          debugPrint("LoginScreen: Deep Link received: $uri");
          try {
            await supabase.auth.getSessionFromUrl(uri);
          } catch (e) {
            debugPrint("Error processing session from URL: $e");
            if (mounted) setState(() => _isGoogleLoading = false);
          }
        }
      });
    }
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String label,
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon:
          Icon(icon, color: AppColors.primary.withOpacity(0.6), size: 20),
      suffixIcon: suffix,
      labelText: label,
      labelStyle:
          TextStyle(color: Colors.grey[700], fontFamily: 'Cairo', fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.grey[50], // 🎨 Subtle fill color
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await Supabase.instance.client.auth
          .signInWithOAuth(
            OAuthProvider.google,
            redirectTo: 'itqan://login-callback',
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is TimeoutException) {
        errorMessage =
            S.of(context).unexpectedError; // Or a specific timeout message
      }
      customShowToast(msg: "${S.of(context).error}: $errorMessage");
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          CashHelper.setData('isLoggedIn', true);
          CashHelper.setData('token', state.loginModel.token ?? "");
          CashHelper.setData('name', state.loginModel.userNicename ?? "User");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is LoginFailure) {
          customShowToast(msg: state.errMessage);
        }
      },
      builder: (context, state) {
        return AuthTemplate(
          title: S.of(context).login,
          subtitle: S.of(context).welcomeInQB,
          body: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // 📏 reasonable mobile padding
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12), // 📏 Spacing after subtitle/start
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      icon: Icons.alternate_email_rounded,
                      label: S.of(context).email,
                      hint: S.of(context).enterEmail,
                    ),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : S.of(context).pleaseEnterEmail,
                  ),
                  const SizedBox(height: 24), // 📏 Increased spacing
                  TextFormField(
                    controller: passwordController,
                    style:
                        const TextStyle(color: AppColors.primary, fontSize: 16),
                    obscureText: obscurePassword,
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline_rounded,
                      label: S.of(context).password,
                      hint: S.of(context).passwordFormFieldHint,
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (value) => value != null && value.length < 6
                        ? S.of(context).passwordShowHint
                        : null,
                  ),
                  const SizedBox(height: 48), // 📏 Increased spacing
                  HoverEffect(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: (state is LoginLoading)
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    LoginCubit.get(context).login(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                  }
                                },
                          child: Center(
                            child: (state is LoginLoading)
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    S.of(context).login,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // 📏 Spacing
                  HoverEffect(
                    child: OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _googleSignIn,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGoogleLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              )
                            else
                              Image.network(
                                'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png', // Reliable URL
                                height: 22,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.school_rounded,
                                  color: AppColors.accent,
                                  size: 22,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Text(
                              S.of(context).signInWithGoogle,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).createNewAccount,
                        style: TextStyle(
                            color: Colors.grey[600], fontFamily: 'Cairo'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          S.of(context).signUp,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
