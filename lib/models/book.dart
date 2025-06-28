class BookSearchResult {
  final String title;
  final String author;
  final String? imageUrl;
  final int? totalPages;
  final String? isbn;

  BookSearchResult({
    required this.title,
    required this.author,
    this.imageUrl,
    this.totalPages,
    this.isbn,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['cover'],
      totalPages: int.tryParse(json['subInfo']?['itemPage']?.toString() ?? '0'),
      isbn: json['isbn'],
    );
  }
}

class Book {
  final String title;
  final String? author;
  final DateTime startDate;
  final DateTime targetDate;
  final String? imageUrl;
  final int currentPage;
  final int totalPages;

  Book({
    required this.title,
    this.author,
    required this.startDate,
    required this.targetDate,
    this.imageUrl,
    this.currentPage = 0,
    this.totalPages = 0,
  });

  Book copyWith({
    String? title,
    String? author,
    DateTime? startDate,
    DateTime? targetDate,
    String? imageUrl,
    int? currentPage,
    int? totalPages,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
