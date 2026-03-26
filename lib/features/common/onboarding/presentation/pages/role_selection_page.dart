import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../widgets/auth_screen_template.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double gap = Responsive.h(context, 24);

    return AuthScreenTemplate(
      title: "Select your role",
      subtitle: "Tell us how you'll be using the app",
      actionButtons: [
        CleanSlButton(
          text: "Resident",
          onPressed: () => Navigator.pushNamed(context, '/resident-auth-hub'),
          variant: ButtonVariant.primary,
        ),
        SizedBox(height: gap),
        CleanSlButton(
          text: "Driver",
          onPressed: () => Navigator.pushNamed(context, '/driver-login'),
          variant: ButtonVariant.secondary,
        ),
        SizedBox(height: gap),
      ],
    );
  }
}
