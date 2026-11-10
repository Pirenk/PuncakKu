import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/mountain_logo.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _backgroundColor = const Color(0xFFF7F9F8);

  List<Map<String, dynamic>> _gunungList = [];
  bool _isLoadingGunung = true;
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _fetchGunung([String? query]) async {
    setState(() => _isLoadingGunung = true);
    final list = await ApiService.getGunung(search: query);
    if (mounted) {
      setState(() {
        _gunungList = list;
        _isLoadingGunung = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            MountainLogo(size: 28, color: _primaryDark),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pendaki',
                  style: TextStyle(
                    color: _primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'TEMAN DI SETIAP LANGKAH',
                  style: TextStyle(
                    color: const Color(0xFF63796E),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  color: _primaryDark,
                  size: 24,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak ada notifikasi baru.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchGunung(_searchController.text.trim()),
        color: _primaryDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Tamu Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mode tamu',
                  style: TextStyle(
                    color: _primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Greeting
              const Text(
                'Halo, teman pendaki!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264C3B),
                ),
              ),
              const SizedBox(height: 6),

              // Big Headline
              const Text(
                'Langkah kecil,\npetualangan besar.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF152A20),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              const Text(
                'Mau mendaki ke mana? Mulai dari rencana yang matang.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5E7369),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EBE5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (val) => _fetchGunung(val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari gunung atau lokasi',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: Siapkan perjalananmu
              const Text(
                'Siapkan perjalananmu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF152A20),
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Grid
              Row(
                children: [
                  Expanded(
                    child: _buildPreparationCard(
                      icon: Icons.checklist_rounded,
                      title: 'Checklist pintar',
                      subtitle: 'Siapkan perlengkapan',
                      onTap: () => widget.onNavigateTab?.call(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPreparationCard(
                      icon: Icons.map_outlined,
                      title: 'Peta & GPS',
                      subtitle: 'Kenali jalurmu',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Peta & GPS sedang disiapkan.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPreparationCard(
                      icon: Icons.groups_outlined,
                      title: 'Komunitas',
                      subtitle: 'Cerita sesama pendaki',
                      onTap: () => widget.onNavigateTab?.call(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPreparationCard(
                      icon: Icons.directions_walk_outlined,
                      title: 'Riwayat',
                      subtitle: 'Catatan perjalanan',
                      onTap: () => widget.onNavigateTab?.call(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Section: Rekomendasi gunung
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi gunung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF152A20),
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onNavigateTab?.call(1),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Semua gunung',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primaryDark,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward,
                            size: 13,
                            color: _primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mountain List from MySQL / Fallback
              if (_isLoadingGunung)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: _primaryDark),
                  ),
                )
              else if (_gunungList.isNotEmpty)
                Column(
                  children: _gunungList.map((g) {
                    final nama = g['nama_gunung'] ?? 'Gunung';
                    final lokasi = g['lokasi'] ?? '';
                    final ketinggian = "${g['ketinggian'] ?? '-'} mdpl";
                    final tingkat = (g['tingkat_kesulitan'] ?? 'sedang')
                        .toString()
                        .capitalize();
                    final foto = g['foto'] ??
                        'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=800&auto=format&fit=crop';

                    final isMudah = tingkat.toLowerCase() == 'mudah';
                    final badgeBg = isMudah
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7);
                    final badgeText = isMudah
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildMountainCard(
                        title: nama,
                        location: lokasi,
                        elevation: ketinggian,
                        level: tingkat,
                        levelBgColor: badgeBg,
                        levelTextColor: badgeText,
                        imageUrl: foto,
                        onTap: () => _showMountainDetail(
                            context, nama, ketinggian, g['deskripsi']),
                      ),
                    );
                  }).toList(),
                )
              else
                // Fallback default cards if database is still empty
                Column(
                  children: [
                    _buildMountainCard(
                      title: 'Gunung Merbabu',
                      location: 'Boyolali, Jawa Tengah',
                      elevation: '3.145 mdpl',
                      level: 'Menengah',
                      levelBgColor: const Color(0xFFFEF3C7),
                      levelTextColor: const Color(0xFFB45309),
                      imageUrl:
                          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=800&auto=format&fit=crop',
                      onTap: () {
                        _showMountainDetail(
                            context, 'Gunung Merbabu', '3.145 mdpl', null);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMountainCard(
                      title: 'Gunung Prau',
                      location: 'Wonosobo, Jawa Tengah',
                      elevation: '2.565 mdpl',
                      level: 'Pemula',
                      levelBgColor: const Color(0xFFDCFCE7),
                      levelTextColor: const Color(0xFF15803D),
                      imageUrl:
                          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
                      onTap: () {
                        _showMountainDetail(
                            context, 'Gunung Prau', '2.565 mdpl', null);
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              // Tip Banner: Persiapan dulu, puncak kemudian
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2EE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD3E3DA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persiapan dulu, puncak kemudian',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Cek kemampuan diri, lengkapi perlengkapan, dan konfirmasi kondisi jalur ke basecamp.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Color(0xFF435A4F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreparationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EDE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 26,
              color: _primaryDark,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF152A20),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B8075),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMountainCard({
    required String title,
    required String location,
    required String elevation,
    required String level,
    required Color levelBgColor,
    required Color levelTextColor,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFD6E3DC),
                    child: Center(
                      child: MountainLogo(size: 48, color: _primaryDark),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF152A20),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primaryDark,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward,
                            size: 13,
                            color: _primaryDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B8075),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MountainLogo(size: 16, color: _primaryDark),
                          const SizedBox(width: 6),
                          Text(
                            elevation,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B3D2F),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: levelBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: levelTextColor,
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

  void _showMountainDetail(
      BuildContext context, String name, String elevation, String? desc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EFEA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      elevation,
                      style: TextStyle(
                        color: _primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc ??
                    'Gunung ini memiliki pemandangan yang indah dan jalur pendakian yang populer di kalangan pendaki.',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
