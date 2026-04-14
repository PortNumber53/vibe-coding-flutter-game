import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/location_data.dart';

/// Service for tracking device location at regular intervals
/// and posting to an external server
class LocationTracker {
  static const Duration _updateInterval = Duration(minutes: 1);
  static const String _defaultServerUrl = 'https://api.example.com/location';

  Timer? _updateTimer;
  Position? _lastPosition;
  bool _isTracking = false;
  String? _authToken;
  String _serverUrl = _defaultServerUrl;

  /// Whether location tracking is currently active
  bool get isTracking => _isTracking;

  /// The last known position
  Position? get lastPosition => _lastPosition;

  /// Error callback function
  void Function(Object error, StackTrace stackTrace)? onError;

  /// Sets the server URL for location updates
  void setServerUrl(String url) {
    _serverUrl = url;
  }

  /// Sets the authentication token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Requests location permissions
  /// Returns true if permissions are granted, false otherwise
  Future<bool> requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print('Location services are disabled.');
      }
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions are denied.');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('Location permissions are permanently denied.');
      }
      return false;
    }

    return true;
  }

  /// Starts location tracking
  /// [serverUrl] Optional custom server URL
  /// [authToken] Optional authentication token
  Future<void> startTracking({
    String? serverUrl,
    String? authToken,
  }) async {
    if (_isTracking) {
      if (kDebugMode) {
        print('Location tracking is already active.');
      }
      return;
    }

    // Update configuration if provided
    if (serverUrl != null) {
      _serverUrl = serverUrl;
    }
    if (authToken != null) {
      _authToken = authToken;
    }

    // Request permissions first
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw LocationPermissionException('Location permission not granted');
    }

    _isTracking = true;

    // Get initial position
    await _updateAndPostLocation();

    // Start periodic updates
    _updateTimer = Timer.periodic(_updateInterval, (_) {
      _updateAndPostLocation();
    });

    if (kDebugMode) {
      print('Location tracking started. Updates every ${_updateInterval.inMinutes} minute(s).');
    }
  }

  /// Stops location tracking
  void stopTracking() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _isTracking = false;

    if (kDebugMode) {
      print('Location tracking stopped.');
    }
  }

  /// Gets the current position
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = position;
      return position;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      return null;
    }
  }

  /// Updates location and posts to server
  Future<void> _updateAndPostLocation() async {
    final position = await getCurrentPosition();
    if (position != null) {
      await _postLocationToServer(position);
    }
  }

  /// Posts location data to the configured server
  Future<void> _postLocationToServer(Position position) async {
    try {
      // Create LocationData model from position
      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp ?? DateTime.now(),
        platform: defaultTargetPlatform.name,
      );

      final headers = {
        'Content-Type': 'application/json',
      };

      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: headers,
        body: locationData.toJsonString(),
      );

      if (kDebugMode) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('Location posted successfully: ${response.statusCode}');
        } else {
          print('Failed to post location: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  /// Handles errors by calling the error callback if set
  void _handleError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Location tracker error: $error');
    }
    onError?.call(error, stackTrace);
  }

  /// Disposes the tracker and stops any ongoing operations
  void dispose() {
    stopTracking();
    onError = null;
  }
}

/// Exception thrown when location permissions are not granted
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}
