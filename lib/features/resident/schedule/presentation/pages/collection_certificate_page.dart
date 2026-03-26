import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class CollectionCertificatePage extends StatelessWidget {
  // --- TEMPLATE PARAMETERS ---
  final String wasteType;
  final String date;
  final String certificateId;
  final String impactMessage;
  final Color themeColor;
  final IconData impactIcon;
  final String residentName;

  const CollectionCertificatePage({
    super.key,
    required this.wasteType,
    required this.date,
    required this.certificateId,
    required this.impactMessage,
    required this.themeColor,
    required this.impactIcon,
    this.residentName = "Aravinda Perera", // Default mock data
  });

  // Helper to generate the dynamic certificate quote
  String get _certificateQuote {
    final String normalized = wasteType.toLowerCase();
    if (normalized.contains('organic')) {
      return '"This certifies that organic waste was successfully collected and processed for composting."';
    } else if (normalized.contains('recycl')) {
      return '"This certifies that recyclable materials were successfully collected and sent for sustainable processing."';
    }
    return '"This certifies that general waste was successfully collected and safely disposed of according to city guidelines."';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text("Collection Certificate", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            // --- THE CERTIFICATE CARD ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // Top Half (Light Colored Background)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 32)),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32),
                        ),
                        SizedBox(height: Responsive.h(context, 16)),
                        Text("Colombo Municipal Council", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          "OFFICIAL DIGITAL SEAL",
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Half (White Background)
                  Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 24)),
                    child: Column(
                      children: [
                        // Italic Quote
                        Text(
                          _certificateQuote,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.8), fontSize: 15, fontStyle: FontStyle.italic, height: 1.5),
                        ),
                        SizedBox(height: Responsive.h(context, 32)),

                        // Data Grid
                        Row(
                          children: [
                            Expanded(child: _buildDataCell(context, "RESIDENT NAME", residentName)),
                            Expanded(child: _buildDataCell(context, "DATE", date.split('•')[0].trim())), // Strips time off
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 24)),
                        Row(
                          children: [
                            Expanded(child: _buildDataCell(context, "CERTIFICATE ID", certificateId)),
                            Expanded(child: _buildDataCell(context, "WASTE TYPE", wasteType)),
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 32)),

                        // Environmental Impact Box inside Card
                        Container(
                          padding: EdgeInsets.all(Responsive.w(context, 16)),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                                child: Icon(impactIcon, color: Colors.white, size: 16),
                              ),
                              SizedBox(width: Responsive.w(context, 12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ENVIRONMENTAL IMPACT",
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.1),
                                    ),
                                    SizedBox(height: Responsive.h(context, 4)),
                                    Text(impactMessage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.h(context, 32)),

            // --- BUTTONS ---
            // Solid Primary Button mapped to the template color
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Download PDF",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 16)),

            // Outline Button mapped to the template color
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.share_rounded, color: themeColor, size: 20),
                label: Text(
                  "Share Certificate",
                  style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: themeColor.withValues(alpha: 0.5), width: 2),
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),
          ],
        ),
      ),
    );
  }

  // Helper for the data grid inside the certificate
  Widget _buildDataCell(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        SizedBox(height: Responsive.h(context, 4)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
