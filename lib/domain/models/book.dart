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
    int? parsedPages;
    final itemPage = json['subInfo']?['itemPage'];

    if (itemPage != null) {
      if (itemPage is int) {
        parsedPages = itemPage;
      } else if (itemPage is String) {
        parsedPages = int.tryParse(itemPage);
      } else {
        parsedPages = int.tryParse(itemPage.toString());
      }
    }

    print('📖 책 파싱 완료 - 제목: ${json['title']}, 페이지: $parsedPages');

    return BookSearchResult(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['cover'],
      totalPages: parsedPages,
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
  final String? status;

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
    this.status,
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
    String? status,
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
      status: status ?? this.status,
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
      if (status != null) 'status': status,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String?,
      title: json['title'] as String,
      author: json['author'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      targetDate: DateTime.parse(json['target_date'] as String),
      imageUrl: json['image_url'] as String?,
      currentPage: json['current_page'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      status: json['status'] as String?,
    );
  }
}
