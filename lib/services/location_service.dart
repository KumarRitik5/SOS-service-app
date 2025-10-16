import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// LocationService - Handles GPS location retrieval
/// Uses Geolocator package for cross-platform location access
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location service: $e');
      }
      return false;
    }
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permission: $e');
      }
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permission: $e');
      }
      return LocationPermission.denied;
    }
  }

  /// Ensure location permission is granted
  Future<bool> ensurePermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print('Location services are disabled');
      }
      return false;
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions are denied');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('Location permissions are permanently denied');
      }
      return false;
    }

    return true;
  }

  /// Get current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      // Ensure we have permission
      bool hasPermission = await ensurePermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print('Location: ${position.latitude}, ${position.longitude}');
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      return null;
    }
  }

  /// Get last known position (faster but may be outdated)
  Future<Position?> getLastKnownPosition() async {
    try {
      bool hasPermission = await ensurePermission();
      if (!hasPermission) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null && kDebugMode) {
        print(
          'Last known location: ${position.latitude}, ${position.longitude}',
        );
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last known location: $e');
      }
      return null;
    }
  }

  /// Get position with fallback to last known
  Future<Position?> getPositionWithFallback() async {
    // Try current position first
    Position? position = await getCurrentPosition();

    // If current position fails, try last known
    if (position == null) {
      position = await getLastKnownPosition();
    }

    return position;
  }

  /// Get location settings for the app
  LocationSettings getLocationSettings() {
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance (in meters) to trigger update
    );
  }

  /// Stream of position updates (for real-time tracking)
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: getLocationSettings(),
    );
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format coordinates as string
  String formatCoordinates(double latitude, double longitude) {
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lon: ${longitude.toStringAsFixed(6)}';
  }
}
