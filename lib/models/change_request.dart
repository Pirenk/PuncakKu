import 'checklist_item.dart';

enum RequestType { tambah, ubah, hapus }

enum RequestStatus { menunggu, disetujui, ditolak }

class ChangeRequest {
  final String id;
  final String pengaju; // e.g. "@budi"
  final RequestType jenis;
  final String? targetItemId; // if ubah or hapus
  final String namaPerlengkapan;
  final String? jumlahBaru;
  final ItemCategory? kategoriBaru;
  final String? catatanBaru;
  final String? penanggungJawabBaru;
  final String alasan;
  final RequestStatus status;
  final DateTime waktu;

  const ChangeRequest({
    required this.id,
    required this.pengaju,
    required this.jenis,
    this.targetItemId,
    required this.namaPerlengkapan,
    this.jumlahBaru,
    this.kategoriBaru,
    this.catatanBaru,
    this.penanggungJawabBaru,
    required this.alasan,
    this.status = RequestStatus.menunggu,
    required this.waktu,
  });

  factory ChangeRequest.fromJson(Map<String, dynamic> json) {
  RequestType parseJenis(String? value) {
    switch (value) {
      case 'ubah':
        return RequestType.ubah;
      case 'hapus':
        return RequestType.hapus;
      default:
        return RequestType.tambah;
    }
  }

  RequestStatus parseStatus(String? value) {
    switch (value) {
      case 'disetujui':
        return RequestStatus.disetujui;
      case 'ditolak':
        return RequestStatus.ditolak;
      default:
        return RequestStatus.menunggu;
    }
  }

  return ChangeRequest(
    id: json['id'].toString(),
    pengaju: '@${json['username_pengaju'] ?? 'unknown'}',
    jenis: parseJenis(json['jenis']?.toString()),
    targetItemId: json['target_item_id']?.toString(),
    namaPerlengkapan: json['nama_perlengkapan']?.toString() ?? '',
    jumlahBaru: json['jumlah_baru']?.toString(),
    catatanBaru: json['catatan_baru']?.toString(),
    alasan: json['alasan']?.toString() ?? '',
    status: parseStatus(json['status']?.toString()),
    waktu: DateTime.tryParse(
          json['created_at']?.toString() ?? '',
        ) ??
        DateTime.now(),
  );
}

  bool get isMenunggu => status == RequestStatus.menunggu;
  bool get isDisetujui => status == RequestStatus.disetujui;
  bool get isDitolak => status == RequestStatus.ditolak;

  String get jenisLabel {
    switch (jenis) {
      case RequestType.tambah:
        return 'Tambah';
      case RequestType.ubah:
        return 'Ubah';
      case RequestType.hapus:
        return 'Hapus';
    }
  }

  String get statusLabel {
    switch (status) {
      case RequestStatus.menunggu:
        return 'Menunggu';
      case RequestStatus.disetujui:
        return 'Disetujui';
      case RequestStatus.ditolak:
        return 'Ditolak';
    }
  }

  ChangeRequest copyWith({
    String? id,
    String? pengaju,
    RequestType? jenis,
    String? targetItemId,
    String? namaPerlengkapan,
    String? jumlahBaru,
    ItemCategory? kategoriBaru,
    String? catatanBaru,
    String? penanggungJawabBaru,
    String? alasan,
    RequestStatus? status,
    DateTime? waktu,
  }) {
    return ChangeRequest(
      id: id ?? this.id,
      pengaju: pengaju ?? this.pengaju,
      jenis: jenis ?? this.jenis,
      targetItemId: targetItemId ?? this.targetItemId,
      namaPerlengkapan: namaPerlengkapan ?? this.namaPerlengkapan,
      jumlahBaru: jumlahBaru ?? this.jumlahBaru,
      kategoriBaru: kategoriBaru ?? this.kategoriBaru,
      catatanBaru: catatanBaru ?? this.catatanBaru,
      penanggungJawabBaru: penanggungJawabBaru ?? this.penanggungJawabBaru,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      waktu: waktu ?? this.waktu,
    );
  }
}
