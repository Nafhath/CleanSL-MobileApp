import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../data/complaint_model.dart';
import 'detail_data_row.dart';
import 'status_timeline_step.dart';

class InProgressComplaintView extends StatelessWidget {
  final Complaint complaint;

  const InProgressComplaintView({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.schedule_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  "In Progress",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          Text("Complaint #${complaint.id}", style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: Responsive.h(context, AppTheme.space8)),
          Text("${complaint.category} reported in District 4", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.7))),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // TIMELINE
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.space24)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.analytics_outlined, color: AppTheme.accentColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text("Status Timeline", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  ],
                ),
                SizedBox(height: Responsive.h(context, AppTheme.space24)),
                const StatusTimelineStep(title: "Submitted", sub: "Oct 24, 2023 • 09:15 AM", isDone: true, showLine: true, icon: Icons.check),
                const StatusTimelineStep(title: "Field Team Assigned", sub: "Oct 24, 2023 • 11:30 AM", isDone: true, showLine: true, icon: Icons.people),
                const StatusTimelineStep(title: "Resolution", sub: "Expected in 24 hours", isDone: false, showLine: false, icon: Icons.check),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space24)),

          // DETAILS
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.space24)),
            child: Column(
              children: [
                DetailDataRow(label: "Category", value: complaint.category),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                DetailDataRow(label: "Assigned Team", value: complaint.assignedTo ?? "Field Team B", valueColor: AppTheme.accentColor),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                DetailDataRow(label: "Submitted Date", value: complaint.dateSubmitted),
                const Divider(height: AppTheme.space32, color: Color(0xFFF3F4F6)),
                DetailDataRow(label: "Est. Resolution", value: "24 Hours", valueColor: Colors.orange.shade700),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // EVIDENCE & DESC
          Text("Evidence & Description", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.space24)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: complaint.isLocal
                      ? Image.asset(
                          complaint.imagePath,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          complaint.imagePath,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
                  child: Column(children: [Text(complaint.fullDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))]),
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
