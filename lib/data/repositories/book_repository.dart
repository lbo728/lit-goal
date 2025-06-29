import '../../domain/models/book.dart';
import '../services/book_service.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<Book?> addBook(Book book);
  Future<Book?> updateBook(String bookId, Book book);
  Future<Book?> updateCurrentPage(String bookId, int currentPage);
  Future<bool> deleteBook(String bookId);
  Future<Book?> getBookById(String bookId);
  Future<List<Book>> getActiveBooks();
  Future<List<Book>> getCompletedBooks();
  List<Book> get cachedBooks;
  bool get hasBooks;
  Book? get latestBook;
}

class BookRepositoryImpl implements BookRepository {
  final BookService _bookService;

  BookRepositoryImpl(this._bookService);

  @override
  Future<List<Book>> getBooks() async {
    return await _bookService.fetchBooks();
  }

  @override
  Future<Book?> addBook(Book book) async {
    return await _bookService.addBook(book);
  }

  @override
  Future<Book?> updateBook(String bookId, Book book) async {
    return await _bookService.updateBook(bookId, book);
  }

  @override
  Future<Book?> updateCurrentPage(String bookId, int currentPage) async {
    return await _bookService.updateCurrentPage(bookId, currentPage);
  }

  @override
  Future<bool> deleteBook(String bookId) async {
    return await _bookService.deleteBook(bookId);
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    return await _bookService.getBookById(bookId);
  }

  @override
  Future<List<Book>> getActiveBooks() async {
    return await _bookService.getActiveBooks();
  }

  @override
  Future<List<Book>> getCompletedBooks() async {
    return await _bookService.getCompletedBooks();
  }

  @override
  List<Book> get cachedBooks => _bookService.books;

  @override
  bool get hasBooks => _bookService.hasBooks;

  @override
  Book? get latestBook => _bookService.latestBook;
}
