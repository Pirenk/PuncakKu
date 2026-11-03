enum ItemCategory { wajib, opsional }

class ChecklistItem {
  final String id;
  final String nama;
  final String jumlah;
  final ItemCategory kategori;
  final String catatan;
  final bool isChecked;
  final String? penanggungJawab;
  final bool isKelompok;

  const ChecklistItem({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.catatan = '',
    this.isChecked = false,
    this.penanggungJawab,
    this.isKelompok = false,
  });

  bool get isWajib => kategori == ItemCategory.wajib;
  bool get isOpsional => kategori == ItemCategory.opsional;

  String get kategoriLabel => isWajib ? 'Wajib' : 'Opsional';

  ChecklistItem copyWith({
    String? id,
    String? nama,
    String? jumlah,
    ItemCategory? kategori,
    String? catatan,
    bool? isChecked,
    String? penanggungJawab,
    bool? isKelompok,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jumlah: jumlah ?? this.jumlah,
      kategori: kategori ?? this.kategori,
      catatan: catatan ?? this.catatan,
      isChecked: isChecked ?? this.isChecked,
      penanggungJawab: penanggungJawab ?? this.penanggungJawab,
      isKelompok: isKelompok ?? this.isKelompok,
    );
  }
}
