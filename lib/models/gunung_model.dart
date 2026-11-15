class JalurPendakian {
  final int id;
  final int gunungId;
  final String namaJalur;
  final String namaBasecamp;
  final String deskripsi;
  final String estimasiNaik;
  final String status;

  const JalurPendakian({
    required this.id,
    required this.gunungId,
    required this.namaJalur,
    required this.namaBasecamp,
    required this.deskripsi,
    required this.estimasiNaik,
    this.status = 'aktif',
  });

  factory JalurPendakian.fromJson(Map<String, dynamic> json) {
    return JalurPendakian(
      id: (json['id'] as num?)?.toInt() ?? 0,
      gunungId: (json['gunung_id'] as num?)?.toInt() ?? 0,
      namaJalur: json['nama_jalur'] ?? '',
      namaBasecamp: json['nama_basecamp'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      estimasiNaik: json['estimasi_naik'] ?? '',
      status: json['status'] ?? 'aktif',
    );
  }
}

class GunungModel {
  final int id;
  final String nama;
  final int ketinggianMdpl;
  final String lokasi;
  final String deskripsi;
  final String gambar;
  final String tingkatKesulitan;
  final String estimasiDurasi;
  final String status;
  final List<JalurPendakian> jalurPendakian;

  const GunungModel({
    required this.id,
    required this.nama,
    required this.ketinggianMdpl,
    required this.lokasi,
    required this.deskripsi,
    required this.gambar,
    required this.tingkatKesulitan,
    required this.estimasiDurasi,
    this.status = 'aktif',
    this.jalurPendakian = const [],
  });

  // URL fallback gambar jika gambar kosong atau nama file lokal
  String get fullImageUrl {
    if (gambar.isEmpty) {
      return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80';
    }
    if (gambar.startsWith('http://') || gambar.startsWith('https://')) {
      return gambar;
    }
    // Mapping default gambar berdasarkan nama file atau nama gunung
    final nameLower = nama.toLowerCase();
    if (nameLower.contains('merbabu')) {
      return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80';
    } else if (nameLower.contains('prau')) {
      return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80';
    } else if (nameLower.contains('slamet')) {
      return 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80';
    } else if (nameLower.contains('sindoro')) {
      return 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80';
    } else if (nameLower.contains('sumbing')) {
      return 'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?auto=format&fit=crop&w=1200&q=80';
    } else if (nameLower.contains('lawu')) {
      return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80';
    }
    return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80';
  }

  factory GunungModel.fromJson(Map<String, dynamic> json) {
    List<JalurPendakian> listJalur = [];
    if (json['jalur_pendakian'] != null && json['jalur_pendakian'] is List) {
      listJalur = (json['jalur_pendakian'] as List)
          .map((item) => JalurPendakian.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return GunungModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama'] ?? '',
      ketinggianMdpl: (json['ketinggian_mdpl'] as num?)?.toInt() ?? 0,
      lokasi: json['lokasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      tingkatKesulitan: json['tingkat_kesulitan'] ?? 'Pemula',
      estimasiDurasi: json['estimasi_durasi'] ?? '1 hari',
      status: json['status'] ?? 'aktif',
      jalurPendakian: listJalur,
    );
  }
}
