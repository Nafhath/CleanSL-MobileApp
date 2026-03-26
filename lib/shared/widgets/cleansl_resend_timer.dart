import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class CleanSlResendTimer extends StatefulWidget {
  final VoidCallback onResend; // Allows the parent page to pass in what happens when tapped

  const CleanSlResendTimer({super.key, required this.onResend});

  @override
  State<CleanSlResendTimer> createState() => _CleanSlResendTimerState();
}

class _CleanSlResendTimerState extends State<CleanSlResendTimer> {
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bodySize = Responsive.sp(context, 14);
    final double labelSize = Responsive.sp(context, 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _canResend ? "Didn't receive the code? " : "Resend code in ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryBackground.withValues(alpha: 0.7),
            fontSize: bodySize,
          ),
        ),
        GestureDetector(
          onTap: _canResend
              ? () {
                  _startTimer(); // Restart the visual countdown
                  widget.onResend(); // Trigger the actual resend action passed from the page
                }
              : null,
          child: Text(
            _canResend ? "Resend" : "${_secondsRemaining}s",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _canResend ? AppTheme.accentColor : AppTheme.primaryBackground,
              fontWeight: FontWeight.bold,
              fontSize: labelSize,
            ),
          ),
        ),
      ],
    );
  }
}
