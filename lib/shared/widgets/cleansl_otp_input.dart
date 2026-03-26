import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class CleanSlOtpInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const CleanSlOtpInput({super.key, this.onChanged});

  @override
  State<CleanSlOtpInput> createState() => _CleanSlOtpInputState();
}

class _CleanSlOtpInputState extends State<CleanSlOtpInput> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyOtpChanged() {
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = Responsive.w(context, 64);
    final double radius = Responsive.r(context, 16);
    final double fontSize = Responsive.sp(context, 24);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4, // 4 digit OTP
        (index) => SizedBox(
          width: boxSize,
          height: boxSize,
          child: TextField(
            controller: _controllers[index],
            autofocus: index == 0, // Automatically focuses the first box
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.textColor, fontSize: fontSize),
            // Limits input to 1 digit per box
            inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              // Automatically jump to the next box when a number is typed
              if (value.length == 1 && index < 3) {
                FocusScope.of(context).nextFocus();
              }
              // Go back if they delete
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
              _notifyOtpChanged();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.primaryBackground,
              counterText: "", // Hides the default character counter
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
