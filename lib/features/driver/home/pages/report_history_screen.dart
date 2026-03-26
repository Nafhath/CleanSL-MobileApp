import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/constants/api_constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _currentlyPlayingUrl = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final driverId = Supabase.instance.client.auth.currentUser?.id;
      final uri = Uri.parse(ApiConstants.driverReportsUrl).replace(
        queryParameters: {
          if (driverId != null && driverId.isNotEmpty) 'driver_id': driverId,
          'limit': '100',
        },
      );
      final response = await http.get(
        uri,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reports = data is List ? data : (data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to fetch reports. The server might be waking up or offline.\n\nDetails: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlay(String url) async {
    if (_currentlyPlayingUrl == url) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      _currentlyPlayingUrl = url;
      await _audioPlayer.play(UrlSource(url));
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Unknown date";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
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
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.secondaryColor1, size: Responsive.w(context, 24)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Report History",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryColor1,
                fontSize: Responsive.sp(context, 22),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppTheme.secondaryColor1, size: Responsive.w(context, 24)),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(context, 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.red.shade400, size: Responsive.w(context, 64)),
              SizedBox(height: Responsive.h(context, 16)),
              Text(
                "Connection Issue",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textColor),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.h(context, 24)),
              ElevatedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text("Try Again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24), vertical: Responsive.h(context, 12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Text(
          "No reports found.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.5)),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accentColor,
      backgroundColor: Colors.white,
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 24),
          vertical: Responsive.h(context, 16),
        ),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          final text = report['transcription'] ?? "No transcription available";
          final storagePath = report['storage_path'];
          
          String? audioUrl = report['audio_url'];
          if ((audioUrl == null || audioUrl.isEmpty) && storagePath != null) {
            audioUrl = "https://suzgjlzertafuyeprshp.supabase.co/storage/v1/object/public/driver-audio/$storagePath";
          }
          
          final createdAt = report['created_at'];
          final isThisPlaying = _currentlyPlayingUrl == audioUrl && _isPlaying;

          return Container(
            margin: EdgeInsets.only(bottom: Responsive.h(context, 16)),
            padding: EdgeInsets.all(Responsive.w(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
              border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryColor1.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    if (audioUrl != null)
                      InkWell(
                        onTap: () => _togglePlay(audioUrl!),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: EdgeInsets.all(Responsive.w(context, 8)),
                          decoration: BoxDecoration(
                            color: isThisPlaying ? AppTheme.accentColor : AppTheme.primaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: isThisPlaying ? Colors.white : AppTheme.accentColor,
                            size: Responsive.w(context, 20),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 12)),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textColor.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
