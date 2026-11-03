import 'package:flutter/material.dart';
import '../state/pendaki_state.dart';

class RoleSwitcherBar extends StatelessWidget {
  final PendakiState state;

  const RoleSwitcherBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.isGroupMode) return const SizedBox.shrink();

    final isKetua = state.isCurrentKetua;
    const primaryDark = Color(0xFF1B4D3E);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isKetua ? const Color(0xFFEBF3EE) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isKetua ? const Color(0xFFC7E2D2) : const Color(0xFFBFDBFE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isKetua ? Icons.admin_panel_settings_outlined : Icons.person_outline,
            size: 20,
            color: isKetua ? primaryDark : const Color(0xFF1D4ED8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Simulasi Peran: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      isKetua ? 'Ketua (@ryan)' : 'Anggota (@${state.activeUsername})',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isKetua ? primaryDark : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
                Text(
                  isKetua
                      ? 'Hak penuh: tambah, ubah, hapus, & kelola permintaan'
                      : 'Hanya centang tugasmu & ajukan permintaan perubahan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showRolePicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ganti',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 16, color: primaryDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRolePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final accepted = state.group.acceptedMembers;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  'Pilih Peran untuk Simulasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uji coba hak akses sebagai Ketua atau Anggota kelompok.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                // Ketua Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1B4D3E),
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                  ),
                  title: const Text('Ryan (Ketua)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Akses penuh kelola barang & persetujuan'),
                  trailing: state.isCurrentKetua
                      ? const Icon(Icons.check_circle, color: Color(0xFF1B4D3E))
                      : null,
                  onTap: () {
                    state.setActivePersona('ryan');
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(),

                // Accepted Members
                ...accepted.where((m) => !m.isKetua).map((m) {
                  final isSelected = state.activeUsername == m.username;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        m.username[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      '${m.nama} (@${m.username})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Hanya centang tugas sendiri & kirim permintaan'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF1B4D3E))
                        : null,
                    onTap: () {
                      state.setActivePersona(m.username);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
