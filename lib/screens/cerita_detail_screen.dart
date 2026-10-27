import 'package:flutter/material.dart';
import '../models/story.dart';
import 'tulis_cerita_screen.dart';

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

  final Color _primaryDark = const Color(0xFF1B4D3E);
  final Color _bgLight = const Color(0xFFF7F9F8);
  final Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      final wasLiked = _currentPost.isLiked;
      final newCount = wasLiked ? _currentPost.likesCount - 1 : _currentPost.likesCount + 1;
      _currentPost = _currentPost.copyWith(
        isLiked: !wasLiked,
        likesCount: newCount < 0 ? 0 : newCount,
      );
    });
    widget.onPostUpdated(_currentPost);
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    final newComment = StoryComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Alya Putri',
      timestamp: 'Baru saja',
      content: text,
    );

    setState(() {
      final updatedComments = List<StoryComment>.from(_currentPost.comments)..add(newComment);
      _currentPost = _currentPost.copyWith(comments: updatedComments);
      _commentController.clear();
      _showError = false;
    });

    widget.onPostUpdated(_currentPost);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Komentar berhasil dikirim!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF1B4D3E),
      ),
    );
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                setState(() {
                  _currentPost = _currentPost.copyWith(content: editController.text.trim());
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
        content: const Text('Apakah Anda yakin ingin menghapus cerita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
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
        title: Text(
          'Cerita ${_currentPost.mountain.replaceFirst('Gunung ', '')}',
          style: const TextStyle(
            color: Color(0xFF182A22),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF182A22)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              const SizedBox(height: 12),

              // Author Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child: ClipOval(
                      child: Image.network(
                        _currentPost.authorAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 22, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPost.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF182A22),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_currentPost.mountain} · ${_currentPost.date}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    _currentPost.imageUrl,
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
              const SizedBox(height: 16),

              // Post Caption Text
              Text(
                _currentPost.content,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: Color(0xFF23382F),
                ),
              ),
              const SizedBox(height: 16),

              // Like and Comment summary bar
              Row(
                children: [
                  InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                      child: Row(
                        children: [
                          Icon(
                            _currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _currentPost.isLiked ? Colors.red : const Color(0xFF23382F),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentPost.isLiked
                                ? '${_currentPost.likesCount} suka · Disukai'
                                : '${_currentPost.likesCount} suka',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _currentPost.isLiked ? FontWeight.bold : FontWeight.w500,
                              color: _currentPost.isLiked ? const Color(0xFF1B4D3E) : const Color(0xFF23382F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 19, color: Color(0xFF23382F)),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentPost.comments.length} komentar',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF23382F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Menu cerita kamu (if current user)
              if (_currentPost.isCurrentUser) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu cerita kamu · akun contoh',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InkWell(
                            onTap: _showEditDialog,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1B4D3E)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Ubah cerita',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1B4D3E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: _confirmDelete,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text(
                                    'Hapus cerita',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Header Percakapan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Percakapan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                  Text(
                    '${_currentPost.comments.length} komentar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of comments
              ..._currentPost.comments.map((comment) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
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
                      const SizedBox(height: 6),
                      Text(
                        comment.content,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C3E36),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Tambahkan Komentar Section
              const Text(
                'Tambahkan komentar',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF182A22),
                ),
              ),
              const SizedBox(height: 8),

              // Comment Input
              Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _showError ? Colors.red.shade400 : Colors.grey.shade300,
                    width: _showError ? 1.5 : 1,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 2,
                  onChanged: (val) {
                    if (_showError && val.trim().isNotEmpty) {
                      setState(() {
                        _showError = false;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Bagikan tanggapan yang baik...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),

              if (_showError) ...[
                const SizedBox(height: 4),
                const Text(
                  'Komentar tidak boleh kosong.',
                  style: TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],

              const SizedBox(height: 12),

              // Kirim Komentar Button
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
                  onPressed: _submitComment,
                  child: const Text(
                    'Kirim komentar · simulasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tulis cerita baru Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryDark,
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Tulis cerita baru',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => TulisCeritaScreen(
                          onStoryCreated: (newPost) {
                            if (widget.onStoryCreated != null) {
                              widget.onStoryCreated!(newPost);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
