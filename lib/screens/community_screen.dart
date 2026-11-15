import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/mountain_logo.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _backgroundColor = const Color(0xFFF7F9F8);

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final currentUser = userProfileNotifier.value;
    final posts = await ApiService.getPostingan(userId: currentUser.id);
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggleLike(Map<String, dynamic> post) async {
    final currentUser = userProfileNotifier.value;
    final userId = currentUser.id ?? 1;
    final postId = post['id_postingan'] as int;

    // Optimistic UI update
    final bool currentLiked = post['is_liked'] ?? false;
    final int currentTotal = post['total_likes'] ?? 0;

    setState(() {
      post['is_liked'] = !currentLiked;
      post['total_likes'] = currentLiked ? currentTotal - 1 : currentTotal + 1;
    });

    final res = await ApiService.toggleLikePostingan(
      idPostingan: postId,
      userId: userId,
    );

    if (res['status'] == 'success' && res['data'] != null && mounted) {
      setState(() {
        post['is_liked'] = res['data']['is_liked'];
        post['total_likes'] = res['data']['total_likes'];
      });
    }
  }

  void _showCreatePostDialog() {
    final captionController = TextEditingController();
    final fotoController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bagikan Cerita Pendakian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: captionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Ceritakan pengalaman, kondisi jalur, atau cuaca di puncak...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: fotoController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.image_outlined, size: 20),
                      hintText: 'Tautan Foto (Opsional: https://...)',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final caption = captionController.text.trim();
                              final foto = fotoController.text.trim();

                              if (caption.isEmpty && foto.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Tuliskan cerita atau sertakan foto terlebih dahulu'),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final currentUser = userProfileNotifier.value;
                              final userId = currentUser.id ?? 1;

                              final res = await ApiService.createPostingan(
                                userId: userId,
                                caption: caption,
                                foto: foto.isNotEmpty ? foto : null,
                              );

                              if (res['status'] == 'success') {
                                Navigator.pop(ctx);
                                _fetchPosts();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Postingan berhasil dibagikan ke komunitas!'),
                                    backgroundColor: Color(0xFF1B4D3E),
                                  ),
                                );
                              } else {
                                setModalState(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        res['message'] ?? 'Gagal membuat postingan'),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Posting Sekarang',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCommentsModal(int idPostingan) {
    final commentController = TextEditingController();
    List<Map<String, dynamic>> comments = [];
    bool isLoadingComments = true;
    bool isPostingComment = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void loadComments() async {
              final list = await ApiService.getKomentar(idPostingan);
              setModalState(() {
                comments = list;
                isLoadingComments = false;
              });
            }

            if (isLoadingComments) {
              loadComments();
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Komentar (${comments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF152A20),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: isLoadingComments
                          ? const Center(child: CircularProgressIndicator())
                          : comments.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada komentar.\nJadilah yang pertama berkomentar!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: comments.length,
                                  itemBuilder: (context, idx) {
                                    final c = comments[idx];
                                    final nama =
                                        c['user_nama'] ?? 'Pendaki';
                                    final isi = c['isi_komentar'] ?? '';
                                    final tgl = _formatTime(c['tanggal_dibuat']);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                const Color(0xFFE5EDE8),
                                            child: Text(
                                              nama.isNotEmpty
                                                  ? nama[0].toUpperCase()
                                                  : 'P',
                                              style: TextStyle(
                                                color: _primaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      nama,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(0xFF152A20),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      tgl,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  isi,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF2C3E35),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: isPostingComment
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(Icons.send_rounded, color: _primaryDark),
                            onPressed: isPostingComment
                                ? null
                                : () async {
                                    final text = commentController.text.trim();
                                    if (text.isEmpty) return;

                                    setModalState(() => isPostingComment = true);

                                    final currentUser =
                                        userProfileNotifier.value;
                                    final userId = currentUser.id ?? 1;

                                    final res = await ApiService.addKomentar(
                                      idPostingan: idPostingan,
                                      userId: userId,
                                      isiKomentar: text,
                                    );

                                    if (res['status'] == 'success') {
                                      commentController.clear();
                                      loadComments();
                                      _fetchPosts(); // refresh post comment counter
                                    }

                                    setModalState(() => isPostingComment = false);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
      if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
      if (diff.inDays < 7) return '${diff.inDays}h yang lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
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
            MountainLogo(size: 26, color: _primaryDark),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Komunitas Pendaki',
                  style: TextStyle(
                    color: _primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'CERITA & PENGALAMAN DARI PUNCAK',
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
            icon: Icon(Icons.add_circle_outline, color: _primaryDark, size: 26),
            tooltip: 'Bagikan Cerita',
            onPressed: _showCreatePostDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Buat Cerita'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        color: _primaryDark,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: _primaryDark),
              )
            : _posts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada cerita di komunitas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jadilah pendaki pertama yang membagikan momen!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _showCreatePostDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryDark,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Bagikan Cerita Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final author = post['author_nama'] ?? 'Pendaki';
                      final username = post['author_username'] != null &&
                              post['author_username'].toString().isNotEmpty
                          ? "@${post['author_username']}"
                          : '';
                      final caption = post['caption'] ?? '';
                      final foto = post['foto'] ?? '';
                      final time = _formatTime(post['tanggal_dibuat']);
                      final bool isLiked = post['is_liked'] ?? false;
                      final int totalLikes = post['total_likes'] ?? 0;
                      final int totalKomentar = post['total_komentar'] ?? 0;
                      final int idPostingan = post['id_postingan'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5EDE8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author Header
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFFE5EDE8),
                                    child: Text(
                                      author.isNotEmpty
                                          ? author[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          author,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF152A20),
                                          ),
                                        ),
                                        Text(
                                          "$username · $time",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Caption Text
                            if (caption.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                child: Text(
                                  caption,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Color(0xFF2C3E35),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            // Image if available
                            if (foto.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    foto,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        height: 120,
                                        color: const Color(0xFFE8F2EC),
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            color: _primaryDark,
                                            size: 36,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            // Action Bar: Like & Comment
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  // Like Button
                                  InkWell(
                                    onTap: () => _handleToggleLike(post),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border_rounded,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.grey.shade600,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$totalLikes',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Comment Button
                                  InkWell(
                                    onTap: () =>
                                        _showCommentsModal(idPostingan),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            color: Colors.grey.shade600,
                                            size: 19,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$totalKomentar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
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
                      );
                    },
                  ),
      ),
    );
  }
}

