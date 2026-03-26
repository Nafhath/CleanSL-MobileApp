import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../pages/ongoing_pickups.dart';

class LiveTrackingCard extends StatefulWidget {
  final String wasteType;
  final String zone;
  final String team;
  final String etaTime;
  final String etaDistance;
  final Color themeColor;
  final IconData wasteIcon;
  final List<String> checklistItems;
  final List<LatLng>? routePoints;
  final LatLng? truckPosition;
  final LatLng? userPosition;
  final LatLng? initialMapCenter;
  final String? statusText;
  final bool isNavigationEnabled;
  final bool showRefreshButton;
  final String zoneLabel;

  const LiveTrackingCard({
    super.key,
    required this.wasteType,
    required this.zone,
    required this.team,
    required this.etaTime,
    required this.etaDistance,
    required this.themeColor,
    required this.wasteIcon,
    required this.checklistItems,
    this.routePoints,
    this.truckPosition,
    this.userPosition,
    this.initialMapCenter,
    this.statusText,
    this.isNavigationEnabled = true,
    this.showRefreshButton = true,
    this.zoneLabel = 'CURRENT ZONE',
  });

  @override
  State<LiveTrackingCard> createState() => _LiveTrackingCardState();
}

class _LiveTrackingCardState extends State<LiveTrackingCard> {
  static const LatLng _defaultMapCenter = LatLng(6.9061, 79.8687);

  GoogleMapController? _mapController;
  bool _isRefreshing = false;
  BitmapDescriptor? _truckMarkerIcon;
  BitmapDescriptor? _homeMarkerIcon;

  @override
  void initState() {
    super.initState();
    _prepareMarkerIcons();
  }

  CameraPosition _initialCameraPosition() {
    final List<LatLng> routePoints = widget.routePoints ?? const <LatLng>[];
    final LatLng center = widget.initialMapCenter ?? widget.truckPosition ?? widget.userPosition ?? (routePoints.isNotEmpty ? routePoints.first : _defaultMapCenter);

    return CameraPosition(target: center, zoom: 13.5);
  }

  Set<Polyline> _buildPolylines() {
    final List<LatLng> routePoints = widget.routePoints ?? const <LatLng>[];
    if (routePoints.length < 2) {
      return const <Polyline>{};
    }

    return <Polyline>{Polyline(polylineId: const PolylineId('schedule-live-route'), points: routePoints, color: widget.themeColor, width: 5, startCap: Cap.roundCap, endCap: Cap.roundCap)};
  }

  Set<Marker> _buildMarkers() {
    if (widget.truckPosition == null && widget.userPosition == null) {
      return const <Marker>{};
    }

    final Set<Marker> markers = <Marker>{};

    if (widget.truckPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('schedule-live-truck'),
          position: widget.truckPosition!,
          icon: _truckMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Collection Truck'),
        ),
      );
    }

    if (widget.userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('schedule-user-location'),
          position: widget.userPosition!,
          icon: _homeMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    return markers;
  }

  Future<void> _fitMapToRoute() async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) {
      return;
    }

    final List<LatLng> points = [...?widget.routePoints];
    if (widget.truckPosition != null) {
      points.add(widget.truckPosition!);
    }
    if (widget.userPosition != null) {
      points.add(widget.userPosition!);
    }

    if (points.isEmpty) {
      return;
    }

    try {
      if (points.length == 1) {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
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

      await controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 42));
    } catch (_) {}
  }

  Future<void> _prepareMarkerIcons() async {
    try {
      final BitmapDescriptor truck = await _buildMapMarkerIcon(icon: Icons.local_shipping_rounded, backgroundColor: AppTheme.accentColor, fallbackHue: BitmapDescriptor.hueGreen);
      final BitmapDescriptor home = await _buildMapMarkerIcon(icon: Icons.home_rounded, backgroundColor: AppTheme.secondaryColor1, fallbackHue: BitmapDescriptor.hueAzure);

      if (!mounted) {
        return;
      }

      setState(() {
        _truckMarkerIcon = truck;
        _homeMarkerIcon = home;
      });

      _fitMapToRoute();
    } catch (_) {
      // Falls back to default marker hues if custom icon generation fails.
    }
  }

  Future<BitmapDescriptor> _buildMapMarkerIcon({required IconData icon, required Color backgroundColor, required double fallbackHue}) async {
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
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);

    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(fallbackHue);
    }

    // ignore: deprecated_member_use
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), size: const Size(markerSize, markerSize));
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final controller = _mapController;
      if (controller != null) {
        await controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition()));
        await _fitMapToRoute();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiveTrackingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routePoints != widget.routePoints ||
        oldWidget.truckPosition != widget.truckPosition ||
        oldWidget.userPosition != widget.userPosition ||
        oldWidget.initialMapCenter != widget.initialMapCenter) {
      _fitMapToRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isNavigationEnabled
          ? () {
              // PASS ALL TEMPLATE DATA TO THE NEXT PAGE
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OngoingPickupsPage(
                    wasteType: widget.wasteType,
                    zone: widget.zone,
                    team: widget.team,
                    etaTime: widget.etaTime,
                    etaDistance: widget.etaDistance,
                    themeColor: widget.themeColor,
                    wasteIcon: widget.wasteIcon,
                    checklistItems: widget.checklistItems,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            SizedBox(
              height: Responsive.h(context, 210),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition(),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _fitMapToRoute();
                        },
                        polylines: _buildPolylines(),
                        markers: _buildMarkers(),
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                      ),
                    ),
                    // Removed truck icon overlay above the card
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(Responsive.w(context, 16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.zoneLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.75), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.zone, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.2)),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 12)),
                  if (widget.showRefreshButton)
                    SizedBox(
                      width: Responsive.w(context, 122),
                      child: ElevatedButton(
                        onPressed: _isRefreshing ? null : _handleRefresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor, // Dynamic Button Color
                          disabledBackgroundColor: widget.themeColor.withValues(alpha: 0.7),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isRefreshing) ...[const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)), const SizedBox(width: 8)],
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
          ],
        ),
      ),
    );
  }
}
