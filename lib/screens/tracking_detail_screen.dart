import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/tracking_database.dart';
import '../utils/gps_tracking.dart';
import '../utils/gps_tracking_point.dart';
import '../utils/tracking_calculator.dart';

// =============================================================================
// LAYAR DETAIL RIWAYAT TRACKING GPS
// =============================================================================
// Menampilkan kembali perjalanan tracking yang sudah tersimpan:
// - Mengambil ringkasan dari tabel `gps_tracking`
// - Mengambil seluruh titik koordinat dari tabel `gps_tracking_points`
// - Menggambar rute perjalanan (Polyline) pada peta OpenStreetMap
// =============================================================================

class TrackingDetailScreen extends StatefulWidget {
  final GpsTracking tracking;

  const TrackingDetailScreen({
    super.key,
    required this.tracking,
  });

  @override
  State<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends State<TrackingDetailScreen> {
  final MapController _mapController = MapController();
  List<GpsTrackingPoint> _points = [];
  List<LatLng> _latLngList = [];
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    if (widget.tracking.idTracking == null) return;

    final points = await TrackingDatabase.instance.getPointsByTrackingId(
      widget.tracking.idTracking!,
    );

    if (mounted) {
      setState(() {
        _points = points;
        _latLngList = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        _isLoading = false;
      });

      // Posisikan kamera di titik awal jika ada koordinat
      if (_latLngList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_latLngList.first, 15.5);
        });
      }
    }
  }

  void _fitRouteBounds() {
    if (_latLngList.isEmpty) return;

    if (_latLngList.length == 1) {
      _mapController.move(_latLngList.first, 16.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(_latLngList);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = widget.tracking;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking #${tracking.idTracking ?? 1}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map_rounded),
            tooltip: 'Fokuskan Seluruh Rute',
            onPressed: _fitRouteBounds,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. Peta OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _latLngList.isNotEmpty
                        ? _latLngList.first
                        : const LatLng(-7.1234, 110.1234),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mobile_pendakian',
                    ),
                    if (_latLngList.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _latLngList,
                            strokeWidth: 5.0,
                            color: const Color(0xFF1B4D3E),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_latLngList.isNotEmpty)
                          Marker(
                            point: _latLngList.first,
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.green,
                              size: 36,
                            ),
                          ),
                        if (_latLngList.length > 1)
                          Marker(
                            point: _latLngList.last,
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // 2. Panel Ringkasan Tracking
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tracking.status == 'selesai'
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tracking.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: tracking.status == 'selesai'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ID User: ${tracking.idUser}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_points.length} Titik Koordinat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCol(
                              icon: Icons.straighten_rounded,
                              label: 'Total Jarak',
                              value: tracking.formattedJarak,
                            ),
                            Container(width: 1, height: 32, color: Colors.grey.shade200),
                            _buildInfoCol(
                              icon: Icons.timer_outlined,
                              label: 'Durasi',
                              value: tracking.formattedDurasi,
                            ),
                            Container(width: 1, height: 32, color: Colors.grey.shade200),
                            _buildInfoCol(
                              icon: Icons.calendar_today_rounded,
                              label: 'Waktu Mulai',
                              value: TrackingCalculator.formatDateTime(tracking.tanggalMulai),
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

  Widget _buildInfoCol({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: _primaryColor),
        const SizedBox(height: 4),
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
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}