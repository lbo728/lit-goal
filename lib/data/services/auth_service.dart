import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  AuthService() {
    _init();
  }

  void _init() {
    _currentUser = _supabase.auth.currentUser != null
        ? UserModel.fromUser(_supabase.auth.currentUser!)
        : null;

    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            _currentUser = UserModel.fromUser(session!.user);
            notifyListeners();
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  // 이메일 회원가입
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 이메일 로그인
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 카카오 로그인
  Future<String?> signInWithKakao() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: kIsWeb ? null : 'io.supabase.lit_goal://login-callback',
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 구글 로그인
  Future<String?> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.lit_goal://login-callback',
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 로그아웃
  Future<String?> signOut() async {
    try {
      await _supabase.auth.signOut();
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 비밀번호 재설정 이메일 전송
  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.lit_goal://reset-callback',
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
