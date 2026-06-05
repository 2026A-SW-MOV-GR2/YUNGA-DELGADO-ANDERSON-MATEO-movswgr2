// lib/domain/entities/post_item.dart

class PostItem {
  final int id;
  final int userId;
  final String title;
  final String body;

  const PostItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
  };

  PostItem copyWith({String? title, String? body}) {
    return PostItem(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }
}