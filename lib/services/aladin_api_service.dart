import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';

class AladinApiService {
  static Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    AppConfig.validateApiKeys();

    try {
      final uri = Uri.parse(AppConfig.aladinBaseUrl).replace(queryParameters: {
        'ttbkey': AppConfig.aladinApiKey,
        'Query': query,
        'QueryType': 'Title',
        'MaxResults': AppConfig.maxSearchResults.toString(),
        'start': '1',
        'SearchTarget': 'Book',
        'output': 'js',
        'Version': AppConfig.apiVersion,
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
