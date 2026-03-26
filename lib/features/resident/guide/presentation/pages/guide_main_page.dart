import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class GuideMainPage extends StatelessWidget {
  const GuideMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text(
          "Waste Sorting Guide",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        leading: IconButton(
          padding: EdgeInsets.only(left: Responsive.w(context, 16)),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: Responsive.w(context, AppTheme.space24),
          right: Responsive.w(context, AppTheme.space24),
          top: Responsive.h(context, AppTheme.space32),
          bottom: Responsive.h(context, AppTheme.space48),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to sort your waste",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textColor),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),
            Text(
              "Follow these simple steps to help us process waste efficiently and protect the environment.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.8), height: 1.5),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            _buildWasteCategoryCard(
              context,
              title: "Organic Waste",
              description: "Biodegradable materials that can be composted.",
              icon: Icons.eco_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.15),
              tags: ["FOOD SCRAPS", "GARDEN WASTE", "PAPER TOWELS"],
              onTap: () => Navigator.pushNamed(context, '/organic-waste'),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            _buildWasteCategoryCard(
              context,
              title: "Recyclable",
              description: "Materials that can be processed and reused.",
              icon: Icons.recycling_rounded,
              iconColor: Colors.blue.shade600,
              iconBgColor: Colors.blue.shade50,
              tags: ["PLASTICS", "GLASS", "METAL CANS"],
              onTap: () => Navigator.pushNamed(context, '/recyclables'),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            _buildWasteCategoryCard(
              context,
              title: "Non-recyclable",
              description: "Waste destined for landfill disposal.",
              icon: Icons.delete_rounded,
              iconColor: Colors.orange.shade700,
              iconBgColor: Colors.orange.shade50,
              tags: ["DIAPERS", "STYROFOAM", "HAZARDOUS"],
              onTap: () => Navigator.pushNamed(context, '/non-recyclables'),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required List<String> tags,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 16)),
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: Responsive.w(context, 32)),
              ),
              SizedBox(width: Responsive.w(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 20)),
          Wrap(spacing: Responsive.w(context, 8), runSpacing: Responsive.h(context, 8), children: tags.map((tag) => _buildTag(context, tag)).toList()),
          SizedBox(height: Responsive.h(context, 24)),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
              decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Responsive.r(context, 30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Learn More",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: Responsive.w(context, 8)),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accentColor, size: Responsive.w(context, 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 12), vertical: Responsive.h(context, 6)),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(Responsive.r(context, 8))),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: Responsive.sp(context, 10)),
      ),
    );
  }
}