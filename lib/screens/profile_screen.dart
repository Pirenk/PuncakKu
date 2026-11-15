import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/mountain_logo.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _backgroundColor = const Color(0xFFF7F9F8);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileFromDb();
  }

  Future<void> _loadProfileFromDb() async {
    final current = userProfileNotifier.value;
    if (current.id == null && current.email.isEmpty) return;

    setState(() => _isLoading = true);

    final data = await ApiService.getProfile(
      userId: current.id,
      email: current.email,
    );

    if (data != null && mounted) {
      final user = data['user'];
      final totalPendakian = (data['total_pendakian'] as num?)?.toInt() ?? 0;
      final totalJarak =
          (data['total_jarak_km'] as num?)?.toDouble() ?? current.totalDistanceKm;

      userProfileNotifier.updateProfile(
        id: int.tryParse(user['id'].toString()),
        name: user['nama'] ?? current.name,
        username: user['username'] ?? current.username,
        email: user['email'] ?? current.email,
        avatarUrl: (user['foto_profil'] != null &&
                user['foto_profil'].toString().isNotEmpty)
            ? user['foto_profil']
            : current.avatarUrl,
        tripsCount: totalPendakian > 0 ? totalPendakian : current.tripsCount,
      );
      userProfileNotifier.value = userProfileNotifier.value.copyWith(
        totalDistanceKm: totalJarak,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari akun?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Kamu akan kembali ke halaman masuk.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
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
            MountainLogo(size: 26, color: _primaryDark),
            const SizedBox(width: 10),
            Text(
              'Profilku',
              style: TextStyle(
                color: _primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfileFromDb,
          color: _primaryDark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ValueListenableBuilder<UserProfile>(
              valueListenable: userProfileNotifier,
              builder: (context, user, _) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        user.id != null
                            ? 'Akun terdaftar di database Laragon'
                            : 'Mode demo · data lokal',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Avatar
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFCFDCD5),
                              child: Icon(
                                Icons.person,
                                size: 46,
                                color: _primaryDark,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF152A20),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Email
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5E7368),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bio / Origin
                    Text(
                      'Pendaki pemula · ${user.city.isNotEmpty ? user.city : 'Yogyakarta'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E8278),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Button Ubah Profil
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 16, color: _primaryDark),
                            const SizedBox(width: 8),
                            Text(
                              'Ubah profil',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2EE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4E3DB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('${user.tripsCount}', 'Pendakian'),
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFCBDCD3),
                          ),
                          _buildStatItem(
                            '${user.totalDistanceKm.toString().replaceAll('.', ',')} km',
                            'Total jarak',
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFCBDCD3),
                          ),
                          _buildStatItem(
                              '${user.savedMountainsCount}', 'Gunung disimpan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Riwayat pendakian card
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membuka riwayat pendakian...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5EDE8)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_walk_outlined,
                              size: 26,
                              color: _primaryDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Riwayat pendakian',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF152A20),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${user.tripsCount} perjalanan tercatat',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B8075),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section: Gunung tersimpan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gunung tersimpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF152A20),
                          ),
                        ),
                        Text(
                          '${user.savedMountainsCount} gunung',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildSavedMountainItem(
                      name: 'Gunung Merbabu',
                      detail: '3.145 mdpl · Boyolali',
                      imageUrl:
                          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=800&auto=format&fit=crop',
                    ),
                    const SizedBox(height: 10),
                    _buildSavedMountainItem(
                      name: 'Gunung Prau',
                      detail: '2.565 mdpl · Wonosobo',
                      imageUrl:
                          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
                    ),
                    const SizedBox(height: 20),

                    // Button Keluar dari akun
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => _showLogoutDialog(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 18, color: _primaryDark),
                            const SizedBox(width: 8),
                            Text(
                              'Keluar dari akun',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Pendaki · versi desain 1.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
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
            fontWeight: FontWeight.w800,
            color: Color(0xFF152A20),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF5E7368),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedMountainItem({
    required String name,
    required String detail,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 44,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFCFDCD5),
                    child: Center(
                      child: MountainLogo(size: 20, color: _primaryDark),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF152A20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B8075),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark_border_rounded,
              color: _primaryDark,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
