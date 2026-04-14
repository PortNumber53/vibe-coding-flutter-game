import 'dart:convert';

/// Model class for location data sent to the server
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final String platform;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.platform,
  });

  /// Creates a LocationData from a Position
  factory LocationData.fromPosition({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double altitude,
    required double speed,
    required double heading,
    required DateTime timestamp,
    required String platform,
  }) {
    return LocationData(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
      platform: platform,
    );
  }

  /// Converts LocationData to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'platform': platform,
    };
  }

  /// Creates LocationData from a JSON map
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
    );
  }

  /// Converts LocationData to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Creates a copy of LocationData with modified fields
  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? platform,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      platform: platform ?? this.platform,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, acc: $accuracy, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, timestamp);
}

/// Status of location tracking
enum LocationStatus {
  idle,
  requestingPermission,
  permissionDenied,
  permissionDeniedForever,
  tracking,
  error,
}

/// Wrapper for location tracking state
class LocationTrackingState {
  final LocationStatus status;
  final LocationData? lastLocation;
  final String? errorMessage;
  final bool isPosting;
  final DateTime? lastPostTime;
  final bool lastPostSuccess;

  LocationTrackingState({
    this.status = LocationStatus.idle,
    this.lastLocation,
    this.errorMessage,
    this.isPosting = false,
    this.lastPostTime,
    this.lastPostSuccess = false,
  });

  LocationTrackingState copyWith({
    LocationStatus? status,
    LocationData? lastLocation,
    String? errorMessage,
    bool? isPosting,
    DateTime? lastPostTime,
    bool? lastPostSuccess,
    bool clearError = false,
    bool clearLocation = false,
  }) {
    return LocationTrackingState(
      status: status ?? this.status,
      lastLocation: clearLocation ? null : (lastLocation ?? this.lastLocation),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPosting: isPosting ?? this.isPosting,
      lastPostTime: lastPostTime ?? this.lastPostTime,
      lastPostSuccess: lastPostSuccess ?? this.lastPostSuccess,
    );
  }

  bool get hasPermission => status == LocationStatus.tracking;
  bool get isPermissionDenied =>
      status == LocationStatus.permissionDenied ||
      status == LocationStatus.permissionDeniedForever;
}
