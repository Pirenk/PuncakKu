enum JenisPerjalanan { berkemah, tektok }

class TripPlan {
  final String id;
  final String gunung;
  final String jalur;
  final JenisPerjalanan jenisPerjalanan;
  final String durasi;
  final int jumlahAnggota;

  const TripPlan({
    required this.id,
    required this.gunung,
    required this.jalur,
    required this.jenisPerjalanan,
    required this.durasi,
    required this.jumlahAnggota,
  });

  bool get isSolo => jumlahAnggota <= 1;

  String get judulPendakian => '$gunung · $jalur';

  String get jenisString =>
      jenisPerjalanan == JenisPerjalanan.berkemah ? 'Berkemah' : 'Tek-tok';

  TripPlan copyWith({
    String? id,
    String? gunung,
    String? jalur,
    JenisPerjalanan? jenisPerjalanan,
    String? durasi,
    int? jumlahAnggota,
  }) {
    return TripPlan(
      id: id ?? this.id,
      gunung: gunung ?? this.gunung,
      jalur: jalur ?? this.jalur,
      jenisPerjalanan: jenisPerjalanan ?? this.jenisPerjalanan,
      durasi: durasi ?? this.durasi,
      jumlahAnggota: jumlahAnggota ?? this.jumlahAnggota,
    );
  }
}
