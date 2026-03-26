import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_mobnum_input.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../common/onboarding/presentation/widgets/auth_screen_template.dart';
import '../../../../../core/services/auth_service.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().sendDriverOTP(mobile: _mobileController.text.trim());
      if (mounted) {
        Navigator.pushNamed(context, '/driver-otp', arguments: _mobileController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSendOtp = _mobileController.text.length == 9;

    return AuthScreenTemplate(
      title: "Driver Access",
      subtitle: "Enter your registered mobile number. We'll send you an OTP to verify it's you.",
      actionButtons: [
        // 1. Mobile Number Input Field
        CleanSlMobNumInput(controller: _mobileController),

        SizedBox(height: Responsive.h(context, 32)),

        // 2. Send OTP Button
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CleanSlButton(
                text: "Send OTP",
                variant: ButtonVariant.primary,
                onPressed: canSendOtp ? _handleSendOtp : null,
              ),

        SizedBox(height: Responsive.h(context, 16)),

        // 3. Back Button
        CleanSlButton(text: "Cancel", variant: ButtonVariant.text, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
