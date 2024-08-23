class Comment {
  final String username;
  final String content;

  Comment({required this.username, required this.content});

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'] ?? '',
      content: map['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'content': content,
    };
  }
}
