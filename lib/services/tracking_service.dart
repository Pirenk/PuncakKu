import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../database/tracking_database.dart';
import '../utils/tracking_calculator.dart';

// =============================================================================
// MODUL SERVICE TRACKING LOKASI & FOREGROUND SERVICE (BACKGROUND GPS)
// =============================================================================
// File ini adalah service pusat yang menangani:
// 1. Izin lokasi (Location Permission)
// 2. Pengambilan koordinat GPS di latar belakang (Background Tracking)
// 3. Optimasi baterai smartphone agar tidak boros saat pendakian
// 4. Pengiriman data stream ke UI secara realtime (Reaktif)
// =============================================================================

// Status aktivitas tracking (Mesin status / State Machine)
enum TrackingStatus { stopped, tracking, paused }

// -----------------------------------------------------------------------------
// [MODEL STATISTIK RUNTIME]
// Data gabungan yang dikirim setiap detik/setiap ada sinyal GPS baru ke antarmuka UI.
// -----------------------------------------------------------------------------
class TrackingStats {
  final double currentLatitude; // Titik Lintang saat ini
  final double currentLongitude; // Titik Bujur saat ini
  final double currentAltitude; // Ketinggian (mdpl)
  final double currentSpeed; // Kecepatan bergerak (m/s)
  final double totalDistance; // Akumulasi jarak tempuh (meter)
  final double elevationGain; // Akumulasi kenaikan elevasi (meter)
  final Duration duration; // Lama waktu tracking berjalan
  final double accuracy; // Akurasi GPS (dalam radius meter)
  final double heading; // Arah hadap mata angin (0-360 derajat)

  TrackingStats({
    required this.currentLatitude,
    required this.currentLongitude,
    required this.currentAltitude,
    required this.currentSpeed,
    required this.totalDistance,
    required this.elevationGain,
    required this.duration,
    required this.accuracy,
    required this.heading,
  });
}

// -----------------------------------------------------------------------------
// [CLASS TRACKING SERVICE]
// Service Singleton yang mengelola siklus hidup GPS di background.
// -----------------------------------------------------------------------------
class TrackingService {
  static final TrackingService instance = TrackingService._init();
  TrackingService._init();

  StreamSubscription<Position>? _positionStream; // Langganan sinyal GPS
  Timer? _durationTimer; // Timer stopwatch pendakian

  TrackingStatus _status = TrackingStatus.stopped;
  TrackingStatus get status => _status;

  int? _activeSessionId; // ID sesi database yang sedang aktif direkam
  int? get activeSessionId => _activeSessionId;

  DateTime? _startTime;
  Duration _elapsedDuration = Duration.zero;

  double _totalDistanceMeters = 0.0;
  double _elevationGainMeters = 0.0;
  final List<double> _altitudeHistory = []; // Riwayat ketinggian untuk hitung elev gain

  Position? _lastRecordedPosition;
  Position? get lastPosition => _lastRecordedPosition;

  // StreamController untuk komunikasi asinkron antara Service dan Tampilan UI
  final _statsController = StreamController<TrackingStats>.broadcast();
  Stream<TrackingStats> get statsStream => _statsController.stream;

  final _statusController = StreamController<TrackingStatus>.broadcast();
  Stream<TrackingStatus> get statusStream => _statusController.stream;

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 5: PENANGANAN IZIN LOKASI (PERMISSION HANDLING)]
  // Penjelasan: "Aplikasi secara otomatis memeriksa apakah hardware GPS di HP aktif.
  // Jika belum, sistem meminta user menyalakan GPS. Selanjutnya memeriksa izin
  // runtime akses lokasi (ACCESS_FINE_LOCATION) dan background."
  // ---------------------------------------------------------------------------
  Future<bool> checkAndRequestPermissions() async {
    // 1. Cek apakah layanan GPS di HP menyala
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 2. Cek izin akses dari sistem operasi Android
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // Jika user memilih 'Tolak dan jangan tanya lagi'
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 6: BACKGROUND LOCATION & FOREGROUND SERVICE & HEMAT BATERAI]
  // Pertanyaan Dosen: "Bagaimana cara tracking tetap hidup saat layar HP mati tanpa
  // menguras baterai?"
  // Jawaban:
  // 1. Foreground Service: Menampilkan notifikasi persisten di status bar Android
  //    dengan flag 'enableWakeLock: true'. Ini mencegah OS Android 'membunuh' (kill)
  //    proses aplikasi saat layar dimatikan dan dimasukkan ke saku.
  // 2. Optimasi Baterai:
  //    - distanceFilter: 10 (Hanya membaca GPS jika pendaki bergerak minimal 10 meter).
  //    - intervalDuration: 15 detik (GPS tidak polling terus-menerus setiap milidetik,
  //      melainkan berjarak 15 detik untuk menghemat konsumsi daya baterai)."
  // ---------------------------------------------------------------------------
  Future<int?> startTracking({String sessionTitle = 'Pendakian Baru'}) async {
    if (_status == TrackingStatus.tracking) return _activeSessionId;

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    // Reset seluruh variabel kalkulasi sesi sebelumnya
    _totalDistanceMeters = 0.0;
    _elevationGainMeters = 0.0;
    _altitudeHistory.clear();
    _lastRecordedPosition = null;
    _startTime = DateTime.now();
    _elapsedDuration = Duration.zero;

    // Langkah 1: Buat baris sesi baru di SQLite
    _activeSessionId = await TrackingDatabase.instance.createSession(sessionTitle);

    _status = TrackingStatus.tracking;
    _statusController.add(_status);

    // Langkah 2: Mulai timer stopwatch (update per 1 detik)
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == TrackingStatus.tracking) {
        _elapsedDuration = DateTime.now().difference(_startTime!);
        _broadcastCurrentStats();
      }
    });

    // Langkah 3: Konfigurasi pengaturan Android Foreground Service & filter hemat baterai
    late final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high, // Akurasi tinggi berbasis satelit GPS
        distanceFilter: 10, // Minimal perpindahan 10 meter (Hemat Baterai)
        intervalDuration: const Duration(seconds: 15), // Polling interval 15 detik (Hemat Baterai)
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'PuncakKu - Tracking Aktif',
          notificationText: 'Melacak rute pendakian di background (layar mati tetap aktif)',
          enableWakeLock: true, // Layar mati GPS tetap siaga
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    // Langkah 4: Aktifkan listener stream GPS terus-menerus
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onNewPositionReceived);

    return _activeSessionId;
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 7: PEMROSESAN TITIK GPS & PENYIMPANAN OTOMATIS]
  // Penjelasan: "Setiap sinyal koordinat baru diterima dari satelit:
  // 1. Jarak dihitung menggunakan Formula Haversine terhadap titik sebelumnya.
  // 2. Ketinggian dicatat untuk mengakumulasi Elevation Gain.
  // 3. Titik koordinat otomatis di-INSERT ke tabel SQLite."
  // ---------------------------------------------------------------------------
  Future<void> _onNewPositionReceived(Position position) async {
    if (_status != TrackingStatus.tracking || _activeSessionId == null) {
      _lastRecordedPosition = position;
      _broadcastCurrentStats();
      return;
    }

    // Kalkulasi jarak menggunakan rumus matematika Haversine
    if (_lastRecordedPosition != null) {
      final distance = TrackingCalculator.calculateHaversineDistance(
        lat1: _lastRecordedPosition!.latitude,
        lon1: _lastRecordedPosition!.longitude,
        lat2: position.latitude,
        lon2: position.longitude,
      );

      // Hanya tambahkan jika pergeseran >= 3 meter untuk membuang jitter/noise sinyal
      if (distance >= 3.0) {
        _totalDistanceMeters += distance;
      }
    }

    // Kalkulasi akumulasi tanjakan elevasi positif
    _altitudeHistory.add(position.altitude);
    _elevationGainMeters = TrackingCalculator.calculateElevationGain(_altitudeHistory);

    _lastRecordedPosition = position;

    // Simpan koordinat ke database lokal SQLite
    final point = LocationPointModel(
      sessionId: _activeSessionId!,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: DateTime.now(),
    );
    await TrackingDatabase.instance.insertLocationPoint(point);

    // Pancarkan data statistik terbaru ke UI
    _broadcastCurrentStats();
  }

  // Fungsi jeda tracking (misal saat istirahat/makan di pos pendakian)
  void pauseTracking() {
    if (_status == TrackingStatus.tracking) {
      _status = TrackingStatus.paused;
      _statusController.add(_status);
    }
  }

  // Fungsi melanjutkan kembali setelah jeda
  void resumeTracking() {
    if (_status == TrackingStatus.paused) {
      _status = TrackingStatus.tracking;
      _statusController.add(_status);
    }
  }

  // Fungsi menghentikan tracking dan menyimpan rekapan akhir ke database SQLite
  Future<void> stopTracking() async {
    if (_status == TrackingStatus.stopped) return;

    _status = TrackingStatus.stopped;
    _statusController.add(_status);
    _positionStream?.cancel();
    _durationTimer?.cancel();

    if (_activeSessionId != null) {
      await TrackingDatabase.instance.updateSessionStats(
        sessionId: _activeSessionId!,
        totalDistance: _totalDistanceMeters,
        elevationGain: _elevationGainMeters,
        durationSeconds: _elapsedDuration.inSeconds,
        endTime: DateTime.now(),
      );
    }

    _activeSessionId = null;
  }

  // Helper untuk mengirim objek statistik terkini ke Stream
  void _broadcastCurrentStats() {
    if (_lastRecordedPosition == null) return;

    _statsController.add(
      TrackingStats(
        currentLatitude: _lastRecordedPosition!.latitude,
        currentLongitude: _lastRecordedPosition!.longitude,
        currentAltitude: _lastRecordedPosition!.altitude,
        currentSpeed: _lastRecordedPosition!.speed,
        totalDistance: _totalDistanceMeters,
        elevationGain: _elevationGainMeters,
        duration: _elapsedDuration,
        accuracy: _lastRecordedPosition!.accuracy,
        heading: _lastRecordedPosition!.heading,
      ),
    );
  }

  // Bersihkan resource saat service ditutup
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    _statsController.close();
    _statusController.close();
  }
}
