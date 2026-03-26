import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../home/data/live_pickup_tracking_model.dart';
import '../../../home/data/resident_live_tracking_service.dart';

class OngoingPickupsPage extends StatefulWidget {
  // --- TEMPLATE PARAMETERS (Passed from Card) ---
  final String wasteType;
  final String zone;
  final String team;
  final String etaTime;
  final String etaDistance;
  final Color themeColor;
  final IconData wasteIcon;
  final List<String> checklistItems;

  const OngoingPickupsPage({
    super.key,
    required this.wasteType,
    required this.zone,
    required this.team,
    required this.etaTime,
    required this.etaDistance,
    required this.themeColor,
    required this.wasteIcon,
    required this.checklistItems,
  });

  @override
  State<OngoingPickupsPage> createState() => _OngoingPickupsPageState();
}

class _OngoingPickupsPageState extends State<OngoingPickupsPage> {
  // 1. TOGGLE: Keep dummy map visible while real-time runs in background
  final bool _showDemoDummyMapOnly = true;

  // 2. DUMMY DATA (Matching home page)
  static const LatLng _demoTruckLocation = LatLng(6.852111, 79.865833);
  static const LatLng _demoUserLocation = LatLng(6.867472, 79.861528);
  static const List<LatLng> _demoRoutePoints = <LatLng>[
    LatLng(6.852111, 79.865833),
    LatLng(6.855420, 79.864510),
    LatLng(6.859810, 79.863120),
    LatLng(6.863500, 79.862200),
    LatLng(6.867472, 79.861528),
  ];

  // 3. REAL-TIME STATE
  final ResidentLiveTrackingService _liveTrackingService = ResidentLiveTrackingService();
  GoogleMapController? _mapController;
  StreamSubscription<List<Map<String, dynamic>>>? _pickupRowsSubscription;
  Timer? _driverLocationPollingTimer;

  LivePickupTracking? _livePickup;
  bool _isMapReady = false;
  bool _isRefreshing = false;
  bool _isLiveDataLoading = true;
  bool _isRealtimeConnected = false;
  String? _activeDriverId;

  Set<Polyline> _mapPolylines = const <Polyline>{};
  Set<Marker> _mapMarkers = const <Marker>{};

  // Custom Icons State
  BitmapDescriptor? _truckMarkerIcon;
  BitmapDescriptor? _residentMarkerIcon;

  final Map<String, bool> _checklistState = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.checklistItems.length; i++) {
      _checklistState[widget.checklistItems[i]] = i < 2;
    }

    _prepareMarkerIcons();
    _initializeLiveTracking();
  }

  @override
  void dispose() {
    _pickupRowsSubscription?.cancel();
    _driverLocationPollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // --- REAL-TIME SUPABASE LOGIC ---
  Future<void> _initializeLiveTracking() async {
    final List<Map<String, dynamic>> initialRows = await _liveTrackingService.fetchPickupRowsForCurrentResident();
    if (!mounted) return;

    _applyPickupRows(initialRows, fromRealtime: false);

    try {
      _pickupRowsSubscription?.cancel();
      _pickupRowsSubscription = _liveTrackingService.watchPickupRowsForCurrentResident().listen(
        (rows) {
          if (mounted) _applyPickupRows(rows, fromRealtime: true);
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _isRealtimeConnected = false;
              _isLiveDataLoading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLiveDataLoading = false);
    }
  }

  void _applyPickupRows(List<Map<String, dynamic>> rows, {required bool fromRealtime}) {
    final LivePickupTracking? selectedPickup = _liveTrackingService.selectCurrentPickup(rows);

    if (selectedPickup == null || selectedPickup.status != LivePickupStatus.ongoing || selectedPickup.driverId == null) {
      _driverLocationPollingTimer?.cancel();
      _driverLocationPollingTimer = null;
      _activeDriverId = null;
    } else if (_activeDriverId != selectedPickup.driverId) {
      _startDriverLocationPolling(selectedPickup.driverId!);
    }

    final Set<Polyline> polylines = _buildPolylinesForPickup(selectedPickup);
    final Set<Marker> markers = _buildMarkersForPickup(selectedPickup);

    setState(() {
      _livePickup = selectedPickup;
      _isLiveDataLoading = false;
      _isRealtimeConnected = fromRealtime || _isRealtimeConnected;
      _mapPolylines = polylines;
      _mapMarkers = markers;
    });

    if (!_showDemoDummyMapOnly) _fitMapToCurrentRoute();
  }

  void _startDriverLocationPolling(String driverId) {
    _activeDriverId = driverId;
    _driverLocationPollingTimer?.cancel();
    _driverLocationPollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _refreshDriverLocation(driverId);
    });
    _refreshDriverLocation(driverId);
  }

  Future<void> _refreshDriverLocation(String driverId) async {
    if (_livePickup == null || _livePickup!.driverId != driverId) return;

    final Map<String, dynamic>? row = await _liveTrackingService.fetchLatestDriverLocation(driverId);
    if (!mounted || row == null) return;

    final LivePickupTracking mergedPickup = _liveTrackingService.mergeDriverLocation(_livePickup!, row);

    setState(() {
      _livePickup = mergedPickup;
      _mapMarkers = _buildMarkersForPickup(mergedPickup);
    });
  }

  // --- MAP RENDERERS ---
  Set<Polyline> _buildPolylinesForPickup(LivePickupTracking? pickup) {
    if (pickup == null || !pickup.hasRoute) return const <Polyline>{};
    return <Polyline>{Polyline(polylineId: const PolylineId('live-route'), points: pickup.routePoints, color: widget.themeColor, width: 6, startCap: Cap.roundCap, endCap: Cap.roundCap)};
  }

  Set<Marker> _buildMarkersForPickup(LivePickupTracking? pickup) {
    if (pickup == null || pickup.truckLocation == null) return const <Marker>{};
    return <Marker>{
      Marker(markerId: const MarkerId('live-truck'), position: pickup.truckLocation!, icon: _truckMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
      Marker(
        markerId: const MarkerId('live-resident'),
        position: _demoUserLocation, // Assuming resident stays fixed
        icon: _residentMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  Set<Polyline> _buildDemoPolylines() {
    return <Polyline>{Polyline(polylineId: const PolylineId('demo-route'), points: _demoRoutePoints, color: widget.themeColor, width: 6, startCap: Cap.roundCap, endCap: Cap.roundCap)};
  }

  Set<Marker> _buildDemoMarkers() {
    return <Marker>{
      Marker(markerId: const MarkerId('demo-truck'), position: _demoTruckLocation, icon: _truckMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
      Marker(markerId: const MarkerId('demo-resident'), position: _demoUserLocation, icon: _residentMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
    };
  }

  // --- CUSTOM MARKER BUILDER LOGIC ---
  Future<void> _prepareMarkerIcons() async {
    try {
      final BitmapDescriptor truck = await _buildMapMarkerIcon(icon: Icons.local_shipping_rounded, backgroundColor: widget.themeColor, fallbackHue: BitmapDescriptor.hueGreen);
      final BitmapDescriptor resident = await _buildMapMarkerIcon(icon: Icons.home_rounded, backgroundColor: AppTheme.secondaryColor1, fallbackHue: BitmapDescriptor.hueAzure);

      if (!mounted) return;
      setState(() {
        _truckMarkerIcon = truck;
        _residentMarkerIcon = resident;
      });
      _centerMap();
    } catch (_) {}
  }

  Future<BitmapDescriptor> _buildMapMarkerIcon({required IconData icon, required Color backgroundColor, required double fallbackHue}) async {
    const double markerSize = 48;
    const double iconSize = 22;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = backgroundColor;

    canvas.drawCircle(const Offset(markerSize / 2, markerSize / 2), markerSize / 2, paint);

    final TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: iconSize, fontFamily: icon.fontFamily, package: icon.fontPackage, color: Colors.white),
      );

    textPainter.layout();
    textPainter.paint(canvas, Offset((markerSize - textPainter.width) / 2, (markerSize - textPainter.height) / 2));

    final ui.Image image = await recorder.endRecording().toImage(markerSize.toInt(), markerSize.toInt());
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);

    if (data == null) return BitmapDescriptor.defaultMarkerWithHue(fallbackHue);
    return BitmapDescriptor.bytes(data.buffer.asUint8List());
  }

  // --- CAMERA CONTROLS ---
  Future<void> _handleRefresh() async {
    if (_isRefreshing || !_isMapReady) return;
    setState(() => _isRefreshing = true);

    try {
      _centerMap();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Live map updated"), duration: Duration(milliseconds: 900)));
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _centerMap() async {
    if (_showDemoDummyMapOnly) {
      _fitBounds(_demoRoutePoints);
    } else {
      _fitMapToCurrentRoute();
    }
  }

  void _fitMapToCurrentRoute() {
    if (_livePickup == null || _livePickup!.routePoints.isEmpty) return;

    final List<LatLng> points = List<LatLng>.from(_livePickup!.routePoints);
    if (_livePickup!.truckLocation != null) points.add(_livePickup!.truckLocation!);

    _fitBounds(points);
  }

  void _fitBounds(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    try {
      await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 60));
    } catch (_) {}
  }

  // --- DYNAMIC TEXT DISPLAYS ---
  String _displayEtaTime() {
    if (_showDemoDummyMapOnly) return widget.etaTime;
    return _livePickup?.etaMinutes != null ? '${_livePickup!.etaMinutes}m' : '--';
  }

  String _displayEtaDistance() {
    if (_showDemoDummyMapOnly) return "Truck is ${widget.etaDistance} away";
    return 'Truck is En route';
  }

  String _displayZoneText() {
    if (_showDemoDummyMapOnly) return widget.zone;
    return _livePickup?.areaName ?? 'Connecting...';
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
        title: Padding(
          padding: EdgeInsets.only(top: Responsive.h(context, AppTheme.space8)),
          child: Text("Live Tracking", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        leading: Padding(
          padding: EdgeInsets.only(top: Responsive.h(context, AppTheme.space8)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: Responsive.h(context, 40)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THE MAP SECTION
            SizedBox(
              height: Responsive.h(context, 380),
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(target: _demoTruckLocation, zoom: 14.0),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (!mounted) return;
                      setState(() => _isMapReady = true);
                      _centerMap();
                    },
                    polylines: _showDemoDummyMapOnly ? _buildDemoPolylines() : _mapPolylines,
                    markers: _showDemoDummyMapOnly ? _buildDemoMarkers() : _mapMarkers,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),

                  // Live Status Badge
                  if (!_showDemoDummyMapOnly && !_isLiveDataLoading)
                    Positioned(
                      top: Responsive.h(context, 14),
                      left: Responsive.w(context, 14),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 10), vertical: Responsive.h(context, 4)),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          _isRealtimeConnected ? 'LIVE' : 'OFFLINE',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),

                  // Bottom Overlay Card (Estimated Arrival)
                  Positioned(
                    bottom: Responsive.h(context, 18),
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20), vertical: Responsive.h(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "ESTIMATED ARRIVAL",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                                ),
                                const SizedBox(height: 4),
                                Text(_displayZoneText(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                // FIX: _displayEtaDistance is now correctly used here!
                                Text(_displayEtaDistance(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          SizedBox(width: Responsive.w(context, 12)),
                          SizedBox(
                            width: Responsive.w(context, 122),
                            child: ElevatedButton(
                              onPressed: (_isRefreshing || !_isMapReady) ? null : _handleRefresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.themeColor,
                                disabledBackgroundColor: widget.themeColor.withValues(alpha: 0.7),
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isRefreshing) ...[const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), const SizedBox(width: 8)],
                                  const Text(
                                    "Refresh",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.h(context, 24)),

            // 2. COLLECTION DETAILS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Collection Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                        _buildDetailRow(widget.wasteIcon, "WASTE TYPE", widget.wasteType, widget.themeColor.withValues(alpha: 0.15), widget.themeColor),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                        ),
                        _buildDetailRow(Icons.timer_outlined, "ETA TIME", _displayEtaTime(), AppTheme.secondaryColor1.withValues(alpha: 0.12), AppTheme.secondaryColor1),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                        ),
                        _buildDetailRow(Icons.people_outline_rounded, "ASSIGNED TEAM", widget.team, AppTheme.secondaryColor2.withValues(alpha: 0.08), AppTheme.secondaryColor2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.h(context, 32)),

            // 3. PREPARATION CHECKLIST
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Preparation Checklist", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: Responsive.h(context, 16)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: widget.checklistItems.map((item) {
                        return _buildChecklistItem(item, _checklistState[item] ?? false, (val) => setState(() => _checklistState[item] = val!));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDetailRow(IconData icon, String label, String value, Color iconBg, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: Responsive.w(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor1.withValues(alpha: 0.55), letterSpacing: 1.1),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: onChanged,
      title: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppTheme.textColor),
      ),
      activeColor: widget.themeColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: Colors.grey.shade300, width: 2),
      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}
