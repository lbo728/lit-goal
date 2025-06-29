class BookImage {
  final String? id;
  final String bookId;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;

  BookImage({
    this.id,
    required this.bookId,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
  });

  BookImage copyWith({
    String? id,
    String? bookId,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
  }) {
    return BookImage(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'book_id': bookId,
      'image_url': imageUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookImage.fromJson(Map<String, dynamic> json) {
    return BookImage(
      id: json['id'],
      bookId: json['book_id'],
      imageUrl: json['image_url'],
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
