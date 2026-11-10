import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

// =============================================================================
// MODUL MATEMATIKA & PERHITUNGAN GEOSPASIAL (TRACKING CALCULATOR)
// =============================================================================
// File ini berfungsi sebagai "otak kalkulasi" untuk aplikasi PuncakKu.
// Digunakan untuk menghitung jarak akurat antar-koordinat dan kenaikan elevasi
// yang dialami oleh pendaki gunung selama tracking berlangsung.
// =============================================================================

class TrackingCalculator {
  // Radius rata-rata bumi dalam satuan meter menurut standar geodesi WGS-84.
  // Digunakan sebagai konstanta utama dalam rumus trigonometri bola (Haversine).
  static const double _earthRadiusMeters = 6371000.0;

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 1: FORMULA HAVERSINE]
  // Pertanyaan Dosen: "Kenapa tidak pakai rumus jarak Euclidean biasa (Pythagoras)?"
  // Jawaban: "Karena bumi berbentuk bulat/elipsoid, bukan datar. Rumus Pythagoras
  // menghasilkan distorsi error yang besar pada koordinat derajat (lat/long).
  // Formula Haversine memperhitungkan kelengkungan bola bumi sehingga kalkulasi
  // jarak antar titik GPS sangat presisi hingga satuan meter."
  // ---------------------------------------------------------------------------
  static double calculateHaversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // Langkah 1: Ubah selisih derajat lintang & bujur ke dalam bentuk radian.
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    // Langkah 2: Ubah titik awal dan tujuan ke bentuk radian untuk kalkulasi sinus & kosinus.
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    // Langkah 3: Hitung 'a', yaitu kuadrat dari setengah tali busur antara dua titik.
    // Rumus: a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(rLat1) *
            math.cos(rLat2);

    // Langkah 4: Hitung jarak sudut dalam radian menggunakan fungsi arctangent 2.
    // Rumus: c = 2 * atan2( √a, √(1-a) )
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    // Langkah 5: Kalikan jarak sudut dengan radius bumi untuk mendapatkan jarak dalam meter.
    return _earthRadiusMeters * c;
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 2: AKUMULASI JARAK RUTE (POLYLINE)]
  // Fungsi ini menjumlahkan jarak dari setiap segmen titik koordinat yang berurutan
  // (Titik 0 ke 1, 1 ke 2, 2 ke 3, dst.) untuk menghasilkan total jarak tempuh pendaki.
  // ---------------------------------------------------------------------------
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
  // [POIN PRESENTASI 3: ELEVATION GAIN (TOTAL KENAIKAN ELEVASI POSITIF)]
  // Pertanyaan Dosen: "Bagaimana cara menghitung tanjakan/elevasi pendakian?"
  // Jawaban: "Elevation Gain BUKAN hanya puncak dikurangi kaki gunung, melainkan
  // total akumulasi tanjakan naik yang dilewati pendaki selama jalur naik-turun.
  // Kami menambahkan 'noise threshold' sebesar 2.0 meter untuk memfilter getaran/
  // fluktuasi sinyal barometrik GPS agar elevasi tidak bertambah saat pendaki diam."
  // ---------------------------------------------------------------------------
  static double calculateElevationGain(
    List<double> altitudes, {
    double noiseThresholdMeters = 2.0, // Filter noise sinyal GPS
  }) {
    if (altitudes.length < 2) return 0.0;

    double gain = 0.0;
    double lastValidAltitude = altitudes.first;

    for (int i = 1; i < altitudes.length; i++) {
      final currentAltitude = altitudes[i];
      final delta = currentAltitude - lastValidAltitude;

      // Hanya tambahkan jika kenaikan elevasi melewati batas threshold (misal > 2 meter)
      if (delta >= noiseThresholdMeters) {
        gain += delta;
        lastValidAltitude = currentAltitude;
      } else if (delta <= -noiseThresholdMeters) {
        // Jika sedang menuruni lereng, catat dasar lembah tanpa menambah gain
        lastValidAltitude = currentAltitude;
      }
    }

    return gain;
  }

  // Helper konversi sudut derajat (0° - 360°) ke bentuk Radian (0 - 2π)
  static double _toRadians(double degree) {
    return degree * (math.pi / 180.0);
  }

  // ---------------------------------------------------------------------------
  // HELPER FORMAT TAMPILAN UI (PRESENTASI METRIK)
  // ---------------------------------------------------------------------------

  // Format Jarak: Jika di bawah 1 km tampilkan 'meter', di atasnya jadi 'km'
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  // Format Waktu: Mengubah durasi detik ke format stopwatch resmi HH:MM:SS
  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // Format Kecepatan: Konversi meter per detik (m/s dari GPS) menjadi km/jam
  // Rumus: km/h = (m/s) * 3.6
  static String formatSpeed(double metersPerSecond) {
    final kmh = metersPerSecond * 3.6;
    if (kmh < 0.1) return '0.0 km/j';
    return '${kmh.toStringAsFixed(1)} km/j';
  }
}
