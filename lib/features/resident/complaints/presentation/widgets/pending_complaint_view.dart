import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/complaint_model.dart';
import 'detail_data_row.dart';

class PendingComplaintView extends StatelessWidget {
  final Complaint complaint;

  const PendingComplaintView({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS CARD
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.space16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CURRENT STATUS", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
                SizedBox(height: Responsive.h(context, AppTheme.space16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.orange, size: 10),
                        SizedBox(width: Responsive.w(context, AppTheme.space8)),
                        Text(complaint.statusTitle, style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                      child: Text("Pending", style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, AppTheme.space16)),
                Text(complaint.statusDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.7), height: 1.5)),
                SizedBox(height: Responsive.h(context, AppTheme.space24)),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Cancel Complaint"),
                        content: const Text("Are you sure you want to cancel this complaint? This action cannot be undone."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No, Keep It")),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx); // Close the dialog
                              try {
                                await Supabase.instance.client
                                    .from('complaints')
                                    .delete()
                                    .eq('id', complaint.dbId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint cancelled successfully.')));
                                  // Pop the Complaint Details page entirely
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
                                }
                              }
                            },
                            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(AppTheme.space16)),
                    child: Center(
                      child: Text("Cancel this Complaint", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // INFO CARD
          Text("COMPLAINT INFORMATION", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.space16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailDataRow(label: "Complaint ID", value: "#${complaint.id}"),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                DetailDataRow(label: "Category", value: complaint.category),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                DetailDataRow(label: "Date Submitted", value: complaint.dateSubmitted),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                Text("Description", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6))),
                SizedBox(height: Responsive.h(context, AppTheme.space8)),
                Text(complaint.fullDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // EVIDENCE
          Text("EVIDENCE PHOTO", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.space16),
            child: Stack(
              children: [
                complaint.isLocal
                    ? Image.asset(
                        complaint.imagePath,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        complaint.imagePath,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                          ),
                        ),
                      ),
                Positioned(
                  bottom: AppTheme.space16, right: AppTheme.space16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: const Icon(Icons.fullscreen_rounded, color: AppTheme.secondaryColor2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space48)),
        ],
      ),
    );
  }
}