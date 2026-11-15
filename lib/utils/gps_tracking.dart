import 'package:flutter/foundation.dart';

/// Model representing a tracking session (summary).
/// Corresponds to the `gps_tracking` table.
class GpsTracking {
  final int? idTracking;
  final int idUser;
  final int? idTrip;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final double totalJarak; // km
  final int durasiDetik;
  final String status; // berlangsung, dijeda, selesai
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GpsTracking({
    this.idTracking,
    required this.idUser,
    this.idTrip,
    required this.tanggalMulai,
    this.tanggalSelesai,
    this.totalJarak = 0.0,
    this.durasiDetik = 0,
    this.status = 'berlangsung',
    this.createdAt,
    this.updatedAt,
  });

  /// Format tanggal YYYY-MM-DD HH:MM:SS sesuai standar MySQL DATETIME
  static String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} '
        '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}';
  }

  /// Convert to a map suitable for SQLite / MySQL insertion.
  Map<String, dynamic> toMap() {
    return {
      'id_tracking': idTracking,
      'id_user': idUser,
      'id_trip': idTrip,
      'tanggal_mulai': _formatDateTime(tanggalMulai),
      'tanggal_selesai': tanggalSelesai != null ? _formatDateTime(tanggalSelesai!) : null,
      'total_jarak': totalJarak,
      'durasi_detik': durasiDetik,
      'status': status,
      'created_at': createdAt != null ? _formatDateTime(createdAt!) : _formatDateTime(DateTime.now()),
      'updated_at': updatedAt != null ? _formatDateTime(updatedAt!) : _formatDateTime(DateTime.now()),
    };
  }

  /// Recreate the model from a map (e.g., SQLite query result).
  factory GpsTracking.fromMap(Map<String, dynamic> map) {
    return GpsTracking(
      idTracking: map['id_tracking'] as int?,
      idUser: (map['id_user'] as num).toInt(),
      idTrip: map['id_trip'] != null ? (map['id_trip'] as num).toInt() : null,
      tanggalMulai: DateTime.parse(map['tanggal_mulai'] as String),
      tanggalSelesai: map['tanggal_selesai'] != null ? DateTime.parse(map['tanggal_selesai'] as String) : null,
      totalJarak: (map['total_jarak'] as num).toDouble(),
      durasiDetik: (map['durasi_detik'] as num).toInt(),
      status: map['status'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  /// Helper to display distance in a user‑friendly format.
  String get formattedJarak {
    if (totalJarak >= 1.0) {
      return '${totalJarak.toStringAsFixed(2).replaceAll('.', ',')} km';
    }
    final meters = (totalJarak * 1000).round();
    return '$meters m';
  }

  /// Helper to display duration in a readable format.
  String get formattedDurasi {
    final hours = durasiDetik ~/ 3600;
    final minutes = (durasiDetik % 3600) ~/ 60;
    final seconds = durasiDetik % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }
}
