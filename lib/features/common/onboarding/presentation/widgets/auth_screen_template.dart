import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_branding.dart';

class AuthScreenTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actionButtons;

  const AuthScreenTemplate({super.key, required this.title, required this.subtitle, required this.actionButtons});

  @override
  Widget build(BuildContext context) {
    final double cardRadius = Responsive.r(context, AppTheme.space48);
    final double cardPadH = Responsive.w(context, AppTheme.space32);
    final double cardPadV = Responsive.h(context, AppTheme.space32);
    final double titleSize = Responsive.sp(context, 24);
    final double subtitleSize = Responsive.sp(context, 14);
    final double titleGap = Responsive.h(context, AppTheme.space8);
    final double contentGap = Responsive.h(context, AppTheme.space32);
    final double bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false, // We handle bottom padding manually via bottomSafe
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // 1. Top Section (Global Branding)
                  const Expanded(flex: 3, child: CleanSlBranding()),

                  // 2. Bottom Section (Curved Container)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor1,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(cardRadius),
                        topRight: Radius.circular(cardRadius),
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                    ),
                    padding: EdgeInsets.only(
                      top: cardPadV,
                      left: cardPadH,
                      right: cardPadH,
                      bottom: cardPadV + bottomSafe,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryBackground,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: titleGap),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBackground.withValues(alpha: 0.7),
                            fontSize: subtitleSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: contentGap),

                        // Unpacks your list of buttons here
                        ...actionButtons,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
