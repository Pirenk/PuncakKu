import 'package:flutter/material.dart';
import '../../data/mountain_data.dart';
import '../../models/trip_plan.dart';
import '../../state/pendaki_state.dart';

class RencanaPendakianScreen extends StatefulWidget {
  final PendakiState state;

  const RencanaPendakianScreen({super.key, required this.state});

  @override
  State<RencanaPendakianScreen> createState() => _RencanaPendakianScreenState();
}

class _RencanaPendakianScreenState extends State<RencanaPendakianScreen> {
  late String _selectedGunung;
  late String _selectedJalur;
  late JenisPerjalanan _selectedJenis;
  late String _selectedDurasi;
  late int _jumlahAnggota;

  final Color _primaryDark = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    _loadFromState();
  }

  void _loadFromState() {
    final p = widget.state.plan;
    _selectedGunung = p.gunung;
    _selectedJalur = p.jalur;
    _selectedJenis = p.jenisPerjalanan;
    _selectedDurasi = p.durasi;
    _jumlahAnggota = p.jumlahAnggota;
  }

  void _saveToState() {
    final updatedPlan = TripPlan(
      id: widget.state.plan.id,
      gunung: _selectedGunung,
      jalur: _selectedJalur,
      jenisPerjalanan: _selectedJenis,
      durasi: _selectedDurasi,
      jumlahAnggota: _jumlahAnggota,
    );
    widget.state.updateTripPlan(updatedPlan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () {
            // Optional: can show a notice or navigate to Beranda
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kamu sedang berada di langkah awal persiapan.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        title: const Text(
          'Checklist',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill Badge: Langkah 1 dari 2 · Rencana trip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EFE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _jumlahAnggota > 1
                    ? 'Langkah 1 dari 2 · Rencana trip'
                    : 'Rencana trip solo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Headline
            const Text(
              'Persiapan yang pas\nuntuk perjalananmu.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Isi rencana, lalu gunakan rekomendasi sebagai titik awal perlengkapanmu.',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Form Field 1: Gunung tujuan
            _buildFieldLabel('Gunung tujuan'),
            const SizedBox(height: 8),
            _buildSelectorCard(
              title: '$_selectedGunung · $_selectedJalur',
              icon: Icons.keyboard_arrow_down,
              onTap: _showMountainPicker,
            ),
            const SizedBox(height: 20),

            // Form Field 2: Jenis perjalanan
            _buildFieldLabel('Jenis perjalanan'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildChoiceChip(
                  label: 'Berkemah',
                  isSelected: _selectedJenis == JenisPerjalanan.berkemah,
                  onSelected: () {
                    setState(() {
                      _selectedJenis = JenisPerjalanan.berkemah;
                      if (!MountainData.durasiBerkemah.contains(_selectedDurasi)) {
                        _selectedDurasi = MountainData.durasiBerkemah.first;
                      }
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildChoiceChip(
                  label: 'Tek-tok',
                  isSelected: _selectedJenis == JenisPerjalanan.tektok,
                  onSelected: () {
                    setState(() {
                      _selectedJenis = JenisPerjalanan.tektok;
                      _selectedDurasi = MountainData.durasiTektok.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form Field 3: Durasi
            _buildFieldLabel('Durasi'),
            const SizedBox(height: 8),
            _buildSelectorCard(
              title: _selectedDurasi,
              icon: Icons.keyboard_arrow_down,
              onTap: _showDurationPicker,
            ),
            const SizedBox(height: 20),

            // Form Field 4: Jumlah anggota
            _buildFieldLabel('Jumlah anggota'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_jumlahAnggota orang${_jumlahAnggota == 1 ? ' (Solo)' : ' (Kelompok)'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF182A22),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _jumlahAnggota > 1 ? _primaryDark : Colors.grey.shade400,
                    ),
                    onPressed: _jumlahAnggota > 1
                        ? () {
                            setState(() {
                              _jumlahAnggota--;
                            });
                          }
                        : null,
                  ),
                  Text(
                    '$_jumlahAnggota',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _jumlahAnggota < 12 ? _primaryDark : Colors.grey.shade400,
                    ),
                    onPressed: _jumlahAnggota < 12
                        ? () {
                            setState(() {
                              _jumlahAnggota++;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _jumlahAnggota == 1 ? Icons.person_outline : Icons.groups_outlined,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _jumlahAnggota == 1
                  ? 'Pendakian 1 orang akan langsung membuka checklist perlengkapan pribadi.'
                  : 'Jumlah anggota mencakup ketua (1 ketua + ${_jumlahAnggota - 1} anggota).',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Big CTA Button: Buat rekomendasi perlengkapan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  _saveToState();
                  widget.state.handleRencanaContinue();
                },
                child: Text(
                  _jumlahAnggota == 1
                      ? 'Buat rekomendasi perlengkapan pribadi'
                      : 'Lanjutkan ke pembuatan kelompok',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF182A22),
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF182A22),
                ),
              ),
            ),
            Icon(icon, color: Colors.grey.shade600, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryDark : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF182A22),
            ),
          ),
        ),
      ),
    );
  }

  void _showMountainPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
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
                      'Pilih Gunung & Jalur Pendakian',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF182A22),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Daftar gunung populer di wilayah Jawa Tengah',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: MountainData.daftarGunungJateng.length,
                        itemBuilder: (context, index) {
                          final mountain = MountainData.daftarGunungJateng[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: mountain.nama == _selectedGunung,
                              leading: const Icon(Icons.terrain, color: Color(0xFF1B4D3E)),
                              title: Text(
                                '${mountain.nama} (${mountain.ketinggianMdpl} mdpl)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                mountain.deskripsi,
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              children: mountain.jalurList.map((jalur) {
                                final isChosen = mountain.nama == _selectedGunung &&
                                    jalur == _selectedJalur;
                                return ListTile(
                                  title: Text(
                                    jalur,
                                    style: TextStyle(
                                      fontWeight:
                                          isChosen ? FontWeight.bold : FontWeight.normal,
                                      color: isChosen
                                          ? _primaryDark
                                          : const Color(0xFF182A22),
                                    ),
                                  ),
                                  trailing: isChosen
                                      ? Icon(Icons.check_circle, color: _primaryDark)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedGunung = mountain.nama;
                                      _selectedJalur = jalur;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDurationPicker() {
    final options = _selectedJenis == JenisPerjalanan.berkemah
        ? MountainData.durasiBerkemah
        : MountainData.durasiTektok;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                  'Pilih Durasi Pendakian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isChosen = opt == _selectedDurasi;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                        color: isChosen ? _primaryDark : const Color(0xFF182A22),
                      ),
                    ),
                    trailing: isChosen
                        ? Icon(Icons.check_circle, color: _primaryDark)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedDurasi = opt;
                      });
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
