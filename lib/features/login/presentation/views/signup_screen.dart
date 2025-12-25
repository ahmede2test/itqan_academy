import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/views/home_screen_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/cash_helper.dart';
import '../../../../core/utils/functions/custom_toast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool _isLoading = false;
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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _setupAuthListener() {
    final supabase = Supabase.instance.client;

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          debugPrint("SignUpScreen: Auth success detected via listener.");
          setState(() {
            _isLoading = false;
            _isGoogleLoading = false;
          });

          CashHelper.setData('isLoggedIn', true);
          CashHelper.setData('token', session.accessToken);
          CashHelper.setData(
              'name',
              session.user.userMetadata?['first_name'] ??
                  session.user.email?.split('@')[0] ??
                  "User");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    });

    if (!kIsWeb) {
      _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
        if (uri.scheme == 'itqan' && uri.host == 'login-callback') {
          debugPrint("SignUpScreen: Deep Link received: $uri");
          try {
            await supabase.auth.getSessionFromUrl(uri);
          } catch (e) {
            debugPrint("Error processing session from URL: $e");
            if (mounted) {
              setState(() {
                _isLoading = false;
                _isGoogleLoading = false;
              });
            }
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': 'user',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.user != null) {
        if (mounted) {
          customShowToast(msg: S.of(context).accountCreatedSuccess);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e is TimeoutException) {
        errorMessage = S.of(context).unexpectedError;
      }
      customShowToast(msg: errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        errorMessage = S.of(context).unexpectedError;
      }
      customShowToast(msg: "${S.of(context).error}: $errorMessage");
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  S.of(context).signupTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).welcomeInQB,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white38,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // First Name
                TextFormField(
                  controller: firstNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration(
                    icon: Icons.person_rounded,
                    label: S.of(context).firstName,
                    hint: S.of(context).firstName,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? S.of(context).requiredField
                      : null,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: lastNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration(
                    icon: Icons.person_outline_rounded,
                    label: S.of(context).lastName,
                    hint: S.of(context).lastName,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? S.of(context).requiredField
                      : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration(
                    icon: Icons.alternate_email_rounded,
                    label: S.of(context).email,
                    hint: S.of(context).enterEmail,
                  ),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : S.of(context).pleaseEnterEmail,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (value) => value != null && value.length < 6
                      ? S.of(context).passwordShowHint
                      : null,
                ),
                const SizedBox(height: 40),

                // Sign Up Button
                HoverEffect(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: _isLoading ? null : _signUp,
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  S.of(context).signUp,
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
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
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

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).alreadyHaveAccount,
                      style: const TextStyle(
                          color: Colors.white54, fontFamily: 'Cairo'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        S.of(context).login,
                        style: const TextStyle(
                          color: Color(0xFF00D2FF),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
