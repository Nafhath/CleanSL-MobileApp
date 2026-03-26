import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class EvidencePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final bool isProcessing;

  const EvidencePicker({
    super.key,
    required this.image,
    required this.onTap,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        height: Responsive.h(context, 180),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            style: BorderStyle.solid, // Note: For true dotted borders, use 'dotted_border' package
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Picked Image Preview
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
                child: Image.file(
                  image!, 
                  width: double.infinity, 
                  height: double.infinity, 
                  fit: BoxFit.cover
                ),
              ),

            // 2. The "Empty" State (Add Photo)
            if (image == null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1), 
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.accentColor, size: 32),
                  ),
                  SizedBox(height: Responsive.h(context, 12)),
                  Text(
                    "Tap to add photo",
                    style: TextStyle(
                      color: AppTheme.secondaryColor1.withValues(alpha: 0.7), 
                      fontWeight: FontWeight.w600, 
                      fontSize: 13
                    ),
                  ),
                ],
              ),

            // 3. The ML Processing Overlay
            if (isProcessing)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4), 
                  borderRadius: BorderRadius.circular(Responsive.r(context, 16))
                ),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}