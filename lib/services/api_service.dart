import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/gps_tracking.dart';
import '../utils/gps_tracking_point.dart';

// =============================================================================
// API SERVICE - MENGHUBUNGKAN APLIKASI PUNCAKKU DENGAN MYSQL LARAGON
// =============================================================================

class ApiService {
  static final ApiService instance = ApiService._init();
  ApiService._init();

  // IP Laptop Anda di jaringan Wi-Fi/Hotspot: 192.168.43.76
  // Bisa diubah secara dinamis lewat aplikasi jika IP berubah
  static const String initialIp = '192.168.43.76';

  String _baseUrl = 'http://$initialIp/puncakku_api';

  String get baseUrl => _baseUrl;
  set baseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Format DateTime ke format SQL: YYYY-MM-DD HH:MM:SS
  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} '
        '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}';
  }

  /// Tes koneksi ke API Laragon dengan timeout cepat
  Future<Map<String, dynamic>> testConnection() async {
    // Coba URL aktif
    final candidates = [
      _baseUrl,
      'http://192.168.43.76/puncakku_api',
      'http://10.0.2.2/puncakku_api',
      'http://localhost/puncakku_api',
    ];

    for (final url in candidates) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 3);
        final request = await client.getUrl(Uri.parse('$url/get_tracking.php'));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        client.close();

        if (response.statusCode == 200) {
          _baseUrl = url; // Simpan URL yang sukses
          return {
            'success': true,
            'url': url,
            'message': 'Terhubung ke Laragon ($url)',
          };
        }
      } catch (e) {
        debugPrint('Gagal ping $url: $e');
      }
    }

    return {
      'success': false,
      'url': _baseUrl,
      'message': 'Tidak dapat menjangkau Laragon di $_baseUrl. Pastikan HP dan Laptop di satu Wi-Fi/Hotspot.',
    };
  }

  /// KIRIM DATA KE MYSQL: Menyimpan sesi tracking & seluruh titik koordinatnya
  Future<Map<String, dynamic>> saveTrackingToMysql({
    required GpsTracking tracking,
    required List<GpsTrackingPoint> points,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);

      final payload = {
        'id_user': tracking.idUser,
        'id_trip': tracking.idTrip,
        'tanggal_mulai': _formatDateTime(tracking.tanggalMulai),
        'tanggal_selesai': tracking.tanggalSelesai != null
            ? _formatDateTime(tracking.tanggalSelesai!)
            : _formatDateTime(DateTime.now()),
        'total_jarak': tracking.totalJarak,
        'durasi_detik': tracking.durasiDetik,
        'status': tracking.status,
        'points': points.map((p) => {
          'latitude': p.latitude,
          'longitude': p.longitude,
          'altitude': p.altitude,
          'accuracy': p.accuracy,
          'speed': p.speed,
          'recorded_at': _formatDateTime(p.recordedAt),
        }).toList(),
      };

      final request = await client.postUrl(Uri.parse('$_baseUrl/save_tracking.php'));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);
        return {
          'success': decoded['status'] == true,
          'message': decoded['message'] ?? 'Berhasil simpan ke MySQL',
          'id_tracking': decoded['id_tracking'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error (Status ${response.statusCode}): $responseBody',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal koneksi ke Laragon ($_baseUrl): $e',
      };
    }
  }

  /// AMBIL RIWAYAT TRACKING DARI MYSQL
  Future<List<GpsTracking>?> fetchTrackingFromMysql() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.getUrl(Uri.parse('$_baseUrl/get_tracking.php'));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);
        if (json['status'] == true && json['data'] is List) {
          final list = (json['data'] as List)
              .map((e) => GpsTracking.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          return list;
        }
      }
      return null;
    } catch (e) {
      debugPrint('ApiService fetchTrackingFromMysql error: $e');
      return null;
    }
  }

  /// HAPUS TRACKING DARI MYSQL
  Future<bool> deleteTrackingFromMysql(int idTracking) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.getUrl(Uri.parse('$_baseUrl/delete_tracking.php?id_tracking=$idTracking'));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService deleteTrackingFromMysql error: $e');
      return false;
    }
  }
}
