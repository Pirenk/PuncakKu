import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

// =============================================================================
// MODUL MATEMATIKA & PERHITUNGAN GEOSPASIAL (TRACKING CALCULATOR)
// =============================================================================
// File ini berfungsi sebagai "otak kalkulasi" untuk aplikasi PuncakKu:
// 1. Rumus Haversine: Jarak lengkung bumi 2 koordinat GPS presisi satuan meter
// 2. Akumulasi jarak rute garis Polyline
// 3. Elevation Gain: Akumulasi kenaikan elevasi dengan filter noise barometrik
// 4. Formatter jarak, durasi, dan waktu
// =============================================================================

class TrackingCalculator {
  // Radius rata-rata bumi dalam satuan meter menurut standar geodesi WGS-84.
  static const double _earthRadiusMeters = 6371000.0;

  // ---------------------------------------------------------------------------
  // [FORMULA HAVERSINE]
  // Menghitung jarak lengkungan bola bumi antara dua titik koordinat (lat, lon).
  // ---------------------------------------------------------------------------
  static double calculateHaversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(rLat1) *
            math.cos(rLat2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  // Akumulasi total jarak rute sekumpulan titik LatLng (dalam meter)
  static double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += calculateHaversineDistance(
        lat1: points[i].latitude,
        lon1: points[i].longitude,
        lat2: points[i + 1].latitude,
        lon2: points[i + 1].longitude,
      );
    }
    return total;
  }

  // ---------------------------------------------------------------------------
  // [ELEVATION GAIN]
  // Akumulasi total tanjakan naik dengan threshold 2 meter untuk filter noise GPS.
  // ---------------------------------------------------------------------------
  static double calculateElevationGain(
    List<double> altitudes, {
    double noiseThresholdMeters = 2.0,
  }) {
    if (altitudes.length < 2) return 0.0;

    double gain = 0.0;
    double lastValidAltitude = altitudes.first;

    for (int i = 1; i < altitudes.length; i++) {
      final currentAltitude = altitudes[i];
      final delta = currentAltitude - lastValidAltitude;

      if (delta >= noiseThresholdMeters) {
        gain += delta;
        lastValidAltitude = currentAltitude;
      } else if (delta <= -noiseThresholdMeters) {
        lastValidAltitude = currentAltitude;
      }
    }

    return gain;
  }

  // Format jarak tempuh (misal input dalam meter: 1250 m -> "1,25 km")
  static String formatDistance(double meters) {
    if (meters >= 1000.0) {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(2).replaceAll('.', ',')} km';
    } else {
      return '${meters.toStringAsFixed(0)} m';
    }
  }

  // Format durasi waktu (contoh: Duration(minutes: 45) -> "45 menit" atau "00:45:00")
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // Format tanggal & jam Indonesia (contoh: "15 Nov 2026, 17:15")
  static String formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // Helper konversi derajat ke radian
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
