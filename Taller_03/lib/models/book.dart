class Book {
  final String id;
  String title;
  String author;
  String genre;
  String description;
  DateTime publishDate;
  bool isRead;
  String coverColor;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    this.description = '',
    required this.publishDate,
    this.isRead = false,
    required this.coverColor,
  });
}