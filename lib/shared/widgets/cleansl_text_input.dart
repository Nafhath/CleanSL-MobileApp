import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class CleanSlTextInput extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const CleanSlTextInput({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<CleanSlTextInput> createState() => _CleanSlTextInputState();
}

class _CleanSlTextInputState extends State<CleanSlTextInput> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final double hPad = Responsive.w(context, AppTheme.space24);
    final double vPad = Responsive.h(context, 16);
    final double radius = Responsive.r(context, 30);

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontSize: Responsive.sp(context, 16)),
      decoration: InputDecoration(
        hintText: widget.hintText,
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
        suffixIcon: widget.isPassword
            ? Padding(
                padding: EdgeInsets.only(right: Responsive.w(context, 12)),
                child: IconButton(
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppTheme.secondaryColor1.withValues(alpha: 0.5),
                    size: Responsive.w(context, 22),
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
              )
            : null,
      ),
    );
  }
}
