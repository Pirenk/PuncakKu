import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/tracking_service.dart';
import '../utils/tracking_calculator.dart';
import 'tracking_history_screen.dart';

// =============================================================================
// LAYAR UTAMA: GPS TRACKING LIVE & OPENSTREETMAP (PUNCAKKU)
// =============================================================================
// File ini menghubungkan:
// 1. Peta OpenStreetMap (Standard OSM, Kontur Topografi, dan Satelit Esri)
// 2. TrackingService (Listener sinyal GPS background secara reaktif)
// 3. Persistensi ke tabel `gps_tracking` dan `gps_tracking_points`
// =============================================================================

enum MapLayerType { openStreetMap, topoMap, satellite }

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  final MapController _mapController = MapController();
  final TrackingService _trackingService = TrackingService.instance;

  StreamSubscription<TrackingStats>? _statsSubscription;
  StreamSubscription<TrackingStatus>? _statusSubscription;

  // Koordinat default Gunung Slamet / Jawa Tengah (sesuai data dump)
  static const LatLng _initialPosition = LatLng(-7.2425, 109.2083);

  LatLng? _currentLatLng;
  final List<LatLng> _routeCoordinates = [];

  TrackingStatus _currentStatus = TrackingStatus.stopped;
  TrackingStats? _latestStats;

  bool _autoFollowUser = true;
  MapLayerType _selectedLayer = MapLayerType.openStreetMap;

  final Color _primaryColor = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    _listenToTrackingService();
    _checkPermissionAndInitLocation();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  // Permintaan izin lokasi & pemusatan peta ke koordinat awal HP
  Future<void> _checkPermissionAndInitLocation() async {
    final granted = await _trackingService.checkAndRequestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin GPS diperlukan untuk membaca posisi Anda di peta.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _currentLatLng = userLatLng;
        });
        _mapController.move(userLatLng, 16.5);
      }
    } catch (e) {
      debugPrint('Info deteksi lokasi awal: $e');
    }
  }

  // Stream listener dari TrackingService
  void _listenToTrackingService() {
    _statusSubscription = _trackingService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });

    _statsSubscription = _trackingService.statsStream.listen((stats) {
      final newLatLng = LatLng(stats.currentLatitude, stats.currentLongitude);

      if (mounted) {
        setState(() {
          _latestStats = stats;
          _currentLatLng = newLatLng;

          // Tambahkan koordinat ke garis rute jika tracking aktif
          if (_currentStatus == TrackingStatus.tracking) {
            if (_routeCoordinates.isEmpty ||
                _routeCoordinates.last.latitude != newLatLng.latitude ||
                _routeCoordinates.last.longitude != newLatLng.longitude) {
              _routeCoordinates.add(newLatLng);
            }
          }
        });

        if (_autoFollowUser) {
          _mapController.move(newLatLng, _mapController.camera.zoom);
        }
      }
    });
  }

  // Mulai sesi tracking baru (Insert ke tabel gps_tracking)
  Future<void> _startOrResumeTracking() async {
    if (_currentStatus == TrackingStatus.stopped) {
      _routeCoordinates.clear();
      // Mulai tracking untuk user ID 1 (default user Mirza dari database)
      final id = await _trackingService.startTracking(userId: 1);
      if (id != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracking #$id dimulai. Titik GPS direkam ke database.'),
            backgroundColor: _primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memulai tracking. Pastikan izin lokasi diberikan dan GPS aktif.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (_currentStatus == TrackingStatus.paused) {
      await _trackingService.resumeTracking();
    }
  }

  // Jeda tracking (Status menjadi 'dijeda' di database)
  Future<void> _pauseTracking() async {
    await _trackingService.pauseTracking();
  }

  // Selesaikan tracking (Update jarak, durasi, dan status 'selesai' di database)
  Future<void> _stopAndSaveTracking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Tracking?'),
        content: const Text(
          'Aktivitas tracking akan diakhiri dan seluruh ringkasan serta titik koordinat akan disimpan ke tabel gps_tracking & gps_tracking_points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan & Selesai'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _trackingService.stopTracking();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perjalanan berhasil disimpan ke tabel gps_tracking & gps_tracking_points!'),
            backgroundColor: const Color(0xFF1B4D3E),
            action: SnackBarAction(
              label: 'Lihat Riwayat',
              textColor: Colors.amberAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrackingHistoryScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  // Memusatkan kamera kembali ke pengguna (Re-center)
  Future<void> _recenterToCurrentLocation() async {
    setState(() {
      _autoFollowUser = true;
    });

    if (_currentLatLng != null) {
      _mapController.move(_currentLatLng!, 17.0);
    } else {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final latLng = LatLng(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _currentLatLng = latLng;
          });
          _mapController.move(latLng, 17.0);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membaca sinyal GPS: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // URL penyedia ubin peta OpenStreetMap
  String _getTileUrl() {
    switch (_selectedLayer) {
      case MapLayerType.topoMap:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayerType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.openStreetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = _currentStatus == TrackingStatus.tracking;
    final isPaused = _currentStatus == TrackingStatus.paused;

    return Scaffold(
      body: Stack(
        children: [
          // 1. PETA INTERAKTIF OPENSTREETMAP (FLUTTER_MAP)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 15.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && _autoFollowUser) {
                  setState(() {
                    _autoFollowUser = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                userAgentPackageName: 'com.example.mobile_pendakian',
              ),
              // Garis rute polyline dari titik-titik gps_tracking_points
              if (_routeCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeCoordinates,
                      strokeWidth: 5.0,
                      color: _primaryColor,
                    ),
                  ],
                ),
              // Marker posisi awal & posisi saat ini
              MarkerLayer(
                markers: [
                  if (_routeCoordinates.isNotEmpty)
                    Marker(
                      point: _routeCoordinates.first,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.green,
                        size: 36,
                      ),
                    ),
                  if (_currentLatLng != null)
                    Marker(
                      point: _currentLatLng!,
                      width: 50,
                      height: 50,
                      child: _buildUserLocationMarker(),
                    ),
                ],
              ),
            ],
          ),

          // 2. HEADER ATAS: TOMBOL KEMBALI, STATUS GPS, RIWAYAT, & GANTI LAYER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Tombol Kembali ke Beranda
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF182A22)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status GPS Bar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTracking
                                ? Icons.sync_rounded
                                : (isPaused ? Icons.pause_circle_outline : Icons.satellite_alt_rounded),
                            size: 16,
                            color: isTracking ? Colors.green : (isPaused ? Colors.orange : _primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTracking
                                  ? 'Tracking Aktif'
                                  : (_currentLatLng != null ? 'GPS Terhubung' : 'Mencari GPS...'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF182A22),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tombol Riwayat Tracking
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.history_rounded, color: _primaryColor),
                      tooltip: 'Lihat Riwayat Tracking',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Dropdown Pemilihan Jenis Layer Peta
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<MapLayerType>(
                      icon: Icon(Icons.layers_rounded, color: _primaryColor),
                      onSelected: (MapLayerType type) {
                        setState(() {
                          _selectedLayer = type;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: MapLayerType.openStreetMap,
                          child: Text('Peta Jalan (OpenStreetMap)'),
                        ),
                        const PopupMenuItem(
                          value: MapLayerType.topoMap,
                          child: Text('Kontur Topografi (Gunung)'),
                        ),
                        const PopupMenuItem(
                          value: MapLayerType.satellite,
                          child: Text('Citra Satelit (Esri)'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. FLOATING ACTION BUTTON: PUSATKAN POSISI GPS
          Positioned(
            right: 16,
            bottom: 275,
            child: FloatingActionButton(
              heroTag: 'recenter_gps_tracking',
              backgroundColor: _autoFollowUser ? _primaryColor : Colors.white,
              foregroundColor: _autoFollowUser ? Colors.white : _primaryColor,
              elevation: 4,
              onPressed: _recenterToCurrentLocation,
              tooltip: 'Pusatkan Posisi GPS',
              child: Icon(
                _autoFollowUser ? Icons.my_location : Icons.location_searching,
                size: 24,
              ),
            ),
          ),

          // 4. BOTTOM DASHBOARD: STATISTIK REAL-TIME & KONTROL TRACKING
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status & Durasi Stopwatch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isTracking
                                  ? Colors.green
                                  : (isPaused ? Colors.orange : Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTracking
                                ? 'SEDANG MELACAK'
                                : (isPaused ? 'DIJEDA' : 'STANDBY'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isTracking
                                  ? Colors.green
                                  : (isPaused ? Colors.orange : Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _latestStats != null
                            ? TrackingCalculator.formatDuration(_latestStats!.duration)
                            : '00:00:00',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),

                  // 4 Metrik Statistik Utama: Jarak (Haversine), Elevasi, Gain, Kecepatan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.straighten_rounded,
                        label: 'Jarak Tempuh',
                        value: _latestStats != null
                            ? TrackingCalculator.formatDistance(_latestStats!.totalDistanceMeters)
                            : '0 m',
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      _buildStatItem(
                        icon: Icons.height_rounded,
                        label: 'Ketinggian',
                        value: _latestStats != null
                            ? '${_latestStats!.currentAltitude.toStringAsFixed(0)} mdpl'
                            : '- mdpl',
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      _buildStatItem(
                        icon: Icons.trending_up_rounded,
                        label: 'Elev Gain',
                        value: _latestStats != null
                            ? '+${_latestStats!.elevationGain.toStringAsFixed(0)}m'
                            : '+0m',
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      _buildStatItem(
                        icon: Icons.speed_rounded,
                        label: 'Kecepatan',
                        value: _latestStats != null
                            ? '${(_latestStats!.currentSpeed * 3.6).toStringAsFixed(1)} km/j'
                            : '0 km/j',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Kontrol: Mulai / Jeda / Lanjut / Selesai
                  if (_currentStatus == TrackingStatus.stopped)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'Mulai Tracking Pendakian',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _startOrResumeTracking,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isTracking ? Colors.orange : _primaryColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: Icon(
                                isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isTracking ? Colors.orange : _primaryColor,
                              ),
                              label: Text(
                                isTracking ? 'Jeda' : 'Lanjutkan',
                                style: TextStyle(
                                  color: isTracking ? Colors.orange : _primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: isTracking ? _pauseTracking : _startOrResumeTracking,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text(
                                'Selesai',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: _stopAndSaveTracking,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan marker lokasi pengguna dengan titik dan cincin berdenyut
  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryColor.withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  // Widget kolom metrik ringkas
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _primaryColor),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF182A22),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
