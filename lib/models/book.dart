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
  final String? id;
  final String title;
  final String? author;
  final DateTime startDate;
  final DateTime targetDate;
  final String? imageUrl;
  final int currentPage;
  final int totalPages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    this.id,
    required this.title,
    this.author,
    required this.startDate,
    required this.targetDate,
    this.imageUrl,
    this.currentPage = 0,
    this.totalPages = 0,
    this.createdAt,
    this.updatedAt,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    DateTime? startDate,
    DateTime? targetDate,
    String? imageUrl,
    int? currentPage,
    int? totalPages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'author': author,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'image_url': imageUrl,
      'current_page': currentPage,
      'total_pages': totalPages,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'],
      startDate: DateTime.parse(json['start_date']),
      targetDate: DateTime.parse(json['target_date']),
      imageUrl: json['image_url'],
      currentPage: json['current_page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
