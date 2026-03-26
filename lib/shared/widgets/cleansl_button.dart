import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

// 1. Define all your possible button types here
enum ButtonVariant { primary, secondary, outline, text }

class CleanSlButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double?width;
  final Widget? icon; // Optional icon parameter

  const CleanSlButton({
    super.key,
    required this.text, 
    required this.onPressed,
    this.variant = ButtonVariant.primary, // Defaults to primary if not specified
    this.width = double.infinity, // Defaults to full width
    this.icon,
  
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;
    Color shadowColor = Colors.transparent;
    double elevation = 0;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppTheme.accentColor;
        textColor = AppTheme.textColor;
        shadowColor = AppTheme.accentColor.withValues(alpha: 0.2);
        elevation = 8;
        break;
      case ButtonVariant.secondary:
        bgColor = AppTheme.primaryBackground;
        textColor = AppTheme.textColor;
        shadowColor = AppTheme.primaryBackground.withValues(alpha: 0.2);
        elevation = 8;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppTheme.secondaryColor1;
        borderSide = const BorderSide(color: AppTheme.secondaryColor1, width: 2);
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = AppTheme.hoverColor.withValues(alpha: 0.8);
        break;
    }

    final double vPad = Responsive.h(context, 16);
    final double hPad = Responsive.w(context, 24);
    final double radius = Responsive.r(context, 30);
    final double fontSize = Responsive.sp(context, 16);
    final double iconHeight = Responsive.h(context, 32);

    // 2. RESPONSIVE PADDING
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: textColor,
      shadowColor: shadowColor,
      elevation: elevation,
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: borderSide),
      textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        // 3. Force the inside content height to scale with the device
        child: SizedBox(
          height: iconHeight,
          child: Row(
            mainAxisAlignment: icon != null ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: Responsive.w(context, 24))],
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
