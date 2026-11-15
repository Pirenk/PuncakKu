import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  bool _isSaving = false;
  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _backgroundColor = const Color(0xFFF7F9F8);

  @override
  void initState() {
    super.initState();
    final user = userProfileNotifier.value;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _cityController = TextEditingController(text: user.city);
    _bioController = TextEditingController(text: user.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final currentUser = userProfileNotifier.value;

    // Simpan ke MySQL jika user punya ID
    if (currentUser.id != null) {
      await ApiService.updateProfile(
        userId: currentUser.id!,
        nama: newName,
        fotoProfil: currentUser.avatarUrl,
      );
    }

    userProfileNotifier.updateProfile(
      name: newName,
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      bio: _bioController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan profil berhasil disimpan ke database!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          'Ubah profil',
          style: TextStyle(
            color: _primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<UserProfile>(
                valueListenable: userProfileNotifier,
                builder: (context, user, _) {
                  return Text(
                    'Akun terhubung · ${user.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B8075),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Avatar & Change Photo
              Center(
                child: Column(
                  children: [
                    ValueListenableBuilder<UserProfile>(
                      valueListenable: userProfileNotifier,
                      builder: (context, user, _) {
                        return Container(
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
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih foto dari galeri.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Ganti foto profil',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPG/PNG, maks. 5 MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('Nama lengkap'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameController,
                hintText: 'Nama',
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Email'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailController,
                hintText: 'Alamat email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Kota asal (opsional)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _cityController,
                hintText: 'Contoh: Yogyakarta',
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Bio (opsional)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _bioController,
                hintText: 'Tuliskan sedikit tentang dirimu...',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan perubahan profil',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal · kembali ke profil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F352B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF152A20)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryDark, width: 1.5),
        ),
      ),
    );
  }
}
