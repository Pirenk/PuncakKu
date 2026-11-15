import 'package:flutter/material.dart';
import '../database/tracking_database.dart';
import '../services/api_service.dart';
import '../utils/gps_tracking.dart';
import '../utils/tracking_calculator.dart';
import 'tracking_detail_screen.dart';

// =============================================================================
// LAYAR RIWAYAT TRACKING GPS - PUNCAKKU
// =============================================================================
// Menampilkan daftar riwayat tracking murni dari database (tabel `gps_tracking`).
// Tidak menggunakan data dummy. Jika belum ada perjalanan, riwayat kosong.
// =============================================================================

class TrackingHistoryScreen extends StatefulWidget {
  const TrackingHistoryScreen({super.key});

  @override
  State<TrackingHistoryScreen> createState() => _TrackingHistoryScreenState();
}

class _TrackingHistoryScreenState extends State<TrackingHistoryScreen> {
  List<GpsTracking> _trackings = [];
  bool _isLoading = true;
  final Color _primaryColor = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await TrackingDatabase.instance.getAllTracking();
      if (mounted) {
        setState(() {
          _trackings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error mengambil riwayat tracking: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTracking(int idTracking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat Tracking?'),
        content: const Text(
          'Seluruh titik koordinat rute yang terkait dengan tracking ini akan ikut terhapus dari database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TrackingDatabase.instance.deleteTracking(idTracking);
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat tracking berhasil dihapus.'),
            backgroundColor: Color(0xFF1B4D3E),
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Semua Riwayat?'),
        content: const Text(
          'Semua data tracking di perangkat akan dihapus bersih (reset). Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TrackingDatabase.instance.clearAllData();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seluruh riwayat tracking telah dikosongkan.'),
            backgroundColor: Color(0xFF1B4D3E),
          ),
        );
      }
    }
  }

  // Dialog Ubah IP Laptop / Server
  Future<void> _showIpSettingsDialog() async {
    final controller = TextEditingController(text: ApiService.instance.baseUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan IP Server Laragon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alamat IP laptop Anda yang terhubung satu Wi-Fi dengan HP:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL API Backend',
                hintText: 'http://192.168.43.76/puncakku_api',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'IP Laptop saat ini: 192.168.43.76',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan & Tes'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl.isNotEmpty) {
      ApiService.instance.baseUrl = newUrl;
      _syncToMysql();
    }
  }

  // Sinkronkan data lokal ke MySQL Laragon
  Future<void> _syncToMysql() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menghubungkan ke ${ApiService.instance.baseUrl}...'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    final connResult = await ApiService.instance.testConnection();
    final bool isConnected = connResult['success'] == true;

    if (!isConnected) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Koneksi ke Laragon Gagal'),
            content: Text(
              'Aplikasi tidak dapat menghubungi: ${ApiService.instance.baseUrl}\n\n'
              'Penyebab umum:\n'
              '1. Apache di Laragon belum di-"Start All".\n'
              '2. HP dan Laptop belum berada di satu jaringan Wi-Fi / Hotspot yang sama.\n'
              '3. Alamat IP laptop telah berubah.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                  _showIpSettingsDialog();
                },
                child: const Text('Ubah IP Laptop'),
              ),
            ],
          ),
        );
      }
      return;
    }

    int syncedCount = 0;
    String lastMessage = '';
    for (final item in _trackings) {
      if (item.idTracking != null) {
        final points = await TrackingDatabase.instance.getPointsByTrackingId(item.idTracking!);
        final res = await ApiService.instance.saveTrackingToMysql(tracking: item, points: points);
        if (res['success'] == true) {
          syncedCount++;
        } else {
          lastMessage = res['message'] ?? '';
        }
      }
    }

    if (mounted) {
      if (syncedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SUKSES! $syncedCount data tracking berhasil disimpan ke tabel gps_tracking & gps_tracking_points di Laragon.'),
            backgroundColor: const Color(0xFF1B4D3E),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data ke MySQL: $lastMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text(
          'Riwayat Tracking GPS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Sinkron ke MySQL (Laragon)',
            onPressed: _trackings.isEmpty ? null : _syncToMysql,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'ip') _showIpSettingsDialog();
              if (value == 'clear') _clearAllData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ip',
                child: Row(
                  children: [
                    Icon(Icons.settings_ethernet, color: Color(0xFF1B4D3E), size: 20),
                    SizedBox(width: 8),
                    Text('Ubah IP Laptop / Server'),
                  ],
                ),
              ),
              if (_trackings.isNotEmpty)
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Kosongkan Riwayat', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trackings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum Ada Riwayat Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF182A22),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data riwayat kosong karena belum ada perjalanan yang disimpan. Tekan menu "Peta & GPS" di Beranda untuk mulai tracking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trackings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _trackings[index];
                      return _buildTrackingCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildTrackingCard(GpsTracking item) {
    final isDone = item.status == 'selesai';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackingDetailScreen(tracking: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3EE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.terrain_rounded,
                          color: _primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tracking #${item.idTracking ?? 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF182A22),
                            ),
                          ),
                          Text(
                            TrackingCalculator.formatDateTime(item.tanggalMulai),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedJarak,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedDurasi,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () {
                          if (item.idTracking != null) {
                            _deleteTracking(item.idTracking!);
                          }
                        },
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
