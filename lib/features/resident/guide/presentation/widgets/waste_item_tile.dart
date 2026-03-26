import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class WasteItemTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor; // Made nullable because Organic page doesn't use a background here
  final IconData? trailingIcon; // For the checkmarks on the Recyclable page

  const WasteItemTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, AppTheme.space16)),
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If iconBgColor is provided, wrap it in a circle. Otherwise, just show the icon.
          if (iconBgColor != null)
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 12)),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: Responsive.w(context, 24)),
            )
          else
            Icon(icon, color: iconColor, size: Responsive.w(context, 28)),
          
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryColor1.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: Responsive.w(context, 8)),
            Padding(
              padding: EdgeInsets.only(top: Responsive.h(context, 8)),
              child: Icon(trailingIcon, color: Colors.grey.shade300, size: Responsive.w(context, 24)),
            ),
          ]
        ],
      ),
    );
  }
}