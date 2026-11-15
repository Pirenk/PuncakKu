import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../database/tracking_database.dart';
import '../utils/gps_tracking.dart';
import '../utils/gps_tracking_point.dart';
import '../utils/tracking_calculator.dart';

// =============================================================================
// SERVICE TRACKING GPS & BACKGROUND LOCATION - PUNCAKKU
// =============================================================================

enum TrackingStatus { stopped, tracking, paused }

class TrackingStats {
  final int? idTracking;
  final double currentLatitude;
  final double currentLongitude;
  final double currentAltitude;
  final double currentSpeed;
  final double totalDistanceMeters;
  final double totalDistanceKm;
  final double elevationGain;
  final Duration duration;
  final double accuracy;
  final double heading;
  final int pointsCount;

  TrackingStats({
    this.idTracking,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.currentAltitude,
    required this.currentSpeed,
    required this.totalDistanceMeters,
    required this.totalDistanceKm,
    required this.elevationGain,
    required this.duration,
    required this.accuracy,
    required this.heading,
    this.pointsCount = 0,
  });
}

class TrackingService {
  static final TrackingService instance = TrackingService._init();
  TrackingService._init();

  StreamSubscription<Position>? _positionStream;
  Timer? _durationTimer;

  TrackingStatus _status = TrackingStatus.stopped;
  TrackingStatus get status => _status;

  int? _activeTrackingId;
  int? get activeTrackingId => _activeTrackingId;

  int _currentUserId = 1; // default user
  int? _currentTripId;

  DateTime? _startTime;
  Duration _elapsedDuration = Duration.zero;

  double _totalDistanceMeters = 0.0;
  double _elevationGainMeters = 0.0;
  final List<double> _altitudeHistory = [];
  int _pointsCount = 0;

  Position? _lastRecordedPosition;
  Position? get lastPosition => _lastRecordedPosition;

  final _statsController = StreamController<TrackingStats>.broadcast();
  Stream<TrackingStats> get statsStream => _statsController.stream;

  final _statusController = StreamController<TrackingStatus>.broadcast();
  Stream<TrackingStatus> get statusStream => _statusController.stream;

  // ---------------------------------------------------------------
  // GPS permission handling
  // ---------------------------------------------------------------
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Coba minta aktifkan GPS atau buka settings
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------
  // Start tracking – creates a row in `gps_tracking`
  // ---------------------------------------------------------------
  Future<int?> startTracking({int userId = 1, int? tripId}) async {
    if (_status == TrackingStatus.tracking) return _activeTrackingId;

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      debugPrint('TrackingService: Izin GPS ditolak atau GPS tidak aktif.');
      return null;
    }

    _currentUserId = userId;
    _currentTripId = tripId;
    _totalDistanceMeters = 0.0;
    _elevationGainMeters = 0.0;
    _altitudeHistory.clear();
    _lastRecordedPosition = null;
    _pointsCount = 0;
    _startTime = DateTime.now();
    _elapsedDuration = Duration.zero;

    // Ambil koordinat GPS awal secara langsung agar peta langsung update
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _lastRecordedPosition = initialPosition;
    } catch (e) {
      debugPrint('Catatan awal GPS: $e');
    }

    // Insert summary row using the new GpsTracking model.
    final tracking = GpsTracking(
      idUser: _currentUserId,
      idTrip: _currentTripId,
      tanggalMulai: _startTime!,
    );
    _activeTrackingId = await TrackingDatabase.instance.insertTracking(tracking);

    // Jika koordinat awal sudah didapat, simpan langsung sebagai titik pertama
    if (_lastRecordedPosition != null && _activeTrackingId != null) {
      final firstPoint = GpsTrackingPoint(
        idTracking: _activeTrackingId!,
        latitude: _lastRecordedPosition!.latitude,
        longitude: _lastRecordedPosition!.longitude,
        altitude: _lastRecordedPosition!.altitude,
        accuracy: _lastRecordedPosition!.accuracy,
        speed: _lastRecordedPosition!.speed,
        recordedAt: DateTime.now(),
      );
      await TrackingDatabase.instance.insertTrackingPoint(firstPoint);
      _pointsCount = 1;
      _altitudeHistory.add(_lastRecordedPosition!.altitude);
    }

    _status = TrackingStatus.tracking;
    _statusController.add(_status);
    _broadcastCurrentStats();

    // Stopwatch timer.
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == TrackingStatus.tracking) {
        _elapsedDuration = DateTime.now().difference(_startTime!);
        _broadcastCurrentStats();
      }
    });

    // Location settings
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Catat setiap perubahan lokasi
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'PuncakKu - GPS Tracking Aktif',
          notificationText: 'Merekam rute pendakian ke database PuncakKu',
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    // Start GPS stream.
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _onNewPositionReceived,
      onError: (err) {
        debugPrint('Error pada getPositionStream: $err');
      },
    );

    return _activeTrackingId;
  }

  // ---------------------------------------------------------------
  // Handle new GPS positions – inserts into `gps_tracking_points`
  // ---------------------------------------------------------------
  Future<void> _onNewPositionReceived(Position position) async {
    if (_status != TrackingStatus.tracking || _activeTrackingId == null) {
      _lastRecordedPosition = position;
      _broadcastCurrentStats();
      return;
    }

    // Distance calculation.
    if (_lastRecordedPosition != null) {
      final distance = TrackingCalculator.calculateHaversineDistance(
        lat1: _lastRecordedPosition!.latitude,
        lon1: _lastRecordedPosition!.longitude,
        lat2: position.latitude,
        lon2: position.longitude,
      );
      if (distance >= 3.0) _totalDistanceMeters += distance;
    }

    // Elevation gain.
    _altitudeHistory.add(position.altitude);
    _elevationGainMeters = TrackingCalculator.calculateElevationGain(_altitudeHistory);

    _lastRecordedPosition = position;
    _pointsCount++;

    final point = GpsTrackingPoint(
      idTracking: _activeTrackingId!,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      recordedAt: DateTime.now(),
    );
    await TrackingDatabase.instance.insertTrackingPoint(point);

    _broadcastCurrentStats();
  }

  // ---------------------------------------------------------------
  // Pause, resume, and stop tracking – update `gps_tracking` status.
  // ---------------------------------------------------------------
  Future<void> pauseTracking() async {
    if (_status == TrackingStatus.tracking) {
      _status = TrackingStatus.paused;
      _statusController.add(_status);
      if (_activeTrackingId != null) {
        await TrackingDatabase.instance.updateTrackingStatus(
          idTracking: _activeTrackingId!,
          status: 'dijeda',
        );
      }
    }
  }

  Future<void> resumeTracking() async {
    if (_status == TrackingStatus.paused) {
      _status = TrackingStatus.tracking;
      _statusController.add(_status);
      if (_activeTrackingId != null) {
        await TrackingDatabase.instance.updateTrackingStatus(
          idTracking: _activeTrackingId!,
          status: 'berlangsung',
        );
      }
    }
  }

  Future<void> stopTracking() async {
    if (_status == TrackingStatus.stopped) return;
    _status = TrackingStatus.stopped;
    _statusController.add(_status);
    _positionStream?.cancel();
    _durationTimer?.cancel();

    if (_activeTrackingId != null) {
      final totalKm = _totalDistanceMeters / 1000.0;
      await TrackingDatabase.instance.finishTracking(
        idTracking: _activeTrackingId!,
        totalJarakKm: totalKm,
        durasiDetik: _elapsedDuration.inSeconds,
        tanggalSelesai: DateTime.now(),
      );
    }
    _activeTrackingId = null;
  }

  // ---------------------------------------------------------------
  // Broadcast stats to UI.
  // ---------------------------------------------------------------
  void _broadcastCurrentStats() {
    if (_lastRecordedPosition == null) return;
    _statsController.add(
      TrackingStats(
        idTracking: _activeTrackingId,
        currentLatitude: _lastRecordedPosition!.latitude,
        currentLongitude: _lastRecordedPosition!.longitude,
        currentAltitude: _lastRecordedPosition!.altitude,
        currentSpeed: _lastRecordedPosition!.speed,
        totalDistanceMeters: _totalDistanceMeters,
        totalDistanceKm: _totalDistanceMeters / 1000.0,
        elevationGain: _elevationGainMeters,
        duration: _elapsedDuration,
        accuracy: _lastRecordedPosition!.accuracy,
        heading: _lastRecordedPosition!.heading,
        pointsCount: _pointsCount,
      ),
    );
  }

  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    _statsController.close();
    _statusController.close();
  }
}
