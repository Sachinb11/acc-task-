import 'comment_modal.dart';

class Post {
  String id;
  String userId;
  String email;
  String name;
  String content;
  String? mediaUrl;
  String? mediaType;
  int likes;
  List<Comment> comments;
  String? timestamp;
  String? userProfileImageUrl; // Add this field

  Post({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.likes = 0,
    this.comments = const [],
    this.timestamp,
    this.userProfileImageUrl, // Initialize this field
  });

  /// Creates a Post object from a map (e.g., from Firestore)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      likes: map['likes'] ?? 0,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromMap(c as Map<String, dynamic>))
          .toList(),
      timestamp: map['timestamp'],
      userProfileImageUrl: map['userProfileImageUrl'],
    );
  }


  /// Converts the Post object to a map (e.g., for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'name': name,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'timestamp': timestamp,
      'userProfileImageUrl': userProfileImageUrl, // Include this field
    };
  }
}
