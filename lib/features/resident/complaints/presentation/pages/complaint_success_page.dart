import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class ComplaintSuccessPage extends StatelessWidget {
  final String referenceId;

  const ComplaintSuccessPage({super.key, required this.referenceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(center: const Alignment(0, -0.2), radius: 1.2, colors: [const Color(0xFFE8F5E9), AppTheme.primaryBackground]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedCheck(),
            SizedBox(height: Responsive.h(context, 48)),
            Text("Report Submitted!", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Text(
                "Your report has been received and is being processed. You can track its status in the Complaints tab.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.7), height: 1.6),
              ),
            ),
            SizedBox(height: Responsive.h(context, 48)),
            _buildDashboardButton(context),
            SizedBox(height: Responsive.h(context, 32)),
            _buildReferencePill(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCheck() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.hoverColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppTheme.hoverColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)],
      ),
      child: const Icon(Icons.check_rounded, color: AppTheme.secondaryColor2, size: 60),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: () => Navigator.of(context).popUntil(ModalRoute.withName('/resident-main')),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: AppTheme.secondaryColor2, borderRadius: BorderRadius.circular(30)),
          alignment: Alignment.center,
          child: const Text(
            "Back to Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildReferencePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
      child: Text(
        "REFERENCE ID: #$referenceId",
        style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
