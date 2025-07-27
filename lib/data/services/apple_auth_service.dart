import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppleAuthService {
  static String? _currentNonce;

  /// Apple Sign In을 통해 사용자 인증을 수행합니다.
  static Future<AuthResponse?> signInWithApple() async {
    try {
      // 1. Apple Sign In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _generateNonce(),
      );

      // 2. Supabase에 Apple ID 토큰으로 인증
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: _currentNonce!,
      );

      return response;
    } catch (e) {
      print('Apple Sign In 오류: $e');
      return null;
    }
  }

  /// Apple Sign In이 사용 가능한지 확인합니다.
  static Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Apple Sign Out을 수행합니다.
  static Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Apple Sign Out 오류: $e');
    }
  }

  /// 현재 사용자 정보를 가져옵니다.
  static User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  /// SHA256 해시를 사용하여 nonce를 생성합니다.
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List<int>.generate(
        length,
        (_) => charset.codeUnitAt(
            (DateTime.now().millisecondsSinceEpoch % charset.length)));
    _currentNonce = base64Url.encode(random);
    return _currentNonce!;
  }
}
