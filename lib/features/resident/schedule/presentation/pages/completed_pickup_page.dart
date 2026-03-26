import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import 'collection_certificate_page.dart';

class CompletedPickupDetailsPage extends StatelessWidget {
  // --- TEMPLATE PARAMETERS ---
  final String title;
  final String subtitle;
  final String imagePath;
  final String certificateId;
  final String date;
  final String location;
  final String wasteType;
  final String collectedBy;
  final String impactMessage;
  final Color themeColor;
  final IconData impactIcon;

  const CompletedPickupDetailsPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.certificateId,
    required this.date,
    required this.location,
    required this.wasteType,
    required this.collectedBy,
    required this.impactMessage,
    required this.themeColor,
    required this.impactIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text("Pickup Completed", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24), vertical: Responsive.h(context, AppTheme.space16)),
        child: Column(
          children: [
            // 1. SUCCESS HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            SizedBox(height: Responsive.h(context, 20)),
            Text(title, style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: Responsive.h(context, 8)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 2. IMAGE & CERTIFICATE CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    // Using errorBuilder to handle missing mockup images gracefully during development
                    child: Image.asset(
                      imagePath,
                      height: Responsive.h(context, 180),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: Responsive.h(context, 180),
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text("Waste Image", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 20)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "CERTIFICATE ISSUED",
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1),
                            ),
                            Text(
                              certificateId,
                              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 16)),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            // --- UPDATE THE ONPRESSED FUNCTION HERE ---
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CollectionCertificatePage(
                                    wasteType: wasteType,
                                    date: date,
                                    certificateId: certificateId,
                                    impactMessage: impactMessage,
                                    themeColor: themeColor,
                                    impactIcon: impactIcon,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.workspace_premium_rounded, color: themeColor, size: 20),
                            label: Text(
                              "View Certificate",
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: themeColor.withValues(alpha: 0.1),
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 3. COLLECTION DETAILS
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Collection Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 20)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, Icons.calendar_today_rounded, "Date & Time", date),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(context, Icons.location_on_rounded, "Pickup Location", location),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(context, Icons.recycling_rounded, "Waste Type", wasteType),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(context, Icons.person_rounded, "Collected By", collectedBy),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 24)),

            // 4. ENVIRONMENTAL IMPACT
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 20)),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: themeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(impactIcon, color: themeColor, size: 20),
                  ),
                  SizedBox(width: Responsive.w(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Environmental Impact",
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: Responsive.h(context, 6)),
                        Text(impactMessage, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 40)),
          ],
        ),
      ),
    );
  }

  // Helper for Details rows
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.secondaryColor1, size: 18),
        ),
        SizedBox(width: Responsive.w(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
