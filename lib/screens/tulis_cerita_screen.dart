import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class TulisCeritaScreen extends StatefulWidget {
  final Function(StoryPost newPost) onStoryCreated;

  const TulisCeritaScreen({
    super.key,
    required this.onStoryCreated,
  });

  @override
  State<TulisCeritaScreen> createState() => _TulisCeritaScreenState();
}

class _TulisCeritaScreenState extends State<TulisCeritaScreen> {
  final TextEditingController _captionController = TextEditingController();
  int _selectedImageIndex = 0;
  String _selectedMountain = 'Gunung Merbabu';
  bool _showError = false;
  bool _isPublishing = false;

  final List<String> _mountainImages = [
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80',
  ];

  final List<String> _mountainOptions = [
    'Gunung Merbabu',
    'Gunung Prau',
    'Gunung Rinjani',
    'Gunung Semeru',
    'Gunung Gede Pangrango',
    'Gunung Sindoro',
    'Gunung Sumbing',
    'Gunung Lawu',
    'Lainnya',
  ];

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _cycleImage() {
    setState(() {
      _selectedImageIndex = (_selectedImageIndex + 1) % _mountainImages.length;
    });
  }

  void _publishStory() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() => _isPublishing = true);

    final currentUser = userProfileNotifier.value;
    final userId = currentUser.id ?? 1;
    final mountainName = _selectedMountain.replaceFirst('Gunung ', '');
    final selectedImage = _mountainImages[_selectedImageIndex];

    // Simpan ke database MySQL Laragon
    final fullCaption = "[$_selectedMountain] $caption";
    final res = await ApiService.createPostingan(
      userId: userId,
      caption: fullCaption,
      foto: selectedImage,
    );

    int? newId;
    if (res['status'] == 'success' && res['data'] != null) {
      newId = (res['data']['id_postingan'] as num?)?.toInt();
    }

    final newPost = StoryPost(
      id: newId?.toString() ?? 'post_${DateTime.now().millisecondsSinceEpoch}',
      rawIdPostingan: newId,
      rawIdUser: userId,
      authorName: currentUser.name,
      authorAvatar: currentUser.avatarUrl,
      mountain: mountainName,
      date: 'Baru saja',
      content: caption,
      imageUrl: selectedImage,
      likesCount: 0,
      isLiked: false,
      category: 'Terbaru',
      isCurrentUser: true,
      comments: [],
    );

    widget.onStoryCreated(newPost);

    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerita berhasil diterbitkan ke database!'),
          backgroundColor: Color(0xFF1B4D3E),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Tulis cerita',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan Gunung Dropdown
            const Text(
              'Pilih Gunung',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMountain,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _mountainOptions.map((mountain) {
                    return DropdownMenuItem(
                      value: mountain,
                      child: Text(mountain, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMountain = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Caption Text Field
            const Text(
              'Cerita Anda',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: _captionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan pengalaman, pelajaran, atau tips dari pendakian ini...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Cerita tidak boleh kosong',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
            const SizedBox(height: 16),

            // Foto Pendakian Preview & Ganti
            const Text(
              'Foto Pendakian',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _mountainImages[_selectedImageIndex],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Ganti Foto', style: TextStyle(fontSize: 12)),
                    onPressed: _cycleImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Tombol Publikasikan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isPublishing ? null : _publishStory,
                child: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publikasikan Cerita',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
