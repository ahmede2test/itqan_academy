import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_cubit.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_state.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/utils/cash_helper.dart';
import '../../../../core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';
import 'package:itqan_academy/features/home/presentation/views/home_screen_view.dart';
import 'package:app_links/app_links.dart';
import 'signup_screen.dart';

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
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      suffixIcon: suffix,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00D2FF), width: 1.5),
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
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.15),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/itqan_logo.png',
                          height: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      S.of(context).login,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      S.of(context).welcomeInQB,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => obscurePassword = !obscurePassword),
                        ),
                      ),
                      validator: (value) => value != null && value.length < 6
                          ? S.of(context).passwordShowHint
                          : null,
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button
                    HoverEffect(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF009FFF), Color(0xFFec2F4B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFec2F4B).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
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

                    const SizedBox(height: 24),

                    // Google Sign In
                    HoverEffect(
                      child: OutlinedButton.icon(
                        onPressed: _isGoogleLoading ? null : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const FaIcon(FontAwesomeIcons.google,
                                color: Colors.red, size: 20),
                        label: Text(
                          S.of(context).signInWithGoogle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).createNewAccount,
                          style: const TextStyle(
                              color: Colors.white54, fontFamily: 'Cairo'),
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
                              color: Color(0xFF00D2FF),
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
          ),
        );
      },
    );
  }
}
