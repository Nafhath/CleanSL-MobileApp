import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../data/live_pickup_tracking_model.dart';
import '../../data/resident_live_tracking_service.dart';
import '../../../complaints/data/complaint_model.dart';
import '../../../complaints/presentation/pages/complaint_details_page.dart';
import '../../../complaints/presentation/pages/file_complaint_page.dart';
import '../../../guide/presentation/pages/guide_main_page.dart';
import 'notifications_page.dart';
import 'recent_activity_page.dart';
import '../../../schedule/presentation/pages/ongoing_pickups.dart';

class ResidentHomePage extends StatefulWidget {
  const ResidentHomePage({super.key});

  @override
  State<ResidentHomePage> createState() => _ResidentHomePageState();
}

class _ResidentHomePageState extends State<ResidentHomePage> {
  // Username loaded from Supabase
  String _userName = 'Resident';
  final bool _showDemoDummyMapOnly = true;
  static const String _demoTruckArea = 'Galle Road, Dehiwala';
  static const String _demoResidentArea = '42nd Lane, Wellawatte';
  static const LatLng _demoTruckLocation = LatLng(6.852111, 79.865833);
  static const LatLng _demoUserLocation = LatLng(6.867472, 79.861528);
  static const List<LatLng> _demoRoutePoints = <LatLng>[
    LatLng(6.852111, 79.865833),
    LatLng(6.855420, 79.864510),
    LatLng(6.859810, 79.863120),
    LatLng(6.863500, 79.862200),
    LatLng(6.867472, 79.861528),
  ];
  final DateFormat _timeFormatter = DateFormat('h:mm a');
  final ResidentLiveTrackingService _liveTrackingService = ResidentLiveTrackingService();

  BitmapDescriptor? _demoTruckMarkerIcon;
  BitmapDescriptor? _demoHomeMarkerIcon;

  GoogleMapController? _mapController;
  StreamSubscription<List<Map<String, dynamic>>>? _pickupRowsSubscription;
  Timer? _driverLocationPollingTimer;

  LivePickupTracking? _livePickup;
  bool _isLiveDataLoading = true;
  bool _isRealtimeConnected = false;
  String? _liveDataError;

  Set<Polyline> _mapPolylines = const <Polyline>{};
  Set<Marker> _mapMarkers = const <Marker>{};
  String? _lastFocusedPickupId;
  String? _activeDriverId;

  // Dynamic greeting based on current time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initializeLiveTracking();
    _prepareDemoMarkerIcons();
  }

  @override
  void dispose() {
    _pickupRowsSubscription?.cancel();
    _driverLocationPollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('id', userId)
          .single();
      final fullName = data['full_name'] as String? ?? 'Resident';
      if (mounted) {
        setState(() => _userName = fullName.split(' ').first);
      }
    } catch (_) {
      // Falls back to 'Resident' silently
    }
  }

  Future<void> _initializeLiveTracking() async {
    final List<Map<String, dynamic>> initialRows = await _liveTrackingService.fetchPickupRowsForCurrentResident();

    if (!mounted) {
      return;
    }

    _applyPickupRows(initialRows, fromRealtime: false);

    try {
      _pickupRowsSubscription?.cancel();
      _pickupRowsSubscription = _liveTrackingService.watchPickupRowsForCurrentResident().listen(
        (rows) {
          if (!mounted) {
            return;
          }
          _applyPickupRows(rows, fromRealtime: true);
        },
        onError: (_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isRealtimeConnected = false;
            _liveDataError = 'Live updates unavailable';
            _isLiveDataLoading = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRealtimeConnected = false;
        _liveDataError = 'Live updates unavailable';
        _isLiveDataLoading = false;
      });
    }
  }

  void _applyPickupRows(List<Map<String, dynamic>> rows, {required bool fromRealtime}) {
    final LivePickupTracking? selectedPickup = _liveTrackingService.selectCurrentPickup(rows);

    if (selectedPickup == null || selectedPickup.status != LivePickupStatus.ongoing || selectedPickup.driverId == null || selectedPickup.driverId!.isEmpty) {
      _driverLocationPollingTimer?.cancel();
      _driverLocationPollingTimer = null;
      _activeDriverId = null;
    } else {
      if (_activeDriverId != selectedPickup.driverId) {
        _startDriverLocationPolling(selectedPickup.driverId!);
      }
    }

    final Set<Polyline> polylines = _buildPolylinesForPickup(selectedPickup);
    final Set<Marker> markers = _buildMarkersForPickup(selectedPickup);

    setState(() {
      _livePickup = selectedPickup;
      _isLiveDataLoading = false;
      _isRealtimeConnected = fromRealtime || _isRealtimeConnected;
      _liveDataError = null;
      _mapPolylines = polylines;
      _mapMarkers = markers;
    });

    _fitMapToCurrentRoute(force: fromRealtime);
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
    final LivePickupTracking? pickup = _livePickup;
    if (pickup == null || pickup.status != LivePickupStatus.ongoing || pickup.driverId != driverId) {
      return;
    }

    final Map<String, dynamic>? row = await _liveTrackingService.fetchLatestDriverLocation(driverId);
    if (!mounted || row == null) {
      return;
    }

    final LivePickupTracking mergedPickup = _liveTrackingService.mergeDriverLocation(pickup, row);

    setState(() {
      _livePickup = mergedPickup;
      _mapMarkers = _buildMarkersForPickup(mergedPickup);
    });
  }

  Set<Polyline> _buildPolylinesForPickup(LivePickupTracking? pickup) {
    if (pickup == null || !pickup.hasRoute) {
      return const <Polyline>{};
    }

    return <Polyline>{Polyline(polylineId: const PolylineId('resident-live-route'), points: pickup.routePoints, color: AppTheme.accentColor, width: 5, startCap: Cap.roundCap, endCap: Cap.roundCap)};
  }

  Set<Marker> _buildMarkersForPickup(LivePickupTracking? pickup) {
    if (pickup == null || pickup.status != LivePickupStatus.ongoing || pickup.truckLocation == null) {
      return const <Marker>{};
    }

    return <Marker>{
      Marker(
        markerId: const MarkerId('resident-live-truck'),
        position: pickup.truckLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: pickup.areaName, snippet: 'Collection truck'),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_showDemoDummyMapOnly) {
      _centerHomeMap();
      return;
    }
    _fitMapToCurrentRoute(force: true);
  }

  Future<void> _fitMapToCurrentRoute({bool force = false}) async {
    final GoogleMapController? controller = _mapController;
    final LivePickupTracking? pickup = _livePickup;

    if (controller == null || pickup == null || pickup.routePoints.isEmpty) {
      return;
    }

    if (!force && pickup.pickupId == _lastFocusedPickupId) {
      return;
    }

    final List<LatLng> points = List<LatLng>.from(pickup.routePoints);
    if (pickup.status == LivePickupStatus.ongoing && pickup.truckLocation != null) {
      points.add(pickup.truckLocation!);
    }

    try {
      if (points.length == 1) {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14.5));
        _lastFocusedPickupId = pickup.pickupId;
        return;
      }

      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final LatLng point in points.skip(1)) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      if ((maxLat - minLat).abs() < 0.0001 && (maxLng - minLng).abs() < 0.0001) {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14.5));
        _lastFocusedPickupId = pickup.pickupId;
        return;
      }

      await controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 48));

      _lastFocusedPickupId = pickup.pickupId;
    } catch (_) {
      // Ignore transient camera animation errors while the map is settling.
    }
  }

  String _liveMapAreaText() {
    final LivePickupTracking? pickup = _livePickup;
    if (pickup == null) {
      return 'No active route';
    }

    return pickup.areaName;
  }

  String _liveMapStatusText() {
    final LivePickupTracking? pickup = _livePickup;
    if (pickup == null) {
      if (_isLiveDataLoading) {
        return 'Connecting to live updates...';
      }
      return 'No pickups today';
    }

    if (pickup.status == LivePickupStatus.ongoing) {
      final int? eta = pickup.etaMinutes;
      if (eta != null) {
        return 'Arriving in ${eta}m';
      }
      return 'Pickup is in progress';
    }

    if (pickup.scheduledTime != null) {
      return 'Upcoming pickup at ${_timeFormatter.format(pickup.scheduledTime!)}';
    }

    return 'Upcoming pickup today';
  }

  String _syncBadgeLabel() {
    if (_isLiveDataLoading) {
      return 'SYNCING';
    }

    if (_liveDataError != null) {
      return 'OFFLINE';
    }

    if (_livePickup != null) {
      return 'LIVE';
    }

    if (_isRealtimeConnected) {
      return 'READY';
    }

    return 'IDLE';
  }

  Set<Polyline> _buildDemoPolylines() {
    return <Polyline>{const Polyline(polylineId: PolylineId('resident-demo-route'), points: _demoRoutePoints, color: AppTheme.accentColor, width: 6, startCap: Cap.roundCap, endCap: Cap.roundCap)};
  }

  Set<Marker> _buildDemoMarkers() {
    return <Marker>{
      Marker(
        markerId: const MarkerId('resident-demo-truck'),
        position: _demoTruckLocation,
        icon: _demoTruckMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Collection Truck', snippet: _demoTruckArea),
      ),
      Marker(
        markerId: const MarkerId('resident-demo-user'),
        position: _demoUserLocation,
        icon: _demoHomeMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location', snippet: _demoResidentArea),
      ),
    };
  }

  Future<void> _prepareDemoMarkerIcons() async {
    if (!_showDemoDummyMapOnly) {
      return;
    }

    try {
      final BitmapDescriptor truckIcon = await _buildDemoMarkerIcon(icon: Icons.local_shipping_rounded, backgroundColor: AppTheme.accentColor, fallbackHue: BitmapDescriptor.hueGreen);
      final BitmapDescriptor homeIcon = await _buildDemoMarkerIcon(icon: Icons.home_rounded, backgroundColor: AppTheme.secondaryColor1, fallbackHue: BitmapDescriptor.hueAzure);

      if (!mounted) {
        return;
      }

      setState(() {
        _demoTruckMarkerIcon = truckIcon;
        _demoHomeMarkerIcon = homeIcon;
      });

      // Refresh camera once custom icons are ready so map updates marker render.
      _centerHomeMap();
    } catch (_) {
      // Falls back to default marker hues if custom icon generation fails.
    }
  }

  Future<BitmapDescriptor> _buildDemoMarkerIcon({required IconData icon, required Color backgroundColor, required double fallbackHue}) async {
    const double markerSize = 48;
    const double iconSize = 22;
    const double innerInset = 3;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Offset center = const Offset(markerSize / 2, markerSize / 2);

    final Paint outerPaint = Paint()..color = Colors.white;
    final Paint innerPaint = Paint()..color = backgroundColor;

    canvas.drawCircle(center, markerSize / 2, outerPaint);
    canvas.drawCircle(center, (markerSize / 2) - innerInset, innerPaint);

    final TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: iconSize, fontFamily: icon.fontFamily, package: icon.fontPackage, color: Colors.white),
      );

    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));

    final ui.Image image = await recorder.endRecording().toImage(markerSize.toInt(), markerSize.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(fallbackHue);
    }

    // ignore: deprecated_member_use
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), size: const Size(markerSize, markerSize));
  }

  String _displayMapAreaText() {
    if (_showDemoDummyMapOnly) {
      return 'Truck: $_demoTruckArea';
    }
    return _liveMapAreaText();
  }

  String _displayMapStatusText() {
    if (_showDemoDummyMapOnly) {
      return 'Arriving in 45m';
    }
    return _liveMapStatusText();
  }

  String _displayUserLocationText() {
    if (_showDemoDummyMapOnly) {
      return 'You: $_demoResidentArea';
    }

    return '';
  }

  Future<void> _centerHomeMap() async {
    if (_showDemoDummyMapOnly) {
      final GoogleMapController? controller = _mapController;
      if (controller != null) {
        try {
          double minLat = _demoRoutePoints.first.latitude;
          double maxLat = _demoRoutePoints.first.latitude;
          double minLng = _demoRoutePoints.first.longitude;
          double maxLng = _demoRoutePoints.first.longitude;

          for (final LatLng point in _demoRoutePoints.skip(1)) {
            if (point.latitude < minLat) minLat = point.latitude;
            if (point.latitude > maxLat) maxLat = point.latitude;
            if (point.longitude < minLng) minLng = point.longitude;
            if (point.longitude > maxLng) maxLng = point.longitude;
          }

          await controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 48));
        } catch (_) {}
      }
      return;
    }

    _fitMapToCurrentRoute(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: Responsive.w(context, AppTheme.space24),
          right: Responsive.w(context, AppTheme.space24),
          top: Responsive.h(context, AppTheme.space32),
          bottom: Responsive.h(context, 120),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Dynamic Greeting & Name)
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            // 2. LIVE GOOGLE MAP TRACKING
            _buildLiveMapTracking(context),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            // 3. NEXT PICKUP CARD
            _buildNextPickupCard(context),
            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            // 4. QUICK ACTIONS
            _buildQuickActionsRow(context),
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            // 5. RECENT ACTIVITY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Activity", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecentActivityPage()));
                  },
                  child: Text(
                    "See All",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(context, AppTheme.space16)),
            _buildRecentActivityList(context),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            "Hello, $_userName",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            SizedBox(height: Responsive.h(context, 4)),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
          },
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 4)),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded, color: AppTheme.textColor, size: 28),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveMapTracking(BuildContext context) {
    return Container(
      height: Responsive.h(context, 260),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
        child: Stack(
          children: [
            // REAL GOOGLE MAP
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(6.8398, 79.8646), // Set to Mount Lavinia context
                zoom: 14.5,
              ),
              onMapCreated: _onMapCreated,
              polylines: _showDemoDummyMapOnly ? _buildDemoPolylines() : _mapPolylines,
              markers: _showDemoDummyMapOnly ? _buildDemoMarkers() : _mapMarkers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              mapType: MapType.normal,

              onTap: (_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OngoingPickupsPage(
                      wasteType: "Ongoing Pickup",
                      zone: "Truck: $_demoTruckArea\nYou: $_demoResidentArea",
                      team: "Team C-04",
                      etaTime: "45m",
                      etaDistance: "1.5km",
                      themeColor: AppTheme.accentColor,
                      wasteIcon: Icons.local_shipping_rounded,
                      checklistItems: const ["Bins washed and clean", "Plastics sorted together", "Cardboard flattened"],
                    ),
                  ),
                );
              },
            ),

            if (!_showDemoDummyMapOnly)
              Positioned(
                top: Responsive.h(context, 14),
                left: Responsive.w(context, 14),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 10), vertical: Responsive.h(context, 4)),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _syncBadgeLabel(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),

            // ETA OVERLAY CARD
            Positioned(
              bottom: Responsive.h(context, 20),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16), vertical: Responsive.h(context, 12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(context, 20)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_displayMapAreaText(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            _displayMapStatusText(),
                            style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          if (_displayUserLocationText().isNotEmpty) ...[
                            SizedBox(height: Responsive.h(context, 2)),
                            Text(
                              _displayUserLocationText(),
                              style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.68), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // LOCATION BUTTON OVERLAY
            Positioned(
              bottom: Responsive.h(context, 20),
              right: Responsive.w(context, 16),
              child: GestureDetector(
                onTap: () {
                  _centerHomeMap();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.my_location_rounded, color: AppTheme.textColor, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPickupCard(BuildContext context) {
    // 1. Setup Dynamic Variables (Default to Demo Data)
    String wasteType = "Organic Waste";
    String timeStr = "10:30";
    String amPm = "AM";
    String statusText = "Driver is 2 stops away";
    String etaTimeStr = "45m";
    String etaDistanceStr = "1.5km";
    String zoneStr = "Truck: $_demoTruckArea\nYou: $_demoResidentArea";
    String teamStr = "Team C-04";
    double progressValue = 0.6; // Demo progress (60%)

    // 2. Override with Real-Time Data if Live Mode is active
    if (!_showDemoDummyMapOnly) {
      if (_isLiveDataLoading) {
        wasteType = "Syncing...";
        timeStr = "--:--";
        amPm = "";
        statusText = "Connecting to live updates...";
        progressValue = 0.0;
      } else if (_livePickup == null) {
        wasteType = "No Pickups";
        timeStr = "--:--";
        amPm = "";
        statusText = "You are all caught up for today!";
        progressValue = 0.0;
      } else {
        wasteType = "Organic Waste"; 
        zoneStr = _livePickup!.areaName;
        
        if (_livePickup!.scheduledTime != null) {
          timeStr = DateFormat('h:mm').format(_livePickup!.scheduledTime!);
          amPm = DateFormat('a').format(_livePickup!.scheduledTime!).toUpperCase();
        } else {
          timeStr = "TBD";
          amPm = "";
        }

        if (_livePickup!.status == LivePickupStatus.ongoing) {
          final eta = _livePickup!.etaMinutes;
          if (eta != null) {
            statusText = "Arriving in $eta mins";
            etaTimeStr = "${eta}m";
            progressValue = 0.8; // 80% progress if ongoing
          } else {
            statusText = "Pickup is in progress";
            etaTimeStr = "En route";
            progressValue = 0.5; // 50% progress
          }
        } else {
          statusText = "Upcoming pickup scheduled";
          etaTimeStr = "--";
          progressValue = 0.1; // 10% progress if scheduled but not started
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Prevent navigation if there is no actual live pickup
        if (!_showDemoDummyMapOnly && _livePickup == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No active pickups to track today.'),
              backgroundColor: AppTheme.secondaryColor1,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
          return;
        }

        // Navigate passing the dynamic data to the details page
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OngoingPickupsPage(
            wasteType: wasteType,
            zone: zoneStr,
            team: teamStr,
            etaTime: etaTimeStr,
            etaDistance: etaDistanceStr,
            themeColor: AppTheme.accentColor,
            wasteIcon: Icons.recycling_rounded,
            checklistItems: const [
              "Bins washed and clean",
              "Plastics sorted together",
              "Cardboard flattened"
            ],
          ),
        ));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Next Pickup", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: const [
                      Icon(Icons.schedule_rounded, color: AppTheme.accentColor, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Today",
                        style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(context, 4)),
            Text(wasteType, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            SizedBox(height: Responsive.h(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(timeStr, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(width: 4),
                    Text(
                      amPm,
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.recycling_rounded, color: AppTheme.accentColor, size: 32),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(context, 16)),
            
            // Dynamic Progress Bar
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 8,
                      width: constraints.maxWidth * progressValue,
                      decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                );
              }
            ),
            
            SizedBox(height: Responsive.h(context, 8)),
            Text(statusText, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        // Primary Action (Green)
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FileComplaintPage()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 20), horizontal: Responsive.w(context, 16)),
              decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(Responsive.r(context, 20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white, size: 28),
                  SizedBox(height: Responsive.h(context, 12)),
                  const Text(
                    "Report",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  const Text("Missed pickup or\noverflow", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: Responsive.w(context, 16)),
        // Secondary Action (White)
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuideMainPage()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 20), horizontal: Responsive.w(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.r(context, 20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.recycling_rounded, color: Colors.blueAccent, size: 24),
                  ),
                  SizedBox(height: Responsive.h(context, 12)),
                  const Text(
                    "Guide",
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text("Sorting rules\nand tips", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    return Column(
      children: [
        _buildActivityTile(
          context,
          title: "Recycling Pickup Completed",
          date: "Yesterday, 9:45 AM",
          icon: Icons.check_circle_rounded,
          iconColor: AppTheme.accentColor,
          bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
        ),
        SizedBox(height: Responsive.h(context, AppTheme.space16)),
        _buildActivityTile(
          context,
          title: "Issue Reported: Overflowing Bin",
          date: "Mon, 14 Aug",
          icon: Icons.history_rounded,
          iconColor: Colors.orange,
          bgColor: Colors.orange.withValues(alpha: 0.1),
          onTap: () => _openComplaintDetails(
            context,
            Complaint(
              id: "8795",
              dbId: "8795",
              category: "Overflowing Bin",
              status: "In Progress",
              statusTitle: "Team Assigned",
              statusDescription: "A field team has been dispatched to resolve the issue.",
              dateSubmitted: "Oct 10, 2023",
              fullDescription: "Public bin at the corner of 5th Ave is overflowing and causing a health hazard.",
              imagePath: 'assets/img/overflowing_bin.jpg',
              isLocal: true,
              assignedTo: "Field Team B",
            ),
          ),
        ),
        SizedBox(height: Responsive.h(context, AppTheme.space16)),
        _buildActivityTile(
          context,
          title: "Organic Pickup Completed",
          date: "Sat, 12 Aug",
          icon: Icons.check_circle_rounded,
          iconColor: AppTheme.accentColor,
          bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildActivityTile(BuildContext context, {required String title, required String date, required IconData icon, required Color iconColor, required Color bgColor, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(context, 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 10)),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: Responsive.w(context, 22)),
              ),
              SizedBox(width: Responsive.w(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openComplaintDetails(BuildContext context, Complaint complaint) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailsPage(complaint: complaint)));
  }
}
