import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/models/change_request.dart';
import 'package:mobile_pendakian/models/group_member.dart';
import 'package:mobile_pendakian/models/trip_plan.dart';
import 'package:mobile_pendakian/state/pendaki_state.dart';

void main() {
  group('PendakiState - Alur Rencana Pendakian & Kelompok', () {
    late PendakiState state;

    setUp(() {
      state = PendakiState();
    });

    test('Alur 1: Jika jumlah anggota 1 (Solo), lewati pembuatan kelompok', () {
      state.updateTripPlan(const TripPlan(
        id: 'plan_solo',
        gunung: 'Gunung Prau',
        jalur: 'via Patakbanteng',
        jenisPerjalanan: JenisPerjalanan.tektok,
        durasi: '1 hari (Tek-tok / PP)',
        jumlahAnggota: 1,
      ));

      expect(state.plan.isSolo, isTrue);

      // Handle continue
      state.handleRencanaContinue();

      // Langsung ke checklist pribadi
      expect(state.currentSubScreen, PersiapanSubScreen.checklist);
      expect(state.isGroupMode, isFalse);

      // Kembali dari checklist pribadi harus menuju rencana pendakian tanpa hapus data
      state.backFromChecklist();
      expect(state.currentSubScreen, PersiapanSubScreen.rencana);
      expect(state.plan.gunung, 'Gunung Prau');
    });

    test('Alur 2: Jika anggota > 1, arahkan ke pembuatan kelompok', () {
      state.updateTripPlan(const TripPlan(
        id: 'plan_group',
        gunung: 'Gunung Merbabu',
        jalur: 'via Selo',
        jenisPerjalanan: JenisPerjalanan.berkemah,
        durasi: '2 hari · 1 malam',
        jumlahAnggota: 4,
      ));

      expect(state.plan.isSolo, isFalse);

      state.handleRencanaContinue();

      // Menuju halaman kelompok
      expect(state.currentSubScreen, PersiapanSubScreen.kelompok);

      // Checklist belum terkonfirmasi
      expect(state.isGroupConfirmed, isFalse);
    });

    test('Alur 3: Validasi input undangan anggota', () {
      // 1. Kosong
      final errEmpty = state.inviteMember('');
      expect(errEmpty, contains('tidak boleh kosong'));

      // 2. Diri sendiri / ketua
      final errSelf = state.inviteMember('ryan');
      expect(errSelf, contains('diri sendiri'));

      // 3. Duplikat (budi sudah ada di seeded members)
      final errDup = state.inviteMember('budi');
      expect(errDup, contains('sudah pernah diundang'));

      // 4. Sukses
      final errSuccess = state.inviteMember('dewi');
      expect(errSuccess, isNull);
      expect(state.group.members.any((m) => m.username == 'dewi'), isTrue);
    });

    test('Alur 4: Simulasi penerimaan & penolakan undangan anggota', () {
      final siti = state.group.members.firstWhere((m) => m.username == 'siti');
      expect(siti.status, MemberStatus.menunggu);

      // Simulasi terima
      state.simulateMemberResponse(siti.id, MemberStatus.diterima);
      final sitiAccepted =
          state.group.members.firstWhere((m) => m.username == 'siti');
      expect(sitiAccepted.status, MemberStatus.diterima);

      // Simulasi tolak
      final andi = state.group.members.firstWhere((m) => m.username == 'andi');
      state.simulateMemberResponse(andi.id, MemberStatus.ditolak);
      final andiRejected =
          state.group.members.firstWhere((m) => m.username == 'andi');
      expect(andiRejected.status, MemberStatus.ditolak);

      // Anggota yang menolak tidak masuk ke acceptedMembers
      expect(state.group.acceptedMembers.any((m) => m.username == 'andi'),
          isFalse);
    });

    test('Alur 5: Tombol Buat Kelompok dapat ditekan walau ada undangan menunggu',
        () {
      expect(state.group.isConfirmed, isFalse);

      // Konfirmasi dan buat checklist
      state.confirmGroupAndCreateChecklist();

      expect(state.group.isConfirmed, isTrue);
      expect(state.currentSubScreen, PersiapanSubScreen.checklist);

      // Status anggota menunggu tetap akurat setelah checklist dibuka
      final andi = state.group.members.firstWhere((m) => m.username == 'andi');
      expect(andi.isMenunggu, isTrue);
    });

    test('Alur 6: Hak akses Ketua vs Anggota pada Checklist Kelompok', () {
      // Setup group
      state.confirmGroupAndCreateChecklist();

      final firstItem = state.items.first;

      // Ketua (@ryan) dapat toggle item apapun
      state.setActivePersona('ryan');
      expect(state.isCurrentKetua, isTrue);
      expect(state.canToggleItem(firstItem), isTrue);

      // Anggota (@budi) hanya dapat toggle item yang menjadi tanggung jawabnya
      state.setActivePersona('budi');
      expect(state.isCurrentKetua, isFalse);

      final budiItem = state.items.firstWhere(
        (it) => it.penanggungJawab == 'budi',
        orElse: () => firstItem,
      );

      if (budiItem.penanggungJawab == 'budi') {
        expect(state.canToggleItem(budiItem), isTrue);
      }

      // Cari item yang BUKAN tanggung jawab budi
      final notBudiItem = state.items.firstWhere(
        (it) => it.penanggungJawab != 'budi',
      );
      expect(state.canToggleItem(notBudiItem), isFalse);

      final errToggle = state.toggleItemCheck(notBudiItem.id);
      expect(errToggle, contains('tanggung jawab'));
    });

    test('Alur 7: Permintaan Perubahan (Submit, Setujui, Tolak)', () {
      state.confirmGroupAndCreateChecklist();

      // Anggota budi mengajukan tambah barang
      state.setActivePersona('budi');
      final initialCount = state.items.length;

      state.submitChangeRequest(
        jenis: RequestType.tambah,
        namaPerlengkapan: 'Flysheet Tambahan 4x6',
        jumlahBaru: '1 lembar',
        alasan: 'Antisipasi hujan lebat di pos 3 Merbabu',
      );

      final latestReq = state.changeRequests.first;
      expect(latestReq.namaPerlengkapan, 'Flysheet Tambahan 4x6');
      expect(latestReq.status, RequestStatus.menunggu);

      // Checklist belum bertambah sebelum disetujui
      expect(state.items.length, initialCount);

      // Ketua ryan menyetujui permintaan
      state.setActivePersona('ryan');
      state.approveChangeRequest(latestReq.id);

      final approvedReq =
          state.changeRequests.firstWhere((r) => r.id == latestReq.id);
      expect(approvedReq.status, RequestStatus.disetujui);

      // Sekarang checklist bertambah 1 item
      expect(state.items.length, initialCount + 1);
      expect(state.items.any((it) => it.nama == 'Flysheet Tambahan 4x6'),
          isTrue);

      // Uji tolak permintaan
      state.submitChangeRequest(
        jenis: RequestType.hapus,
        targetItemId: state.items.first.id,
        namaPerlengkapan: state.items.first.nama,
        alasan: 'Barang tidak diperlukan',
      );

      final reqToReject = state.changeRequests.first;
      state.rejectChangeRequest(reqToReject.id);

      final rejectedReq =
          state.changeRequests.firstWhere((r) => r.id == reqToReject.id);
      expect(rejectedReq.status, RequestStatus.ditolak);
    });

    test('Alur 8: Undangan masuk (Terima dan Tolak)', () {
      final initialInvite = state.incomingInvitations.first;
      expect(initialInvite.isMenunggu, isTrue);

      // Terima undangan
      state.acceptIncomingInvitation(initialInvite.id);
      final acceptedInv = state.incomingInvitations
          .firstWhere((inv) => inv.id == initialInvite.id);
      expect(acceptedInv.isDiterima, isTrue);

      // Tolak undangan kedua
      final secondInvite = state.incomingInvitations[1];
      state.rejectIncomingInvitation(secondInvite.id);
      final rejectedInv = state.incomingInvitations
          .firstWhere((inv) => inv.id == secondInvite.id);
      expect(rejectedInv.isDitolak, isTrue);
    });
  });
}
