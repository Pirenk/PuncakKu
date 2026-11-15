import 'package:flutter/material.dart';
import '../../models/gunung_model.dart';
import '../../services/api_service.dart';
import '../../state/pendaki_state.dart';
import 'detail_gunung_screen.dart';

class CariGunungScreen extends StatefulWidget {
  final PendakiState? state;
  final Function(int targetTab)? onSwitchTab;

  const CariGunungScreen({super.key, this.state, this.onSwitchTab});

  @override
  State<CariGunungScreen> createState() => _CariGunungScreenState();
}

class _CariGunungScreenState extends State<CariGunungScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GunungModel> _gunungList = [];
  bool _isLoading = true;
  String _selectedKesulitan = 'Semua';
  String _selectedLokasi = '';

  final List<String> _kesulitanOptions = ['Semua', 'Pemula', 'Menengah', 'Sulit'];
  final List<String> _lokasiOptions = [
    'Semua Lokasi',
    'Boyolali',
    'Wonosobo',
    'Purbalingga',
    'Temanggung',
    'Karanganyar',
  ];

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);

  @override
  void initState() {
    super.initState();
    _fetchGunung();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGunung() async {
    setState(() => _isLoading = true);

    try {
      final res = await ApiService.getDaftarGunung(
        search: _searchController.text.trim(),
        kesulitan: _selectedKesulitan == 'Semua' ? '' : _selectedKesulitan,
        lokasi: _selectedLokasi == 'Semua Lokasi' ? '' : _selectedLokasi,
      );

      if (mounted) {
        setState(() {
          _gunungList = res.map((item) => GunungModel.fromJson(item)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLokasiFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Wilayah / Lokasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _lokasiOptions.map((loc) {
                    final isSelected = (_selectedLokasi.isEmpty && loc == 'Semua Lokasi') ||
                        _selectedLokasi == loc;
                    return ChoiceChip(
                      label: Text(loc),
                      selected: isSelected,
                      selectedColor: _primaryDark,
                      backgroundColor: const Color(0xFFF0F4F2),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF182A22),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedLokasi = (loc == 'Semua Lokasi') ? '' : loc;
                        });
                        Navigator.pop(context);
                        _fetchGunung();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.landscape_outlined, color: _primaryDark, size: 22),
            ),
            const SizedBox(width: 8),
            const Text(
              'Jelajahi gunung',
              style: TextStyle(
                color: Color(0xFF182A22),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF182A22)),
            onPressed: _showLokasiFilterDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryDark,
        onRefresh: _fetchGunung,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              const Text(
                'Temukan perjalanan\nyang cocok untukmu.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF182A22),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),

              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetchGunung(),
                  decoration: InputDecoration(
                    hintText: 'Cari gunung atau lokasi',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _fetchGunung();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips (Semua, Pemula, Menengah, Lokasi)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._kesulitanOptions.map((opt) {
                      final isSelected = _selectedKesulitan == opt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(opt),
                          selected: isSelected,
                          selectedColor: _primaryDark,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? _primaryDark : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF182A22),
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedKesulitan = opt);
                              _fetchGunung();
                            }
                          },
                        ),
                      );
                    }),

                    // Tombol Filter Lokasi Dropdown
                    ActionChip(
                      backgroundColor: _selectedLokasi.isNotEmpty ? _primaryDark : Colors.white,
                      side: BorderSide(
                        color: _selectedLokasi.isNotEmpty ? _primaryDark : Colors.grey.shade300,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedLokasi.isNotEmpty ? _selectedLokasi : 'Lokasi',
                            style: TextStyle(
                              color: _selectedLokasi.isNotEmpty ? Colors.white : const Color(0xFF182A22),
                              fontSize: 12.5,
                              fontWeight: _selectedLokasi.isNotEmpty ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: _selectedLokasi.isNotEmpty ? Colors.white : Colors.grey.shade600,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      onPressed: _showLokasiFilterDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Jumlah Gunung
              Text(
                '${_gunungList.length} gunung untuk dijelajahi',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 12),

              // List Gunung
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF1B4D3E)),
                  ),
                )
              else if (_gunungList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada gunung yang cocok',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coba cari dengan kata kunci lain atau reset filter pilihan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gunungList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final gunung = _gunungList[index];
                    return _buildGunungCard(gunung);
                  },
                ),

              const SizedBox(height: 24),
              Text(
                'Tingkat kesulitan adalah gambaran umum, bukan jaminan keamanan jalur.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGunungCard(GunungModel gunung) {
    // Format ketinggian 3145 -> 3.145 mdpl
    final heightFormatted = gunung.ketinggianMdpl
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    // Badge color berdasarkan kesulitan
    Color badgeBg = const Color(0xFFFFF8E1);
    Color badgeText = const Color(0xFFB78103);
    if (gunung.tingkatKesulitan.toLowerCase() == 'pemula') {
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = const Color(0xFF2E7D32);
    } else if (gunung.tingkatKesulitan.toLowerCase() == 'sulit') {
      badgeBg = const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFC62828);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailGunungScreen(
                gunungId: gunung.id,
                initialGunung: gunung,
                state: widget.state,
                onSwitchTab: widget.onSwitchTab,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Gunung
            AspectRatio(
              aspectRatio: 16 / 7.5,
              child: Image.network(
                gunung.fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.landscape, size: 48, color: Colors.grey),
                  );
                },
              ),
            ),

            // Konten Card
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gunung.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    gunung.lokasi,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.landscape_outlined, size: 16, color: _primaryDark),
                          const SizedBox(width: 4),
                          Text(
                            '$heightFormatted mdpl',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF182A22),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gunung.tingkatKesulitan,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
