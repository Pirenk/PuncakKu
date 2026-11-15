import 'package:flutter/foundation.dart';

/// Model representing a single GPS coordinate point.
/// Corresponds to the `gps_tracking_points` table.
class GpsTrackingPoint {
  final int? idPoint;
  final int idTracking; // foreign key to gps_tracking.id_tracking
  final double latitude;
  final double longitude;
  final double? altitude; // mdpl, optional
  final double? accuracy; // meters, optional
  final double? speed; // m/s, optional
  final DateTime recordedAt;
  final DateTime? createdAt;

  GpsTrackingPoint({
    this.idPoint,
    required this.idTracking,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    required this.recordedAt,
    this.createdAt,
  });

  /// Format tanggal YYYY-MM-DD HH:MM:SS sesuai standar MySQL DATETIME
  static String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} '
        '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}';
  }

  /// Convert to a map for SQLite insertion / json serialization.
  Map<String, dynamic> toMap() {
    return {
      'id_point': idPoint,
      'id_tracking': idTracking,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'recorded_at': _formatDateTime(recordedAt),
      'created_at': createdAt != null ? _formatDateTime(createdAt!) : _formatDateTime(DateTime.now()),
    };
  }

  /// Recreate the model from a map (e.g., SQLite query result).
  factory GpsTrackingPoint.fromMap(Map<String, dynamic> map) {
    return GpsTrackingPoint(
      idPoint: map['id_point'] as int?,
      idTracking: (map['id_tracking'] as num).toInt(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: map['altitude'] != null ? (map['altitude'] as num).toDouble() : null,
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }
}
