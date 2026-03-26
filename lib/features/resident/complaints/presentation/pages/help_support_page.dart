import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../widgets/faq_tile.dart'; // New Import

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text("Help & Support", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How can we help?", style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: Responsive.h(context, AppTheme.space8)),
            Text("Find answers to common questions about our waste management services.",
                style: textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.7), height: 1.5)),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),
            
            Text("Frequently Asked Questions", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor1)),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),
            
            // Using extracted Widgets
            const FAQTile(question: "How long does it take to resolve a complaint?", answer: "Most complaints are reviewed within 24 hours and resolved within 3 working days."),
            const FAQTile(question: "What images should I upload for an overflowing bin?", answer: "Please provide a clear wide-angle shot showing the bin and its surroundings."),
            const FAQTile(question: "Can I cancel a reported issue?", answer: "Yes, you can cancel a pending report by viewing the complaint details."),

            SizedBox(height: Responsive.h(context, AppTheme.space48)),
            _buildContactSection(context, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor1,
        borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
        boxShadow: [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text("Still need help?", style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.h(context, AppTheme.space8)),
          Text("Our support team is available 24/7 for urgent matters.", textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
          SizedBox(height: Responsive.h(context, AppTheme.space24)),
          _buildContactButton(context, Icons.phone_rounded, "Call Helpline", () {}),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          _buildContactButton(context, Icons.email_rounded, "Email Support", () {}),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.secondaryColor2,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 12))),
          elevation: 0,
        ),
      ),
    );
  }
}