import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/ml_service.dart'; // Import Nafhath'S ML Service
import '../widgets/evidence_picker.dart';
import 'complaint_success_page.dart';

class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({super.key});

  @override
  State<FileComplaintPage> createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  final ImagePicker _picker = ImagePicker();
  File? _evidenceImage;
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  // 1. Initialize Nafhath's Real ML Service
  final MLService _mlService = MLService();
  bool _isMLProcessing = false;
  bool _hasScanned = false; // Tracks if AI analysis is complete
  String _mlResultLabel = "";
  double _mlResultConfidence = 0.0;
  String _currentAddress = "Loading address...";

  // Added 'Waste Sorting Issue' to match the ML model's purpose!
  final List<String> _issueCategories = ['Waste Sorting Issue', 'Missed Pickup', 'Overflowing Bin', 'Illegal Dumping', 'Other'];

  @override
  void initState() {
    super.initState();
    // 2. Load the .tflite brain into memory when the page opens
    _mlService.loadModel();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _currentAddress = "Unknown Location");
        return;
      }
      
      final response = await Supabase.instance.client
          .from('addresses')
          .select('street_address, zone_or_ward')
          .eq('resident_id', userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _currentAddress = "${response['street_address']}, ${response['zone_or_ward']}";
        });
      } else if (mounted) {
        setState(() {
          _currentAddress = "Address not configured";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "Error fetching address");
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleImageAction() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

    if (image != null) {
      setState(() {
        _evidenceImage = File(image.path);
        _hasScanned = false; // Reset AI state if new image picked
      });
    }
  }

  // --- Helper: Upload image to Supabase Storage and return public URL ---
  Future<String> _uploadEvidenceImage() async {
    final fileExt = _evidenceImage!.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    await Supabase.instance.client.storage.from('complaints').upload(fileName, _evidenceImage!);
    return Supabase.instance.client.storage.from('complaints').getPublicUrl(fileName);
  }

  // --- Helper: Get current user's address_id ---
  Future<String?> _getAddressId(String userId) async {
    final resp = await Supabase.instance.client
        .from('addresses')
        .select('id')
        .eq('resident_id', userId)
        .maybeSingle();
    return resp?['id'];
  }

  // --- 3. THE SMART SUBMISSION LOGIC ---
  Future<void> _handlePrimaryAction() async {
    // Validation
    if (_evidenceImage == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category and add evidence.")));
      return;
    }

    // BRANCH 1: Needs AI Scanning (If Waste Sorting Issue and hasn't scanned yet)
    if (_selectedCategory == 'Waste Sorting Issue' && !_hasScanned) {
      setState(() => _isMLProcessing = true);
      try {
        final mlResult = await _mlService.predict(_evidenceImage!);
        setState(() {
          _mlResultLabel = mlResult['label'];
          _mlResultConfidence = mlResult['confidence'];
          _hasScanned = true;
          _isMLProcessing = false;
        });
      } catch (e) {
        setState(() => _isMLProcessing = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error analyzing image: $e")));
      }
      return; // Stop here and wait for second button press
    }

    // BRANCH 2: Final Submission (Either Standard or Post-Scan)
    setState(() => _isMLProcessing = true);

    try {
      // Upload image first (needed for all branches)
      final photoUrl = await _uploadEvidenceImage();
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final addressId = await _getAddressId(userId);

      // BRANCH 1: ONLY Run ML if it is a Waste Sorting Issue!
      if (_selectedCategory == 'Waste Sorting Issue') {
        String detectedMaterial = _mlResultLabel; // e.g., "plastic"
        double confidence = _mlResultConfidence; // e.g., 0.88 (88%)

        debugPrint("ML Detected: $detectedMaterial with ${(confidence * 100).toStringAsFixed(1)}% confidence");

        // Apply the 85% Rule
        if (confidence >= 0.85) {
          debugPrint("ROUTING TO RESIDENT LOG: Auto-verified $detectedMaterial issue.");
          // Insert directly into user's resolved log (auto-approved by AI)
          await Supabase.instance.client.from('complaints').insert({
            'resident_id': userId,
            'address_id': addressId,
            'photo_url': photoUrl,
            'location_name': _currentAddress,
            'complaint_text': _descriptionController.text.isNotEmpty ? _descriptionController.text : _selectedCategory,
            'material_label': detectedMaterial,
            'ai_confidence': confidence,
            'ai_sorted_percentage': (confidence * 100).toInt(),
            'priority_level': 'high',
            'status': 'resolved', // Auto-resolved by AI
          });
        } else {
          debugPrint("ROUTING TO CMC ADMIN: Confidence too low. Needs human verification.");
          // Insert into CMC manual review queue (pending admin review)
          await Supabase.instance.client.from('complaints').insert({
            'resident_id': userId,
            'address_id': addressId,
            'photo_url': photoUrl,
            'location_name': _currentAddress,
            'complaint_text': _descriptionController.text.isNotEmpty ? _descriptionController.text : _selectedCategory,
            'material_label': detectedMaterial,
            'ai_confidence': confidence,
            'ai_sorted_percentage': (confidence * 100).toInt(),
            'priority_level': 'medium',
            'status': 'pending', // Needs CMC admin review
          });
        }
      }
      // 🚛 BRANCH 2: Standard Complaints (Missed Pickups, Overflowing Bins)
      else {
        debugPrint("STANDARD REPORT: Bypassing AI for '$_selectedCategory'.");
        // Insert standard complaint straight to the database
        await Supabase.instance.client.from('complaints').insert({
          'resident_id': userId,
          'address_id': addressId,
          'photo_url': photoUrl,
          'location_name': _currentAddress,
          'complaint_text': _descriptionController.text.isNotEmpty ? _descriptionController.text : _selectedCategory,
          'priority_level': 'low',
          'status': 'pending',
        });
      }

      // Success! Stop processing and go to the Success Page
      if (!mounted) return;
      setState(() => _isMLProcessing = false);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ComplaintSuccessPage(referenceId: "CMC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}")));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMLProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error processing request: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text("Report Issue", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24), vertical: Responsive.h(context, AppTheme.space16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's the problem?",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.secondaryColor2),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            Text("Help us keep Colombo clean by reporting missed pickups or illegal dumping.", style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.7), height: 1.5)),
            SizedBox(height: Responsive.h(context, 32)),

            Text(
              "Issue Category",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor1),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            _buildDropdown(),
            SizedBox(height: Responsive.h(context, 24)),

            Text(
              "Description",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor1),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            _buildDescriptionField(),
            SizedBox(height: Responsive.h(context, 24)),

            Text(
              "Evidence",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor1),
            ),
            SizedBox(height: Responsive.h(context, 8)),

            // Using extracted Widget (Now spins when processing ML!)
            EvidencePicker(image: _evidenceImage, onTap: _handleImageAction, isProcessing: _isMLProcessing && _selectedCategory == 'Waste Sorting Issue' && !_hasScanned),

            SizedBox(height: Responsive.h(context, 24)),
            _buildLocationBox(),
            SizedBox(height: Responsive.h(context, 24)),

            // UI INJECTION: The AI Verification Card
            _buildAICard(),
            
            SizedBox(height: Responsive.h(context, 16)),

            // 4. Update the Button to call the ML function!
            _buildSubmitButton(),

            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Responsive.r(context, 8))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Text("Select a category", style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.5))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.secondaryColor1),
          items: _issueCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Briefly describe the waste issue...",
        hintStyle: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildLocationBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor1),
        ),
        SizedBox(height: Responsive.h(context, 8)),
        Container(
          padding: EdgeInsets.all(Responsive.w(context, AppTheme.space16)),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Responsive.r(context, 16))),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 12)),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.location_searching_rounded, color: Colors.blue, size: 24),
              ),
              SizedBox(width: Responsive.w(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CURRENT LOCATION",
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(_currentAddress, style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.8), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAICard() {
    if (!_hasScanned || _selectedCategory != 'Waste Sorting Issue') return const SizedBox.shrink();

    bool isHighConfidence = _mlResultConfidence >= 0.70;

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 16)),
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: isHighConfidence ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        border: Border.all(color: isHighConfidence ? Colors.green.shade200 : Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHighConfidence ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                color: isHighConfidence ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                child: Text(
                  "AI Detected: ${_mlResultLabel.toUpperCase()}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isHighConfidence ? Colors.green.shade800 : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            isHighConfidence
                ? "High confidence match."
                : "Low confidence. This may require manual review.",
            style: TextStyle(
              color: isHighConfidence ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Confidence Score",
                style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
              ),
              Text(
                "${(_mlResultConfidence * 100).toStringAsFixed(0)}%",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _mlResultConfidence,
              backgroundColor: Colors.black12,
              color: isHighConfidence ? Colors.green : Colors.orange,
              minHeight: 8,
            ),
          ),
          SizedBox(height: Responsive.h(context, 16)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Re-scan instantly on the SAME image without opening the camera
                setState(() => _hasScanned = false);
                await _handlePrimaryAction();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Re-Scan Image"),
              style: OutlinedButton.styleFrom(
                foregroundColor: isHighConfidence ? Colors.green.shade800 : Colors.orange.shade800,
                side: BorderSide(color: isHighConfidence ? Colors.green.shade300 : Colors.orange.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.r(context, 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    bool needsScan = _selectedCategory == 'Waste Sorting Issue' && !_hasScanned;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isMLProcessing ? null : _handlePrimaryAction,
        icon: _isMLProcessing && !needsScan
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : Icon(needsScan ? Icons.document_scanner_rounded : Icons.send_rounded, size: 18),
        label: Text(
          _isMLProcessing && !needsScan 
              ? "Submitting..." 
              : (needsScan ? "Analyse Image" : "Submit Report"),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 24))),
          elevation: 2,
        ),
      ),
    );
  }
}