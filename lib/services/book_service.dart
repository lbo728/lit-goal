import '../models/book.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final List<Book> _books = [];

  List<Book> get books => List.unmodifiable(_books);

  bool get hasBooks => _books.isNotEmpty;

  Book? get latestBook => _books.isNotEmpty ? _books.last : null;

  void addBook(Book book) {
    _books.add(book);
  }

  void removeBook(Book book) {
    _books.remove(book);
  }

  void updateBook(Book oldBook, Book newBook) {
    final index = _books.indexOf(oldBook);
    if (index != -1) {
      _books[index] = newBook;
    }
  }

  void clearBooks() {
    _books.clear();
  }
}
