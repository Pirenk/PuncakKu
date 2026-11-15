import 'package:flutter/material.dart';
import '../../models/gunung_model.dart';
import '../../models/trip_plan.dart';
import '../../services/api_service.dart';
import '../../state/pendaki_state.dart';
import '../persiapan/checklist_screen.dart';
import '../persiapan/persiapan_hub_screen.dart';

class DetailGunungScreen extends StatefulWidget {
  final int gunungId;
  final GunungModel? initialGunung;
  final PendakiState? state;
  final Function(int targetTab)? onSwitchTab;

  const DetailGunungScreen({
    super.key,
    required this.gunungId,
    this.initialGunung,
    this.state,
    this.onSwitchTab,
  });

  @override
  State<DetailGunungScreen> createState() => _DetailGunungScreenState();
}

class _DetailGunungScreenState extends State<DetailGunungScreen> {
  GunungModel? _gunung;
  bool _isLoading = true;
  bool _isBookmarked = false;
  int _selectedJalurIndex = 0;

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);

  @override
  void initState() {
    super.initState();
    _gunung = widget.initialGunung;
    _fetchDetailGunung();
  }

  Future<void> _fetchDetailGunung() async {
    try {
      final data = await ApiService.getDetailGunung(widget.gunungId);
      if (data != null && mounted) {
        setState(() {
          _gunung = GunungModel.fromJson(data);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gunung = _gunung;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail gunung',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
              color: _primaryDark,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Gunung disimpan ke penanda.'
                        : 'Penanda dihapus.',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _primaryDark,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading && gunung == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B4D3E)),
            )
          : gunung == null
              ? const Center(
                  child: Text('Data gunung tidak ditemukan'),
                )
              : _buildContent(gunung),
      bottomNavigationBar: gunung != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final jalurList = gunung.jalurPendakian;
                      final selectedJalurName = (jalurList.isNotEmpty && _selectedJalurIndex < jalurList.length)
                          ? jalurList[_selectedJalurIndex].namaJalur
                          : (jalurList.isNotEmpty
                              ? jalurList.first.namaJalur
                              : 'Jalur Utama');

                      // Tampilkan loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (c) => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF1B4D3E)),
                        ),
                      );

                      try {
                        final pState = widget.state ?? PendakiState();
                        final updatedPlan = pState.plan.copyWith(
                          gunung: gunung.nama,
                          jalur: selectedJalurName,
                        );
                        pState.updateTripPlan(updatedPlan);

                        // Siapkan perjalanan pribadi dan checklist di database
                        await pState.createSoloTripAndChecklist();

                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading

                          // Jika onSwitchTab tersedia, langsung pindah ke Tab Persiapan (index 2)
                          if (widget.onSwitchTab != null) {
                            Navigator.pop(context); // Tutup DetailGunungScreen kembali ke tab utama
                            widget.onSwitchTab!(2); // Beralih ke menu Persiapan (Checklist)
                          } else {
                            // Fallback jika dibuka terpisah
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChecklistScreen(state: pState),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyiapkan checklist: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.checklist_outlined, size: 20),
                    label: Text(
                      'Siapkan checklist ${gunung.nama.replaceAll('Gunung ', '')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(GunungModel gunung) {
    final jalurList = gunung.jalurPendakian;
    final currentJalur = (jalurList.isNotEmpty && _selectedJalurIndex < jalurList.length)
        ? jalurList[_selectedJalurIndex]
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Gunung
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                gunung.fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.landscape, size: 60, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle / Lokasi Singkat
          Text(
            gunung.lokasi.split(',').last.trim(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),

          // Nama Gunung
          Text(
            gunung.nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF182A22),
            ),
          ),
          const SizedBox(height: 6),

          // Lokasi lengkap
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: _primaryDark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  gunung.lokasi,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Cards (Ketinggian, Kesulitan, Estimasi Trip)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  title: '${gunung.ketinggianMdpl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} m',
                  subtitle: 'Ketinggian',
                ),
                Container(width: 1, height: 35, color: Colors.grey.shade200),
                _buildInfoColumn(
                  title: gunung.tingkatKesulitan,
                  subtitle: 'Kesulitan',
                ),
                Container(width: 1, height: 35, color: Colors.grey.shade200),
                _buildInfoColumn(
                  title: gunung.estimasiDurasi,
                  subtitle: 'Estimasi trip',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tentang Gunung
          Text(
            'Tentang ${gunung.nama.replaceAll('Gunung ', '')}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF182A22),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gunung.deskripsi,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),

          // Jalur Pendakian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jalur pendakian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              if (jalurList.length > 1)
                Text(
                  '${jalurList.length} Pilihan jalur',
                  style: TextStyle(
                    fontSize: 12,
                    color: _primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Jalur Selector jika ada lebih dari 1
          if (jalurList.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(jalurList.length, (index) {
                  final j = jalurList[index];
                  final isSelected = index == _selectedJalurIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        j.namaJalur,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : const Color(0xFF182A22),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _primaryDark,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? _primaryDark : Colors.grey.shade300,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedJalurIndex = index);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),

            // Card Jalur Aktif
            if (currentJalur != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentJalur.namaJalur,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF182A22),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pilihan trip',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentJalur.deskripsi,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Estimasi naik ${currentJalur.estimasiNaik} ke puncak',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB78103),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Durasi dipengaruhi cuaca, beban, dan kondisi fisik.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'Informasi jalur pendakian belum tersedia untuk gunung ini.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Basecamp Info
          if (currentJalur != null) ...[
            Text(
              currentJalur.namaBasecamp,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentJalur.namaBasecamp.replaceFirst("Basecamp ", "")}, ${gunung.lokasi.split(",").first}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Konfirmasi kuota, jadwal buka dan kebutuhan registrasi langsung ke pengelola.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka rute peta ${currentJalur.namaBasecamp}...'),
                          backgroundColor: _primaryDark,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 16, color: _primaryDark),
                        const SizedBox(width: 6),
                        Text(
                          'Lihat basecamp di peta →',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Aturan & Keselamatan
          const Text(
            'Aturan & keselamatan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF182A22),
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleItem('Ikuti jalur resmi dan arahan petugas.'),
          _buildRuleItem('Bawa turun seluruh sampah.'),
          _buildRuleItem('Jangan menyalakan api sembarangan.'),
          _buildRuleItem('Periksa syarat izin dan perlengkapan ke basecamp sebelum berangkat.'),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({required String title, required String subtitle}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF182A22),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF182A22),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
