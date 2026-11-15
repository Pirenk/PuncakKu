import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../screens/tulis_cerita_screen.dart';

class CeritaDetailScreen extends StatefulWidget {
  final StoryPost post;
  final Function(StoryPost updatedPost) onPostUpdated;
  final Function(String postId) onPostDeleted;
  final Function(StoryPost newPost)? onStoryCreated;

  const CeritaDetailScreen({
    super.key,
    required this.post,
    required this.onPostUpdated,
    required this.onPostDeleted,
    this.onStoryCreated,
  });

  @override
  State<CeritaDetailScreen> createState() => _CeritaDetailScreenState();
}

class _CeritaDetailScreenState extends State<CeritaDetailScreen> {
  late StoryPost _currentPost;
  final TextEditingController _commentController = TextEditingController();
  bool _showError = false;
  bool _isLoadingComments = true;
  bool _isSendingComment = false;

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);
  final Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _fetchCommentsFromDb();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchCommentsFromDb() async {
    final rawId = _currentPost.rawIdPostingan ?? int.tryParse(_currentPost.id);
    if (rawId == null) {
      setState(() => _isLoadingComments = false);
      return;
    }

    final commentMaps = await ApiService.getKomentar(rawId);
    if (mounted) {
      setState(() {
        if (commentMaps.isNotEmpty) {
          final loadedComments = commentMaps
              .map((m) => StoryComment.fromMap(m))
              .toList();
          _currentPost = _currentPost.copyWith(comments: loadedComments);
        }
        _isLoadingComments = false;
      });
    }
  }

  void _toggleLike() async {
    final wasLiked = _currentPost.isLiked;
    final newCount = wasLiked
        ? _currentPost.likesCount - 1
        : _currentPost.likesCount + 1;

    setState(() {
      _currentPost = _currentPost.copyWith(
        isLiked: !wasLiked,
        likesCount: newCount < 0 ? 0 : newCount,
      );
    });
    widget.onPostUpdated(_currentPost);

    final rawId = _currentPost.rawIdPostingan ?? int.tryParse(_currentPost.id);
    if (rawId != null) {
      final currentUser = userProfileNotifier.value;
      final userId = currentUser.id ?? 1;
      final res = await ApiService.toggleLikePostingan(
        idPostingan: rawId,
        userId: userId,
      );
      if (res['status'] == 'success' && res['data'] != null && mounted) {
        setState(() {
          _currentPost = _currentPost.copyWith(
            isLiked: res['data']['is_liked'] ?? _currentPost.isLiked,
            likesCount: res['data']['total_likes'] ?? _currentPost.likesCount,
          );
        });
        widget.onPostUpdated(_currentPost);
      }
    }
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() => _isSendingComment = true);

    final currentUser = userProfileNotifier.value;
    final userId = currentUser.id ?? 1;
    final rawId = _currentPost.rawIdPostingan ?? int.tryParse(_currentPost.id);

    if (rawId != null) {
      await ApiService.addKomentar(
        idPostingan: rawId,
        userId: userId,
        isiKomentar: text,
      );
    }

    final newComment = StoryComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      authorName: currentUser.name,
      timestamp: 'Baru saja',
      content: text,
    );

    setState(() {
      final updatedComments = List<StoryComment>.from(_currentPost.comments)
        ..add(newComment);
      _currentPost = _currentPost.copyWith(
        comments: updatedComments,
        totalComments: _currentPost.totalComments + 1,
      );
      _commentController.clear();
      _showError = false;
      _isSendingComment = false;
    });

    widget.onPostUpdated(_currentPost);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil dikirim ke database!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF1B4D3E),
        ),
      );
    }
  }

  void _showEditDialog() {
    final editController = TextEditingController(text: _currentPost.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ubah Cerita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4D3E),
          ),
        ),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Edit cerita kamu...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                final rawId =
                    _currentPost.rawIdPostingan ??
                    int.tryParse(_currentPost.id);
                if (rawId != null) {
                  await ApiService.updatePostingan(
                    idPostingan: rawId,
                    caption: "[Gunung ${_currentPost.mountain}] $newContent",
                  );
                }

                setState(() {
                  _currentPost = _currentPost.copyWith(content: newContent);
                });
                widget.onPostUpdated(_currentPost);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Cerita?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus cerita ini dari database?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final rawId =
                  _currentPost.rawIdPostingan ?? int.tryParse(_currentPost.id);
              if (rawId != null) {
                await ApiService.deletePostingan(rawId);
              }

              Navigator.pop(ctx);
              widget.onPostDeleted(_currentPost.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
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
          'Detail cerita',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF182A22)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan cerita disalin!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Post Content Card
            Container(
              color: _cardBg,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          _currentPost.authorAvatar,
                        ),
                        backgroundColor: Colors.grey.shade200,
                        onBackgroundImageError: (_, __) {},
                        child: _currentPost.authorAvatar.isEmpty
                            ? Text(_currentPost.authorName[0])
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
                                  _currentPost.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF182A22),
                                  ),
                                ),
                                if (_currentPost.isCurrentUser) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primaryDark.withValues(
                                        alpha: 0.1,
                                      ),
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
                              'Gunung ${_currentPost.mountain} · ${_currentPost.date}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentPost.isCurrentUser)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showEditDialog();
                            } else if (val == 'delete') {
                              _confirmDelete();
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ubah'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Content text
                  Text(
                    _currentPost.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E35),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Image
                  if (_currentPost.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _currentPost.imageUrl,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.landscape,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Action bar (Like & Comments count)
                  Row(
                    children: [
                      InkWell(
                        onTap: _toggleLike,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _currentPost.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: _currentPost.isLiked
                                    ? Colors.red
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_currentPost.likesCount} suka',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _currentPost.isLiked
                                      ? Colors.red
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_currentPost.comments.length} komentar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Comments Section Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Text(
                'Komentar (${_currentPost.comments.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Comment input box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _showError ? Colors.red : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar atau tips balasan...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_showError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Komentar tidak boleh kosong',
                        style: TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: _isSendingComment ? null : _submitComment,
                      child: _isSendingComment
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Comments List
            _isLoadingComments
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: _primaryDark),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentPost.comments.length,
                    itemBuilder: (ctx, idx) {
                      final comment = _currentPost.comments[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF182A22),
                                  ),
                                ),
                                Text(
                                  comment.timestamp,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.content,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2C3E35),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
