import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';

class AladinApiService {
  static Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    AppConfig.validateApiKeys();

    try {
      final searchUri =
          Uri.parse(AppConfig.aladinBaseUrl).replace(queryParameters: {
        'ttbkey': AppConfig.aladinApiKey,
        'Query': query,
        'QueryType': 'Title',
        'MaxResults': AppConfig.maxSearchResults.toString(),
        'start': '1',
        'SearchTarget': 'Book',
        'output': 'js',
        'Version': AppConfig.apiVersion,
      });

      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final List<dynamic> searchItems = searchData['item'] ?? [];

        List<BookSearchResult> detailedBooks = [];

        for (var item in searchItems.take(5)) {
          final isbn13 = item['isbn13'];
          if (isbn13 != null && isbn13.toString().isNotEmpty) {
            final detailedBook = await _fetchBookDetails(isbn13.toString());
            if (detailedBook != null) {
              detailedBooks.add(detailedBook);
            } else {
              detailedBooks.add(BookSearchResult.fromJson(item));
            }
          } else {
            detailedBooks.add(BookSearchResult.fromJson(item));
          }
        }

        return detailedBooks;
      } else {
        throw Exception('Failed to load books: ${searchResponse.statusCode}');
      }
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }

  static Future<BookSearchResult?> _fetchBookDetails(String isbn) async {
    try {
      final lookupUri =
          Uri.parse(AppConfig.aladinBaseUrl).replace(queryParameters: {
        'ttbkey': AppConfig.aladinApiKey,
        'itemIdType': 'ISBN',
        'ItemId': isbn,
        'output': 'js',
        'Version': AppConfig.apiVersion,
        'OptResult': 'ebookList,usedList,reviewList',
      });

      print('📡 상품 조회 API 요청: $lookupUri');
      final response = await http.get(lookupUri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📩 상세 정보 응답: ${jsonData.toString()}');

        final List<dynamic> items = jsonData['item'] ?? [];
        if (items.isNotEmpty) {
          return BookSearchResult.fromJson(items[0]);
        }
      } else {
        print('⚠️ 상세 정보 API 응답 실패 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('❌ 상세 정보 조회 실패: $e');
    }
    return null;
  }
}
