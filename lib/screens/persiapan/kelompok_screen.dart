import 'package:flutter/material.dart';
import '../../models/group_member.dart';
import '../../state/pendaki_state.dart';
import '../../widgets/badge_status.dart';

class KelompokScreen extends StatefulWidget {
  final PendakiState state;

  const KelompokScreen({super.key, required this.state});

  @override
  State<KelompokScreen> createState() => _KelompokScreenState();
}

class _KelompokScreenState extends State<KelompokScreen> {
  late TextEditingController _namaKelompokController;
  final TextEditingController _usernameController = TextEditingController();
  String? _inviteErrorText;

  final Color _primaryDark = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    _namaKelompokController =
        TextEditingController(text: widget.state.group.namaKelompok);
  }

  @override
  void dispose() {
    _namaKelompokController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleInvite() {
    final error = widget.state.inviteMember(_usernameController.text);
    if (error != null) {
      setState(() {
        _inviteErrorText = error;
      });
    } else {
      setState(() {
        _inviteErrorText = null;
        _usernameController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Undangan berhasil dikirim (status: Menunggu).'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.state.group;
    final plan = widget.state.plan;
    final joined = group.joinedCount;
    final target = group.targetCount;
    final isFull = group.isAllAccepted;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () {
            // Kembali ke Rencana Pendakian tanpa menghapus data yang sudah diisi
            widget.state.backFromKelompok();
          },
        ),
        title: const Text(
          'Kelompok Pendakian',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC7E2D2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terrain, color: Color(0xFF1B4D3E), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.judulPendakian,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4D3E),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.state.backFromKelompok(),
                        child: const Text(
                          'Ubah rencana',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4D3E),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${plan.jenisString} · ${plan.durasi} · Target: $target anggota (1 ketua + ${target - 1} anggota)',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama Kelompok Input
            const Text(
              'Nama Kelompok',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _namaKelompokController,
                onChanged: (val) => widget.state.updateGroupName(val),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Tim Merbabu Selo',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.groups, color: Color(0xFF1B4D3E)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Undangan Anggota Form
            const Text(
              'Undang Anggota Kelompok',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _inviteErrorText != null
                            ? Colors.red.shade400
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      onChanged: (val) {
                        if (_inviteErrorText != null) {
                          setState(() {
                            _inviteErrorText = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _handleInvite(),
                      decoration: const InputDecoration(
                        hintText: 'Ketik username, misal: siti',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: InputBorder.none,
                        prefixText: '@ ',
                        prefixStyle: TextStyle(
                          color: Color(0xFF1B4D3E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _handleInvite,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Undang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (_inviteErrorText != null) ...[
              const SizedBox(height: 6),
              Text(
                _inviteErrorText!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ],
            const SizedBox(height: 20),

            // Daftar Anggota yang Diundang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Anggota',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                Text(
                  '$joined / $target bergabung',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isFull ? const Color(0xFF166534) : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Member list container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.members.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final member = group.members[index];
                  return _buildMemberTile(member);
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '💡 Tips: Gunakan tombol simulasi di samping nama anggota untuk menguji status Diterima / Ditolak.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Section: Undangan Masuk
            _buildIncomingInvitationsSection(),
            const SizedBox(height: 24),

            // Status Banner Sebelum Tombol Buat Kelompok
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFull ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFull ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFull
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: isFull ? const Color(0xFF166534) : const Color(0xFFB45309),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isFull
                          ? 'Semua anggota yang dibutuhkan telah bergabung ($joined/$target).'
                          : 'Menunggu semua anggota menerima undangan ($joined/$target bergabung).',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isFull ? const Color(0xFF166534) : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tombol "Buat Kelompok"
            // CATATAN PENTING: Tombol HARUS tetap dapat ditekan meskipun masih ada undangan yang menunggu!
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  widget.state.confirmGroupAndCreateChecklist();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFull
                            ? 'Kelompok "${group.namaKelompok}" berhasil dibuat! Membuka checklist.'
                            : 'Kelompok "${group.namaKelompok}" dikonfirmasi untuk simulasi.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Buat Kelompok',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: member.isKetua
                ? const Color(0xFF1B4D3E)
                : const Color(0xFFEBF3EE),
            child: Text(
              member.username[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: member.isKetua ? Colors.white : const Color(0xFF1B4D3E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${member.username}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF182A22),
                      ),
                    ),
                    const SizedBox(width: 6),
                    RoleBadge(role: member.role),
                  ],
                ),
                Text(
                  member.nama,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: member.status),
          const SizedBox(width: 6),

          // Simulation popup menu for testing member response
          if (!member.isKetua)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
              tooltip: 'Simulasi Respon Undangan',
              onSelected: (val) {
                if (val == 'terima') {
                  widget.state.simulateMemberResponse(member.id, MemberStatus.diterima);
                } else if (val == 'tolak') {
                  widget.state.simulateMemberResponse(member.id, MemberStatus.ditolak);
                } else if (val == 'menunggu') {
                  widget.state.simulateMemberResponse(member.id, MemberStatus.menunggu);
                } else if (val == 'hapus') {
                  widget.state.removeMember(member.id);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'terima',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Simulasi: Terima Undangan'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'tolak',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Simulasi: Tolak Undangan'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'menunggu',
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Simulasi: Reset ke Menunggu'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'hapus',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus dari Daftar'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildIncomingInvitationsSection() {
    final invites = widget.state.incomingInvitations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Undangan Masuk',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${invites.length} undangan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (invites.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'Tidak ada undangan masuk saat ini.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final inv = invites[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          inv.namaKelompok,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF182A22),
                          ),
                        ),
                        StatusBadge(status: inv.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diundang oleh @${inv.pengundang} · ${inv.gunung} (${inv.jalur})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    Text(
                      'Jadwal: ${inv.tanggal}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                    ),
                    if (inv.isMenunggu) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                widget.state.rejectIncomingInvitation(inv.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Undangan dari "${inv.namaKelompok}" ditolak.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Tolak', style: TextStyle(fontSize: 12.5)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                              ),
                              onPressed: () {
                                widget.state.acceptIncomingInvitation(inv.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Undangan dari "${inv.namaKelompok}" diterima!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Terima', style: TextStyle(fontSize: 12.5)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
