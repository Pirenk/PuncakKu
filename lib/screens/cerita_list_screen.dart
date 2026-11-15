import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import 'cerita_detail_screen.dart';
import 'tulis_cerita_screen.dart';

class CeritaListScreen extends StatefulWidget {
  const CeritaListScreen({super.key});

  @override
  State<CeritaListScreen> createState() => _CeritaListScreenState();
}

class _CeritaListScreenState extends State<CeritaListScreen> {
  List<StoryPost> _stories = [];
  bool _isLoading = true;
  String _selectedCategory = 'Untukmu';
  final List<String> _categories = ['Untukmu', 'Terbaru', 'Tips pemula'];

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);

  @override
  void initState() {
    super.initState();
    _loadStoriesFromApi();
  }

  Future<void> _loadStoriesFromApi() async {
    final currentUser = userProfileNotifier.value;
    final apiPosts = await ApiService.getPostingan(userId: currentUser.id);

    if (mounted) {
      setState(() {
        if (apiPosts.isNotEmpty) {
          _stories = apiPosts
              .map((m) => StoryPost.fromMap(m, currentUserId: currentUser.id))
              .toList();
        } else {
          _stories = [];
        }
        _isLoading = false;
      });
    }
  }

  void _toggleLike(StoryPost post) async {
    final wasLiked = post.isLiked;
    setState(() {
      post.isLiked = !wasLiked;
      post.likesCount =
          wasLiked ? (post.likesCount - 1).clamp(0, 99999) : post.likesCount + 1;
    });

    final rawId = post.rawIdPostingan ?? int.tryParse(post.id);
    if (rawId != null) {
      final currentUser = userProfileNotifier.value;
      final userId = currentUser.id ?? 1;
      final res = await ApiService.toggleLikePostingan(
        idPostingan: rawId,
        userId: userId,
      );
      if (res['status'] == 'success' && res['data'] != null && mounted) {
        setState(() {
          post.isLiked = res['data']['is_liked'] ?? post.isLiked;
          post.likesCount = res['data']['total_likes'] ?? post.likesCount;
        });
      }
    }
  }

  void _onPostUpdated(StoryPost updatedPost) {
    setState(() {
      final index = _stories.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        _stories[index] = updatedPost;
      }
    });
  }

  void _onPostDeleted(String postId) async {
    setState(() {
      _stories.removeWhere((p) => p.id == postId);
    });

    final intId = int.tryParse(postId);
    if (intId != null) {
      await ApiService.deletePostingan(intId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerita berhasil dihapus dari database.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onStoryCreated(StoryPost newPost) {
    setState(() {
      _stories.insert(0, newPost);
    });
    // Muat ulang dari database di background untuk sinkronisasi penuh
    _loadStoriesFromApi();
  }

  List<StoryPost> get _filteredStories {
    if (_selectedCategory == 'Untukmu') {
      return _stories;
    } else if (_selectedCategory == 'Terbaru') {
      // Tab 'Terbaru' menampilkan seluruh postingan terbaru yang baru dibuat/diambil dari database
      return _stories;
    } else if (_selectedCategory == 'Tips pemula') {
      return _stories.where((post) {
        final content = post.content.toLowerCase();
        return post.category == 'Tips pemula' ||
            content.contains('tips') ||
            content.contains('pemula') ||
            content.contains('persiapan') ||
            content.contains('jangan');
      }).toList();
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
          onRefresh: _loadStoriesFromApi,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? _primaryDark : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _primaryDark
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
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
                        'Tulis cerita pendakian',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _navigateToCreate,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F2EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: _primaryDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cerita asli dari database pendaki. Tips jalur & kondisi cuaca nyata.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feed List
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: _primaryDark),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.terrain_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada cerita di kategori ini.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final post = filtered[index];
                        return _buildStoryCard(post);
                      },
                    ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(post),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top author row
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.authorAvatar),
                    backgroundColor: Colors.grey.shade200,
                    onBackgroundImageError: (_, __) {},
                    child: post.authorAvatar.isEmpty
                        ? Text(post.authorName[0])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF182A22),
                              ),
                            ),
                            if (post.isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _primaryDark.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Anda',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gunung ${post.mountain} · ${post.date}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content text
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2C3E35),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),

            // Post image
            if (post.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.landscape,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom action row: Like & Comment
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _toggleLike(post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 19,
                            color: post.isLiked
                                ? Colors.red
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: post.isLiked
                                  ? Colors.red
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  InkWell(
                    onTap: () => _navigateToDetail(post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 17,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.totalComments > 0 ? post.totalComments : post.comments.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
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
