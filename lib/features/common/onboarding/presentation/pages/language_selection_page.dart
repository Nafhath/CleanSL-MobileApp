import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';
import '../widgets/auth_screen_template.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double gap = Responsive.h(context, 24);

    return AuthScreenTemplate(
      title: "Choose your language",
      subtitle: "භාෂාව තෝරන්න | மொழியைத் தேர்ந்தெடுக்கவும்",
      actionButtons: [
        CleanSlButton(
          text: "English",
          onPressed: () => Navigator.pushNamed(context, '/role'),
          variant: ButtonVariant.secondary,
        ),
        SizedBox(height: gap),
        CleanSlButton(
          text: "සිංහල",
          onPressed: () => Navigator.pushNamed(context, '/role'),
          variant: ButtonVariant.secondary,
        ),
        SizedBox(height: gap),
        CleanSlButton(
          text: "தமிழ்",
          onPressed: () => Navigator.pushNamed(context, '/role'),
          variant: ButtonVariant.secondary,
        ),
        SizedBox(height: gap),
      ],
    );
  }
}
