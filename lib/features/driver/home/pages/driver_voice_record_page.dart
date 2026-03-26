import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cleansl_button.dart';
import '../../../../../core/constants/api_constants.dart';
import 'report_history_screen.dart';

class VoiceRecordPage extends StatefulWidget {
  final String taskId;
  final String laneName;
  final int houseNumber;

  const VoiceRecordPage({super.key, required this.taskId, required this.laneName, required this.houseNumber});

  @override
  State<VoiceRecordPage> createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  bool _isRecording = false;
  bool _isReadyToSend = false;
  bool _isUploading = false; // Tracks API call state
  int _seconds = 0;
  Timer? _timer;

  late AudioRecorder _audioRecorder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 🛑 Stop recording
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      _showConfirmationDialog();
    } else {
      // 🎙 Start recording
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: _audioPath!,
        );

        setState(() {
          _isRecording = true;
          _seconds = 0;
          _isReadyToSend = false;
        });
        
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _seconds++);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone permission denied. Cannot record.'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _discardRecording() async {
    if (_audioPath != null) {
      final file = File(_audioPath!);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _audioPath = null;
        _seconds = 0;
        _isReadyToSend = false;
      });
    }
  }

  Future<void> _uploadReport() async {
    if (_audioPath == null) return;

    setState(() {
      _isUploading = true;
    });

    final String uploadFilePath = _audioPath!;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.driverReportsUrl),
      );
      request.fields['task_id'] = widget.taskId;
      request.fields['lane_name'] = widget.laneName;
      request.fields['house_number'] = widget.houseNumber.toString();
      final driverId = Supabase.instance.client.auth.currentUser?.id;
      if (driverId != null && driverId.isNotEmpty) {
        request.fields['driver_id'] = driverId;
      }
      request.files.add(
        await http.MultipartFile.fromPath('audio', uploadFilePath),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        // Cleanup local file on success
        final file = File(uploadFilePath);
        if (await file.exists()) await file.delete();
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: const Text('Report submitted successfully!'), 
               backgroundColor: AppTheme.hoverColor,
               behavior: SnackBarBehavior.floating,
             ),
           );
           Navigator.pop(context, true); // Return to previous screen
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Upload failed: $e'), 
               backgroundColor: Colors.red.shade600,
               behavior: SnackBarBehavior.floating,
             ),
         );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _audioPath = null;
          _seconds = 0;
          _isReadyToSend = false;
        });
      }
    }
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.primaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(context, 20))),
          title: Text("Review Recording", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.secondaryColor1)),
          content: Text("You recorded $_formattedTime of audio. Do you want to submit this issue report?", style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _discardRecording();
              },
              child: const Text(
                "Discard",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isReadyToSend = true;
                });
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.secondaryColor1),
          onPressed: () {
             if (_audioPath != null && !_isReadyToSend) {
               _discardRecording(); // Clean up if they back out
             }
             Navigator.pop(context, false);
          }
        ),
        title: Text(
          "${widget.laneName} — House ${widget.houseNumber}",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.secondaryColor1, fontSize: Responsive.sp(context, 22)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.secondaryColor1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 1. The Massive Mic Button
              GestureDetector(
                onTap: _isUploading ? null : _toggleRecording, // Disable tapping while uploading
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: Responsive.w(context, 200),
                  height: Responsive.w(context, 200),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red.shade500 : AppTheme.secondaryColor1,
                    shape: BoxShape.circle,
                    boxShadow: [if (_isRecording) BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 10)],
                  ),
                  child: _isUploading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: Responsive.w(context, 80)),
                ),
              ),

              SizedBox(height: Responsive.h(context, 48)),

              // 2. Helper Text & Timer
              Text(
                _isUploading ? "Uploading report to server..." : 
                (_isRecording ? "Recording... tap to stop" : "Tap and speak to record the issue"),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.7)),
              ),
              SizedBox(height: Responsive.h(context, 16)),
              
              if (!_isUploading)
                Text(
                  _formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.textColor, fontSize: Responsive.sp(context, 48)),
                ),

              const Spacer(),

              // 3. Footer Data (Task & Ward)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CURRENT TASK",
                        style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text("Waste Collection", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.secondaryColor1)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WARD",
                        style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text("District 5", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textColor)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: Responsive.h(context, 32)),

              // 4. Send Report Button
              CleanSlButton(
                text: _isUploading ? "Sending..." : "Send Report",
                variant: ButtonVariant.primary,
                onPressed: (_isReadyToSend && !_isUploading) ? () {
                  _uploadReport(); // Connects the button to the API logic
                } : null, 
              ),
              SizedBox(height: Responsive.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}
