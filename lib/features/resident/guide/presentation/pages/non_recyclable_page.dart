import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../widgets/guide_back_button.dart';
import '../widgets/guide_hero_card.dart';
import '../widgets/guide_info_box.dart';
import '../widgets/waste_item_tile.dart';

class NonRecyclablePage extends StatelessWidget {
  const NonRecyclablePage({super.key});

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
          "Non-recyclable Waste",
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
              imagePath: 'assets/img/non-recyclable_waste.jpg',
              badgeText: 'GUIDE',
              title: 'Landfill Guide',
              subtitle: 'Dispose of general waste safely.',
              accentColor: AppTheme.accentColor,
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            Text(
              "Items for Landfill",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),

            WasteItemTile(
              title: "Sanitary Products & Diapers",
              description: "Used diapers, wipes, and feminine hygiene products.",
              icon: Icons.baby_changing_station_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.12),
            ),
            WasteItemTile(
              title: "Styrofoam & Polystyrene",
              description: "Takeout containers, packing peanuts, and foam cups.",
              icon: Icons.takeout_dining_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.12),
            ),
            WasteItemTile(
              title: "Contaminated Packaging",
              description: "Greasy pizza boxes, food-soaked wrappers, and soiled paper.",
              icon: Icons.fastfood_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.12),
            ),
            WasteItemTile(
              title: "Hazardous Materials",
              description: "Light bulbs, ceramics, mirrors, and specific medical waste.",
              icon: Icons.warning_rounded,
              iconColor: AppTheme.accentColor,
              iconBgColor: AppTheme.accentColor.withValues(alpha: 0.12),
            ),

            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            GuideInfoBox(
              title: "Proper Disposal Tips",
              icon: Icons.lightbulb_rounded,
              iconColor: AppTheme.accentColor,
              bgColor: AppTheme.primaryBackground,
              borderColor: AppTheme.accentColor.withValues(alpha: 0.2),
              child: Column(
                children: [
                  _buildTipRow(context, "Bag all loose items to prevent litter during collection."),
                  _buildTipRow(context, "Double-bag pet waste and sharp objects for safety."),
                  _buildTipRow(context, "Check local regulations for large furniture or bulky items."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Responsive.h(context, 4)),
            child: Icon(Icons.check_circle_rounded, color: AppTheme.accentColor, size: Responsive.w(context, 16)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.8), height: 1.4)),
          ),
        ],
      ),
    );
  }
}
