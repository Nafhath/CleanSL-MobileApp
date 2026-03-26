import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../widgets/guide_back_button.dart';
import '../widgets/guide_hero_card.dart';
import '../widgets/guide_info_box.dart';
import '../widgets/waste_item_tile.dart';

class RecyclablesPage extends StatelessWidget {
  const RecyclablesPage({super.key});

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
          "Recyclable Waste",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        leadingWidth: Responsive.w(context, 100),
        leading: Padding(
          padding: EdgeInsets.only(left: Responsive.w(context, AppTheme.space16)),
          child: Center(child: GuideBackButton(iconColor: AppTheme.accentColor)),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Responsive.w(context, AppTheme.space24)),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(Responsive.w(context, 8)),
                decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.recycling_rounded, color: AppTheme.accentColor, size: Responsive.w(context, 20)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: Responsive.w(context, AppTheme.space24),
          right: Responsive.w(context, AppTheme.space24),
          top: Responsive.h(context, AppTheme.space16),
          bottom: Responsive.h(context, AppTheme.space48),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideHeroCard(
              imagePath: 'assets/img/recyclable_waste.jpg',
              badgeText: 'GUIDE',
              title: 'Recycling Guide',
              subtitle: 'Proper sorting helps reduce landfill waste.',
              accentColor: AppTheme.accentColor,
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            GuideInfoBox(
              title: "Cleaning Instructions",
              icon: Icons.wash_rounded,
              iconColor: AppTheme.accentColor,
              bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
              borderColor: AppTheme.accentColor.withValues(alpha: 0.2),
              child: Text(
                "Always rinse containers thoroughly before recycling. Food residue can contaminate an entire batch of recyclables.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryColor1.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
              ),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            Row(
              children: [
                Icon(Icons.list_alt_rounded, color: AppTheme.accentColor, size: Responsive.w(context, 24)),
                SizedBox(width: Responsive.w(context, 8)),
                Text("Accepted Items", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              ],
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),

            WasteItemTile(
              title: "Plastic Bottles",
              description: "PET 1 and HDPE 2 Plastics",
              icon: Icons.local_drink_rounded,
              iconColor: Colors.blue.shade600,
              iconBgColor: Colors.blue.shade50,
              trailingIcon: Icons.check_circle_rounded,
            ),
            WasteItemTile(
              title: "Paper & Cardboard",
              description: "Magazines, envelopes, and boxes",
              icon: Icons.description_rounded,
              iconColor: AppTheme.secondaryColor1,
              iconBgColor: AppTheme.secondaryColor1.withValues(alpha: 0.1),
              trailingIcon: Icons.check_circle_rounded,
            ),
            WasteItemTile(
              title: "Glass Jars",
              description: "Food and beverage containers",
              icon: Icons.liquor_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.15),
              trailingIcon: Icons.check_circle_rounded,
            ),
            WasteItemTile(
              title: "Metal Cans",
              description: "Aluminum and steel tin cans",
              icon: Icons.inventory_2_rounded,
              iconColor: Colors.blueGrey.shade600,
              iconBgColor: Colors.blueGrey.shade50,
              trailingIcon: Icons.check_circle_rounded,
            ),

            SizedBox(height: Responsive.h(context, AppTheme.space32)),
            _buildDidYouKnowCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDidYouKnowCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 24)),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(Icons.lightbulb_outline_rounded, color: Colors.white.withValues(alpha: 0.15), size: Responsive.w(context, 120)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Did you know?", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: Responsive.h(context, 12)),
              Padding(
                padding: EdgeInsets.only(right: Responsive.w(context, 40)),
                child: Text(
                  "Recycling one aluminum can saves enough energy to run a TV for three hours.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}