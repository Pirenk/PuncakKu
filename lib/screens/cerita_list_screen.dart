import 'package:flutter/material.dart';
import '../models/story.dart';
import '../data/dummy_data.dart';
import 'cerita_detail_screen.dart';
import 'tulis_cerita_screen.dart';

class CeritaListScreen extends StatefulWidget {
  const CeritaListScreen({super.key});

  @override
  State<CeritaListScreen> createState() => _CeritaListScreenState();
}

class _CeritaListScreenState extends State<CeritaListScreen> {
  late List<StoryPost> _stories;
  String _selectedCategory = 'Untukmu';
  final List<String> _categories = ['Untukmu', 'Terbaru', 'Tips pemula'];

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);

  @override
  void initState() {
    super.initState();
    _stories = List.from(initialStories);
  }

  void _toggleLike(StoryPost post) {
    setState(() {
      final wasLiked = post.isLiked;
      post.isLiked = !wasLiked;
      post.likesCount = wasLiked ? (post.likesCount - 1).clamp(0, 99999) : post.likesCount + 1;
    });
  }

  void _onPostUpdated(StoryPost updatedPost) {
    setState(() {
      final index = _stories.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        _stories[index] = updatedPost;
      }
    });
  }

  void _onPostDeleted(String postId) {
    setState(() {
      _stories.removeWhere((p) => p.id == postId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cerita berhasil dihapus.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onStoryCreated(StoryPost newPost) {
    setState(() {
      _stories.insert(0, newPost);
      // Auto select appropriate category or stay on current
    });
  }

  List<StoryPost> get _filteredStories {
    if (_selectedCategory == 'Untukmu') {
      return _stories;
    }
    return _stories.where((post) => post.category == _selectedCategory).toList();
  }

  void _navigateToDetail(StoryPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CeritaDetailScreen(
          post: post,
          onPostUpdated: _onPostUpdated,
          onPostDeleted: _onPostDeleted,
          onStoryCreated: _onStoryCreated,
        ),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TulisCeritaScreen(
          onStoryCreated: _onStoryCreated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStories;

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primaryDark,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
            setState(() {
              // Refresh simulation
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App title & Mountain icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.landscape_outlined,
                          color: Color(0xFF1B4D3E),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cerita pendaki',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4D3E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  const Text(
                    'Belajar dari langkah\nsatu sama lain.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF182A22),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? _primaryDark : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _primaryDark : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Tulis cerita · masuk dulu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _navigateToCreate,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info Banner
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
                                'Baca bebas, berbagi dengan akun',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B4D3E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Masuk untuk membuat cerita, menyukai, dan berkomentar. Semua unggahan berikut data contoh.',
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
                  const SizedBox(height: 18),

                  // Story Cards List
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.feed_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada cerita di kategori ini.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((post) {
                      return _buildStoryCard(post);
                    }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(StoryPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: Image.network(
                      post.authorAvatar,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${post.mountain} · ${post.date}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {
                    _showStoryOptions(post);
                  },
                ),
              ],
            ),
          ),

          // Post Image (Tappable to detail)
          GestureDetector(
            onTap: () => _navigateToDetail(post),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Post Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: GestureDetector(
              onTap: () => _navigateToDetail(post),
              child: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: Color(0xFF23382F),
                ),
              ),
            ),
          ),

          // Actions: Like & Comments
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 14, 14),
            child: Row(
              children: [
                // Like Button
                InkWell(
                  onTap: () => _toggleLike(post),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 19,
                          color: post.isLiked ? Colors.red : const Color(0xFF23382F),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${post.likesCount}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: post.isLiked ? FontWeight.bold : FontWeight.w500,
                            color: post.isLiked ? const Color(0xFF1B4D3E) : const Color(0xFF23382F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Comment Button / Link to detail
                Expanded(
                  child: InkWell(
                    onTap: () => _navigateToDetail(post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Color(0xFF23382F),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${post.comments.length} komentar · Lihat cerita ->',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStoryOptions(StoryPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF1B4D3E)),
              title: const Text('Bagikan Cerita'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan cerita disalin!')),
                );
              },
            ),
            if (post.isCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Cerita', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _onPostDeleted(post.id);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.grey),
                title: const Text('Laporkan Cerita'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Laporan Anda telah diterima.')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
