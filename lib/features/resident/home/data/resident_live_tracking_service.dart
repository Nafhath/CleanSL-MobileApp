import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'live_pickup_tracking_model.dart';

class ResidentLiveTrackingService {
  ResidentLiveTrackingService({SupabaseClient? client}) : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String? get _residentId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> fetchPickupRowsForCurrentResident() async {
    final residentId = _residentId;
    if (residentId == null) {
      return const [];
    }

    try {
      final dynamic rows = await _supabase.from('pickups').select().eq('resident_id', residentId).order('scheduled_time', ascending: true);

      if (rows is! List) {
        return const [];
      }

      return rows.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchPickupRowsForCurrentResident() {
    final residentId = _residentId;
    if (residentId == null) {
      return Stream<List<Map<String, dynamic>>>.value(const []);
    }

    return _supabase
        .from('pickups')
        .stream(primaryKey: ['id'])
        .eq('resident_id', residentId)
        .order('scheduled_time', ascending: true)
        .map((rows) => rows.map((row) => Map<String, dynamic>.from(row)).toList(growable: false));
  }

  Future<Map<String, dynamic>?> fetchLatestDriverLocation(String driverId) async {
    try {
      final dynamic row = await _supabase.from('driver_locations').select().eq('driver_id', driverId).order('updated_at', ascending: false).limit(1).maybeSingle();

      if (row is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(row);
    } catch (_) {
      return null;
    }
  }

  LivePickupTracking? selectCurrentPickup(List<Map<String, dynamic>> rows, {DateTime? now}) {
    if (rows.isEmpty) {
      return null;
    }

    final DateTime reference = now ?? DateTime.now();
    final List<LivePickupTracking> ongoing = [];
    final List<LivePickupTracking> upcomingToday = [];

    for (final row in rows) {
      final LivePickupStatus? status = _parsePickupStatus(row['status']);
      if (status == null) {
        continue;
      }

      final DateTime? scheduledTime = _parseDateTime(row['scheduled_time'] ?? row['scheduled_at'] ?? row['pickup_time']);

      final LivePickupTracking pickup = LivePickupTracking(
        pickupId: row['id']?.toString() ?? '',
        status: status,
        areaName: _extractAreaName(row),
        routePoints: _parseRoutePoints(row),
        scheduledTime: scheduledTime,
        etaMinutes: _parseInt(row['eta_minutes'] ?? row['eta_mins'] ?? row['eta']),
        driverId: row['driver_id']?.toString(),
        truckLocation: _parseLatLng(rawLat: row['truck_lat'] ?? row['current_lat'] ?? row['lat'] ?? row['latitude'], rawLng: row['truck_lng'] ?? row['current_lng'] ?? row['lng'] ?? row['longitude']),
        lastUpdatedAt: _parseDateTime(row['updated_at'] ?? row['last_updated_at']),
      );

      if (status == LivePickupStatus.ongoing) {
        ongoing.add(pickup);
        continue;
      }

      if (status == LivePickupStatus.upcomingToday && scheduledTime != null && _isSameDay(scheduledTime, reference)) {
        upcomingToday.add(pickup);
      }
    }

    if (ongoing.isNotEmpty) {
      ongoing.sort((a, b) {
        final DateTime aTime = a.lastUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bTime = b.lastUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return ongoing.first;
    }

    if (upcomingToday.isNotEmpty) {
      upcomingToday.sort((a, b) {
        final DateTime aTime = a.scheduledTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bTime = b.scheduledTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
      return upcomingToday.first;
    }

    return null;
  }

  LivePickupTracking mergeDriverLocation(LivePickupTracking pickup, Map<String, dynamic>? row) {
    if (row == null) {
      return pickup;
    }

    final LatLng? location = _parseLatLng(rawLat: row['lat'] ?? row['latitude'] ?? row['truck_lat'], rawLng: row['lng'] ?? row['longitude'] ?? row['truck_lng']);
    final int? eta = _parseInt(row['eta_minutes'] ?? row['eta_mins'] ?? row['eta']);
    final DateTime? updatedAt = _parseDateTime(row['updated_at'] ?? row['created_at']);

    if (location == null && eta == null && updatedAt == null) {
      return pickup;
    }

    return LivePickupTracking(
      pickupId: pickup.pickupId,
      status: pickup.status,
      areaName: pickup.areaName,
      routePoints: pickup.routePoints,
      scheduledTime: pickup.scheduledTime,
      etaMinutes: eta ?? pickup.etaMinutes,
      driverId: pickup.driverId,
      truckLocation: location ?? pickup.truckLocation,
      lastUpdatedAt: updatedAt ?? pickup.lastUpdatedAt,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  LivePickupStatus? _parsePickupStatus(dynamic rawStatus) {
    if (rawStatus == null) {
      return null;
    }

    final String normalized = rawStatus.toString().trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

    if (normalized == 'ongoing' || normalized == 'in_progress' || normalized == 'live') {
      return LivePickupStatus.ongoing;
    }

    if (normalized == 'scheduled' || normalized == 'upcoming' || normalized == 'pending' || normalized == 'assigned') {
      return LivePickupStatus.upcomingToday;
    }

    return null;
  }

  String _extractAreaName(Map<String, dynamic> row) {
    final dynamic value = row['area_name'] ?? row['area'] ?? row['zone_name'] ?? row['zone'] ?? row['location_name'];
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return 'Pickup Route';
    }
    return text;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value.toLocal();
    }

    return DateTime.tryParse(value.toString())?.toLocal();
  }

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value.toString());
  }

  double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  LatLng? _parseLatLng({dynamic rawLat, dynamic rawLng}) {
    final double? lat = _parseDouble(rawLat);
    final double? lng = _parseDouble(rawLng);
    if (lat == null || lng == null) {
      return null;
    }

    if (!_isValidLatLng(lat, lng)) {
      return null;
    }

    return LatLng(lat, lng);
  }

  bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  List<LatLng> _parseRoutePoints(Map<String, dynamic> row) {
    final dynamic rawPoints = row['route_points'] ?? row['route_coordinates'] ?? row['route_path'];

    if (rawPoints is List) {
      final List<LatLng> points = _parseRoutePointList(rawPoints);
      if (points.isNotEmpty) {
        return points;
      }
    }

    final dynamic rawPolyline = row['route_polyline'] ?? row['encoded_polyline'] ?? row['polyline'];

    if (rawPolyline is String && rawPolyline.trim().isNotEmpty) {
      return _decodePolyline(rawPolyline.trim());
    }

    return const [];
  }

  List<LatLng> _parseRoutePointList(List<dynamic> rawPoints) {
    final List<LatLng> points = [];

    for (final dynamic value in rawPoints) {
      if (value is Map) {
        final double? lat = _parseDouble(value['lat'] ?? value['latitude']);
        final double? lng = _parseDouble(value['lng'] ?? value['lon'] ?? value['longitude']);

        if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
          points.add(LatLng(lat, lng));
        }
        continue;
      }

      if (value is List && value.length >= 2) {
        final double? first = _parseDouble(value[0]);
        final double? second = _parseDouble(value[1]);

        if (first == null || second == null) {
          continue;
        }

        double lat = second;
        double lng = first;
        if (!_isValidLatLng(lat, lng) && _isValidLatLng(first, second)) {
          lat = first;
          lng = second;
        }

        if (_isValidLatLng(lat, lng)) {
          points.add(LatLng(lat, lng));
        }
      }
    }

    return points;
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      final (int value, int nextIndex)? latComponent = _decodePolylineValue(encoded, index);
      if (latComponent == null) {
        break;
      }
      lat += latComponent.$1;
      index = latComponent.$2;

      final (int value, int nextIndex)? lngComponent = _decodePolylineValue(encoded, index);
      if (lngComponent == null) {
        break;
      }
      lng += lngComponent.$1;
      index = lngComponent.$2;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  (int value, int nextIndex)? _decodePolylineValue(String encoded, int startIndex) {
    int index = startIndex;
    int shift = 0;
    int result = 0;

    while (index < encoded.length) {
      final int byte = encoded.codeUnitAt(index) - 63;
      index++;
      result |= (byte & 0x1f) << shift;
      shift += 5;

      if (byte < 0x20) {
        final int delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
        return (delta, index);
      }
    }

    return null;
  }
}
