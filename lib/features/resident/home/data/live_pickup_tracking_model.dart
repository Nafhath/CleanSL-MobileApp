import 'package:google_maps_flutter/google_maps_flutter.dart';

enum LivePickupStatus { ongoing, upcomingToday }

class LivePickupTracking {
  const LivePickupTracking({
    required this.pickupId,
    required this.status,
    required this.areaName,
    required this.routePoints,
    this.scheduledTime,
    this.etaMinutes,
    this.driverId,
    this.truckLocation,
    this.lastUpdatedAt,
  });

  final String pickupId;
  final LivePickupStatus status;
  final String areaName;
  final DateTime? scheduledTime;
  final int? etaMinutes;
  final String? driverId;
  final LatLng? truckLocation;
  final DateTime? lastUpdatedAt;
  final List<LatLng> routePoints;

  bool get hasRoute => routePoints.isNotEmpty;
}
