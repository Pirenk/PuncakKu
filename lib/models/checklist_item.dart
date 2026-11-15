enum ItemCategory { wajib, opsional }

class ChecklistItem {
  final String id;
  final String nama;
  final String jumlah;
  final ItemCategory kategori;
  final String catatan;
  final bool isChecked;
  final String? penanggungJawab;
  final int? penanggungJawabId;
  final bool isKelompok;

  const ChecklistItem({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.catatan = '',
    this.isChecked = false,
    this.penanggungJawab,
    this.penanggungJawabId,
    this.isKelompok = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      jumlah: '${json['jumlah'] ?? 0} ${json['satuan'] ?? ''}'.trim(),
      kategori: json['kategori'] == 'opsional'
          ? ItemCategory.opsional
          : ItemCategory.wajib,
      catatan: json['catatan'] ?? '',
      isChecked: json['is_checked'] == 1,
      isKelompok: json['is_kelompok'] == 1,
      penanggungJawab: json['penanggung_jawab'],
      penanggungJawabId: json['penanggung_jawab_id'] == null
    ? null
    : int.tryParse(json['penanggung_jawab_id'].toString()),
    );
  }

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
    int? penanggungJawabId,
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
      penanggungJawabId: penanggungJawabId ?? this.penanggungJawabId,
      isKelompok: isKelompok ?? this.isKelompok,
    );
  }
}
