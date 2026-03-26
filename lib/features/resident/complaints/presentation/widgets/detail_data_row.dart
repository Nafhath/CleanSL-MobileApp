import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class DetailDataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DetailDataRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.secondaryColor1.withValues(alpha: 0.6)
          )
        ),
        Text(
          value, 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            color: valueColor ?? AppTheme.textColor
          )
        ),
      ],
    );
  }
}