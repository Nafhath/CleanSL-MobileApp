import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

// 1. Define the two different styles
enum BrandingLayout { vertical, horizontal }

class CleanSlBranding extends StatelessWidget {
  final BrandingLayout layout; // 2. Add layout parameter

  const CleanSlBranding({
    super.key,
    this.layout = BrandingLayout.vertical, // Defaults to vertical so it doesn't break old screens!
  });

  @override
  Widget build(BuildContext context) {
    // 3. Return the correct layout based on what was passed
    if (layout == BrandingLayout.horizontal) {
      return _buildHorizontalLayout(context);
    }
    return _buildVerticalLayout(context);
  }

  // --- THE NEW HORIZONTAL RESIDENT STYLE ---
  Widget _buildHorizontalLayout(BuildContext context) {
    final double logoSize = Responsive.w(context, 72);
    final double fontSize = Responsive.sp(context, 24);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/img/logo.png', height: logoSize, width: logoSize),
        Transform.translate(
          offset: Offset(Responsive.w(context, -8), 0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Clean",
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: AppTheme.textColor, letterSpacing: 1.2, fontSize: fontSize),
                ),
                TextSpan(
                  text: "SL",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.accentColor,
                    letterSpacing: 1.2,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- THE ORIGINAL VERTICAL DRIVER/ONBOARDING STYLE ---
  Widget _buildVerticalLayout(BuildContext context) {
    final double logoSize = Responsive.w(context, 150);
    final double fontSize = Responsive.sp(context, 32);
    final double subtitleSize = Responsive.sp(context, 16);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/img/logo.png', height: logoSize, width: logoSize, fit: BoxFit.contain),
        Transform.translate(
          offset: Offset(0, Responsive.h(context, -20)),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Clean",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.textColor,
                        letterSpacing: 1.2,
                        fontSize: fontSize,
                      ),
                    ),
                    TextSpan(
                      text: "SL",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.accentColor,
                        letterSpacing: 1.2,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(context, AppTheme.space8)),
              Text(
                "Welcome to a cleaner future",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                  fontSize: subtitleSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
