import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'database/tracking_database.dart';
import 'services/tracking_service.dart';
import 'utils/tracking_calculator.dart';

// =============================================================================
// APLIKASI PUNCAKKU - MODUL GPS LIVE TRACKING & PENDAKIAN GUNUNG
// =============================================================================
// File ini adalah User Interface (UI) utama dari bagian proyek:
// 1. Peta Interaktif (OpenStreetMap / Topografi Gunung) tanpa batas API Key.
// 2. Tombol Bidikan GPS (Menampilkan & Mengunci posisi HP secara Real-time).
// 3. Garis Rute Jejak Langkah Kaki (Polyline Layer).
// 4. Panel Dashboard Statistik (Durasi, Jarak Haversine, Elevasi mdpl, Elev Gain).
// 5. Riwayat Pendakian yang tersimpan dalam Database Lokal SQLite.
// =============================================================================

void main() {
  // Memastikan framework binding Flutter siap sebelum inisialisasi plugin/database
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// [ROOT WIDGET: MYAPP]
// Mengatur tema visual global aplikasi (Forest Green #1B4D3E yang khas alam bebas).
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4D3E); // Warna hijau hutan (Tema Pendakian)

    return MaterialApp(
      title: 'PuncakKu - Tracking Pendakian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// [MAIN NAVIGATION SCREEN]
// Menyediakan struktur navigasi 5 menu tab utama aplikasi PuncakKu.
// -----------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Index 1 disetel sebagai default agar fitur Tracking GPS langsung tampil saat aplikasi dibuka
  int _currentIndex = 1;

  final Color _primaryDark = const Color(0xFF1B4D3E);

  // Widget pembantu untuk tab yang masih dikerjakan oleh anggota tim lain
  Widget _buildPlaceholder(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: _primaryDark.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Halaman $title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bagian anggota tim lain dari project PuncakKu.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman pada aplikasi:
    // Tab 1 (Index 1) adalah fitur utama GPS Tracking yang dipresentasikan
    final List<Widget> pages = [
      _buildPlaceholder('Beranda', Icons.home_outlined),
      const HikingTrackingScreen(), // <-- FITUR UTAMA ANDA: GPS TRACKING
      _buildPlaceholder('Gunung', Icons.landscape_outlined),
      _buildPlaceholder('Komunitas', Icons.groups_outlined),
      _buildPlaceholder('Profil', Icons.person_outline),
    ];

    return Scaffold(
      // IndexedStack menjaga state peta tidak ter-reset saat pengguna berpindah tab
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Beranda'),
                _buildNavItem(1, Icons.navigation_rounded, 'Tracking GPS'),
                _buildNavItem(2, Icons.landscape_outlined, 'Gunung'),
                _buildNavItem(3, Icons.groups_outlined, 'Komunitas'),
                _buildNavItem(4, Icons.person_outline, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tombol navigasi bawah kustom dengan animasi garis indikator aktif
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? _primaryDark : Colors.grey.shade600,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _primaryDark : Colors.grey.shade600,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 16,
                decoration: BoxDecoration(
                  color: _primaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// [POIN PRESENTASI 8: ARSITEKTUR LAYAR UTAMA HIKING TRACKING SCREEN]
// Penjelasan: "Layar ini menggabungkan 3 komponen utama:
// 1. FlutterMap (Peta OpenStreetMap tanpa batasan API Key)
// 2. TrackingService (Listener sinyal GPS background secara reaktif)
// 3. Panel Kontrol dan Statistik (Kalkulasi metrik & penyimpanan SQLite)"
// =============================================================================

// Pilihan jenis layer peta (OpenStreetMap, Topografi Gunung, Citra Satelit)
enum MapLayerType { openStreetMap, topoMap, satellite }

class HikingTrackingScreen extends StatefulWidget {
  const HikingTrackingScreen({super.key});

  @override
  State<HikingTrackingScreen> createState() => _HikingTrackingScreenState();
}

class _HikingTrackingScreenState extends State<HikingTrackingScreen> {
  // Controller untuk menggerakkan peta (zoom, panning, re-center) secara programatik
  final MapController _mapController = MapController();

  // Akses ke instance tunggal (Singleton) Service Pelacakan
  final TrackingService _trackingService = TrackingService.instance;

  // Langganan stream data statistik dan status tracking
  StreamSubscription<TrackingStats>? _statsSubscription;
  StreamSubscription<TrackingStatus>? _statusSubscription;

  // Koordinat titik default (Gn. Semeru / Ranu Kumbolo) sebelum sinyal GPS HP tertangkap
  static const LatLng _initialPosition = LatLng(-8.1077, 112.9225);

  LatLng? _currentLatLng; // Titik koordinat terkini HP pengguna
  final List<LatLng> _routeCoordinates = []; // Deretan koordinat untuk digambar menjadi Polyline

  TrackingStatus _currentStatus = TrackingStatus.stopped;
  TrackingStats? _latestStats;

  // Flag apakah kamera peta harus terus otomatis mengikuti pergerakan pengguna
  bool _autoFollowUser = true;

  // Layer peta yang sedang aktif (default: Peta Jalan / OSM)
  MapLayerType _selectedLayer = MapLayerType.openStreetMap;

  @override
  void initState() {
    super.initState();
    _listenToTrackingService(); // Hubungkan listener ke Service
    _checkPermissionAndInit(); // Ambil posisi GPS pertama kali saat layar dibuka
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 9: DETEKSI LOKASI INSTAN SAAT APLIKASI PERTAMA DIBUKA]
  // Penjelasan: "Begitu user membuka tab ini, sistem langsung meminta izin lokasi
  // dan secara otomatis menggeser peta ke posisi GPS pengguna secara instan."
  // ---------------------------------------------------------------------------
  Future<void> _checkPermissionAndInit() async {
    final granted = await _trackingService.checkAndRequestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin GPS diperlukan untuk menampilkan posisi Anda di peta.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Dapatkan posisi GPS tercepat dari hardware smartphone
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _currentLatLng = userLatLng;
        });

        // Geser kamera peta langsung ke lokasi pengguna (Zoom level 17)
        _mapController.move(userLatLng, 17.0);
      }
    } catch (e) {
      debugPrint('Error mendapatkan posisi awal: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 10: PEMBARUAN DATA REAKTIF DENGAN DART STREAM]
  // Penjelasan: "Kami menggunakan pola Reaktif. Setiap kali Background Service
  // memancarkan koordinat baru, UI otomatis menerima pembaruan tanpa perlu polling manual."
  // ---------------------------------------------------------------------------
  void _listenToTrackingService() {
    // 1. Dengarkan perubahan status (Stopped -> Tracking -> Paused)
    _statusSubscription = _trackingService.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
      });
    });

    // 2. Dengarkan data statistik GPS (Koordinat, Jarak Haversine, Elevasi, Kecepatan)
    _statsSubscription = _trackingService.statsStream.listen((stats) {
      final newLatLng = LatLng(stats.currentLatitude, stats.currentLongitude);

      setState(() {
        _latestStats = stats;
        _currentLatLng = newLatLng;

        // Jika tombol 'Mulai Tracking' sedang aktif, tambahkan titik ke rute garis (Polyline)
        if (_currentStatus == TrackingStatus.tracking) {
          if (_routeCoordinates.isEmpty ||
              _routeCoordinates.last.latitude != newLatLng.latitude ||
              _routeCoordinates.last.longitude != newLatLng.longitude) {
            _routeCoordinates.add(newLatLng);
          }
        }
      });

      // Fitur Auto-Follow: Kamera peta otomatis mengikuti pergerakan pendaki
      if (_autoFollowUser) {
        _mapController.move(newLatLng, _mapController.camera.zoom);
      }
    });
  }

  // Memulai sesi tracking baru atau melanjutkan setelah jeda
  Future<void> _startOrResumeTracking() async {
    if (_currentStatus == TrackingStatus.stopped) {
      _routeCoordinates.clear(); // Bersihkan jejak sebelumnya
      await _trackingService.startTracking(
        sessionTitle: 'Pendakian ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );
    } else if (_currentStatus == TrackingStatus.paused) {
      _trackingService.resumeTracking();
    }
  }

  // Menjeda perekaman sementara
  void _pauseTracking() {
    _trackingService.pauseTracking();
  }

  // Menghentikan tracking dan menampilkan dialog konfirmasi penyimpanan ke SQLite
  Future<void> _stopAndSaveTracking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pendakian?'),
        content: const Text(
          'Tracking akan dihentikan dan seluruh rute beserta statistik akan disimpan ke database lokal SQLite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _trackingService.stopTracking();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rute pendakian berhasil disimpan ke database lokal SQLite!'),
            backgroundColor: Color(0xFF1B4D3E),
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 11: TOMBOL BIDIKAN GPS (RE-CENTER / AUTO-FOLLOW)]
  // Penjelasan: "Fungsi ini dipicu saat pengguna mengeklik tombol bulat floating GPS.
  // Kamera langsung memusatkan peta ke sinyal HP saat ini dan mengaktifkan Auto-Follow."
  // ---------------------------------------------------------------------------
  Future<void> _recenterToCurrentLocation() async {
    setState(() {
      _autoFollowUser = true; // Kunci kamera kembali ke HP
    });

    if (_currentLatLng != null) {
      _mapController.move(_currentLatLng!, 17.5);
    } else {
      // Jika GPS belum siap, minta paksa koordinat baru secara langsung
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final latLng = LatLng(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _currentLatLng = latLng;
          });
          _mapController.move(latLng, 17.5);
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

  // URL penyedia ubin peta gratis (Tile Provider) tanpa memerlukan pendaftaran API Key
  String _getTileUrl() {
    switch (_selectedLayer) {
      case MapLayerType.topoMap:
        // Kontur topografi gunung OpenTopoMap (Sangat cocok untuk melihat lereng/ketinggian gunung)
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayerType.satellite:
        // Citra Satelit Esri World Imagery (Foto udara resolusi tinggi gratis)
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.openStreetMap:
        // Peta Jalan Standard OpenStreetMap
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  // ---------------------------------------------------------------------------
  // [POIN PRESENTASI 12: MODAL RIWAYAT DATABASE LOKAL SQLITE]
  // Penjelasan: "Menampilkan BottomSheet yang menarik seluruh data sesi pendakian
  // langsung dari memori database lokal HP (SQLite), lengkap dengan jarak dan durasi."
  // ---------------------------------------------------------------------------
  Future<void> _showHistoryBottomSheet() async {
    final sessions = await TrackingDatabase.instance.getAllSessions();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar abu-abu penarik modal
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Database SQLite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      Text(
                        '${sessions.length} Sesi Tersimpan',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada riwayat pendakian yang tersimpan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = sessions[index];
                            final duration = Duration(seconds: item.durationSeconds);

                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F0EC),
                                child: Icon(Icons.terrain, color: Color(0xFF1B4D3E)),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Jarak: ${TrackingCalculator.formatDistance(item.totalDistance)} • Gain: +${item.elevationGain.toStringAsFixed(0)}m\nDurasi: ${TrackingCalculator.formatDuration(duration)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  if (item.id != null) {
                                    await TrackingDatabase.instance.deleteSession(item.id!);
                                    Navigator.pop(context);
                                    _showHistoryBottomSheet(); // Refresh daftar riwayat
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STRUKTUR WIDGET BUILD (HIERARKI TAMPILAN)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4D3E);
    final isTracking = _currentStatus == TrackingStatus.tracking;
    final isPaused = _currentStatus == TrackingStatus.paused;

    return Scaffold(
      body: Stack(
        children: [
          // ===================================================================
          // 1. TAMPILAN PETA INTERAKTIF FLUTTERMAP
          // ===================================================================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 16.0,
              // Jika user menyentuh dan menggeser layar peta secara sengaja,
              // matikan auto-follow sementara agar tidak melawan navigasi tangan pengguna
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && _autoFollowUser) {
                  setState(() {
                    _autoFollowUser = false;
                  });
                }
              },
            ),
            children: [
              // Layer 1: Tile Layer Peta (Tanpa API Key)
              TileLayer(
                urlTemplate: _getTileUrl(),
                userAgentPackageName: 'com.example.mobile_pendakian',
              ),

              // Layer 2: Rute Garis Jejak Pendakian (Polyline Layer)
              if (_routeCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeCoordinates,
                      strokeWidth: 5.0,
                      color: const Color(0xFF1B4D3E),
                    ),
                  ],
                ),

              // Layer 3: Marker Titik Start & Posisi Realtime Pengguna
              MarkerLayer(
                markers: [
                  // Marker Titik Awal Mulai Pendakian (Bendera Hijau)
                  if (_routeCoordinates.isNotEmpty)
                    Marker(
                      point: _routeCoordinates.first,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.green,
                        size: 36,
                      ),
                    ),

                  // Marker Posisi Terkini Pengguna (Blue Dot Berdenyut)
                  if (_currentLatLng != null)
                    Marker(
                      point: _currentLatLng!,
                      width: 60,
                      height: 60,
                      child: _buildUserLocationMarker(),
                    ),
                ],
              ),
            ],
          ),

          // ===================================================================
          // 2. HEADER ATAS: Status Koneksi GPS, Riwayat SQLite & Switcher Layer
          // ===================================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Badge Indikator Status GPS / Background Service
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
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
                            color: isTracking ? Colors.green : (isPaused ? Colors.orange : primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTracking
                                  ? 'Background GPS Aktif'
                                  : (_currentLatLng != null ? 'Sinyal GPS Terkoneksi' : 'Mencari Sinyal GPS...'),
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

                  // Tombol Membuka Daftar Riwayat SQLite
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.history_rounded, color: primaryColor),
                      tooltip: 'Riwayat Pendakian SQLite',
                      onPressed: _showHistoryBottomSheet,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Menu Dropdown Pilihan Layer (Standard, Topografi, Satelit)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<MapLayerType>(
                      icon: const Icon(Icons.layers_rounded, color: primaryColor),
                      onSelected: (MapLayerType type) {
                        setState(() {
                          _selectedLayer = type;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: MapLayerType.openStreetMap,
                          child: Text('Peta Jalan (Standard)'),
                        ),
                        const PopupMenuItem(
                          value: MapLayerType.topoMap,
                          child: Text('Kontur Gunung (Topografi)'),
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

          // ===================================================================
          // 3. FLOATING ACTION BUTTON: KLIK UNTUK MUNCULKAN & PUSATKAN POSISI HP
          // ===================================================================
          Positioned(
            right: 16,
            bottom: 245,
            child: FloatingActionButton(
              heroTag: 'recenter_gps_button',
              backgroundColor: _autoFollowUser ? primaryColor : Colors.white,
              foregroundColor: _autoFollowUser ? Colors.white : primaryColor,
              elevation: 5,
              onPressed: _recenterToCurrentLocation,
              tooltip: 'Klik untuk memusatkan posisi Anda saat ini',
              child: Icon(
                _autoFollowUser ? Icons.my_location : Icons.location_searching,
                size: 26,
              ),
            ),
          ),

          // ===================================================================
          // 4. BOTTOM DASHBOARD: STATISTIK REALTIME & KONTROL TRACKING
          // ===================================================================
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
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
                  // Header Status Tracking & Stopwatch Durasi
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
                      // Teks Durasi Waktu Format HH:MM:SS
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

                  // Baris 4 Metrik Utama: Jarak (Haversine), Elevasi, Elev Gain, Kecepatan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.straighten_rounded,
                        label: 'Jarak (Haversine)',
                        value: _latestStats != null
                            ? TrackingCalculator.formatDistance(_latestStats!.totalDistance)
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
                        label: 'Elev. Gain',
                        value: _latestStats != null
                            ? '+${_latestStats!.elevationGain.toStringAsFixed(0)} m'
                            : '+0 m',
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      _buildStatItem(
                        icon: Icons.speed_rounded,
                        label: 'Kecepatan',
                        value: _latestStats != null
                            ? TrackingCalculator.formatSpeed(_latestStats!.currentSpeed)
                            : '0.0 km/j',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Aksi: Mulai, Jeda, Lanjutkan, Selesai (Simpan ke SQLite)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startOrResumeTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTracking ? Colors.orange.shade800 : primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(
                            isTracking
                                ? Icons.pause_rounded
                                : (isPaused ? Icons.play_arrow_rounded : Icons.play_arrow_rounded),
                          ),
                          label: Text(
                            isTracking
                                ? 'Jeda'
                                : (isPaused ? 'Lanjutkan' : 'Mulai Tracking Pendakian'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Tombol Stop (Hanya muncul jika sedang aktif tracking atau jeda)
                      if (isTracking || isPaused) ...[
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: _stopAndSaveTracking,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                          ),
                          icon: const Icon(Icons.stop_rounded),
                          tooltip: 'Selesaikan & Simpan ke SQLite',
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // HELPER VISUAL: TITIK BIRU POSISI GPS (BLUE DOT & ACCURACY CIRCLE)
  // Menampilkan pin lokasi modern layaknya Google Maps asli
  // ---------------------------------------------------------------------------
  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran transparan luar (Pulsing Radius Efek Akurasi)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withValues(alpha: 0.22),
          ),
        ),
        // Lingkaran putih pembatas kontras
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
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Titik biru solid di tengah
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  // Helper tampilan item metrik individual di dalam dashboard
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF182A22),
          ),
        ),
      ],
    );
  }
}
