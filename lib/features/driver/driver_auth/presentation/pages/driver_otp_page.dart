import 'package:flutter/material.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../../shared/widgets/cleansl_otp_input.dart';
import '../../../../../shared/widgets/cleansl_resend_timer.dart';
import '../../../../common/onboarding/presentation/widgets/auth_screen_template.dart';

class DriverOtpPage extends StatefulWidget {
  const DriverOtpPage({super.key});

  @override
  State<DriverOtpPage> createState() => _DriverOtpPageState();
}

class _DriverOtpPageState extends State<DriverOtpPage> {
  final AuthService _authService = AuthService();
  String _otp = '';
  bool _isLoading = false;

  Future<void> _handleVerifyOTP(String mobile) async {
    setState(() => _isLoading = true);
    try {
      await _authService.verifyDriverOTP(mobile: mobile, token: _otp);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.pushNamedAndRemoveUntil(context, '/driver-home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Invalid OTP. Please try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: Responsive.h(context, 32), left: Responsive.w(context, 48), right: Responsive.w(context, 48)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 30))),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend(String mobile) async {
    try {
      await _authService.sendDriverOTP(mobile: mobile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("New OTP sent!", textAlign: TextAlign.center),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: Responsive.h(context, 32), left: Responsive.w(context, 80), right: Responsive.w(context, 80)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 30))),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to resend: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String mobileNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return AuthScreenTemplate(
      title: "Verify your number",
      subtitle: "Enter the 4-digit code we just sent to +94 $mobileNumber",
      actionButtons: [
        CleanSlOtpInput(
          onChanged: (value) {
            setState(() {
              _otp = value;
            });
          },
        ),

        SizedBox(height: Responsive.h(context, 32)),

        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CleanSlButton(
                text: "Verify & Login",
                variant: ButtonVariant.primary,
                onPressed: _otp.length == 4
                    ? () => _handleVerifyOTP(mobileNumber)
                    : null,
              ),

        SizedBox(height: Responsive.h(context, 24)),

        CleanSlResendTimer(
          onResend: () => _handleResend(mobileNumber),
        ),

        SizedBox(height: Responsive.h(context, 16)),

        CleanSlButton(text: "Change mobile number", variant: ButtonVariant.text, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
