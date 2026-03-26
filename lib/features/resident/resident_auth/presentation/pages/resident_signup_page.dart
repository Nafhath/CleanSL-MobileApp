import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_text_input.dart';
import '../../../../../shared/widgets/cleansl_mobnum_input.dart';
import '../widgets/resident_auth_template.dart';
import '../../../../../core/services/auth_service.dart';

class ResidentSignUpPage extends StatefulWidget {
  const ResidentSignUpPage({super.key});

  @override
  State<ResidentSignUpPage> createState() => _ResidentSignUpPageState();
}

class _ResidentSignUpPageState extends State<ResidentSignUpPage> {
  final AuthService _authService = AuthService();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool get _passwordIsValid {
    final pw = _passwordController.text;
    if (pw.length < 8) return false;
    if (!pw.contains(RegExp(r'[A-Z]'))) return false;
    if (!pw.contains(RegExp(r'[a-z]'))) return false;
    if (!pw.contains(RegExp(r'[0-9]'))) return false;
    if (!pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  bool get _passwordsMatch => _passwordController.text == _confirmPasswordController.text && _confirmPasswordController.text.isNotEmpty;

  bool get _isFullNameValid {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) return false;
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) return false;
    return true;
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return false;
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);
  }

  bool get _isMobileValid => _mobileController.text.trim().length == 9;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(() => setState(() {}));
    _mobileController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_isFullNameValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name can only contain letters.")));
      return;
    }
    if (!_isMobileValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mobile number must be exactly 9 digits.")));
      return;
    }
    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid email address.")));
      return;
    }
    if (!_passwordIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password does not meet requirements.")));
      return;
    }
    if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must agree to the Terms & Conditions.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signUpResident(
        fullName: _fullNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.signedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Account created successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.primaryBackground, fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: Responsive.h(context, 32), left: Responsive.w(context, 48), right: Responsive.w(context, 48)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 30))),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, '/resident-main');
      } else if (result.requiresEmailConfirmation) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(ctx, 20))),
            title: const Text("Verify your email"),
            content: Text(
              "Your account was created for ${result.email ?? _emailController.text.trim()}. Please verify your email address before signing in.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/resident-login');
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = "Something went wrong. Please try again.";
        final error = e.toString().toLowerCase();

        if (error.contains('already registered') || error.contains('user already registered') || error.contains('already been registered')) {
          message = "An account with this email already exists. Try signing in instead.";
        } else if (error.contains('email') && error.contains('invalid')) {
          message = "Please enter a valid email address.";
        } else if (error.contains('network') || error.contains('socket') || error.contains('connection')) {
          message = "No internet connection. Please check your network and try again.";
        } else if (error.contains('rate') || error.contains('too many')) {
          message = "Too many attempts. Please wait a moment and try again.";
        } else if (error.contains('weak password') || error.contains('password')) {
          message = "Your password is too weak. Please choose a stronger one.";
        }

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(ctx, 20))),
            title: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: Responsive.w(ctx, 28)),
                SizedBox(width: Responsive.w(ctx, 8)),
                const Text("Sign Up Failed"),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldGap = Responsive.h(context, 20);
    final double sectionGap = Responsive.h(context, AppTheme.space16);
    final double smallGap = Responsive.h(context, AppTheme.space16);
    final double checkboxSize = Responsive.w(context, 24);

    return ResidentAuthTemplate(
      title: "Get Started",
      subtitle: "Please enter your details to create a new account.",
      topSpacing: AppTheme.space16,
      formChildren: [
        CleanSlTextInput(hintText: "Full Name", controller: _fullNameController),
        SizedBox(height: fieldGap),

        CleanSlMobNumInput(controller: _mobileController),
        SizedBox(height: fieldGap),

        CleanSlTextInput(hintText: "Email", keyboardType: TextInputType.emailAddress, controller: _emailController),
        SizedBox(height: fieldGap),

        CleanSlTextInput(hintText: "Create Password", isPassword: true, controller: _passwordController),
        SizedBox(height: fieldGap),

        CleanSlTextInput(hintText: "Confirm Password", isPassword: true, controller: _confirmPasswordController),
        SizedBox(height: fieldGap),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: checkboxSize,
              height: checkboxSize,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                activeColor: AppTheme.accentColor,
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreedToTerms = !_agreedToTerms;
                  });
                },
                child: Text.rich(
                  TextSpan(
                    text: "I agree to the ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryBackground.withValues(alpha: 0.8), fontSize: Responsive.sp(context, 12)),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.w600, fontSize: Responsive.sp(context, 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        if (_passwordController.text.isNotEmpty && !_passwordIsValid)
          Padding(
            padding: EdgeInsets.only(top: Responsive.h(context, 8), bottom: Responsive.h(context, 8)),
            child: Text(
              "Password must be at least 8 characters with uppercase, lowercase, number, and special character.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryBackground.withValues(alpha: 0.6), fontSize: Responsive.sp(context, 11)),
            ),
          ),

        if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch)
          Padding(
            padding: EdgeInsets.only(top: Responsive.h(context, 8), bottom: Responsive.h(context, 8)),
            child: Text(
              "Passwords do not match.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent.shade100, fontSize: Responsive.sp(context, 11)),
            ),
          ),

        SizedBox(height: sectionGap),

        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            : CleanSlButton(
                text: "Sign Up",
                variant: ButtonVariant.primary,
                onPressed: _handleSignUp,
              ),

        SizedBox(height: smallGap),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryBackground.withValues(alpha: 0.8), fontSize: Responsive.sp(context, 14)),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/resident-login'),
              child: Text(
                "Sign In",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.accentColor, fontSize: Responsive.sp(context, 16)),
              ),
            ),
          ],
        ),

        SizedBox(height: Responsive.h(context, AppTheme.space16)),
      ],
    );
  }
}
