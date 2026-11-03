import 'package:flutter/material.dart';
import 'screens/persiapan/persiapan_hub_screen.dart';
import 'screens/placeholder_screens.dart';
import 'state/pendaki_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4D3E);

    return MaterialApp(
      title: 'Pendaki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          
          primary: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Mulai langsung di tab Persiapan (index 2) agar fitur langsung tampil
  int _currentIndex = 2;

  final Color _primaryDark = const Color(0xFF1B4D3E);

  // Instansiasi state persiapan satu kali agar tetap persisten selama navigasi
  late final PendakiState _pendakiState;

  @override
  void initState() {
    super.initState();
    _pendakiState = PendakiState();
  }

  @override
  void dispose() {
    _pendakiState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5 Halaman lengkap sesuai dengan rancangan tab navigasi bawah
    final List<Widget> pages = [
      const PlaceholderScreen(
        title: 'Beranda',
        icon: Icons.home_outlined,
        subtitle: 'Jelajahi panduan pendakian, tips keselamatan, dan info cuaca gunung.',
      ),
      const PlaceholderScreen(
        title: 'Gunung',
        icon: Icons.landscape_outlined,
        subtitle: 'Informasi jalur resmi, pos pendakian, dan kuota tiket gunung di Jawa Tengah.',
      ),
      PersiapanHubScreen(state: _pendakiState),
      const PlaceholderScreen(
        title: 'Komunitas',
        icon: Icons.groups_outlined,
        subtitle: 'Cerita pendaki, forum tanya jawab, dan cari teman pendakian bareng.',
      ),
      const PlaceholderScreen(
        title: 'Profil',
        icon: Icons.person_outline,
        subtitle: 'Kelola akun pendaki, riwayat pendakian, dan sertifikat kelulusan simaksi.',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Beranda'),
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? _primaryDark : Colors.grey.shade600,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _primaryDark : Colors.grey.shade600,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 16,
                decoration: BoxDecoration(
                  color: _primaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
