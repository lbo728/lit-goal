class Book {
  final String title;
  final DateTime startDate;
  final DateTime targetDate;
  final String? imageUrl;
  final int currentPage;
  final int totalPages;

  Book({
    required this.title,
    required this.startDate,
    required this.targetDate,
    this.imageUrl,
    this.currentPage = 0,
    this.totalPages = 0,
  });

  Book copyWith({
    String? title,
    DateTime? startDate,
    DateTime? targetDate,
    String? imageUrl,
    int? currentPage,
    int? totalPages,
  }) {
    return Book(
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
