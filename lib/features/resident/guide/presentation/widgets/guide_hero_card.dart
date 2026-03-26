import 'package:flutter/material.dart';
import '../../../../../../core/utils/responsive.dart';

class GuideHeroCard extends StatelessWidget {
  final String imagePath;
  final String badgeText;
  final String title;
  final String subtitle;
  final Color accentColor;

  const GuideHeroCard({
    super.key,
    required this.imagePath,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: Responsive.h(context, 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        padding: EdgeInsets.all(Responsive.w(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 10),
                vertical: Responsive.h(context, 4),
              ),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(Responsive.r(context, 8)),
              ),
              child: Text(
                badgeText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            SizedBox(height: Responsive.h(context, 4)),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}