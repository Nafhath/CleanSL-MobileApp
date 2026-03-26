import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_otp_input.dart';
import '../../../../../shared/widgets/cleansl_resend_timer.dart';
import '../widgets/resident_auth_template.dart';

class ForgotPasswordVerifyPage extends StatefulWidget {
  const ForgotPasswordVerifyPage({super.key});

  @override
  State<ForgotPasswordVerifyPage> createState() => _ForgotPasswordVerifyPageState();
}

class _ForgotPasswordVerifyPageState extends State<ForgotPasswordVerifyPage> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    // Receive the identifier passed from the previous screen
    final String identifier = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    final bool isEmail = identifier.contains('@');

    return ResidentAuthTemplate(
      title: isEmail ? "Check your email" : "Check your phone",
      subtitle: isEmail ? "We've sent a 4-digit code to $identifier. Enter it below to continue." : "We've sent a 4-digit code to +94 $identifier. Enter it below to continue.",
      topSpacing: AppTheme.space16,
      formChildren: [
        CleanSlOtpInput(
          onChanged: (value) {
            setState(() {
              _otp = value;
            });
          },
        ),

        SizedBox(height: Responsive.h(context, AppTheme.space32)),

        CleanSlButton(
          text: "Verify Code",
          variant: ButtonVariant.primary,
          onPressed: _otp.length == 4
              ? () {
                  //TODO: Backend teammate will add actual code verification here
                  Navigator.pushReplacementNamed(context, '/reset-password');
                }
              : null,
        ),

        SizedBox(height: Responsive.h(context, AppTheme.space24)),

        CleanSlResendTimer(
          onResend: () {
            // TODO: Backend teammate will add actual resend logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("New code sent!", textAlign: TextAlign.center),
                backgroundColor: AppTheme.accentColor,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: Responsive.h(context, 32), left: Responsive.w(context, 80), right: Responsive.w(context, 80)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 30))),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),

        SizedBox(height: Responsive.h(context, AppTheme.space16)),

        CleanSlButton(
          text: "Back to Sign In",
          variant: ButtonVariant.text,
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/resident-login'));
          },
        ),
      ],
    );
  }
}
