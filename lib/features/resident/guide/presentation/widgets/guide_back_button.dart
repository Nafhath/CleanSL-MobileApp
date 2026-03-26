import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class GuideBackButton extends StatelessWidget {
  final Color iconColor;

  const GuideBackButton({
    super.key,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(Responsive.r(context, 30)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 12),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: iconColor,
              size: Responsive.w(context, 18),
            ),
            SizedBox(width: Responsive.w(context, 4)),
            Text(
              "Back",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}