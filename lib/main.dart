// ==============================================================================
// APLIKASI PENDAKIAN LENGKAP - 1 FILE (main.dart)
// ==============================================================================
// Alur Perjalanan & Navigasi Terhubung Lengkap:
// 1. Beranda (Home)
// 2. Jelajahi Gunung (Katalog Gunung + Filter Kategori)
// 3. Detail Gunung (Info Ketinggian, Jalur Selo, Basecamp, Panduan)
// 4. Feed Cerita Pendaki (Komunitas)
// 5. Detail Cerita Pendaki & Percakapan Komentar
// 6. Buat Postingan / Tulis Cerita Baru
// 7. Peta & GPS Simulasi (Rute Pilihan, Kontur Peta)
// 8. Perjalanan Berlangsung (Tracking Timer, Elevasi, Kecepatan, Jeda)
// 9. Perjalanan Dijeda (Istirahat sejenak, Lanjutkan, Akhiri)
// 10. Ringkasan Perjalanan (Pulang aman, Catatan, Simpan ke riwayat)
// 11. Riwayat Pendakian (Statistik 3 Pendakian, Filter, Kartu Riwayat)
// 12. Detail Perjalanan (Jejak perjalanan, Catatan Alya, Album, Bagikan cerita)
// 13. Persiapan & Checklist Pintar
// 14. Profilku (Profil Alya Putri, Riwayat, Gunung tersimpan, Keluar)
// 15. Ubah Profil (Form Ganti Foto, Nama, Email, Kota Asal, Bio)
// 16. Halaman Masuk / Login
// ==============================================================================

import 'package:flutter/material.dart';

// ------------------------------------------------------------------------------
// FUNGSI UTAMA (Entry Point)
// ------------------------------------------------------------------------------
void main() {
  runApp(const AplikasiPendakian());
}

// ------------------------------------------------------------------------------
// PALET WARNA TEMA APLIKASI
// ------------------------------------------------------------------------------
class AppColors {
  static const Color primary = Color(0xFF1B4D3E); // Hijau tua pinus
  static const Color primaryLight = Color(0xFFE8F2EC); // Hijau muda lembut
  static const Color background = Color(0xFFF7F9F8); // Latar abu-abu sangat muda
  static const Color textDark = Color(0xFF182A22); // Teks utama hitam-hijau
  static const Color textMuted = Color(0xFF6B7280); // Teks abu-abu
  static const Color border = Color(0xFFE5E7EB); // Garis border
  static const Color orangeBadgeBg = Color(0xFFFEF3C7);
  static const Color orangeBadgeText = Color(0xFF92400E);
  static const Color greenBadgeBg = Color(0xFFDCFCE7);
  static const Color greenBadgeText = Color(0xFF166534);
}

// ------------------------------------------------------------------------------
// MODEL DATA DUMMY
// ------------------------------------------------------------------------------
class MountainModel {
  final String name;
  final String location;
  final String height;
  final String difficulty;
  final String imageUrl;
  final String estimatedTrip;
  final String description;

  const MountainModel({
    required this.name,
    required this.location,
    required this.height,
    required this.difficulty,
    required this.imageUrl,
    this.estimatedTrip = '1-2 hari',
    this.description =
        'Hamparan sabana dan punggungan terbuka menjadi daya tarik Merbabu. Jalur menanjak cukup panjang; bangun stamina dan sesuaikan ritme dengan anggota paling lambat.',
  });
}

class CommentModel {
  final String author;
  final String time;
  final String content;

  const CommentModel({
    required this.author,
    required this.time,
    required this.content,
  });
}

class CommunityPostModel {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String mountainTag;
  final String date;
  final String content;
  final String promptQuestion;
  final String imageUrl;
  final int likes;
  final List<CommentModel> comments;

  const CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.mountainTag,
    required this.date,
    required this.content,
    this.promptQuestion = 'Apa pelajaran dari pendakian pertamamu?',
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });
}

class HikeHistoryModel {
  final String title;
  final String date;
  final String route;
  final String distance;
  final String duration;
  final String elevation;
  final String members;
  final String imageUrl;
  final String note;

  const HikeHistoryModel({
    required this.title,
    required this.date,
    required this.route,
    required this.distance,
    required this.duration,
    this.elevation = '720 m',
    this.members = '4 anggota',
    required this.imageUrl,
    this.note =
        'Berhenti di Pos 3, lalu turun bersama. Ritme santai dan semua pulang aman. Untuk trip berikutnya: kurangi beban dan mulai latihan lebih rutin.',
  });
}

// ------------------------------------------------------------------------------
// DATA DUMMY GLOBAL
// ------------------------------------------------------------------------------
final List<MountainModel> dummyMountains = [
  const MountainModel(
    name: 'Gunung Merbabu',
    location: 'Boyolali, Jawa Tengah',
    height: '3.145 mdpl',
    difficulty: 'Menengah',
    imageUrl:
        'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=800&auto=format&fit=crop',
  ),
  const MountainModel(
    name: 'Gunung Prau',
    location: 'Wonosobo, Jawa Tengah',
    height: '2.565 mdpl',
    difficulty: 'Pemula',
    imageUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
  ),
  const MountainModel(
    name: 'Gunung Andong',
    location: 'Magelang, Jawa Tengah',
    height: '1.726 mdpl',
    difficulty: 'Pemula',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800&auto=format&fit=crop',
  ),
];

final List<CommunityPostModel> dummyCommunityPosts = [
  const CommunityPostModel(
    id: 'post_1',
    authorName: 'Alya Putri',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
    mountainTag: 'Merbabu',
    date: '12 Okt 2026',
    content:
        'Bukan soal cepat sampai. Istirahat di Pos 3, saling tunggu, lalu pulang dengan cerita. 🌿',
    promptQuestion: 'Apa pelajaran dari pendakian pertamamu?',
    imageUrl:
        'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=800&auto=format&fit=crop',
    likes: 25,
    comments: [
      CommentModel(
        author: 'Raka Pratama',
        time: '12 Okt · 14.20',
        content: 'Pelan-pelan, yang penting semua pulang aman.',
      ),
      CommentModel(
        author: 'Nadia Rahma',
        time: '12 Okt · 14.35',
        content: 'Setuju! Jas hujan jangan sampai ketinggalan.',
      ),
      CommentModel(
        author: 'Alya Putri',
        time: '12 Okt · 15.02',
        content: 'Betul, saling cek perlengkapan sebelum mulai.',
      ),
    ],
  ),
  const CommunityPostModel(
    id: 'post_2',
    authorName: 'Nadia Rahma',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
    mountainTag: 'Prau',
    date: '21 Sep 2026',
    content:
        'Prau mengajarkan: lapisan hangat dan teman yang saling jaga itu penting. Apa barang wajibmu?',
    promptQuestion: 'Apa barang wajib yang selalu kamu bawa?',
    imageUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
    likes: 18,
    comments: [
      CommentModel(
        author: 'Dimas Kurnia',
        time: '21 Sep · 10.15',
        content: 'Matras tebal dan kompor mini!',
      ),
    ],
  ),
];

final List<HikeHistoryModel> dummyHikeHistories = [
  const HikeHistoryModel(
    title: 'Merbabu via Selo',
    date: '12 Okt 2026',
    route: 'Selo → Pos 3 → Selo',
    distance: '6,8 km',
    duration: '4j 32m',
    elevation: '720 m',
    members: '4 anggota',
    imageUrl:
        'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=800&auto=format&fit=crop',
  ),
  const HikeHistoryModel(
    title: 'Prau via Patak Banteng',
    date: '21 Sep 2026',
    route: 'Basecamp → puncak → basecamp',
    distance: '5,2 km',
    duration: '5j 10m',
    elevation: '600 m',
    members: '3 anggota',
    imageUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
  ),
  const HikeHistoryModel(
    title: 'Andong via Sawit',
    date: '17 Agu 2026',
    route: 'Basecamp → puncak → basecamp',
    distance: '6,6 km',
    duration: '3j 45m',
    elevation: '450 m',
    members: '2 anggota',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800&auto=format&fit=crop',
  ),
];

// Data Profil Pengguna (Bisa diubah dinamis lewat halaman Ubah Profil)

// ------------------------------------------------------------------------------
// MODEL DATA RENCANA PENDAKIAN & CHECKLIST
// ------------------------------------------------------------------------------
class TripPlanModel {
  String mountain;
  String route;
  String tripType; // 'Berkemah' atau 'Tek-tok'
  String duration; // '2 hari · 1 malam', dll.
  int memberCount;

  TripPlanModel({
    this.mountain = 'Gunung Merbabu',
    this.route = 'via Selo',
    this.tripType = 'Berkemah',
    this.duration = '2 hari · 1 malam',
    this.memberCount = 4,
  });
}

class ChecklistItemModel {
  String id;
  String title;
  String spec;
  String category; // 'Wajib' atau 'Opsional'
  bool isReady;
  String assignedTo; // username anggota atau 'Pribadi'
  String note;

  ChecklistItemModel({
    required this.id,
    required this.title,
    required this.spec,
    required this.category,
    this.isReady = false,
    this.assignedTo = 'Alya Putri (Ketua)',
    this.note = '',
  });
}

enum ChangeRequestType { tambah, ubah, hapus }

class ChangeRequestModel {
  String id;
  String requestedBy;
  ChangeRequestType type;
  String itemName;
  String proposedChange;
  String reason;
  String status; // 'Menunggu', 'Disetujui', 'Ditolak'

  ChangeRequestModel({
    required this.id,
    required this.requestedBy,
    required this.type,
    required this.itemName,
    required this.proposedChange,
    required this.reason,
    this.status = 'Menunggu',
  });
}

class GroupMemberModel {
  String username;
  String status; // 'Menunggu', 'Diterima', 'Ditolak'
  bool isLeader;

  GroupMemberModel({
    required this.username,
    required this.status,
    this.isLeader = false,
  });
}

class GroupInvitationModel {
  String groupName;
  String mountain;
  String leaderName;
  String status; // 'Menunggu', 'Diterima', 'Ditolak'

  GroupInvitationModel({
    required this.groupName,
    required this.mountain,
    required this.leaderName,
    this.status = 'Menunggu',
  });
}

class UserProfileData {
  static String name = 'Alya Putri';
  static String email = 'alya.putri@email.com';
  static String city = 'Yogyakarta';
  static String level = 'Pendaki pemula';
  static String bio = 'Menikmati setiap langkah dan pemandangan alam.';
  static String avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop';
}

// ------------------------------------------------------------------------------
// WIDGET UTAMA (MaterialApp)
// ------------------------------------------------------------------------------
class AplikasiPendakian extends StatelessWidget {
  const AplikasiPendakian({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendaki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ------------------------------------------------------------------------------
// BOTTOM NAVIGATION CONTROLLER
// ------------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _pindahKeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onLihatSemuaGunung: () => _pindahKeTab(1),
        onBukaPetaGps: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapGpsScreen()),
          );
        },
        onBukaChecklist: () => _pindahKeTab(2),
        onBukaKomunitas: () => _pindahKeTab(3),
        onBukaRiwayat: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HikeHistoryScreen()),
          );
        },
      ),
      const ExploreMountainScreen(),
      const PreparationScreen(),
      const CommunityScreen(),
      ProfileScreen(
        onBukaRiwayat: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HikeHistoryScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Beranda'),
                _buildNavItem(1, Icons.terrain_outlined, 'Gunung'),
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
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
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

// ==============================================================================
// 1. BERANDA (HOME SCREEN)
// ==============================================================================
class HomeScreen extends StatelessWidget {
  final VoidCallback onLihatSemuaGunung;
  final VoidCallback onBukaPetaGps;
  final VoidCallback onBukaChecklist;
  final VoidCallback onBukaKomunitas;
  final VoidCallback onBukaRiwayat;

  const HomeScreen({
    super.key,
    required this.onLihatSemuaGunung,
    required this.onBukaPetaGps,
    required this.onBukaChecklist,
    required this.onBukaKomunitas,
    required this.onBukaRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terrain, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pendaki',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'TEMAN DI SETIAP LANGKAH',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
                      onPressed: () {},
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Mode tamu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Halo, teman pendaki!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Langkah kecil,\npetualangan besar.',
              style: TextStyle(
                fontSize: 26,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mau mendaki ke mana? Mulai dari rencana yang matang.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  hintText: 'Cari gunung atau lokasi',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Siapkan perjalananmu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _FeatureCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Checklist pintar',
                  subtitle: 'Siapkan perlengkapan',
                  onTap: onBukaChecklist,
                ),
                _FeatureCard(
                  icon: Icons.map_outlined,
                  title: 'Peta & GPS',
                  subtitle: 'Kenali jalurmu',
                  onTap: onBukaPetaGps,
                ),
                _FeatureCard(
                  icon: Icons.groups_outlined,
                  title: 'Komunitas',
                  subtitle: 'Cerita sesama pendaki',
                  onTap: onBukaKomunitas,
                ),
                _FeatureCard(
                  icon: Icons.directions_walk_outlined,
                  title: 'Riwayat',
                  subtitle: 'Catatan perjalanan',
                  onTap: onBukaRiwayat,
                ),
              ],
            ),
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rekomendasi gunung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: onLihatSemuaGunung,
                  child: Row(
                    children: const [
                      Text(
                        'Semua gunung',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            MountainCard(mountain: dummyMountains[0]),
            const SizedBox(height: 12),
            MountainCard(mountain: dummyMountains[1]),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Persiapan dulu, puncak kemudian',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cek kemampuan diri, lengkapi perlengkapan, dan konfirmasi kondisi jalur ke basecamp.',
                          style: TextStyle(fontSize: 11, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 2. JELAJAHI GUNUNG (KATALOG DENGAN FILTER)
// ==============================================================================
class ExploreMountainScreen extends StatefulWidget {
  const ExploreMountainScreen({super.key});

  @override
  State<ExploreMountainScreen> createState() => _ExploreMountainScreenState();
}

class _ExploreMountainScreenState extends State<ExploreMountainScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final filteredList = dummyMountains.where((m) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Pemula') return m.difficulty == 'Pemula';
      if (_selectedFilter == 'Menengah') return m.difficulty == 'Menengah';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: const [
            Icon(Icons.terrain, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Jelajahi gunung',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          const Text(
            'Temukan perjalanan\nyang cocok untukmu.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                hintText: 'Cari gunung atau lokasi',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Pemula'),
                _buildFilterChip('Menengah'),
                _buildFilterChip('Lokasi ▾'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredList.length} gunung untuk dijelajahi',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                'Data contoh',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...filteredList.map((gunung) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: MountainCard(mountain: gunung),
              )),

          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tingkat kesulitan adalah gambaran umum, bukan jaminan keamanan jalur.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class MountainCard extends StatelessWidget {
  final MountainModel mountain;

  const MountainCard({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    final isMenengah = mountain.difficulty == 'Menengah';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MountainDetailScreen(mountain: mountain),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                mountain.imageUrl,
                height: 145,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 145,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mountain.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mountain.location,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terrain, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            mountain.height,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMenengah ? AppColors.orangeBadgeBg : AppColors.greenBadgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mountain.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isMenengah
                                ? AppColors.orangeBadgeText
                                : AppColors.greenBadgeText,
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

// ==============================================================================
// 3. DETAIL GUNUNG (INFO LENGKAP, JALUR, BASECAMP)
// ==============================================================================
class MountainDetailScreen extends StatelessWidget {
  final MountainModel mountain;

  const MountainDetailScreen({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail gunung',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              mountain.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            '${mountain.location.split(',').last.trim()} · Data contoh',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),

          Text(
            mountain.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                mountain.location,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(mountain.height.replaceAll(' mdpl', ' m'), 'Ketinggian'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildStatItem(mountain.difficulty, 'Kesulitan'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildStatItem(mountain.estimatedTrip, 'Estimasi trip'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Tentang ${mountain.name.replaceAll('Gunung ', '')}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mountain.description,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textDark),
          ),
          const SizedBox(height: 20),

          const Text(
            'Jalur pendakian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Via Selo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Pilihan trip',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Basecamp → Pos 1 → Pos 2 → Pos 3 → Sabana. Medan tanah, tanjakan dan area terbuka.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orangeBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Estimasi naik 7–9 jam ke puncak',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orangeBadgeText,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Data contoh. Durasi dipengaruhi cuaca, beban, dan kondisi fisik.',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Basecamp Selo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selo, Boyolali',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Konfirmasi kuota, jadwal buka dan kebutuhan registrasi langsung ke pengelola.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapGpsScreen()),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.map_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Lihat basecamp di peta →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Aturan & keselamatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Ikuti jalur resmi dan arahan petugas.\n'
            '• Bawa turun seluruh sampah.\n'
            '• Jangan menyalakan api sembarangan.\n'
            '• Periksa syarat izin dan perlengkapan ke basecamp sebelum berangkat.',
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDark),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(initialIndex: 2),
                ),
              );
            },
            icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
            label: Text(
              'Siapkan checklist ${mountain.name.replaceAll('Gunung ', '')}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ==============================================================================
// 4. FEED CERITA PENDAKI (KOMUNITAS)
// ==============================================================================
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _activeTab = 'Untukmu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: const [
            Icon(Icons.terrain, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Cerita pendaki',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          const Text(
            'Belajar dari langkah\nsatu sama lain.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCommunityTab('Untukmu'),
                _buildCommunityTab('Terbaru'),
                _buildCommunityTab('Tips pemula'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Tulis cerita',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          ...dummyCommunityPosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CommunityPostCard(post: post),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCommunityTab(String title) {
    final isSelected = _activeTab == title;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = title;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  final CommunityPostModel post;

  const _CommunityPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoryDetailScreen(post: post)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(post.avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${post.mountainTag} · ${post.date}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              post.content,
              style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.favorite_border, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.comments.length} komentar · Lihat cerita →',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 5. DETAIL CERITA & PERCAKAPAN KOMENTAR
// ==============================================================================
class StoryDetailScreen extends StatefulWidget {
  final CommunityPostModel post;

  const StoryDetailScreen({super.key, required this.post});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late List<CommentModel> _comments;
  final TextEditingController _commentController = TextEditingController();
  late int _likesCount;
  bool _isLiked = true;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.comments);
    _likesCount = widget.post.likes;
  }

  void _kirimKomentar() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.add(
        CommentModel(
          author: 'Kamu (Pendaki)',
          time: 'Baru saja',
          content: _commentController.text.trim(),
        ),
      );
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cerita ${widget.post.mountainTag}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.post.avatarUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${widget.post.mountainTag} · ${widget.post.date}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.post.imageUrl,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            widget.post.content,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),

          Text(
            widget.post.promptQuestion,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _likesCount += _isLiked ? 1 : -1;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _isLiked ? Colors.red : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_likesCount suka · ${_isLiked ? 'Disukai' : 'Suka'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${_comments.length} komentar',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu cerita kamu · akun contoh',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Membuka editor cerita...')),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Ubah cerita',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cerita dihapus (simulasi)')),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'Hapus cerita',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Percakapan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${_comments.length} komentar',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ..._comments.map((comment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          comment.time,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),

          const Text(
            'Tambahkan komentar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Bagikan tanggapan yang baik...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _kirimKomentar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Kirim komentar',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text(
              'Tulis cerita baru',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ==============================================================================
// 6. BUAT POSTINGAN / TULIS CERITA BARU
// ==============================================================================
class CreateStoryScreen extends StatelessWidget {
  const CreateStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cerita Merbabu',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(UserProfileData.avatarUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserProfileData.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Buat Postinganmu',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Bagikan Ceritamu Disini',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ceritakan tentang pendakianmu, tips atau pengalaman seru lainnya',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            Container(
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textDark),
                    SizedBox(height: 10),
                    Text(
                      'Tambahkan Foto atau Video',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'unggah dokumentasi pendakianmu',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tulis Caption',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cerita berhasil dibagikan!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Kirim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 7. PETA & GPS SIMULASI
// ==============================================================================
class MapGpsScreen extends StatelessWidget {
  const MapGpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peta & GPS',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.orangeBadgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Simulasi GPS · bukan navigasi nyata',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeBadgeText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Rute pilihan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Merbabu - Selo → Pos 3 → Selo',
                  style: TextStyle(fontSize: 13, color: AppColors.textDark),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 250),
                  painter: _ContourPainter(),
                ),
                Positioned(
                  top: 24,
                  right: 28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.terrain, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Merbabu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.nature_people_outlined, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Basecamp Selo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ilustrasi • bukan navigasi',
                      style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: const [
              Icon(Icons.terrain, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Gunung',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              SizedBox(width: 30),
              Icon(Icons.holiday_village_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Basecamp',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Izin lokasi belum diberikan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Lokasi diperlukan untuk merekam jalur. Contoh desain ini menggunakan rute dan koordinat simulasi.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.group_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Bagikan ke kelompok',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Nonaktif',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Opsional - masuk untuk berbagi lokasi simulasi. Tidak ada pelacakan orang lain.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveHikeTrackingScreen()),
              );
            },
            icon: const Icon(Icons.play_arrow_outlined, color: Colors.white),
            label: const Text(
              'Mulai pendakian simulasi',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 8),

          const Center(
            child: Text(
              'Bawa peta luring dan perlengkapan navigasi. Tetap verifikasi jalur dengan basecamp.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ==============================================================================
// 8. PERJALANAN BERLANGSUNG SIMULASI (TRACKER)
// ==============================================================================
class ActiveHikeTrackingScreen extends StatelessWidget {
  const ActiveHikeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perjalanan berlangsung',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Simulasi GPS · sedang merekam',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Merbabu via Selo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Tujuan Pos 3 · rute dan lokasi data contoh',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          Container(
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 210),
                  painter: _ContourPainter(hasActiveDot: true),
                ),
                Positioned(
                  top: 20,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.terrain, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Merbabu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.nature_people_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Basecamp Selo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ilustrasi • bukan navigasi',
                      style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Durasi berjalan · simulasi',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                const Text(
                  '01:24:00',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTrackingStat('2,4 km', 'Jarak'),
                    _buildTrackingStat('310 m', 'Elevasi naik'),
                    _buildTrackingStat('1,7 km/j', 'Kecepatan'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tetap bersama rombongan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Angka ini simulasi, bukan posisi atau kondisi aktual. Berbagi kelompok nonaktif.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PausedHikeScreen()),
              );
            },
            icon: const Icon(Icons.pause, color: Colors.white, size: 18),
            label: const Text(
              'Jeda perjalanan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HikeSummaryScreen()),
              );
            },
            icon: const Icon(Icons.stop_outlined, color: AppColors.primary, size: 18),
            label: const Text(
              'Selesai · lihat ringkasan',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrackingStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ==============================================================================
// 9. PERJALANAN DIJEDA
// ==============================================================================
class PausedHikeScreen extends StatelessWidget {
  const PausedHikeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perjalanan dijeda',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.orangeBadgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Simulasi GPS · dijeda',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeBadgeText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Istirahat sejenak, tidak apa.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Merbabu · Selo → Pos 3 → Selo',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _ContourPainter(hasActiveDot: true),
                ),
                Positioned(
                  top: 20,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.terrain, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Merbabu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.nature_people_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Basecamp Selo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ilustrasi • bukan navigasi',
                      style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Durasi berhenti pada · simulasi',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                const Text(
                  '01:24:00',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPausedStat('2,4 km', 'Jarak tersimpan'),
                    _buildPausedStat('310 m', 'Elevasi naik'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orangeBadgeBg.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.orangeBadgeText, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Perekaman dihentikan sementara',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orangeBadgeText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Jarak dan durasi tidak bertambah saat dijeda. Lanjutkan bila rombongan sudah siap.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            label: const Text(
              'Lanjutkan perjalanan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HikeSummaryScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Akhiri & lihat ringkasan',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPausedStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ==============================================================================
// 10. RINGKASAN PERJALANAN
// ==============================================================================
class HikeSummaryScreen extends StatelessWidget {
  const HikeSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ringkasan perjalanan',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Selesai · Data contoh',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Pulang aman,\nbawa cerita baru.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Merbabu via Selo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 2),
          const Text(
            '12 Okt 2026 · Selo → Pos 3 → Selo\n4 anggota · tidak mencapai puncak',
            style: TextStyle(fontSize: 11, height: 1.35, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _ContourPainter(hasActiveDot: true),
                ),
                Positioned(
                  top: 16,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.terrain, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Merbabu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.nature_people_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Basecamp Selo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat('6,8 km', 'Jarak total'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildSummaryStat('4j 32m', 'Durasi aktif'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildSummaryStat('720 m', 'Elevasi naik'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Catatan perjalanan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Berhenti di Pos 3, lalu turun bersama. Ritme santai dan semua pulang aman.',
              style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Foto berhasil ditambahkan ke catatan!')),
              );
            },
            icon: const Icon(Icons.photo_outlined, size: 18, color: AppColors.primary),
            label: const Text(
              'Tambahkan foto perjalanan',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HikeHistoryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Simpan ke riwayat',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HikeHistoryScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Lihat riwayat',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ==============================================================================
// 11. RIWAYAT PENDAKIAN (SETIAP LANGKAH BERARTI)
// ==============================================================================
class HikeHistoryScreen extends StatefulWidget {
  const HikeHistoryScreen({super.key});

  @override
  State<HikeHistoryScreen> createState() => _HikeHistoryScreenState();
}

class _HikeHistoryScreenState extends State<HikeHistoryScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat pendakian',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          const Text(
            'Simulasi akun · Data contoh',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),

          const Text(
            'Setiap langkah berarti.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('3', 'Pendakian'),
                _buildStatBox('18,6 km', 'Total jarak'),
                _buildStatBox('2026', 'Tahun perjalanan'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistoryFilter('Semua'),
                _buildHistoryFilter('2026'),
                _buildHistoryFilter('Dengan foto'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perjalanan tersimpan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${dummyHikeHistories.length} perjalanan',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...dummyHikeHistories.map((history) => InkWell(
                onTap: () {
                  // Membuka Halaman Detail Perjalanan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HikeDetailScreen(history: history),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          history.imageUrl,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              history.date,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            Text(
                              history.route,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${history.distance} - ${history.duration}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Icon(Icons.photo_outlined, size: 14, color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Text(
                                  'Foto & catatan · Lihat detail →',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildHistoryFilter(String label) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 12. DETAIL PERJALANAN (MERBABU VIA SELO - JEJAK, CATATAN & ALBUM)
// ==============================================================================
class HikeDetailScreen extends StatelessWidget {
  final HikeHistoryModel history;

  const HikeDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail perjalanan',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // Banner Foto Utama
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              history.imageUrl,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          // Badge Tersimpan
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Tersimpan · Simulasi akun',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            history.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            '${history.date} · ${history.members}\n${history.route} · Data contoh',
            style: const TextStyle(fontSize: 11, height: 1.35, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // 3 Info Box Statistik
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(history.distance, 'Jarak total'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildStatItem(history.duration, 'Durasi aktif'),
                Container(height: 28, width: 1, color: AppColors.border),
                _buildStatItem(history.elevation, 'Elevasi naik'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bagian Jejak Perjalanan (Timeline)
          const Text(
            'Jejak perjalanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '07.00 · Mulai dari Basecamp Selo\n'
                  '09.20 · Istirahat di Pos 3\n'
                  '12.10 · Kembali ke Basecamp Selo',
                  style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textDark),
                ),
                SizedBox(height: 8),
                Text(
                  'Waktu contoh termasuk jeda. Perjalanan tidak mencapai puncak.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bagian Catatan Alya
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catatan ${UserProfileData.name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka editor catatan...')),
                  );
                },
                child: const Text(
                  'Ubah catatan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              history.note,
              style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 20),

          // Bagian Album Perjalanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Album perjalanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '2 foto contoh',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=800&auto=format&fit=crop',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Bagikan Cerita ke Komunitas
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            label: const Text(
              'Bagikan cerita ke komunitas',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ==============================================================================
// 13. ALUR PERSIAPAN: RENCANA PENDAKIAN -> KELOMPOK -> CHECKLIST PERLENGKAPAN
// ==============================================================================

// STATE REPOSITORI LOKAL BERSAMA (Simulasi data aplikasi lokal)
class ChecklistAppState {
  static TripPlanModel plan = TripPlanModel(
    mountain: 'Gunung Merbabu',
    route: 'via Selo',
    tripType: 'Berkemah',
    duration: '2 hari · 1 malam',
    memberCount: 4,
  );

  static String groupName = 'Pendaki Merbabu Nusantara';
  static bool isGroupCreated = false;
  static String activeRole = 'Ketua'; // 'Ketua' atau 'Anggota'

  static List<GroupMemberModel> groupMembers = [
    GroupMemberModel(username: 'Alya Putri (Ketua)', status: 'Diterima', isLeader: true),
    GroupMemberModel(username: 'Dimas_Outdoor', status: 'Diterima'),
    GroupMemberModel(username: 'Raka_Pratama', status: 'Menunggu'),
    GroupMemberModel(username: 'Nadia_Rahma', status: 'Menunggu'),
  ];

  static List<GroupInvitationModel> incomingInvitations = [
    GroupInvitationModel(
      groupName: 'Keluarga Rimba Prau',
      mountain: 'Gunung Prau · via Patak Banteng',
      leaderName: 'Bima_Aditya',
      status: 'Menunggu',
    ),
  ];

  // Daftar item checklist
  static List<ChecklistItemModel> items = [
    ChecklistItemModel(
      id: 'item_1',
      title: 'Air minum',
      spec: '2 liter / orang · sesuaikan kebutuhan',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Alya Putri (Ketua)',
    ),
    ChecklistItemModel(
      id: 'item_2',
      title: 'Sepatu trekking',
      spec: '1 pasang · sol tidak licin',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Alya Putri (Ketua)',
    ),
    ChecklistItemModel(
      id: 'item_3',
      title: 'Jaket hangat',
      spec: '1 buah · lapisan penghangat',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Alya Putri (Ketua)',
    ),
    ChecklistItemModel(
      id: 'item_4',
      title: 'P3K pribadi',
      spec: '1 set · termasuk obat pribadi',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Dimas_Outdoor',
    ),
    ChecklistItemModel(
      id: 'item_5',
      title: 'Makanan & camilan',
      spec: '2 hari · cadangan secukupnya',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Dimas_Outdoor',
    ),
    ChecklistItemModel(
      id: 'item_6',
      title: 'Kantong sampah',
      spec: '2 buah · bawa turun kembali',
      category: 'Wajib',
      isReady: true,
      assignedTo: 'Raka_Pratama',
    ),
    ChecklistItemModel(
      id: 'item_7',
      title: 'Lampu kepala',
      spec: '1 buah · baterai cadangan',
      category: 'Wajib',
      isReady: false,
      assignedTo: 'Alya Putri (Ketua)',
      note: 'Bawa baterai cadangan',
    ),
    ChecklistItemModel(
      id: 'item_8',
      title: 'Jas hujan',
      spec: '1 set · mudah dijangkau',
      category: 'Wajib',
      isReady: false,
      assignedTo: 'Nadia_Rahma',
    ),
    ChecklistItemModel(
      id: 'item_9',
      title: 'Tongkat trekking',
      spec: '1 pasang · bantu kestabilan',
      category: 'Opsional',
      isReady: false,
      assignedTo: 'Alya Putri (Ketua)',
    ),
    ChecklistItemModel(
      id: 'item_10',
      title: 'Kamera',
      spec: '1 buah · sesuai kebutuhan',
      category: 'Opsional',
      isReady: false,
      assignedTo: 'Dimas_Outdoor',
    ),
  ];

  static List<ChangeRequestModel> requests = [
    ChangeRequestModel(
      id: 'req_1',
      requestedBy: 'Nadia_Rahma',
      type: ChangeRequestType.tambah,
      itemName: 'Powerbank 20000mAh',
      proposedChange: 'Kategori Wajib, 1 buah',
      reason: 'Baterai HP cepat habis karena dingin',
      status: 'Menunggu',
    ),
  ];
}

// ------------------------------------------------------------------------------
// 13.A HALAMAN RENCANA PENDAKIAN (LANGKAH 1 DARI 2)
// ------------------------------------------------------------------------------
class PreparationScreen extends StatefulWidget {
  const PreparationScreen({super.key});

  @override
  State<PreparationScreen> createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> {
  final List<String> _mountainList = [
    'Gunung Merbabu · via Selo',
    'Gunung Prau · via Patak Banteng',
    'Gunung Andong · via Sawit',
    'Gunung Lawu · via Candi Cetho',
    'Gunung Sumbing · via Garung',
    'Gunung Sindoro · via Kledung',
  ];

  late String _selectedMountainWithRoute;
  late String _selectedTripType;
  late String _selectedDuration;
  late int _memberCount;

  @override
  void initState() {
    super.initState();
    _selectedMountainWithRoute =
        '${ChecklistAppState.plan.mountain} · ${ChecklistAppState.plan.route}';
    _selectedTripType = ChecklistAppState.plan.tripType;
    _selectedDuration = ChecklistAppState.plan.duration;
    _memberCount = ChecklistAppState.plan.memberCount;
  }

  void _simpanRencanaDanLanjut() {
    final parts = _selectedMountainWithRoute.split('·');
    ChecklistAppState.plan.mountain = parts[0].trim();
    ChecklistAppState.plan.route = parts.length > 1 ? parts[1].trim() : 'Jalur Umum';
    ChecklistAppState.plan.tripType = _selectedTripType;
    ChecklistAppState.plan.duration = _selectedDuration;
    ChecklistAppState.plan.memberCount = _memberCount;

    if (_memberCount == 1) {
      // PRIBADI: Langsung buka checklist pribadi (mode pribadi)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChecklistScreen(isPersonalMode: true),
        ),
      );
    } else {
      // KELOMPOK: Arahkan ke Halaman Pembuatan Kelompok
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GroupCreationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            // Jika ada riwayat kembali, pop
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Checklist',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // Badge Langkah 1 dari 2
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Langkah 1 dari 2 · Rencana trip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Persiapan yang pas\nuntuk perjalananmu.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Isi rencana, lalu gunakan rekomendasi sebagai titik awal perlengkapanmu.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),

          // Gunung Tujuan
          const Text(
            'Gunung tujuan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMountainWithRoute,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                items: _mountainList.map((m) {
                  return DropdownMenuItem<String>(
                    value: m,
                    child: Text(m, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMountainWithRoute = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Jenis Perjalanan (Berkemah / Tek-tok)
          const Text(
            'Jenis perjalanan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeChip('Berkemah'),
              const SizedBox(width: 8),
              _buildTypeChip('Tek-tok'),
            ],
          ),
          const SizedBox(height: 18),

          // Durasi
          const Text(
            'Durasi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDuration,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                items: ['1 hari (PP)', '2 hari · 1 malam', '3 hari · 2 malam', '4 hari · 3 malam']
                    .map((d) {
                  return DropdownMenuItem<String>(
                    value: d,
                    child: Text(d, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDuration = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Jumlah Anggota
          const Text(
            'Jumlah anggota',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_memberCount orang',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 22),
                      onPressed: () {
                        if (_memberCount > 1) {
                          setState(() {
                            _memberCount--;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                      onPressed: () {
                        setState(() {
                          _memberCount++;
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.group_outlined, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Lanjut: Buat rekomendasi perlengkapan
          ElevatedButton(
            onPressed: _simpanRencanaDanLanjut,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              _memberCount == 1 ? 'Buka checklist pribadi' : 'Buat rekomendasi perlengkapan',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _selectedTripType == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTripType = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------
// 13.B HALAMAN PEMBUATAN KELOMPOK & UNDANGAN ANGGOTA
// ------------------------------------------------------------------------------
class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _groupNameController =
      TextEditingController(text: ChecklistAppState.groupName);
  final TextEditingController _inviteUsernameController = TextEditingController();

  void _kirimUndangan() {
    final username = _inviteUsernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username anggota tidak boleh kosong!')),
      );
      return;
    }

    if (username.toLowerCase().contains('alya')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ketua tidak dapat mengundang dirinya sendiri.')),
      );
      return;
    }

    final isDuplicate = ChecklistAppState.groupMembers.any(
      (m) => m.username.toLowerCase() == username.toLowerCase(),
    );
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggota ini sudah ada dalam daftar undangan!')),
      );
      return;
    }

    setState(() {
      ChecklistAppState.groupMembers.add(
        GroupMemberModel(username: username, status: 'Menunggu'),
      );
      _inviteUsernameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Undangan terkirim ke $username')),
    );
  }

  void _simulasiPenerimaan(int idx) {
    setState(() {
      ChecklistAppState.groupMembers[idx].status = 'Diterima';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ChecklistAppState.groupMembers[idx].username} menerima undangan (simulasi)!')),
    );
  }

  void _simulasiPenolakan(int idx) {
    setState(() {
      ChecklistAppState.groupMembers[idx].status = 'Ditolak';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ChecklistAppState.groupMembers[idx].username} menolak undangan (simulasi)!')),
    );
  }

  void _buatKelompok() {
    ChecklistAppState.groupName = _groupNameController.text.trim().isEmpty
        ? 'Kelompok Pendaki'
        : _groupNameController.text.trim();
    ChecklistAppState.isGroupCreated = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChecklistScreen(isPersonalMode: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedCount = ChecklistAppState.groupMembers
        .where((m) => m.status == 'Diterima')
        .length;
    final targetCount = ChecklistAppState.plan.memberCount;
    final allAccepted = acceptedCount >= targetCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelompok Pendakian',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // Banner Ringkasan Rencana
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terrain, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${ChecklistAppState.plan.mountain} ${ChecklistAppState.plan.route}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${ChecklistAppState.plan.tripType} · ${ChecklistAppState.plan.duration} · Target: $targetCount orang (Termasuk ketua)',
                  style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Input Nama Kelompok
          const Text(
            'Nama kelompok',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Pendaki Merbabu Nusantara',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Input Username Anggota & Tombol Undang
          const Text(
            'Undang anggota (Username)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _inviteUsernameController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan username',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _kirimUndangan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Daftar Anggota Kelompok
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar anggota & status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              Text(
                '$acceptedCount dari $targetCount bergabung',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...ChecklistAppState.groupMembers.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;

            Color statusBg;
            Color statusText;
            if (m.status == 'Diterima') {
              statusBg = AppColors.greenBadgeBg;
              statusText = AppColors.greenBadgeText;
            } else if (m.status == 'Menunggu') {
              statusBg = AppColors.orangeBadgeBg;
              statusText = AppColors.orangeBadgeText;
            } else {
              statusBg = Colors.red.shade50;
              statusText = Colors.red.shade800;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      m.username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.username,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        if (m.isLeader)
                          const Text('Ketua Kelompok', style: TextStyle(fontSize: 10, color: AppColors.primary))
                        else
                          Text('Simulasi status: ${m.status}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(m.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusText)),
                  ),
                  if (m.status == 'Menunggu' && !m.isLeader) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      tooltip: 'Simulasi Terima',
                      onPressed: () => _simulasiPenerimaan(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.highlight_off, color: Colors.red, size: 20),
                      tooltip: 'Simulasi Tolak',
                      onPressed: () => _simulasiPenolakan(idx),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Bagian Undangan Masuk
          const Text(
            'Undangan masuk (Untuk akunmu)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),

          ...ChecklistAppState.incomingInvitations.map((inv) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.groupName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text(inv.mountain, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('Ketua: ${inv.leaderName}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    if (inv.status == 'Menunggu')
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                inv.status = 'Diterima';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kamu menerima undangan kelompok!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Terima', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                inv.status = 'Ditolak';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Tolak', style: TextStyle(color: Colors.red, fontSize: 11)),
                          ),
                        ],
                      )
                    else
                      Text('Status: ${inv.status}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              )),
          const SizedBox(height: 14),

          // Status & Tombol Buat Kelompok
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: allAccepted ? AppColors.greenBadgeBg : AppColors.orangeBadgeBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  allAccepted ? Icons.check_circle_outline : Icons.info_outline,
                  color: allAccepted ? AppColors.greenBadgeText : AppColors.orangeBadgeText,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allAccepted
                        ? 'Semua anggota yang dibutuhkan telah bergabung.'
                        : 'Menunggu semua anggota menerima undangan. (Kamu tetap bisa membuat kelompok untuk simulasi).',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: allAccepted ? AppColors.greenBadgeText : AppColors.orangeBadgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: _buatKelompok,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Buat Kelompok',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------------
// 13.C HALAMAN CHECKLIST UTAMA (PERLENGKAPANMU - MODE PRIBADI / KELOMPOK)
// ------------------------------------------------------------------------------
class ChecklistScreen extends StatefulWidget {
  final bool isPersonalMode;

  const ChecklistScreen({super.key, required this.isPersonalMode});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _isEditingMode = false;
  int _bottomNavTab = 0; // 0: Checklist, 1: Kelompok, 2: Permintaan

  void _bukaFormTambahBarang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEquipmentScreen(
          isNewItem: true,
          item: ChecklistItemModel(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
            title: '',
            spec: '',
            category: 'Wajib',
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _bukaFormEditBarang(ChecklistItemModel item) {
    if (!widget.isPersonalMode && ChecklistAppState.activeRole != 'Ketua') {
      // Anggota hanya bisa kirim permintaan perubahan
      _bukaDialogPermintaanUbah(item);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEquipmentScreen(
          isNewItem: false,
          item: item,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _hapusBarang(ChecklistItemModel item) {
    if (!widget.isPersonalMode && ChecklistAppState.activeRole != 'Ketua') {
      _bukaDialogPermintaanHapus(item);
      return;
    }

    setState(() {
      ChecklistAppState.items.removeWhere((i) => i.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} dihapus')),
    );
  }

  void _bukaDialogPermintaanUbah(ChecklistItemModel item) {
    final reasonController = TextEditingController();
    final proposedController = TextEditingController(text: item.spec);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajukan Perubahan: ${item.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: proposedController,
              decoration: const InputDecoration(labelText: 'Perubahan yang diajukan'),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Alasan perubahan'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              setState(() {
                ChecklistAppState.requests.add(
                  ChangeRequestModel(
                    id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                    requestedBy: 'Nadia_Rahma',
                    type: ChangeRequestType.ubah,
                    itemName: item.title,
                    proposedChange: proposedController.text.trim(),
                    reason: reasonController.text.trim(),
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permintaan perubahan terkirim ke ketua')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _bukaDialogPermintaanHapus(ChecklistItemModel item) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajukan Hapus: ${item.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Alasan penghapusan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              setState(() {
                ChecklistAppState.requests.add(
                  ChangeRequestModel(
                    id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                    requestedBy: 'Nadia_Rahma',
                    type: ChangeRequestType.hapus,
                    itemName: item.title,
                    proposedChange: 'Hapus barang',
                    reason: reasonController.text.trim(),
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permintaan hapus barang terkirim ke ketua')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kirim Permintaan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Saring item yang ditampilkan
    final wajibItems = ChecklistAppState.items.where((i) => i.category == 'Wajib').toList();
    final opsionalItems = ChecklistAppState.items.where((i) => i.category == 'Opsional').toList();

    final totalItems = ChecklistAppState.items.length;
    final readyItems = ChecklistAppState.items.where((i) => i.isReady).length;
    final wajibReady = wajibItems.where((i) => i.isReady).length;
    final wajibNotReady = wajibItems.length - wajibReady;
    final percent = totalItems > 0 ? ((readyItems / totalItems) * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perlengkapanmu',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _buildCurrentTabBody(wajibItems, opsionalItems, totalItems, readyItems, wajibNotReady, percent),
      bottomNavigationBar: !widget.isPersonalMode
          ? BottomNavigationBar(
              currentIndex: _bottomNavTab,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              onTap: (idx) {
                setState(() {
                  _bottomNavTab = idx;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Checklist'),
                BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Kelompok'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Permintaan'),
              ],
            )
          : null,
    );
  }

  Widget _buildCurrentTabBody(
    List<ChecklistItemModel> wajibItems,
    List<ChecklistItemModel> opsionalItems,
    int totalItems,
    int readyItems,
    int wajibNotReady,
    int percent,
  ) {
    if (_bottomNavTab == 1) {
      return const GroupCreationScreen();
    } else if (_bottomNavTab == 2) {
      return _buildRequestsTab();
    }

    // Tab 0: Checklist Utama
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      children: [
        // Mode & Peran Simulasi Switcher
        if (!widget.isPersonalMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peranmu: ${ChecklistAppState.activeRole}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      ChecklistAppState.activeRole =
                          ChecklistAppState.activeRole == 'Ketua' ? 'Anggota' : 'Ketua';
                    });
                  },
                  child: Text(
                    'Ganti ke ${ChecklistAppState.activeRole == 'Ketua' ? 'Anggota' : 'Ketua'} (Simulasi)',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

        // Header Rencana: Merbabu via Selo + Ubah rencana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ChecklistAppState.plan.mountain} ${ChecklistAppState.plan.route}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ChecklistAppState.plan.tripType} · ${ChecklistAppState.plan.duration.split('·').first.trim()} · ${widget.isPersonalMode ? '1 orang (Pribadi)' : '${ChecklistAppState.plan.memberCount} orang'} · Data contoh',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Kembali ke halaman rencana
              },
              child: const Text(
                'Ubah rencana',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Box Progres: 6 dari 10 siap (60%)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$readyItems dari $totalItems siap',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalItems > 0 ? (readyItems / totalItems) : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sedikit lagi, lengkapi barang wajib dulu.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Banner Warning Jika Ada Barang Wajib Belum Siap
        if (wajibNotReady > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orangeBadgeBg.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.orangeBadgeText, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$wajibNotReady barang wajib belum siap',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orangeBadgeText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lampu kepala dan jas hujan. Jangan berangkat sebelum perlengkapan wajib lengkap.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Bagian Wajib Dibawa
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Wajib dibawa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${wajibItems.where((i) => i.isReady).length} / ${wajibItems.length} siap',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Kartu Checklist Wajib Dibawa
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: wajibItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == wajibItems.length - 1;

              return Column(
                children: [
                  _buildChecklistRow(item),
                  if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Bagian Opsional (Muncul saat mode Edit atau biasa)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Opsional',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${opsionalItems.where((i) => i.isReady).length} / ${opsionalItems.length} siap',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: opsionalItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == opsionalItems.length - 1;

              return Column(
                children: [
                  _buildChecklistRow(item),
                  if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Tombol Tambah Perlengkapan (muncul saat mode edit aktif)
        if (_isEditingMode) ...[
          OutlinedButton.icon(
            onPressed: _bukaFormTambahBarang,
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text(
              'Tambah perlengkapan',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Tombol Edit / Simpan
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditingMode = !_isEditingMode;
            });
            if (!_isEditingMode) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perubahan checklist disimpan!')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _isEditingMode ? 'Simpan' : 'Edit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),

        const Center(
          child: Text(
            'Perlengkapan kelompok seperti tenda dan alat masak perlu dibagi serta dikonfirmasi bersama.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChecklistRow(ChecklistItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox Custom Hijau Bulat/Kotak Lengkung
          InkWell(
            onTap: () {
              // Validasi role jika kelompok: hanya ketua atau penanggung jawab yang boleh centang
              if (!widget.isPersonalMode &&
                  ChecklistAppState.activeRole != 'Ketua' &&
                  !item.assignedTo.contains('Nadia')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hanya ${item.assignedTo} atau Ketua yang dapat memperbarui kesiapan barang ini!')),
                );
                return;
              }

              setState(() {
                item.isReady = !item.isReady;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.isReady ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.isReady ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: item.isReady
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Teks Judul & Spesifikasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    decoration: item.isReady && !_isEditingMode ? null : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.spec,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                if (!widget.isPersonalMode) ...[
                  const SizedBox(height: 2),
                  Text(
                    'PJ: ${item.assignedTo}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),

          // Ikon Edit & Hapus (saat mode edit)
          if (_isEditingMode) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
              onPressed: () => _bukaFormEditBarang(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
              onPressed: () => _hapusBarang(item),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Permintaan Perubahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${ChecklistAppState.requests.length} permintaan',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (ChecklistAppState.requests.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Belum ada permintaan perubahan dari anggota.', style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else
          ...ChecklistAppState.requests.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${req.type.name.toUpperCase()}: ${req.itemName}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: req.status == 'Disetujui' ? AppColors.greenBadgeBg : AppColors.orangeBadgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(req.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: req.status == 'Disetujui' ? AppColors.greenBadgeText : AppColors.orangeBadgeText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Pengaju: ${req.requestedBy}', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  Text('Usulan: ${req.proposedChange}', style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
                  Text('Alasan: ${req.reason}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 10),

                  if (ChecklistAppState.activeRole == 'Ketua' && req.status == 'Menunggu')
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              req.status = 'Disetujui';
                              if (req.type == ChangeRequestType.tambah) {
                                ChecklistAppState.items.add(
                                  ChecklistItemModel(
                                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                                    title: req.itemName,
                                    spec: req.proposedChange,
                                    category: 'Wajib',
                                    assignedTo: req.requestedBy,
                                  ),
                                );
                              } else if (req.type == ChangeRequestType.hapus) {
                                ChecklistAppState.items.removeWhere((i) => i.title.toLowerCase() == req.itemName.toLowerCase());
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Permintaan disetujui & diterapkan ke checklist!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Setujui', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              req.status = 'Ditolak';
                            });
                          },
                          child: const Text('Tolak', style: TextStyle(color: Colors.red, fontSize: 11)),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ------------------------------------------------------------------------------
// 13.D FORM TAMBAH / UBAH PERLENGKAPAN (SESUAI GAMBAR TERAKHIR)
// ------------------------------------------------------------------------------
class EditEquipmentScreen extends StatefulWidget {
  final bool isNewItem;
  final ChecklistItemModel item;

  const EditEquipmentScreen({super.key, required this.isNewItem, required this.item});

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _noteController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.title);
    _qtyController = TextEditingController(text: '1');
    _noteController = TextEditingController(text: widget.item.note);
    _selectedCategory = widget.item.category;
  }

  void _simpanBarang() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama barang wajib diisi!')),
      );
      return;
    }

    if (widget.isNewItem) {
      ChecklistAppState.items.add(
        ChecklistItemModel(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          title: name,
          spec: '${_qtyController.text.trim()} buah · ${_noteController.text.trim()}',
          category: _selectedCategory,
          note: _noteController.text.trim(),
        ),
      );
    } else {
      widget.item.title = name;
      widget.item.category = _selectedCategory;
      widget.item.note = _noteController.text.trim();
      widget.item.spec = '${_qtyController.text.trim()} buah · ${_noteController.text.trim()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perlengkapan berhasil disimpan!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNewItem ? 'Tambah perlengkapan' : 'Ubah perlengkapan',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          children: [
            Text(
              '${ChecklistAppState.plan.mountain.replaceAll('Gunung ', '')} · ${widget.item.title.isEmpty ? 'Barang baru' : widget.item.title}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),

            const Text(
              'Detail barang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            const SizedBox(height: 18),

            // Nama Barang
            const Text(
              'Nama barang',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Lampu kepala',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Jumlah
            const Text(
              'Jumlah',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '1',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kategori (Wajib / Opsional)
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCategoryButton('Wajib'),
                const SizedBox(width: 8),
                _buildCategoryButton('Opsional'),
              ],
            ),
            const SizedBox(height: 16),

            // Catatan (Opsional)
            const Text(
              'Catatan (opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Bawa baterai cadangan',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan Perubahan Barang
            ElevatedButton(
              onPressed: _simpanBarang,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Simpan perubahan barang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Batal
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Batal · kembali ke checklist',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label) {
    final isSelected = _selectedCategory == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}


// ==============================================================================
// 14. PROFILKU (SESUAI GAMBAR REFERENSI DESAIN KEDUA)
// ==============================================================================
class ProfileScreen extends StatelessWidget {
  final VoidCallback onBukaRiwayat;

  const ProfileScreen({super.key, required this.onBukaRiwayat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: const [
            Icon(Icons.terrain, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Profilku',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          const Text(
            'Simulasi akun · bukan sesi masuk nyata',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Foto Profil Lingkaran Besar
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage(UserProfileData.avatarUrl),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: Text(
              UserProfileData.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 2),

          Center(
            child: Text(
              UserProfileData.email,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 4),

          Center(
            child: Text(
              '${UserProfileData.level} · ${UserProfileData.city}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Ubah Profil
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
            label: const Text(
              'Ubah profil',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // Box 3 Kolom Statistik Profil
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('3', 'Pendakian'),
                _buildStatItem('18,6 km', 'Total jarak'),
                _buildStatItem('2', 'Gunung disimpan'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu Box Riwayat Pendakian
          InkWell(
            onTap: onBukaRiwayat,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Riwayat pendakian',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '3 perjalanan dengan foto & catatan',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Daftar Gunung Tersimpan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Gunung tersimpan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '2 gunung',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Kartu Gunung Merbabu Tersimpan
          _buildSavedMountainItem(
            context,
            dummyMountains[0],
          ),
          const SizedBox(height: 10),

          // Kartu Gunung Prau Tersimpan
          _buildSavedMountainItem(
            context,
            dummyMountains[1],
          ),
          const SizedBox(height: 18),

          // Tombol Keluar dari Akun
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, size: 16, color: AppColors.primary),
            label: const Text(
              'Keluar dari akun',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),

          const Center(
            child: Text(
              'Pendaki · versi desain 1.0',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSavedMountainItem(BuildContext context, MountainModel mountain) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MountainDetailScreen(mountain: mountain)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mountain.imageUrl,
                width: 60,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mountain.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mountain.height} · ${mountain.location.split(',').first}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bookmark, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 15. UBAH PROFIL (SESUAI GAMBAR REFERENSI DESAIN KETIGA)
// ==============================================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserProfileData.name);
    _emailController = TextEditingController(text: UserProfileData.email);
    _cityController = TextEditingController(text: UserProfileData.city);
    _bioController = TextEditingController(text: UserProfileData.bio);
  }

  void _simpanPerubahan() {
    setState(() {
      UserProfileData.name = _nameController.text.trim();
      UserProfileData.email = _emailController.text.trim();
      UserProfileData.city = _cityController.text.trim();
      UserProfileData.bio = _bioController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ubah profil',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          children: [
            Text(
              'Simulasi akun · ${UserProfileData.name}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            // Foto Profil Lingkaran
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(UserProfileData.avatarUrl),
              ),
            ),
            const SizedBox(height: 8),

            // Tombol Ganti Foto Profil
            Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka galeri untuk memilih foto...')),
                  );
                },
                child: const Text(
                  'Ganti foto profil',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),

            const Center(
              child: Text(
                'JPG/PNG, maks. 5 MB',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Form Input Nama Lengkap
            const Text(
              'Nama lengkap',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            _buildInputField(_nameController, 'Nama'),
            const SizedBox(height: 14),

            // Form Input Email
            const Text(
              'Email',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            _buildInputField(_emailController, 'Alamat email'),
            const SizedBox(height: 14),

            // Form Input Kota Asal (Opsional)
            const Text(
              'Kota asal (opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            _buildInputField(_cityController, 'Kota asal'),
            const SizedBox(height: 14),

            // Form Input Bio (Opsional)
            const Text(
              'Bio (opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Tulis bio singkatmu...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Tombol Simpan Perubahan Profil
            ElevatedButton(
              onPressed: _simpanPerubahan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Simpan perubahan profil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Batal - Kembali ke Profil
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Batal · kembali ke profil',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// Painter Custom untuk Kontur Peta
class _ContourPainter extends CustomPainter {
  final bool hasActiveDot;

  _ContourPainter({this.hasActiveDot = false});

  @override
  void paint(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = const Color(0xFFBFDFD0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 6; i++) {
      final path = Path();
      path.moveTo(0, size.height * (i * 0.16));
      path.cubicTo(
        size.width * 0.35,
        size.height * (i * 0.16 - 0.08),
        size.width * 0.65,
        size.height * (i * 0.16 + 0.08),
        size.width,
        size.height * (i * 0.16),
      );
      canvas.drawPath(path, contourPaint);
    }

    final trailPaint = Paint()
      ..color = const Color(0xFF1B4D3E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final trailPath = Path();
    trailPath.moveTo(size.width * 0.25, size.height * 0.85);
    trailPath.cubicTo(
      size.width * 0.55,
      size.height * 0.70,
      size.width * 0.35,
      size.height * 0.40,
      size.width * 0.75,
      size.height * 0.15,
    );
    canvas.drawPath(trailPath, trailPaint);

    if (hasActiveDot) {
      final dotOuterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final dotInnerPaint = Paint()
        ..color = const Color(0xFF1B4D3E)
        ..style = PaintingStyle.fill;

      final dotCenter = Offset(size.width * 0.50, size.height * 0.45);
      canvas.drawCircle(dotCenter, 7, dotOuterPaint);
      canvas.drawCircle(dotCenter, 4.5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==============================================================================
// 16. HALAMAN MASUK / LOGIN
// ==============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Masuk',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.terrain,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Selamat datang\nPendaki.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'nama@email.com',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Kata sandi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Lupa kata sandi?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                'atau',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Masuk dengan Google',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: () {},
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    children: [
                      TextSpan(text: 'Belum punya akun? '),
                      TextSpan(
                        text: 'Daftar',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
