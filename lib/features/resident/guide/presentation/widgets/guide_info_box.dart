import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class GuideInfoBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Widget child;

  const GuideInfoBox({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 24)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: Responsive.w(context, 24)),
              SizedBox(width: Responsive.w(context, 12)),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 16)),
          child, // This allows us to pass a simple Text OR a list of Tips
        ],
      ),
    );
  }
}