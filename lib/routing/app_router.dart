import 'package:flutter/material.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/book/widgets/book_list_screen.dart';
import '../ui/book/widgets/book_detail_screen.dart';
import '../ui/reading/widgets/reading_start_screen.dart';
import '../ui/reading/widgets/reading_chart_screen.dart';
import '../ui/calendar/widgets/calendar_screen.dart';
import '../domain/models/book.dart';

class AppRouter {
  static const String home = '/';
  static const String bookList = '/book-list';
  static const String bookDetail = '/book-detail';
  static const String readingStart = '/reading-start';
  static const String readingProgress = '/reading-progress';
  static const String calendar = '/calendar';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case bookList:
        return MaterialPageRoute(builder: (_) => const BookListScreen());
      case bookDetail:
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(book: book),
        );
      case readingStart:
        return MaterialPageRoute(builder: (_) => const ReadingStartScreen());
      case readingProgress:
        return MaterialPageRoute(
          builder: (_) => const ReadingChartScreen(),
        );
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
