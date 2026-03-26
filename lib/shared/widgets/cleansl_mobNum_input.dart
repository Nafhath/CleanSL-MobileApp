import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class CleanSlMobNumInput extends StatelessWidget {
  final TextEditingController? controller;

  const CleanSlMobNumInput({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final double hPad = Responsive.w(context, AppTheme.space24);
    final double vPad = Responsive.h(context, 16);
    final double radius = Responsive.r(context, 30);
    final double iconSize = Responsive.w(context, 24);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 9,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppTheme.textColor,
        fontWeight: FontWeight.w400,
        fontSize: Responsive.sp(context, 16),
      ),
      decoration: InputDecoration(
        hintText: "77 123 4567",
        counterText: "",
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: Responsive.w(context, 24),
            right: Responsive.w(context, 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_android_rounded,
                color: AppTheme.accentColor,
                size: iconSize,
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Text(
                "+94",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: Responsive.sp(context, 16),
                ),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Container(
                height: Responsive.h(context, 24),
                width: 1,
                color: AppTheme.secondaryColor1.withValues(alpha: 0.2),
              ),
              SizedBox(width: Responsive.w(context, 0)),
            ],
          ),
        ),
        filled: true,
        fillColor: AppTheme.primaryBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
