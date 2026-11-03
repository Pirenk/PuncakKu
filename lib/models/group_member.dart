enum MemberRole { ketua, anggota }

enum MemberStatus { menunggu, diterima, ditolak }

class GroupMember {
  final String id;
  final String username;
  final String nama;
  final MemberRole role;
  final MemberStatus status;
  final DateTime waktuDiundang;

  const GroupMember({
    required this.id,
    required this.username,
    required this.nama,
    required this.role,
    required this.status,
    required this.waktuDiundang,
  });

  bool get isKetua => role == MemberRole.ketua;
  bool get isDiterima => status == MemberStatus.diterima;
  bool get isMenunggu => status == MemberStatus.menunggu;
  bool get isDitolak => status == MemberStatus.ditolak;

  String get statusLabel {
    switch (status) {
      case MemberStatus.menunggu:
        return 'Menunggu';
      case MemberStatus.diterima:
        return 'Diterima';
      case MemberStatus.ditolak:
        return 'Ditolak';
    }
  }

  GroupMember copyWith({
    String? id,
    String? username,
    String? nama,
    MemberRole? role,
    MemberStatus? status,
    DateTime? waktuDiundang,
  }) {
    return GroupMember(
      id: id ?? this.id,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      status: status ?? this.status,
      waktuDiundang: waktuDiundang ?? this.waktuDiundang,
    );
  }
}
