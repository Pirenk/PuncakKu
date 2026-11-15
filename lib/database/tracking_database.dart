import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../services/api_service.dart';
import '../utils/gps_tracking.dart';
import '../utils/gps_tracking_point.dart';

// =============================================================================
// MODUL DATABASE LOKAL SQLITE (SQFLITE) UNTUK APLIKASI PUNCAKKU
// =============================================================================
// Menggunakan database 'puncakku_mobile_v1.db' agar bersih dari data lama.
// Dua tabel utama (persis sesuai mobile.sql):
//   1. gps_tracking         → ringkasan per sesi tracking
//   2. gps_tracking_points  → detail titik koordinat GPS
// =============================================================================

class TrackingDatabase {
  static final TrackingDatabase instance = TrackingDatabase._init();
  static Database? _database;

  TrackingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('puncakku_mobile_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ---------------------------------------------------------------------------
  // BUAT TABEL SESUAI SKEMA DATABASE: gps_tracking & gps_tracking_points
  // ---------------------------------------------------------------------------
  Future<void> _createDB(Database db, int version) async {
    // Tabel 1: gps_tracking — ringkasan per sesi tracking
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gps_tracking (
        id_tracking INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        id_trip INTEGER,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT,
        total_jarak REAL NOT NULL DEFAULT 0.0,
        durasi_detik INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'berlangsung',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabel 2: gps_tracking_points — detail titik koordinat GPS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gps_tracking_points (
        id_point INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tracking INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        accuracy REAL,
        speed REAL,
        recorded_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (id_tracking) REFERENCES gps_tracking (id_tracking) ON DELETE CASCADE
      )
    ''');

    // Index untuk performa pencarian titik
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_points_tracking ON gps_tracking_points(id_tracking);',
    );
  }

  // ===========================================================================
  // OPERASI CRUD UNTUK TABEL gps_tracking
  // ===========================================================================

  static String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} '
        '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}';
  }

  /// INSERT: Mulai sesi tracking baru → return id_tracking
  Future<int> insertTracking(GpsTracking tracking) async {
    final db = await database;
    final now = _formatDateTime(DateTime.now());
    final map = tracking.toMap();
    map.remove('id_tracking'); // autoincrement
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('gps_tracking', map);
  }

  /// UPDATE: Ubah status tracking (berlangsung / dijeda / selesai)
  Future<int> updateTrackingStatus({
    required int idTracking,
    required String status,
  }) async {
    final db = await database;
    return await db.update(
      'gps_tracking',
      {
        'status': status,
        'updated_at': _formatDateTime(DateTime.now()),
      },
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
    );
  }

  /// UPDATE: Selesaikan tracking — simpan total jarak, durasi, tanggal selesai
  /// Dan sinkronkan otomatis ke server MySQL (jika online/terhubung)
  Future<int> finishTracking({
    required int idTracking,
    required double totalJarakKm,
    required int durasiDetik,
    required DateTime tanggalSelesai,
  }) async {
    final db = await database;
    final now = _formatDateTime(DateTime.now());
    final updateResult = await db.update(
      'gps_tracking',
      {
        'total_jarak': totalJarakKm,
        'durasi_detik': durasiDetik,
        'tanggal_selesai': _formatDateTime(tanggalSelesai),
        'status': 'selesai',
        'updated_at': now,
      },
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
    );

    // Kirim otomatis ke MySQL Laragon jika API tersedia di jaringan
    try {
      final updatedTracking = await getTrackingById(idTracking);
      final points = await getPointsByTrackingId(idTracking);
      if (updatedTracking != null) {
        final res = await ApiService.instance.saveTrackingToMysql(
          tracking: updatedTracking,
          points: points,
        );
        debugPrint('Auto sync to MySQL: ${res['message']}');
      }
    } catch (e) {
      debugPrint('Sinkronisasi otomatis ke MySQL gagal (offline/server mati): $e');
    }

    return updateResult;
  }

  /// READ: Ambil semua riwayat tracking (urut terbaru)
  Future<List<GpsTracking>> getAllTracking() async {
    final db = await database;
    final result = await db.query(
      'gps_tracking',
      orderBy: 'tanggal_mulai DESC',
    );
    return result.map((e) => GpsTracking.fromMap(e)).toList();
  }

  /// READ: Ambil satu tracking berdasarkan ID
  Future<GpsTracking?> getTrackingById(int idTracking) async {
    final db = await database;
    final result = await db.query(
      'gps_tracking',
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return GpsTracking.fromMap(result.first);
  }

  /// DELETE: Hapus tracking beserta titik-titik koordinatnya
  Future<void> deleteTracking(int idTracking) async {
    final db = await database;
    await db.delete(
      'gps_tracking_points',
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
    );
    await db.delete(
      'gps_tracking',
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
    );

    // Hapus juga di MySQL jika terhubung
    try {
      await ApiService.instance.deleteTrackingFromMysql(idTracking);
    } catch (_) {}
  }

  /// KOSONGKAN SELURUH DATA LOKAL (Reset Bersih)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('gps_tracking_points');
    await db.delete('gps_tracking');
  }

  // ===========================================================================
  // OPERASI CRUD UNTUK TABEL gps_tracking_points
  // ===========================================================================

  /// INSERT: Simpan satu titik koordinat GPS
  Future<int> insertTrackingPoint(GpsTrackingPoint point) async {
    final db = await database;
    final map = point.toMap();
    map.remove('id_point'); // autoincrement
    map['created_at'] = _formatDateTime(DateTime.now());
    return await db.insert('gps_tracking_points', map);
  }

  /// READ: Ambil seluruh titik koordinat untuk satu sesi tracking
  Future<List<GpsTrackingPoint>> getPointsByTrackingId(int idTracking) async {
    final db = await database;
    final result = await db.query(
      'gps_tracking_points',
      where: 'id_tracking = ?',
      whereArgs: [idTracking],
      orderBy: 'recorded_at ASC',
    );
    return result.map((e) => GpsTrackingPoint.fromMap(e)).toList();
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
