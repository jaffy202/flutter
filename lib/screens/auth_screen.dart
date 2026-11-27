import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/diary_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (credential.user != null) {
          await DiaryRepository().createUserProfile(credential.user!);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldLight = Color(0xFFF6E299);
    const goldMid = Color(0xFFD4AF5A);
    const goldDark = Color(0xFF9E7B2F);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Custom Illustrated Background Image
          Image.asset(
            'assets/images/starry_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF0C2338),
            ),
          ),

          // 2. Main Interactive Login Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 54),

                      // Custom Diary Emblem Image
                      Center(
                        child: SizedBox(
                          width: 84,
                          height: 84,
                          child: Image.asset(
                            'assets/images/diary_emblem.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.auto_stories_rounded,
                              color: goldLight,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Metallic Gold App Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFF4C2), goldMid, goldDark],
                        ).createShader(bounds),
                        child: Text(
                          'My Starry Diary',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        _isLogin ? 'Welcome Back' : 'Begin Your Story',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFE6DEC8),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Email Field
                      _StarryTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // Password Field with Eye Toggle
                      _StarryTextField(
                        controller: _passwordController,
                        hintText: 'Password (min 6 chars)',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: goldLight.withValues(alpha: 0.85),
                            size: 22,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),

                      // Error Message Display
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFCDD2),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Ornate Metallic Gold Pill Button
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isLoading ? 0.65 : 1.0,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: goldLight, width: 1.5),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFF6E299),
                                  Color(0xFFD5B15E),
                                  Color(0xFFB38B3A),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Color(0xFF2B1E08),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'LOG IN' : 'SIGN UP',
                                    style: GoogleFonts.cinzel(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2B1E08),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Switch Login / Sign Up Mode
                      TextButton(
                        onPressed: () => setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        }),
                        child: Text(
                          _isLogin
                              ? 'Need an account? Sign up'
                              : 'Already have an account? Log in',
                          style: GoogleFonts.lato(
                            color: const Color(0xFFE6DEC8),
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _StarryTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    const borderGold = Color(0xFFC5A253);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF183642).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderGold.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.lato(
          color: const Color(0xFFF5EFE0),
          fontSize: 16,
        ),
        cursorColor: const Color(0xFFF6E299),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.lato(
            color: const Color(0xFFB5C4C9),
            fontSize: 15.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
