import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get aladinApiKey => dotenv.env['ALADIN_TTB_KEY'] ?? '';

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static String get aladinBaseUrl =>
      'http://www.aladin.co.kr/ttb/api/ItemSearch.aspx';

  // Supabase 설정
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://enyxrgxixrnoazzgqyyd.supabase.co';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your_supabase_anon_key_here';

  static const int maxSearchResults = 10;
  static const String apiVersion = '20131101';

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  static void validateApiKeys() {
    if (aladinApiKey.isEmpty) {
      throw Exception(
          'ALADIN_TTB_KEY is required but not found in environment variables');
    }
    if (supabaseAnonKey == 'your_supabase_anon_key_here') {
      throw Exception(
          'SUPABASE_ANON_KEY is required but not properly configured');
    }
  }
}
