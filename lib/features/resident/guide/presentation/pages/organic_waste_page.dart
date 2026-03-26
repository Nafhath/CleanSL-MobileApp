import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../widgets/guide_back_button.dart';
import '../widgets/guide_hero_card.dart';
import '../widgets/waste_item_tile.dart';

class OrganicWastePage extends StatelessWidget {
  const OrganicWastePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color pageAccent = AppTheme.accentColor;
    final Color pageAccentLight = AppTheme.accentColor.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text(
          "Organic Waste",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        leadingWidth: Responsive.w(context, 100),
        leading: Padding(
          padding: EdgeInsets.only(left: Responsive.w(context, AppTheme.space16)),
          child: Center(child: GuideBackButton(iconColor: pageAccent)),
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
              imagePath: 'assets/img/organic_waste.jpg',
              badgeText: 'GUIDE',
              title: 'Composting 101',
              subtitle: 'Turn your kitchen scraps into black gold.',
              accentColor: pageAccent,
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            Text(
              "Compostable Items",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textColor),
            ),
            SizedBox(height: Responsive.h(context, 4)),
            Text("What can go in your organic bin?", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.8))),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),

            Row(
              children: [
                Expanded(child: _buildGridItem(context, "Fruit Peels", Icons.local_florist_rounded, pageAccent, pageAccentLight)),
                SizedBox(width: Responsive.w(context, AppTheme.space16)),
                Expanded(child: _buildGridItem(context, "Vegetable Scraps", Icons.eco_rounded, pageAccent, pageAccentLight)),
              ],
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),
            Row(
              children: [
                Expanded(child: _buildGridItem(context, "Coffee Grounds", Icons.coffee_rounded, pageAccent, pageAccentLight)),
                SizedBox(width: Responsive.w(context, AppTheme.space16)),
                Expanded(child: _buildGridItem(context, "Eggshells", Icons.egg_rounded, pageAccent, pageAccentLight)),
              ],
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),
            _buildFullWidthItem(context, "Yard Waste", Icons.grass_rounded, pageAccent, pageAccentLight),

            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            Text(
              "Benefits of Composting",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textColor),
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),

            WasteItemTile(
              title: "Reduces Landfill Waste",
              description: "Organic waste in landfills produces methane, a potent greenhouse gas. Composting prevents this.",
              icon: Icons.energy_savings_leaf_rounded,
              iconColor: pageAccent,
            ),
            WasteItemTile(
              title: "Enriches Soil",
              description: "Adds vital nutrients back into your garden, improving soil structure and water retention.",
              icon: Icons.spa_rounded,
              iconColor: pageAccent,
            ),
            WasteItemTile(
              title: "Saves Money",
              description: "Reduces the need for chemical fertilizers and can lower waste collection fees.",
              icon: Icons.savings_rounded,
              iconColor: pageAccent,
            ),
          ],
        ),
      ),
    );
  }

  // Unique elements to the Organic Page only
  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24), horizontal: Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: Responsive.w(context, 24)),
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthItem(BuildContext context, String title, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: Responsive.w(context, 24)),
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
          ),
        ],
      ),
    );
  }
}