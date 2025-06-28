import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class AladinApiService {
  static const String _baseUrl =
      'http://www.aladin.co.kr/ttb/api/ItemSearch.aspx';

  // 알라딘 API 키 발급 방법:
  // 1. https://blog.aladin.co.kr/openapi/popup/6695306 에서 API 키 발급 신청
  // 2. 아래 _ttbKey에 발급받은 키를 입력
  static const String _ttbKey = 'ttbextreme930934002'; // 실제 API 키로 교체 필요

  static Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'ttbkey': _ttbKey,
        'Query': query,
        'QueryType': 'Title',
        'MaxResults': '10',
        'start': '1',
        'SearchTarget': 'Book',
        'output': 'js',
        'Version': '20131101',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> items = jsonData['item'] ?? [];

        return items.map((item) => BookSearchResult.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }
}
