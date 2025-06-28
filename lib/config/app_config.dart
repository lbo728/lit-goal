import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get aladinApiKey => dotenv.env['ALADIN_TTB_KEY'] ?? '';

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static String get aladinBaseUrl =>
      'http://www.aladin.co.kr/ttb/api/ItemSearch.aspx';

  static const int maxSearchResults = 10;
  static const String apiVersion = '20131101';

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  static void validateApiKeys() {
    if (aladinApiKey.isEmpty) {
      throw Exception(
          'ALADIN_TTB_KEY is required but not found in environment variables');
    }
  }
}
