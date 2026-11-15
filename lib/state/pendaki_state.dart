import 'package:flutter/foundation.dart';
import '../models/change_request.dart';
import '../models/checklist_item.dart';
import '../models/group_member.dart';
import '../models/incoming_invitation.dart';
import '../models/trip_group.dart';
import '../models/trip_plan.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/solo_checklist_recommendation.dart';

enum PersiapanSubScreen { rencana, kelompok, checklist, permintaan }

class PendakiState extends ChangeNotifier {
  Future<void> loadActiveTripId() async {
    final prefs = await SharedPreferences.getInstance();

    _activeTripMode = prefs.getString('active_trip_mode') ?? 'kelompok';

    // Pertahankan ID kelompok lama, termasuk trip ID 8.
    final oldGroupId = prefs.getInt('active_trip_id');

    if (oldGroupId != null && prefs.getInt('active_group_trip_id') == null) {
      await prefs.setInt('active_group_trip_id', oldGroupId);
    }

    _activeTripId = _activeTripMode == 'pribadi'
        ? prefs.getInt('active_solo_trip_id')
        : prefs.getInt('active_group_trip_id');
  }

  Future<void> saveActiveTripId(int tripId, {required String mode}) async {
    final prefs = await SharedPreferences.getInstance();

    _activeTripMode = mode;

    if (mode == 'pribadi') {
      await prefs.setInt('active_solo_trip_id', tripId);
    } else {
      await prefs.setInt('active_group_trip_id', tripId);
    }

    await prefs.setString('active_trip_mode', mode);

    _activeTripId = tripId;
  }

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
    namaKelompok: 'Kelompok Pendakian',
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
        id: 'member_ketua',
        username: 'mirza',
        nama: 'Mirza (Ketua)',
        role: MemberRole.ketua,
        status: MemberStatus.diterima,
        waktuDiundang: DateTime.now(),
      ),
    ],
    isConfirmed: false,
  );

  // Anggota kelompok dari database
  List<Map<String, dynamic>> _groupMembersFromApi = [];

  bool _isLoadingGroupMembers = false;
  String? _groupMembersError;

  // Incoming Invitations for current logged-in user
  List<IncomingInvitation> _incomingInvitations = [];

  // Checklist items
  List<ChecklistItem> _items = [];

  // ID perjalanan aktif dari database
  int? _activeTripId;

  String _activeTripMode = 'kelompok';

  // Status proses pembuatan perjalanan pribadi
  bool _isCreatingSoloTrip = false;

  // Change requests
  List<ChangeRequest> _changeRequests = [];

  // Active persona for simulation: "ryan" (Ketua) or member username like "budi", "siti"
  String _activeUsername = '';

  // Navigation within Persiapan flow
  PersiapanSubScreen _currentSubScreen = PersiapanSubScreen.rencana;

  // Filter for checklist: 'semua', 'belum_siap', 'wajib', 'tugas_saya'
  String _checklistFilter = 'semua';

  PendakiState() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await loadActiveTripId();

    if (_activeTripId != null) {
      await _initializeChecklist();

      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('active_trip_mode') ?? 'kelompok';

      if (mode == 'kelompok') {
        await loadGroupConfirmation();
        await loadGroupMembers(_activeTripId!);
        await loadChangeRequests();
      }

      _currentSubScreen = PersiapanSubScreen.checklist;
      notifyListeners();
    }
  }

  Future<void> loadChangeRequests() async {
    try {
      final tripId = _activeTripId;

      if (tripId == null) return;

      final data = await ApiService.getChangeRequests(tripId);

      _changeRequests = data.map((item) {
        return ChangeRequest.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal mengambil permintaan perubahan: $e');
    }
  }

  // Getters
  TripPlan get plan => _plan;
  TripGroup get group => _group;
  List<Map<String, dynamic>> get groupMembersFromApi => _groupMembersFromApi;
  bool get isLoadingGroupMembers => _isLoadingGroupMembers;
  String? get groupMembersError => _groupMembersError;

  List<IncomingInvitation> get incomingInvitations => _incomingInvitations;
  List<ChecklistItem> get items => _items;
  List<ChangeRequest> get changeRequests => _changeRequests;
  String get activeUsername => _activeUsername;
  PersiapanSubScreen get currentSubScreen => _currentSubScreen;
  String get checklistFilter => _checklistFilter;

  bool get isCurrentKetua {
    if (_groupMembersFromApi.isEmpty) return true;

    final currentMember = _groupMembersFromApi.where(
      (m) => m['username'].toString().toLowerCase() == _activeUsername.toLowerCase(),
    );

    if (currentMember.isEmpty) return true; // Default pembuat trip adalah ketua

    return currentMember.first['role'].toString().toLowerCase() == 'ketua';
  }

  bool get isGroupMode => _activeTripMode == 'kelompok';
  bool get isGroupConfirmed => _group.isConfirmed;

  List<String> get acceptedUsernames => _groupMembersFromApi
      .map((m) => m['username'].toString().toLowerCase())
      .toList();

  int get pendingChangeRequestCount =>
      _changeRequests.where((r) => r.isMenunggu).length;

  String get ketuaUsername {
    final ketua = _groupMembersFromApi.firstWhere(
      (m) => m['role'].toString().toLowerCase() == 'ketua',
      orElse: () => {},
    );

    return ketua['username']?.toString().toLowerCase() ?? '';
  }

  int get activeUserId {
    final currentMember = _groupMembersFromApi.firstWhere(
      (m) =>
          m['username'].toString().toLowerCase() ==
          _activeUsername.toLowerCase(),
      orElse: () => {},
    );

    return int.tryParse(currentMember['user_id']?.toString() ?? '') ?? 0;
  }

  Future<void> _initializeChecklist() async {
    try {
      final tripId = _activeTripId;

      if (tripId == null) return;

      final data = await ApiService.getChecklist(tripId);

      _items = data.map((item) {
        return ChecklistItem.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal mengambil checklist: $e');
    }
  }

  Future<void> addManualChecklistItem({
    required String nama,
    required int jumlah,
    required String satuan,
    required ItemCategory kategori,
    String catatan = '',
    bool isKelompok = false,
    int? penanggungJawabId,
  }) async {
    try {
      final tripId = _activeTripId;

      if (tripId == null) {
        throw Exception('ID perjalanan tidak ditemukan');
      }

      await ApiService.addChecklist(
        tripId: tripId,
        createdBy: 1,
        nama: nama,
        jumlah: jumlah,
        satuan: satuan,
        kategori: kategori == ItemCategory.wajib ? 'wajib' : 'opsional',
        catatan: catatan,
        isKelompok: isKelompok,
        penanggungJawabId: penanggungJawabId,
      );

      await _initializeChecklist();

      debugPrint('Perlengkapan berhasil ditambahkan: $nama');
    } catch (e) {
      debugPrint('Gagal menambahkan perlengkapan: $e');
      rethrow;
    }
  }

  Future<void> loadGroupMembers(int tripId) async {
    _isLoadingGroupMembers = true;
    _groupMembersError = null;
    notifyListeners();

    try {
      debugPrint('Trip ID yang diminta: $tripId');
      final data = await ApiService.getGroupMembers(tripId);

      _groupMembersFromApi = data.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      // Jika username aktif belum ada di database,
      // otomatis gunakan username Ketua.
      final activeExists = _groupMembersFromApi.any(
        (m) =>
            m['username'].toString().toLowerCase() ==
            _activeUsername.toLowerCase(),
      );

      if (!activeExists && ketuaUsername.isNotEmpty) {
        _activeUsername = ketuaUsername;
      }

      debugPrint('Anggota dari API: $_groupMembersFromApi');
      debugPrint('Persona aktif: $_activeUsername');
    } catch (e) {
      _groupMembersError = e.toString();
      debugPrint('Gagal mengambil anggota kelompok: $e');
    } finally {
      _isLoadingGroupMembers = false;
      notifyListeners();
    }
  }

  // Plan Management
  void updateTripPlan(TripPlan newPlan) {
    _plan = newPlan;
    _group = _group.copyWith(plan: newPlan);
    notifyListeners();
  }

  // SubScreen Navigation
  void navigateToSubScreen(PersiapanSubScreen subScreen) {
    // Jika kelompok sudah dikonfirmasi, buka Checklist sebagai halaman awal.
    if (isGroupMode &&
        isGroupConfirmed &&
        subScreen == PersiapanSubScreen.rencana) {
      _currentSubScreen = PersiapanSubScreen.checklist;
    } else {
      _currentSubScreen = subScreen;
    }

    notifyListeners();
  }

  Future<void> handleRencanaContinue() async {
    if (_plan.jumlahAnggota <= 1) {
      await createSoloTripAndChecklist();
    } else {
      _currentSubScreen = PersiapanSubScreen.kelompok;
      notifyListeners();
    }
  }

  Future<void> createSoloTripAndChecklist() async {
    if (_isCreatingSoloTrip) return;

    _isCreatingSoloTrip = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Periksa apakah perjalanan pribadi sudah tersedia
      int? tripId = prefs.getInt('active_solo_trip_id');

      // 2. Jika belum ada, buat perjalanan baru
      if (tripId == null) {
        tripId = await ApiService.createTrip(
          ownerId: 1,
          gunung: _plan.gunung,
          jalur: _plan.jalur,
          jenisPerjalanan: _plan.jenisPerjalanan == JenisPerjalanan.berkemah
              ? 'berkemah'
              : 'tektok',
          durasi: _plan.durasi,
          jumlahAnggota: 1,
          mode: 'pribadi',
        );
      }

      // 3. Simpan dan aktifkan ID perjalanan pribadi
      await saveActiveTripId(tripId, mode: 'pribadi');

      // 4. Ambil checklist dari database
      await _initializeChecklist();

      // 5. Periksa apakah rekomendasi sudah pernah dimasukkan
      final seedKey = 'solo_checklist_seeded_$tripId';
      final sudahDiisi = prefs.getBool(seedKey) ?? false;

      if (!sudahDiisi) {
        final rekomendasi = SoloChecklistRecommendation.getRecommendations(
          _plan.jenisPerjalanan == JenisPerjalanan.berkemah
              ? 'berkemah'
              : 'tektok',
        );

        // Masukkan hanya rekomendasi yang belum tersedia
        for (final item in rekomendasi) {
          final sudahAda = _items.any(
            (existing) =>
                existing.nama.toLowerCase() ==
                item['nama'].toString().toLowerCase(),
          );

          if (!sudahAda) {
            await ApiService.addChecklist(
              tripId: tripId,
              createdBy: 1,
              nama: item['nama'],
              jumlah: item['jumlah'],
              satuan: item['satuan'],
              kategori: item['kategori'],
              isKelompok: false,
            );
          }
        }

        await prefs.setBool(seedKey, true);
      }

      // 6. Muat ulang checklist terbaru
      await _initializeChecklist();

      _currentSubScreen = PersiapanSubScreen.checklist;
      notifyListeners();

      debugPrint('Perjalanan pribadi siap: $tripId');
    } catch (e) {
      debugPrint('Gagal membuat perjalanan pribadi: $e');
      rethrow;
    } finally {
      _isCreatingSoloTrip = false;
    }
  }

  void backFromKelompok() {
    // Kembali ke Rencana Pendakian tanpa menghapus data yang sudah diisi
    _currentSubScreen = PersiapanSubScreen.rencana;
    notifyListeners();
  }

  void backFromChecklist() {
    if (_activeTripMode == 'kelompok' && !isGroupConfirmed) {
      _currentSubScreen = PersiapanSubScreen.kelompok;
    } else {
      _currentSubScreen = PersiapanSubScreen.rencana;
    }

    notifyListeners();
  }

  // Menyimpan status konfirmasi kelompok
  Future<void> saveGroupConfirmation() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isGroupConfirmed', _group.isConfirmed);
  }

  // Memuat kembali status konfirmasi kelompok
  Future<void> loadGroupConfirmation() async {
    final prefs = await SharedPreferences.getInstance();

    final isConfirmed = prefs.getBool('isGroupConfirmed') ?? false;

    debugPrint('Status kelompok tersimpan: $isConfirmed');

    _group = _group.copyWith(isConfirmed: isConfirmed);

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

    final updatedMembers = List<GroupMember>.from(_group.members)
      ..add(newMember);
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

  Future<void> resetActiveTripForTesting() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('active_trip_id');

    _activeTripId = null;

    debugPrint('Active Trip ID berhasil direset');
  }

  Future<void> confirmGroupAndCreateChecklist() async {
    try {
      debugPrint('Active Trip ID: $_activeTripId');

      if (_activeTripId == null) {
        final tripId = await ApiService.createTrip(
          ownerId: 1,
          gunung: _plan.gunung,
          jalur: _plan.jalur,
          jenisPerjalanan: _plan.jenisPerjalanan == JenisPerjalanan.berkemah
              ? 'berkemah'
              : 'tektok',
          durasi: _plan.durasi,
          jumlahAnggota: _plan.jumlahAnggota,
          mode: 'kelompok',
        );

        await saveActiveTripId(tripId, mode: 'kelompok');
      }

      if (_activeTripId != null) {
        await saveActiveTripId(_activeTripId!, mode: 'kelompok');
      }

      _group = _group.copyWith(isConfirmed: true);
      await saveGroupConfirmation();

      // Ambil checklist yang sudah tersimpan.
      // Tidak ada rekomendasi otomatis.
      await _initializeChecklist();

      _currentSubScreen = PersiapanSubScreen.checklist;
      notifyListeners();

      debugPrint('Checklist kelompok siap untuk trip $_activeTripId');
    } catch (e) {
      debugPrint('Gagal membuka checklist: $e');
    }
  }

  // Persona / Role Simulation
  void setActivePersona(String username) {
    final cleaned = username.replaceAll('@', '').toLowerCase();

    final exists = _groupMembersFromApi.any(
      (m) => m['username'].toString().toLowerCase() == cleaned,
    );

    if (!exists) return;

    _activeUsername = cleaned;
    notifyListeners();
  }

  // Checklist Actions
  void setChecklistFilter(String filter) {
    _checklistFilter = filter;
    notifyListeners();
  }

  bool canToggleItem(ChecklistItem item) {
    debugPrint('===== CEK HAK CHECKLIST =====');
    debugPrint('Username aktif: $_activeUsername');
    debugPrint('Apakah ketua: $isCurrentKetua');
    debugPrint('Nama barang: ${item.nama}');
    debugPrint('Nama PJ: ${item.penanggungJawab}');
    debugPrint('ID PJ barang: ${item.penanggungJawabId}');
    debugPrint('Data anggota: $_groupMembersFromApi');

    if (!isGroupMode) return true;
    if (isCurrentKetua) return true;

    final currentMember = _groupMembersFromApi.where(
      (m) =>
          m['username'].toString().toLowerCase() ==
          _activeUsername.toLowerCase(),
    );

    if (currentMember.isEmpty) {
      debugPrint('Anggota aktif tidak ditemukan');
      return false;
    }

    final currentMemberId = int.tryParse(
      currentMember.first['trip_member_id'].toString(),
    );

    debugPrint('ID anggota aktif: $currentMemberId');

    final result =
        currentMemberId != null && item.penanggungJawabId == currentMemberId;

    debugPrint('Hasil pengecekan: $result');

    return result;
  }

  Future<String?> toggleItemCheck(String id) async {
    final index = _items.indexWhere((it) => it.id == id);
    if (index == -1) return null;

    final item = _items[index];

    if (!canToggleItem(item)) {
      final pj = item.penanggungJawab != null
          ? '@${item.penanggungJawab}'
          : 'Ketua';
      return 'Perlengkapan ini adalah tanggung jawab $pj.';
    }

    final statusBaru = !item.isChecked;

    try {
      await ApiService.updateChecklistStatus(
        id: int.parse(item.id),
        isChecked: statusBaru,
      );

      _items[index] = item.copyWith(isChecked: statusBaru);
      notifyListeners();

      return null;
    } catch (e) {
      debugPrint('Gagal memperbarui status checklist: $e');
      return 'Gagal memperbarui status checklist.';
    }
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

  // Mengatur penanggung jawab perlengkapan kelompok
  Future<void> assignChecklistItem({
    required String itemId,
    required int tripMemberId,
  }) async {
    final index = _items.indexWhere((item) => item.id == itemId);

    if (index == -1) {
      throw Exception('Perlengkapan tidak ditemukan');
    }

    // Cari anggota berdasarkan ID trip_members atau user_id
    final member = _groupMembersFromApi.firstWhere(
      (item) =>
          item['user_id']?.toString() == tripMemberId.toString() ||
          item['trip_member_id']?.toString() == tripMemberId.toString(),
      orElse: () => {'nama': 'Anggota'},
    );

    final oldItem = _items[index];

    // Memisahkan jumlah dan satuan, misalnya "2 unit"
    final parts = oldItem.jumlah.split(' ');
    final jumlah = int.tryParse(parts.first) ?? 1;
    final satuan = parts.length > 1 ? parts.sublist(1).join(' ') : 'buah';

    await ApiService.updateChecklistAssignee(
      id: int.parse(oldItem.id),
      penanggungJawabId: tripMemberId,
      nama: oldItem.nama,
      jumlah: jumlah,
      satuan: satuan,
      kategori: oldItem.isWajib ? 'wajib' : 'opsional',
    );

    // Perbarui data lokal setelah API berhasil
    _items[index] = oldItem.copyWith(
      penanggungJawabId: tripMemberId,
      penanggungJawab: member['nama'].toString(),
    );

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    try {
      await ApiService.deleteChecklist(int.parse(id));

      _items.removeWhere((it) => it.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menghapus perlengkapan: $e');
      rethrow;
    }
  }

  // Change Requests
  // Change Requests

  // Anggota mengajukan perubahan checklist
  Future<void> submitChangeRequest({
    required RequestType jenis,
    String? targetItemId,
    required String namaPerlengkapan,
    String? jumlahBaru,
    ItemCategory? kategoriBaru,
    String? catatanBaru,
    String? penanggungJawabBaru,
    required String alasan,
  }) async {
    try {
      if (_activeTripId == null) {
        throw Exception('ID perjalanan tidak ditemukan');
      }

      if (activeUserId == 0) {
        throw Exception('ID pengguna aktif tidak ditemukan');
      }

      String jenisApi;

      switch (jenis) {
        case RequestType.tambah:
          jenisApi = 'tambah';
          break;
        case RequestType.ubah:
          jenisApi = 'ubah';
          break;
        case RequestType.hapus:
          jenisApi = 'hapus';
          break;
      }

      final jumlah = jumlahBaru == null
          ? null
          : int.tryParse(jumlahBaru.trim().split(' ').first);

      if (jenis == RequestType.tambah && (jumlah == null || jumlah <= 0)) {
        throw Exception('Jumlah perlengkapan harus berupa angka lebih dari 0');
      }

      await ApiService.submitChangeRequest(
        tripId: _activeTripId!,
        pengajuId: activeUserId,
        jenis: jenisApi,
        targetItemId: targetItemId == null ? null : int.tryParse(targetItemId),
        namaPerlengkapan: namaPerlengkapan,
        jumlahBaru: jumlah,
        catatanBaru: catatanBaru,
        alasan: alasan,
      );

      await loadChangeRequests();

      debugPrint('Pengajuan berhasil dikirim');
    } catch (e) {
      debugPrint('Gagal mengajukan perubahan: $e');
      rethrow;
    }
  }

  // Ketua menyetujui pengajuan
  Future<void> approveChangeRequest(String requestId) async {
    try {
      if (!isCurrentKetua) {
        throw Exception('Hanya ketua yang dapat menyetujui pengajuan');
      }

      if (activeUserId == 0) {
        throw Exception('ID ketua tidak ditemukan');
      }

      await ApiService.approveChangeRequest(
        requestId: int.parse(requestId),
        diprosesOleh: activeUserId,
      );

      await _initializeChecklist();
      await loadChangeRequests();

      debugPrint('Pengajuan berhasil disetujui');
    } catch (e) {
      debugPrint('Gagal menyetujui pengajuan: $e');
      rethrow;
    }
  }

  // Ketua menolak pengajuan
  Future<void> rejectChangeRequest(String requestId) async {
    try {
      if (!isCurrentKetua) {
        throw Exception('Hanya ketua yang dapat menolak pengajuan');
      }

      if (activeUserId == 0) {
        throw Exception('ID ketua tidak ditemukan');
      }

      await ApiService.rejectChangeRequest(
        requestId: int.parse(requestId),
        diprosesOleh: activeUserId,
      );

      await loadChangeRequests();

      debugPrint('Pengajuan berhasil ditolak');
    } catch (e) {
      debugPrint('Gagal menolak pengajuan: $e');
      rethrow;
    }
  }
}
