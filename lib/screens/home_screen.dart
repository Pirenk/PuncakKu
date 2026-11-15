import 'package:flutter/material.dart';
import 'gps_tracking_screen.dart';
import 'tracking_history_screen.dart';

// =============================================================================
// HOME SCREEN - TAMPILAN BERANDA UTAMA (SESUAI DESAIN PENDAKI)
// =============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Default ke tab Beranda
  final Color _primaryDark = const Color(0xFF1B4D3E);

  Widget _buildBerandaView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Logo & Notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terrain_rounded, color: _primaryDark, size: 30),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pendaki',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                            ),
                          ),
                          const Text(
                            'TEMAN DI SETIAP LANGKAH',
                            style: TextStyle(
                              fontSize: 8.5,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 24, color: Color(0xFF182A22)),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chip Mode Tamu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mode tamu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Greeting & Subtitle
              const Text(
                'Halo, teman pendaki!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Langkah kecil,\npetualangan besar.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mau mendaki ke mana? Mulai dari rencana yang matang.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Cari gunung atau lokasi',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: Siapkan perjalananmu
              const Text(
                'Siapkan perjalananmu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 14),

              // 4 Action Cards Grid (Checklist pintar, Peta & GPS, Komunitas, Riwayat)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.checklist_rounded,
                      title: 'Checklist pintar',
                      subtitle: 'Siapkan perlengkapan',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.map_outlined,
                      title: 'Peta & GPS',
                      subtitle: 'Kenali jalurmu',
                      onTap: () {
                        // Buka Layar GPS Tracking
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GpsTrackingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.people_outline_rounded,
                      title: 'Komunitas',
                      subtitle: 'Cerita sesama pendaki',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Riwayat',
                      subtitle: 'Catatan perjalanan',
                      onTap: () {
                        // Masuk langsung ke layar Riwayat Tracking GPS
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingHistoryScreen(),
                          ),
                        );
                      },
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                  Text(
                    'Semua gunung ->',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Banner / Gambar Gunung Card
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade300,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1000&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: _primaryDark),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: _primaryDark.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Halaman $title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBerandaView(),
      _buildPlaceholder('Gunung', Icons.landscape_outlined),
      _buildPlaceholder('Persiapan', Icons.checklist_rtl_rounded),
      _buildPlaceholder('Komunitas', Icons.groups_outlined),
      _buildPlaceholder('Profil', Icons.person_outline),
    ];

    Widget _buildNavItem(int index, IconData icon, String label) {
      final bool isSelected = _currentIndex == index;
      return InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? _primaryDark : Colors.grey.shade500,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _primaryDark : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                _buildNavItem(1, Icons.landscape_outlined, 'Gunung'),
                _buildNavItem(2, Icons.fact_check_outlined, 'Persiapan'),
                _buildNavItem(3, Icons.groups_outlined, 'Komunitas'),
                _buildNavItem(4, Icons.person_outline, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
