import 'package:flutter/foundation.dart';
import '../data/recommendation_data.dart';
import '../models/change_request.dart';
import '../models/checklist_item.dart';
import '../models/group_member.dart';
import '../models/incoming_invitation.dart';
import '../models/trip_group.dart';
import '../models/trip_plan.dart';

enum PersiapanSubScreen {
  rencana,
  kelompok,
  checklist,
  permintaan,
}

class PendakiState extends ChangeNotifier {
  // Current Trip Plan
  TripPlan _plan = const TripPlan(
    id: 'plan_1',
    gunung: 'Gunung Merbabu',
    jalur: 'via Selo',
    jenisPerjalanan: JenisPerjalanan.berkemah,
    durasi: '2 hari · 1 malam',
    jumlahAnggota: 4,
  );

  // Current Group
  TripGroup _group = TripGroup(
    id: 'group_1',
    namaKelompok: 'Tim Merbabu Selo',
    plan: const TripPlan(
      id: 'plan_1',
      gunung: 'Gunung Merbabu',
      jalur: 'via Selo',
      jenisPerjalanan: JenisPerjalanan.berkemah,
      durasi: '2 hari · 1 malam',
      jumlahAnggota: 4,
    ),
    members: [
      GroupMember(
        id: 'member_ryan',
        username: 'ryan',
        nama: 'Ryan (Kamu)',
        role: MemberRole.ketua,
        status: MemberStatus.diterima,
        waktuDiundang: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      GroupMember(
        id: 'member_budi',
        username: 'budi',
        nama: 'Budi Santoso',
        role: MemberRole.anggota,
        status: MemberStatus.diterima,
        waktuDiundang: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      GroupMember(
        id: 'member_siti',
        username: 'siti',
        nama: 'Siti Rahma',
        role: MemberRole.anggota,
        status: MemberStatus.menunggu,
        waktuDiundang: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GroupMember(
        id: 'member_andi',
        username: 'andi',
        nama: 'Andi Pratama',
        role: MemberRole.anggota,
        status: MemberStatus.menunggu,
        waktuDiundang: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    isConfirmed: false,
  );

  // Incoming Invitations for current logged-in user (Ryan)
  List<IncomingInvitation> _incomingInvitations = [
    const IncomingInvitation(
      id: 'inv_1',
      namaKelompok: 'Pendaki Senja Prau',
      pengundang: 'fajar',
      gunung: 'Gunung Prau',
      jalur: 'via Patakbanteng',
      tanggal: 'Sabtu, 14 Nov 2026',
      status: MemberStatus.menunggu,
    ),
    const IncomingInvitation(
      id: 'inv_2',
      namaKelompok: 'Laskar Sumbing',
      pengundang: 'danang',
      gunung: 'Gunung Sumbing',
      jalur: 'via Garung',
      tanggal: 'Minggu, 22 Nov 2026',
      status: MemberStatus.menunggu,
    ),
  ];

  // Checklist items
  List<ChecklistItem> _items = [];

  // Change requests
  final List<ChangeRequest> _changeRequests = [
    ChangeRequest(
      id: 'req_1',
      pengaju: 'budi',
      jenis: RequestType.ubah,
      targetItemId: 'item_3',
      namaPerlengkapan: 'Nesting / set alat masak',
      jumlahBaru: '2 set lengkap',
      catatanBaru: 'Bawa 2 set agar bisa masak sayur dan nasi bersamaan',
      alasan: 'Kapasitas 4 orang membutuhkan 2 panci agar lebih cepat matang.',
      status: RequestStatus.menunggu,
      waktu: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  // Active persona for simulation: "ryan" (Ketua) or member username like "budi", "siti"
  String _activeUsername = 'ryan';

  // Navigation within Persiapan flow
  PersiapanSubScreen _currentSubScreen = PersiapanSubScreen.rencana;

  // Filter for checklist: 'semua', 'belum_siap', 'wajib', 'tugas_saya'
  String _checklistFilter = 'semua';

  PendakiState() {
    _initializeChecklist();
  }

  // Getters
  TripPlan get plan => _plan;
  TripGroup get group => _group;
  List<IncomingInvitation> get incomingInvitations => _incomingInvitations;
  List<ChecklistItem> get items => _items;
  List<ChangeRequest> get changeRequests => _changeRequests;
  String get activeUsername => _activeUsername;
  PersiapanSubScreen get currentSubScreen => _currentSubScreen;
  String get checklistFilter => _checklistFilter;

  bool get isCurrentKetua => _activeUsername.toLowerCase() == 'ryan';
  bool get isGroupMode => _plan.jumlahAnggota > 1;
  bool get isGroupConfirmed => _group.isConfirmed;

  List<String> get acceptedUsernames =>
      _group.acceptedMembers.map((m) => m.username).toList();

  int get pendingChangeRequestCount =>
      _changeRequests.where((r) => r.isMenunggu).length;

  void _initializeChecklist() {
    _items = RecommendationData.generateInitialItems(
      _plan,
      isGroup: isGroupMode,
      joinedUsernames: acceptedUsernames.isNotEmpty ? acceptedUsernames : ['ryan'],
    );
  }

  // Plan Management
  void updateTripPlan(TripPlan newPlan) {
    final oldAnggota = _plan.jumlahAnggota;
    _plan = newPlan;
    _group = _group.copyWith(plan: newPlan);

    // If switching between solo and group, or plan details changed significantly
    if (newPlan.isSolo != (oldAnggota <= 1) || _items.isEmpty) {
      _items = RecommendationData.generateInitialItems(
        _plan,
        isGroup: !newPlan.isSolo,
        joinedUsernames: acceptedUsernames.isNotEmpty ? acceptedUsernames : ['ryan'],
      );
    }
    notifyListeners();
  }

  // SubScreen Navigation
  void navigateToSubScreen(PersiapanSubScreen subScreen) {
    _currentSubScreen = subScreen;
    notifyListeners();
  }

  void handleRencanaContinue() {
    if (_plan.isSolo) {
      // Lewati pembuatan kelompok, langsung buka checklist pribadi
      _items = RecommendationData.generateInitialItems(
        _plan,
        isGroup: false,
      );
      _currentSubScreen = PersiapanSubScreen.checklist;
    } else {
      // Ke pembuatan kelompok
      _currentSubScreen = PersiapanSubScreen.kelompok;
    }
    notifyListeners();
  }

  void backFromKelompok() {
    // Kembali ke Rencana Pendakian tanpa menghapus data yang sudah diisi
    _currentSubScreen = PersiapanSubScreen.rencana;
    notifyListeners();
  }

  void backFromChecklist() {
    if (isGroupMode) {
      // Dari Checklist kelompok kembali ke Kelompok
      _currentSubScreen = PersiapanSubScreen.kelompok;
    } else {
      // Dari Checklist pribadi kembali ke Rencana Pendakian
      _currentSubScreen = PersiapanSubScreen.rencana;
    }
    notifyListeners();
  }

  // Group Management
  void updateGroupName(String name) {
    _group = _group.copyWith(namaKelompok: name.trim());
    notifyListeners();
  }

  String? inviteMember(String rawUsername) {
    final cleaned = rawUsername.trim().replaceAll('@', '').toLowerCase();

    if (cleaned.isEmpty) {
      return 'Username anggota tidak boleh kosong.';
    }

    if (cleaned == 'ryan' || cleaned == _group.ketua?.username.toLowerCase()) {
      return 'Tidak bisa mengundang diri sendiri sebagai ketua.';
    }

    final exists = _group.members.any(
      (m) => m.username.toLowerCase() == cleaned,
    );
    if (exists) {
      return 'Anggota dengan username @$cleaned sudah pernah diundang.';
    }

    final newMember = GroupMember(
      id: 'member_${DateTime.now().millisecondsSinceEpoch}',
      username: cleaned,
      nama: cleaned[0].toUpperCase() + cleaned.substring(1),
      role: MemberRole.anggota,
      status: MemberStatus.menunggu,
      waktuDiundang: DateTime.now(),
    );

    final updatedMembers = List<GroupMember>.from(_group.members)..add(newMember);
    _group = _group.copyWith(members: updatedMembers);

    notifyListeners();
    return null; // Sukses tanpa error
  }

  void removeMember(String memberId) {
    final updated = _group.members.where((m) => m.id != memberId).toList();
    _group = _group.copyWith(members: updated);
    notifyListeners();
  }

  // Simulation: Member response to invitation
  void simulateMemberResponse(String memberId, MemberStatus newStatus) {
    final updatedMembers = _group.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(status: newStatus);
      }
      return m;
    }).toList();

    _group = _group.copyWith(members: updatedMembers);

    // If active user was switched to this member and they got rejected, revert to ketua
    if (newStatus == MemberStatus.ditolak && _activeUsername == memberId) {
      _activeUsername = 'ryan';
    }

    notifyListeners();
  }

  // Incoming Invitations actions
  void acceptIncomingInvitation(String id) {
    _incomingInvitations = _incomingInvitations.map((inv) {
      if (inv.id == id) {
        return inv.copyWith(status: MemberStatus.diterima);
      }
      return inv;
    }).toList();
    notifyListeners();
  }

  void rejectIncomingInvitation(String id) {
    _incomingInvitations = _incomingInvitations.map((inv) {
      if (inv.id == id) {
        return inv.copyWith(status: MemberStatus.ditolak);
      }
      return inv;
    }).toList();
    notifyListeners();
  }

  // Confirm group creation
  void confirmGroupAndCreateChecklist() {
    _group = _group.copyWith(isConfirmed: true);

    // Re-generate or update assignees with actual accepted members
    if (_items.isEmpty) {
      _items = RecommendationData.generateInitialItems(
        _plan,
        isGroup: true,
        joinedUsernames: acceptedUsernames.isNotEmpty ? acceptedUsernames : ['ryan'],
      );
    }

    _currentSubScreen = PersiapanSubScreen.checklist;
    notifyListeners();
  }

  // Persona / Role Simulation
  void setActivePersona(String username) {
    _activeUsername = username.replaceAll('@', '').toLowerCase();
    notifyListeners();
  }

  // Checklist Actions
  void setChecklistFilter(String filter) {
    _checklistFilter = filter;
    notifyListeners();
  }

  bool canToggleItem(ChecklistItem item) {
    if (!isGroupMode) return true; // Solo: can toggle anything
    if (isCurrentKetua) return true; // Ketua: can toggle anything
    // Anggota: only if item is assigned to this member
    return item.penanggungJawab?.toLowerCase() == _activeUsername;
  }

  String? toggleItemCheck(String id) {
    final index = _items.indexWhere((it) => it.id == id);
    if (index == -1) return null;

    final item = _items[index];
    if (!canToggleItem(item)) {
      final pj = item.penanggungJawab != null ? '@${item.penanggungJawab}' : 'Ketua';
      return 'Perlengkapan ini adalah tanggung jawab $pj.';
    }

    _items[index] = item.copyWith(isChecked: !item.isChecked);
    notifyListeners();
    return null;
  }

  void addItem(ChecklistItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(ChecklistItem item) {
    final idx = _items.indexWhere((it) => it.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((it) => it.id == id);
    notifyListeners();
  }

  // Change Requests
  void submitChangeRequest({
    required RequestType jenis,
    String? targetItemId,
    required String namaPerlengkapan,
    String? jumlahBaru,
    ItemCategory? kategoriBaru,
    String? catatanBaru,
    String? penanggungJawabBaru,
    required String alasan,
  }) {
    final newRequest = ChangeRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      pengaju: _activeUsername,
      jenis: jenis,
      targetItemId: targetItemId,
      namaPerlengkapan: namaPerlengkapan,
      jumlahBaru: jumlahBaru,
      kategoriBaru: kategoriBaru,
      catatanBaru: catatanBaru,
      penanggungJawabBaru: penanggungJawabBaru,
      alasan: alasan,
      status: RequestStatus.menunggu,
      waktu: DateTime.now(),
    );

    _changeRequests.insert(0, newRequest);
    notifyListeners();
  }

  void approveChangeRequest(String requestId) {
    final idx = _changeRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;

    final req = _changeRequests[idx];
    _changeRequests[idx] = req.copyWith(status: RequestStatus.disetujui);

    // Apply changes to checklist
    switch (req.jenis) {
      case RequestType.tambah:
        _items.add(ChecklistItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          nama: req.namaPerlengkapan,
          jumlah: req.jumlahBaru ?? '1 buah',
          kategori: req.kategoriBaru ?? ItemCategory.wajib,
          catatan: req.catatanBaru ?? '',
          penanggungJawab: req.penanggungJawabBaru ?? req.pengaju,
          isKelompok: true,
          isChecked: false,
        ));
        break;

      case RequestType.ubah:
        if (req.targetItemId != null) {
          final itemIdx = _items.indexWhere((it) => it.id == req.targetItemId);
          if (itemIdx != -1) {
            final old = _items[itemIdx];
            _items[itemIdx] = old.copyWith(
              nama: req.namaPerlengkapan.isNotEmpty ? req.namaPerlengkapan : old.nama,
              jumlah: req.jumlahBaru ?? old.jumlah,
              kategori: req.kategoriBaru ?? old.kategori,
              catatan: req.catatanBaru ?? old.catatan,
              penanggungJawab: req.penanggungJawabBaru ?? old.penanggungJawab,
            );
          }
        }
        break;

      case RequestType.hapus:
        if (req.targetItemId != null) {
          _items.removeWhere((it) => it.id == req.targetItemId);
        }
        break;
    }

    notifyListeners();
  }

  void rejectChangeRequest(String requestId) {
    final idx = _changeRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _changeRequests[idx] =
          _changeRequests[idx].copyWith(status: RequestStatus.ditolak);
      notifyListeners();
    }
  }
}
