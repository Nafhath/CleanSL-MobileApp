import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_branding.dart';

class ResidentAuthTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> formChildren; // The inputs and buttons that go inside the green card
  final double? topSpacing;

  const ResidentAuthTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formChildren,
    this.topSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final double logoPadTop = Responsive.h(context, AppTheme.space24);
    final double titlePadH = Responsive.w(context, AppTheme.space24);
    final double titleFontSize = Responsive.sp(context, 32);
    final double subtitleFontSize = Responsive.sp(context, 12);
    final double titleGap = Responsive.h(context, AppTheme.space16);
    final double cardRadius = Responsive.r(context, 50);
    final double cardPadTop = Responsive.h(context, AppTheme.space48);
    final double cardPadH = Responsive.w(context, AppTheme.space32);
    final double cardPadBottom = Responsive.h(context, AppTheme.space24);

    final double bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Fixed Logo)
                  Padding(
                    padding: EdgeInsets.only(top: logoPadTop),
                    child: const CleanSlBranding(layout: BrandingLayout.horizontal),
                  ),

                  // 2. The Magic Spacer
                  const Spacer(),

                  // 3. Dynamic Titles
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: titlePadH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(color: AppTheme.textColor, fontSize: titleFontSize),
                        ),
                        SizedBox(height: titleGap),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textColor.withValues(alpha: 0.8),
                            fontSize: subtitleFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: topSpacing != null
                        ? Responsive.h(context, topSpacing!)
                        : Responsive.h(context, AppTheme.space48),
                  ),

                  // 4. The Green Form Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor1,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
                    ),
                    padding: EdgeInsets.only(
                      top: cardPadTop,
                      left: cardPadH,
                      right: cardPadH,
                      bottom: cardPadBottom + bottomSafe,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: formChildren),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
