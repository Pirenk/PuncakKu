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
  final String category; // 'Untukmu', 'Terbaru', 'Tips pemula'
  final bool isCurrentUser;

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
    this.category = 'Untukmu',
    this.isCurrentUser = false,
  });

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
    String? category,
    bool? isCurrentUser,
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
      category: category ?? this.category,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
