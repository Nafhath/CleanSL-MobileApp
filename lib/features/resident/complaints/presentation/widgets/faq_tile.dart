import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, AppTheme.space16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        iconColor: AppTheme.accentColor,
        collapsedIconColor: AppTheme.secondaryColor1,
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          Responsive.w(context, AppTheme.space16),
          0,
          Responsive.w(context, AppTheme.space16),
          Responsive.h(context, AppTheme.space16),
        ),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryColor1.withValues(alpha: 0.7),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}