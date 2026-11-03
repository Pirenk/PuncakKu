import 'package:flutter/material.dart';
import '../../models/change_request.dart';
import '../../state/pendaki_state.dart';
import '../../widgets/badge_status.dart';
import '../../widgets/role_switcher_bar.dart';

class PermintaanScreen extends StatefulWidget {
  final PendakiState state;

  const PermintaanScreen({super.key, required this.state});

  @override
  State<PermintaanScreen> createState() => _PermintaanScreenState();
}

class _PermintaanScreenState extends State<PermintaanScreen> {
  final Color _primaryDark = const Color(0xFF1B4D3E);

  void _showNewRequestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NewRequestModal(state: widget.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.state.changeRequests;
    final isKetua = widget.state.isCurrentKetua;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () {
            // Kembali ke Checklist
            widget.state.navigateToSubScreen(PersiapanSubScreen.checklist);
          },
        ),
        title: const Text(
          'Permintaan Perubahan',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_outlined, size: 20),
        label: const Text(
          'Ajukan Permintaan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _showNewRequestDialog,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Switcher for simulation
            RoleSwitcherBar(state: widget.state),

            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7E2D2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1B4D3E), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isKetua
                          ? 'Sebagai Ketua, kamu dapat menyetujui atau menolak usulan perubahan perlengkapan dari anggota.'
                          : 'Sebagai Anggota (@${widget.state.activeUsername}), kamu dapat mengajukan usulan penambahan, pengeditan, atau penghapusan barang ke Ketua.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF355E4E),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Permintaan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                Text(
                  '${requests.length} usulan',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (requests.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada permintaan perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF182A22),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Anggota dapat mengusulkan perubahan perlengkapan kapan saja.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _buildRequestCard(req, isKetua);
                },
              ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(ChangeRequest req, bool isKetua) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isMenunggu ? const Color(0xFFFDE68A) : Colors.grey.shade300,
          width: req.isMenunggu ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Requester + Request Type + Status Badge
          Row(
            children: [
              RequestTypeBadge(type: req.jenis),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Oleh @${req.pengaju}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF182A22),
                  ),
                ),
              ),
              RequestStatusBadge(status: req.status),
            ],
          ),
          const SizedBox(height: 10),

          // Item Name
          Text(
            req.namaPerlengkapan,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF182A22),
            ),
          ),
          const SizedBox(height: 4),

          // Proposed changes description
          if (req.jumlahBaru != null || req.catatanBaru != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (req.jumlahBaru != null)
                    Text(
                      'Jumlah baru: ${req.jumlahBaru}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  if (req.catatanBaru != null && req.catatanBaru!.isNotEmpty)
                    Text(
                      'Catatan baru: ${req.catatanBaru}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          ],

          // Reason
          Text(
            'Alasan: "${req.alasan}"',
            style: TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          // Actions for Ketua if status is Menunggu
          if (req.isMenunggu && isKetua) ...[
            const Divider(),
            const SizedBox(height: 4),
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
                      widget.state.rejectChangeRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Permintaan perubahan ditolak.')),
                      );
                    },
                    child: const Text('Tolak Usulan', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      widget.state.approveChangeRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Permintaan disetujui! Data checklist telah diperbarui.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Setujui Usulan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NewRequestModal extends StatefulWidget {
  final PendakiState state;

  const _NewRequestModal({required this.state});

  @override
  State<_NewRequestModal> createState() => _NewRequestModalState();
}

class _NewRequestModalState extends State<_NewRequestModal> {
  RequestType _jenis = RequestType.tambah;
  String? _selectedItemId;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();

  final Color _primaryDark = const Color(0xFF1B4D3E);

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  void _submit() {
    String namaBarang = '';
    if (_jenis == RequestType.tambah) {
      namaBarang = _namaController.text.trim();
      if (namaBarang.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama perlengkapan harus diisi.')),
        );
        return;
      }
    } else {
      if (_selectedItemId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih perlengkapan yang ingin diubah/dihapus.')),
        );
        return;
      }
      final target =
          widget.state.items.firstWhere((it) => it.id == _selectedItemId);
      namaBarang = target.nama;
    }

    final alasan = _alasanController.text.trim();
    if (alasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap sertakan alasan permintaan.')),
      );
      return;
    }

    widget.state.submitChangeRequest(
      jenis: _jenis,
      targetItemId: _selectedItemId,
      namaPerlengkapan: namaBarang,
      jumlahBaru: _jumlahController.text.trim().isNotEmpty
          ? _jumlahController.text.trim()
          : null,
      catatanBaru: _catatanController.text.trim().isNotEmpty
          ? _catatanController.text.trim()
          : null,
      alasan: alasan,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permintaan berhasil diajukan kepada Ketua kelompok.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ajukan Permintaan ke Ketua',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Perubahan akan diterapkan pada checklist setelah disetujui Ketua.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),

            // Jenis Permintaan
            const Text(
              'Jenis Permintaan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip(RequestType.tambah, '+ Tambah'),
                const SizedBox(width: 8),
                _buildTypeChip(RequestType.ubah, '✎ Ubah'),
                const SizedBox(width: 8),
                _buildTypeChip(RequestType.hapus, '✕ Hapus'),
              ],
            ),
            const SizedBox(height: 16),

            // Target Item Selection for Ubah/Hapus
            if (_jenis != RequestType.tambah) ...[
              const Text(
                'Pilih Perlengkapan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedItemId,
                    hint: const Text('Pilih barang'),
                    isExpanded: true,
                    items: widget.state.items.map((it) {
                      return DropdownMenuItem<String>(
                        value: it.id,
                        child: Text(
                          '${it.nama} (${it.jumlah})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedItemId = val;
                        if (val != null && _jenis == RequestType.ubah) {
                          final item =
                              widget.state.items.firstWhere((it) => it.id == val);
                          _jumlahController.text = item.jumlah;
                          _catatanController.text = item.catatan;
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Nama barang for Tambah
              const Text(
                'Nama Perlengkapan Baru',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Flysheet tambahan',
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Details for Tambah / Ubah
            if (_jenis != RequestType.hapus) ...[
              const Text(
                'Jumlah yang Diusulkan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _jumlahController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 2 buah',
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catatan Usulan (opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _catatanController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Cadangan jika tenda bocor',
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Alasan
            const Text(
              'Alasan Permintaan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _alasanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan mengapa perubahan ini diperlukan tim...',
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: const Text(
                  'Kirim Permintaan ke Ketua',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(RequestType type, String label) {
    final isSelected = _jenis == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _jenis = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _primaryDark : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF182A22),
            ),
          ),
        ),
      ),
    );
  }
}
