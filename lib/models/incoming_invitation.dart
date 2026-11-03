import 'group_member.dart';

class IncomingInvitation {
  final String id;
  final String namaKelompok;
  final String pengundang;
  final String gunung;
  final String jalur;
  final String tanggal;
  final MemberStatus status;

  const IncomingInvitation({
    required this.id,
    required this.namaKelompok,
    required this.pengundang,
    required this.gunung,
    required this.jalur,
    required this.tanggal,
    this.status = MemberStatus.menunggu,
  });

  bool get isMenunggu => status == MemberStatus.menunggu;
  bool get isDiterima => status == MemberStatus.diterima;
  bool get isDitolak => status == MemberStatus.ditolak;

  IncomingInvitation copyWith({
    String? id,
    String? namaKelompok,
    String? pengundang,
    String? gunung,
    String? jalur,
    String? tanggal,
    MemberStatus? status,
  }) {
    return IncomingInvitation(
      id: id ?? this.id,
      namaKelompok: namaKelompok ?? this.namaKelompok,
      pengundang: pengundang ?? this.pengundang,
      gunung: gunung ?? this.gunung,
      jalur: jalur ?? this.jalur,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
    );
  }
}
