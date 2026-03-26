import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_text_input.dart';
import '../widgets/resident_auth_template.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  // ignore: prefer_final_fields — will be toggled true/false during async backend call
  bool _isLoading = false;

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

  bool get _canSubmit => _passwordIsValid && _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double gap = Responsive.h(context, AppTheme.space16);

    return ResidentAuthTemplate(
      title: "Create new password",
      subtitle: "Your new password must be different from your previous password.",
      topSpacing: AppTheme.space16,
      formChildren: [
        CleanSlTextInput(hintText: "New Password", isPassword: true, controller: _passwordController),

        SizedBox(height: gap),

        CleanSlTextInput(hintText: "Confirm New Password", isPassword: true, controller: _confirmPasswordController),

        if (_passwordController.text.isNotEmpty && !_passwordIsValid)
          Padding(
            padding: EdgeInsets.only(top: Responsive.h(context, 8)),
            child: Text(
              "Password must be at least 8 characters with uppercase, lowercase, number, and special character.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryBackground.withValues(alpha: 0.6), fontSize: Responsive.sp(context, 11)),
            ),
          ),

        if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch)
          Padding(
            padding: EdgeInsets.only(top: Responsive.h(context, 8)),
            child: Text(
              "Passwords do not match.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent.shade100, fontSize: Responsive.sp(context, 11)),
            ),
          ),

        SizedBox(height: gap * 1.5),

        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            : CleanSlButton(
                text: "Reset Password",
                variant: ButtonVariant.primary,
                onPressed: _canSubmit
                    ? () {
                        // TODO: Backend teammate will add actual password update logic here

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Password reset successfully!",
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

                        Navigator.pushNamedAndRemoveUntil(context, '/resident-login', (route) => false);
                      }
                    : null,
              ),

        SizedBox(height: gap),
      ],
    );
  }
}
