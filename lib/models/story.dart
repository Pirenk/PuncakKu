class StoryComment {
  final String id;
  final String authorName;
  final String timestamp;
  final String content;

  StoryComment({
    required this.id,
    required this.authorName,
    required this.timestamp,
    required this.content,
  });

  factory StoryComment.fromMap(Map<String, dynamic> map) {
    String formattedTime = '';
    if (map['tanggal_dibuat'] != null) {
      try {
        final d = DateTime.parse(map['tanggal_dibuat'].toString());
        final diff = DateTime.now().difference(d);
        if (diff.inMinutes < 60) {
          formattedTime = '${diff.inMinutes}m yang lalu';
        } else if (diff.inHours < 24) {
          formattedTime = '${diff.inHours}j yang lalu';
        } else {
          formattedTime = '${d.day}/${d.month} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        }
      } catch (_) {
        formattedTime = map['tanggal_dibuat'].toString();
      }
    }

    return StoryComment(
      id: map['id_komentar']?.toString() ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: map['user_nama'] ?? 'Pendaki',
      timestamp: formattedTime.isNotEmpty ? formattedTime : 'Baru saja',
      content: map['isi_komentar'] ?? '',
    );
  }

  StoryComment copyWith({
    String? id,
    String? authorName,
    String? timestamp,
    String? content,
  }) {
    return StoryComment(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
    );
  }
}

class StoryPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String mountain;
  final String date;
  final String content;
  final String imageUrl;
  int likesCount;
  bool isLiked;
  final List<StoryComment> comments;
  int totalComments; // <-- Menyimpan jumlah total komentar dari database
  final String category; // 'Untukmu', 'Terbaru', 'Tips pemula'
  final bool isCurrentUser;
  final int? rawIdPostingan;
  final int? rawIdUser;

  StoryPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.mountain,
    required this.date,
    required this.content,
    required this.imageUrl,
    required this.likesCount,
    this.isLiked = false,
    required this.comments,
    this.totalComments = 0,
    this.category = 'Untukmu',
    this.isCurrentUser = false,
    this.rawIdPostingan,
    this.rawIdUser,
  });

  factory StoryPost.fromMap(Map<String, dynamic> map, {int? currentUserId}) {
    final rawPostId = (map['id_postingan'] as num?)?.toInt();
    final rawUserId = (map['id_user'] as num?)?.toInt();

    String rawCaption = map['caption'] ?? '';
    String extractedMountain = 'Puncak';
    String cleanedContent = rawCaption;

    // Ekstrak gunung jika ada format "[Gunung XYZ]" di awal caption
    final regex = RegExp(r'^\[(.*?)\]\s*');
    final match = regex.firstMatch(rawCaption);
    if (match != null) {
      extractedMountain = match.group(1)?.replaceFirst('Gunung ', '') ?? 'Puncak';
      cleanedContent = rawCaption.substring(match.end).trim();
    } else {
      final lower = rawCaption.toLowerCase();
      if (lower.contains('merbabu')) {
        extractedMountain = 'Merbabu';
      } else if (lower.contains('prau')) {
        extractedMountain = 'Prau';
      } else if (lower.contains('rinjani')) {
        extractedMountain = 'Rinjani';
      } else if (lower.contains('slamet')) {
        extractedMountain = 'Slamet';
      } else if (lower.contains('sindoro')) {
        extractedMountain = 'Sindoro';
      }
    }

    String formattedDate = 'Hari ini';
    if (map['tanggal_dibuat'] != null) {
      try {
        final d = DateTime.parse(map['tanggal_dibuat'].toString());
        final diff = DateTime.now().difference(d);
        if (diff.inMinutes < 60) {
          formattedDate = '${diff.inMinutes}m yang lalu';
        } else if (diff.inHours < 24) {
          formattedDate = '${diff.inHours}j yang lalu';
        } else {
          formattedDate = '${d.day}/${d.month}/${d.year}';
        }
      } catch (_) {
        formattedDate = map['tanggal_dibuat'].toString();
      }
    }

    final commentCount = (map['total_komentar'] as num?)?.toInt() ?? 0;

    return StoryPost(
      id: rawPostId?.toString() ?? 'post_${DateTime.now().millisecondsSinceEpoch}',
      rawIdPostingan: rawPostId,
      rawIdUser: rawUserId,
      authorName: map['author_nama'] ?? 'Pendaki',
      authorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      mountain: extractedMountain,
      date: formattedDate,
      content: cleanedContent.isNotEmpty ? cleanedContent : rawCaption,
      imageUrl: (map['foto'] != null && map['foto'].toString().isNotEmpty)
          ? map['foto'].toString()
          : 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
      likesCount: (map['total_likes'] as num?)?.toInt() ?? 0,
      isLiked: map['is_liked'] == true,
      comments: [],
      totalComments: commentCount,
      category: 'Untukmu',
      isCurrentUser: currentUserId != null && rawUserId == currentUserId,
    );
  }

  StoryPost copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? mountain,
    String? date,
    String? content,
    String? imageUrl,
    int? likesCount,
    bool? isLiked,
    List<StoryComment>? comments,
    int? totalComments,
    String? category,
    bool? isCurrentUser,
    int? rawIdPostingan,
    int? rawIdUser,
  }) {
    return StoryPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      mountain: mountain ?? this.mountain,
      date: date ?? this.date,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? List.from(this.comments),
      totalComments: totalComments ?? this.totalComments,
      category: category ?? this.category,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      rawIdPostingan: rawIdPostingan ?? this.rawIdPostingan,
      rawIdUser: rawIdUser ?? this.rawIdUser,
    );
  }
}
