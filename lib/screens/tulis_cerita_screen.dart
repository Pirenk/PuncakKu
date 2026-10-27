import 'package:flutter/material.dart';
import '../models/story.dart';
import '../data/dummy_data.dart';

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
      _selectedImageIndex = (_selectedImageIndex + 1) % sampleMountainImages.length;
    });
  }

  void _publishStory() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    final mountainName = _selectedMountain.replaceFirst('Gunung ', '');
    final newPost = StoryPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Alya Putri',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      mountain: mountainName,
      date: 'Hari ini · Data contoh',
      content: caption,
      imageUrl: sampleMountainImages[_selectedImageIndex],
      likesCount: 0,
      isLiked: false,
      category: 'Terbaru',
      isCurrentUser: true,
      comments: [],
    );

    widget.onStoryCreated(newPost);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cerita berhasil diterbitkan!'),
        backgroundColor: Color(0xFF1B4D3E),
        duration: Duration(seconds: 2),
      ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tulis cerita',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulation account pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Simulasi akun - Alya Putri',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2A5944),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              const Text(
                'Cerita kecilmu bisa\nmembantu pendaki lain.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),

              // Photo Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Foto perjalanan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                  InkWell(
                    onTap: _cycleImage,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Text(
                        'Ganti / hapus',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1B4D3E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Photo Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    sampleMountainImages[_selectedImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Simulasi unggahan · 100% · foto-contoh-${_selectedImageIndex + 1}.jpg',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),

              // Gunung dropdown
              const Text(
                'Gunung (opsional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 8),
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
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: _mountainOptions.map((mountain) {
                      return DropdownMenuItem<String>(
                        value: mountain,
                        child: Text(
                          mountain,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF182A22)),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMountain = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Caption input
              const Text(
                'Caption cerita',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showError ? Colors.red.shade400 : Colors.grey.shade300,
                    width: _showError ? 1.5 : 1,
                  ),
                ),
                child: TextField(
                  controller: _captionController,
                  maxLines: 4,
                  maxLength: 1000,
                  onChanged: (val) {
                    if (_showError && val.trim().isNotEmpty) {
                      setState(() {
                        _showError = false;
                      });
                    } else {
                      setState(() {});
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Apa yang kamu pelajari di perjalanan ini?',
                    hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey),
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),

              if (_showError) ...[
                const SizedBox(height: 4),
                const Text(
                  'Caption wajib diisi sebelum cerita diterbitkan.',
                  style: TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],

              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_captionController.text.length} / 1.000 karakter',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 14),

              // Responsible sharing banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2D5A46),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Berbagi dengan bertanggung jawab',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4D3E),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Hindari informasi kondisi jalur yang belum diverifikasi. Unggahan ini hanya simulasi, tidak dikirim ke server.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF355E4E),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Terbitkan cerita button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _publishStory,
                  child: const Text(
                    'Terbitkan cerita · simulasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Batal button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal · kembali ke cerita',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
