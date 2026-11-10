import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// =============================================================================
// MODUL DATABASE LOKAL SQLITE (SQFLITE) UNTUK APLIKASI PUNCAKKU
// =============================================================================
// File ini bertanggung jawab atas persistensi data (penyimpanan lokal di HP).
// Pendaki sering kali kehilangan sinyal internet di gunung (offline mode),
// sehingga data rute dan jejak GPS WAJIB disimpan secara lokal di SQLite.
// =============================================================================

// -----------------------------------------------------------------------------
// [MODEL 1: LOCATION POINT MODEL]
// Merepresentasikan 1 titik koordinat GPS yang direkam saat pendakian berlangsung.
// -----------------------------------------------------------------------------
class LocationPointModel {
  final int? id; // Primary key SQLite (autoincrement)
  final int sessionId; // Relasi foreign key ke tabel sesi pendakian
  final double latitude; // Titik lintang
  final double longitude; // Titik bujur
  final double altitude; // Ketinggian di atas permukaan laut (mdpl)
  final double speed; // Kecepatan bergerak (m/s)
  final DateTime timestamp; // Waktu titik koordinat ini dicatat

  LocationPointModel({
    this.id,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.timestamp,
  });

  // Konversi dari Object Dart ke Map (Kamus data) untuk dimasukkan ke tabel SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Rekonstruksi dari baris query SQLite kembali menjadi Object Dart
  factory LocationPointModel.fromMap(Map<String, dynamic> map) {
    return LocationPointModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: (map['altitude'] as num).toDouble(),
      speed: (map['speed'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

// -----------------------------------------------------------------------------
// [MODEL 2: TRACKING SESSION MODEL]
// Merepresentasikan 1 kali sesi kegiatan pendakian (misal: "Pendakian Gn. Semeru").
// Menyimpan ringkasan akhir seperti total jarak, elevasi gain, dan durasi.
// -----------------------------------------------------------------------------
class TrackingSessionModel {
  final int? id; // Primary key unik untuk sesi
  final String title; // Judul atau nama sesi pendakian
  final DateTime startTime; // Jam mulai start
  final DateTime? endTime; // Jam selesai tracking
  final double totalDistance; // Akumulasi jarak tempuh (dalam meter)
  final double elevationGain; // Akumulasi tanjakan naik (dalam meter)
  final int durationSeconds; // Total waktu pendakian dalam detik

  TrackingSessionModel({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    this.elevationGain = 0.0,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_distance': totalDistance,
      'elevation_gain': elevationGain,
      'duration_seconds': durationSeconds,
    };
  }

  factory TrackingSessionModel.fromMap(Map<String, dynamic> map) {
    return TrackingSessionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      totalDistance: (map['total_distance'] as num?)?.toDouble() ?? 0.0,
      elevationGain: (map['elevation_gain'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (map['duration_seconds'] as int?) ?? 0,
    );
  }
}

// -----------------------------------------------------------------------------
// [CLASS DATABASE HELPER: TRACKING DATABASE]
// Menggunakan pola desain Singleton (hanya ada 1 koneksi database di memori).
// -----------------------------------------------------------------------------
class TrackingDatabase {
  static final TrackingDatabase instance = TrackingDatabase._init();
  static Database? _database;

  TrackingDatabase._init();

  // Getter database: Membuat database baru jika belum ada, atau mengambil yang sudah ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('puncakku_tracking.db');
    return _database!;
  }

  // Inisialisasi file database pada memori penyimpanan lokal HP Android
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
  // [POIN PRESENTASI 4: SKEMA STRUKTUR DATABASE RELASIONAL & INDEKSING]
  // Penjelasan: "Kami memisahkan tabel Sesi (metadata) dan tabel Titik Koordinat.
  // Satu sesi bisa memiliki ribuan titik koordinat (relasi 1-to-many).
  // Dilengkapi ON DELETE CASCADE sehingga jika sesi dihapus, koordinatnya ikut bersih.
  // Kami juga menambahkan INDEX pada session_id agar render rute ribuan titik tetap instan."
  // ---------------------------------------------------------------------------
  Future<void> _createDB(Database db, int version) async {
    // Tabel 1: Sesi Pendakian
    await db.execute('''
      CREATE TABLE tracking_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_distance REAL NOT NULL DEFAULT 0.0,
        elevation_gain REAL NOT NULL DEFAULT 0.0,
        duration_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabel 2: Titik Koordinat GPS
    await db.execute('''
      CREATE TABLE location_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL NOT NULL,
        speed REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES tracking_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Pembuatan INDEX (Optimasi Performa Query Database)
    await db.execute(
      'CREATE INDEX idx_location_session ON location_points(session_id);',
    );
  }

  // ---------------------------------------------------------------------------
  // OPERASI CRUD (CREATE, READ, UPDATE, DELETE)
  // ---------------------------------------------------------------------------

  // CREATE: Menyimpan sesi tracking baru saat user menekan "Mulai Tracking"
  Future<int> createSession(String title) async {
    final db = await database;
    final session = TrackingSessionModel(
      title: title,
      startTime: DateTime.now(),
    );
    return await db.insert('tracking_sessions', session.toMap());
  }

  // INSERT: Menambahkan koordinat GPS baru ke dalam SQLite secara berkala
  Future<int> insertLocationPoint(LocationPointModel point) async {
    final db = await database;
    return await db.insert('location_points', point.toMap());
  }

  // READ: Mengambil seluruh deretan koordinat GPS untuk digambar menjadi garis rute (Polyline)
  Future<List<LocationPointModel>> getPointsBySession(int sessionId) async {
    final db = await database;
    final result = await db.query(
      'location_points',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => LocationPointModel.fromMap(e)).toList();
  }

  // UPDATE: Memperbarui ringkasan akhir (total jarak, gain, durasi) saat user menekan "Selesai"
  Future<int> updateSessionStats({
    required int sessionId,
    required double totalDistance,
    required double elevationGain,
    required int durationSeconds,
    required DateTime endTime,
  }) async {
    final db = await database;
    return await db.update(
      'tracking_sessions',
      {
        'end_time': endTime.toIso8601String(),
        'total_distance': totalDistance,
        'elevation_gain': elevationGain,
        'duration_seconds': durationSeconds,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // READ: Mengambil semua riwayat sesi pendakian untuk ditampilkan di BottomSheet Riwayat
  Future<List<TrackingSessionModel>> getAllSessions() async {
    final db = await database;
    final result = await db.query(
      'tracking_sessions',
      orderBy: 'start_time DESC',
    );
    return result.map((e) => TrackingSessionModel.fromMap(e)).toList();
  }

  // DELETE: Menghapus data sesi pendakian beserta koordinatnya
  Future<int> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'location_points',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return await db.delete(
      'tracking_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Menutup koneksi database saat aplikasi dimatikan
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
