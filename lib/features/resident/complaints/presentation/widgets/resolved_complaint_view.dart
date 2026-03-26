import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../data/complaint_model.dart';
import 'detail_data_row.dart';

class ResolvedComplaintView extends StatelessWidget {
  final Complaint complaint;

  const ResolvedComplaintView({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RESOLVED BANNER
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppTheme.space16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: AppTheme.accentColor, size: 10),
                        const SizedBox(width: 8),
                        Text(
                          "Status: Resolved",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Action completed on ${complaint.completionDate}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.7))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    "FIXED",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space24)),

          // OVAL CARDS
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "COMPLAINT ID",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text("#${complaint.id}", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "CATEGORY",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(complaint.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // DATES
          DetailDataRow(label: "Submitted Date", value: complaint.dateSubmitted),
          const SizedBox(height: AppTheme.space16),
          DetailDataRow(label: "Completion Date", value: complaint.completionDate ?? "Unknown"),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // DESCRIPTION
          Text("Description", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          Container(
            padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(AppTheme.space16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(complaint.fullDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF3F4F6)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Reported in District 4 · Residential collection zone",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppTheme.textColor.withValues(alpha: 0.65)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 15, color: AppTheme.accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Resolved by CleanSL Field Team · Staff #442",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppTheme.textColor.withValues(alpha: 0.65)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // ORIGINAL EVIDENCE
          Text("Original Evidence", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.space16),
            child: Stack(
              children: [
                complaint.isLocal
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
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
                    child: Text(complaint.dateSubmitted.split(',')[0], style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space32)),

          // RESOLUTION PROOF
          Row(
            children: [
              Text("Resolution Proof", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),
              const Icon(Icons.verified_rounded, color: AppTheme.accentColor, size: 18),
            ],
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.space16),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset('assets/img/resolved.jpeg', width: double.infinity, height: 180, fit: BoxFit.cover),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bin Replaced",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("Verified by CleanSL Field Team", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space24)),
          Text(
            "\"The damaged bin was collected and a replacement was delivered. The new bin was checked before handover.\"",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppTheme.textColor.withValues(alpha: 0.7), height: 1.5),
          ),
          SizedBox(height: Responsive.h(context, AppTheme.space48)),
        ],
      ),
    );
  }
}
