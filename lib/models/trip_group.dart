import 'group_member.dart';
import 'trip_plan.dart';

class TripGroup {
  final String id;
  final String namaKelompok;
  final TripPlan plan;
  final List<GroupMember> members;
  final bool isConfirmed;

  const TripGroup({
    required this.id,
    required this.namaKelompok,
    required this.plan,
    required this.members,
    this.isConfirmed = false,
  });

  GroupMember? get ketua {
    try {
      return members.firstWhere((m) => m.role == MemberRole.ketua);
    } catch (_) {
      return null;
    }
  }

  List<GroupMember> get acceptedMembers =>
      members.where((m) => m.status == MemberStatus.diterima).toList();

  List<GroupMember> get pendingMembers =>
      members.where((m) => m.status == MemberStatus.menunggu).toList();

  List<GroupMember> get rejectedMembers =>
      members.where((m) => m.status == MemberStatus.ditolak).toList();

  int get joinedCount => acceptedMembers.length;
  int get targetCount => plan.jumlahAnggota;

  bool get isAllAccepted => joinedCount >= targetCount;

  TripGroup copyWith({
    String? id,
    String? namaKelompok,
    TripPlan? plan,
    List<GroupMember>? members,
    bool? isConfirmed,
  }) {
    return TripGroup(
      id: id ?? this.id,
      namaKelompok: namaKelompok ?? this.namaKelompok,
      plan: plan ?? this.plan,
      members: members ?? this.members,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
