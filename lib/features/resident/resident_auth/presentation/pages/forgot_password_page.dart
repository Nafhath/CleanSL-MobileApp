import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_text_input.dart';
import '../../../../../shared/widgets/cleansl_mobnum_input.dart';
import '../widgets/resident_auth_template.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isEmailMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  // ignore: prefer_final_fields — will be toggled true/false during async backend call
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double gap = Responsive.h(context, AppTheme.space16);

    return ResidentAuthTemplate(
      title: "Forgot Password?",
      subtitle: _isEmailMode
          ? "No worries! Enter your email address and we'll send you a code to reset your password."
          : "No worries! Enter your mobile number and we'll send you a code to reset your password.",
      topSpacing: AppTheme.space16,
      formChildren: [
        _isEmailMode ? CleanSlTextInput(hintText: "Email", keyboardType: TextInputType.emailAddress, controller: _emailController) : CleanSlMobNumInput(controller: _mobileController),

        SizedBox(height: gap * 1.5),

        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            : CleanSlButton(
                text: "Send Reset Code",
                variant: ButtonVariant.primary,
                onPressed: () {
                  final identifier = _isEmailMode ? _emailController.text.trim() : _mobileController.text.trim();

                  if (identifier.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEmailMode ? "Please enter your email address" : "Please enter your mobile number")));
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

                  // TODO: Backend teammate will add the actual send-code logic here
                  Navigator.pushNamed(context, '/forgot-password-verify', arguments: identifier);
                },
              ),

        SizedBox(height: gap),

        CleanSlButton(
          text: _isEmailMode ? "Use Mobile Number instead" : "Use Email instead",
          variant: ButtonVariant.text,
          onPressed: () {
            setState(() {
              _isEmailMode = !_isEmailMode;
            });
          },
        ),

        SizedBox(height: gap),

        CleanSlButton(text: "Back to Sign In", variant: ButtonVariant.text, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
