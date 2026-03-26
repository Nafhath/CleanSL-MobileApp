import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/services/auth_service.dart'; 
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_text_input.dart';
import '../../../../../shared/widgets/cleansl_mobnum_input.dart';
import '../widgets/resident_auth_template.dart';

class ResidentLoginPage extends StatefulWidget {
  const ResidentLoginPage({super.key});

  @override
  State<ResidentLoginPage> createState() => _ResidentLoginPageState();
}

class _ResidentLoginPageState extends State<ResidentLoginPage> {
  bool _isEmailMode = false;

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final identifier = _isEmailMode ? _emailController.text.trim() : _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    if (_isEmailMode && !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(identifier)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid email address")));
      return;
    }

    if (!_isEmailMode && identifier.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid 9-digit mobile number")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInResident(identifier: identifier, password: password);
      if (mounted) Navigator.pushReplacementNamed(context, '/resident-main');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) Navigator.pushReplacementNamed(context, '/resident-main');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gap = Responsive.h(context, AppTheme.space16);
    final double sectionGap = Responsive.h(context, AppTheme.space16);

    return ResidentAuthTemplate(
      title: "Welcome back",
      subtitle: "Please enter your account details to continue making a difference in your community.",
      topSpacing: AppTheme.space16,
      formChildren: [
        _isEmailMode 
            ? CleanSlTextInput(hintText: "Email", keyboardType: TextInputType.emailAddress, controller: _emailController) 
            : CleanSlMobNumInput(controller: _mobileController),
        
        SizedBox(height: gap),

        CleanSlTextInput(hintText: "Password", isPassword: true, controller: _passwordController),

        SizedBox(height: gap),

        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/forgot-password'),
            child: Text(
              "Forgot Password?",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.accentColor, fontSize: Responsive.sp(context, 16)),
            ),
          ),
        ),

        SizedBox(height: gap),

        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            : CleanSlButton(
                text: "Sign In",
                variant: ButtonVariant.primary,
                onPressed: _handleSignIn,
              ),

        SizedBox(height: gap),

        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white38, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space16)),
              child: Text("or", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ),
            const Expanded(child: Divider(color: Colors.white38, thickness: 1)),
          ],
        ),

        SizedBox(height: gap),

        CleanSlButton(
          text: "Continue with Google",
          variant: ButtonVariant.secondary,
          icon: SvgPicture.asset(
            'assets/icons/google_logo.svg',
            height: Responsive.h(context, 32),
            width: Responsive.w(context, 32),
          ),
          onPressed: handleGoogleSignIn,
        ),

        SizedBox(height: gap),

        CleanSlButton(
          text: _isEmailMode ? "Continue with Mobile " : "Continue with Email",
          variant: ButtonVariant.secondary,
          icon: _isEmailMode
              ? Icon(Icons.phone_android_rounded, color: AppTheme.textColor, size: Responsive.w(context, 28))
              : Icon(Icons.email_outlined, color: AppTheme.textColor, size: Responsive.w(context, 28)),
          onPressed: () {
            setState(() {
              _isEmailMode = !_isEmailMode;
            });
          },
        ),

        SizedBox(height: sectionGap),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryBackground.withValues(alpha: 0.8), fontSize: Responsive.sp(context, 14)),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/resident-signup'),
              child: Text(
                "Sign Up",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.accentColor, fontSize: Responsive.sp(context, 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}