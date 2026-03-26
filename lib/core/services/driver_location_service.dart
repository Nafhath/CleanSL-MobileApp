import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DriverLocationStatus {
  idle,
  requestingPermission,
  active,
  permissionDenied,
  unavailable,
  error,
}

class DriverLocationSnapshot {
  const DriverLocationSnapshot({
    required this.status,
    this.message,
    this.position,
    this.updatedAt,
  });

  final DriverLocationStatus status;
  final String? message;
  final Position? position;
  final DateTime? updatedAt;

  DriverLocationSnapshot copyWith({
    DriverLocationStatus? status,
    String? message,
    Position? position,
    DateTime? updatedAt,
  }) {
    return DriverLocationSnapshot(
      status: status ?? this.status,
      message: message ?? this.message,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DriverLocationService {
  DriverLocationService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final ValueNotifier<DriverLocationSnapshot> state = ValueNotifier(
    const DriverLocationSnapshot(status: DriverLocationStatus.idle),
  );

  StreamSubscription<Position>? _positionSubscription;
  bool _starting = false;

  String? get _driverId => _supabase.auth.currentUser?.id;

  Future<void> start() async {
    if (_starting || _positionSubscription != null) {
      return;
    }

    final String? driverId = _driverId;
    if (driverId == null) {
      state.value = const DriverLocationSnapshot(
        status: DriverLocationStatus.unavailable,
        message: 'No signed-in driver session found.',
      );
      return;
    }

    _starting = true;
    state.value = const DriverLocationSnapshot(
      status: DriverLocationStatus.requestingPermission,
      message: 'Requesting location access...',
    );

    try {
      final bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        state.value = const DriverLocationSnapshot(
          status: DriverLocationStatus.unavailable,
          message: 'Location services are turned off on this device.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state.value = const DriverLocationSnapshot(
          status: DriverLocationStatus.permissionDenied,
          message: 'Location permission is required for live truck tracking.',
        );
        return;
      }

      final Position initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _publishPosition(initialPosition);

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 15,
            ),
          ).listen(
            (position) async {
              await _publishPosition(position);
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('[DriverLocation] stream error: $error');
              state.value = DriverLocationSnapshot(
                status: DriverLocationStatus.error,
                message: 'Unable to keep sharing live location.',
                updatedAt: DateTime.now(),
              );
            },
          );
    } catch (error, stackTrace) {
      debugPrint('[DriverLocation] start error: $error');
      debugPrintStack(stackTrace: stackTrace);
      state.value = DriverLocationSnapshot(
        status: DriverLocationStatus.error,
        message: 'Live location failed to start.',
        updatedAt: DateTime.now(),
      );
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    state.value = state.value.copyWith(status: DriverLocationStatus.idle);
  }

  Future<void> _publishPosition(Position position) async {
    final String? driverId = _driverId;
    if (driverId == null) {
      state.value = const DriverLocationSnapshot(
        status: DriverLocationStatus.unavailable,
        message: 'No signed-in driver session found.',
      );
      return;
    }

    final DateTime timestamp = DateTime.now().toUtc();

    await _supabase.from('driver_locations').insert({
      'driver_id': driverId,
      'lat': position.latitude,
      'lng': position.longitude,
      'speed': position.speed >= 0 ? position.speed : 0,
      'accuracy': position.accuracy,
      'updated_at': timestamp.toIso8601String(),
    });

    state.value = DriverLocationSnapshot(
      status: DriverLocationStatus.active,
      message: 'Live location is being shared.',
      position: position,
      updatedAt: timestamp.toLocal(),
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    state.dispose();
  }
}
