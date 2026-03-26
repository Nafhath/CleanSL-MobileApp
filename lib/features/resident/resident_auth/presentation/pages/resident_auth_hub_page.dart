import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../../../../common/onboarding/presentation/widgets/auth_screen_template.dart';

class ResidentAuthHubPage extends StatelessWidget {
  const ResidentAuthHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      title: "Resident Access",
      subtitle: "Log in to schedule your waste collection, or sign up to start making a difference.",
      actionButtons: [
        // 1. Sign In Button
        CleanSlButton(
          text: "Log In",
          variant: ButtonVariant.primary,
          onPressed: () {
            Navigator.pushNamed(context, '/resident-login');
          },
        ),

        SizedBox(height: Responsive.h(context, 16)),
        // 2. Create Account Button
        CleanSlButton(
          text: "Create an Account",
          variant: ButtonVariant.secondary,
          onPressed: () {
            Navigator.pushNamed(context, '/resident-signup');
          },
        ),

        SizedBox(height: Responsive.h(context, 24)),
        // 3. Go Back / Cancel Button
        CleanSlButton(
          text: "Back to Role Selection",
          variant: ButtonVariant.text,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
