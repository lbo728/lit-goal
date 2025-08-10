import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';
import 'dart:io';

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
      final userId = response.user?.id;
      if (userId != null) {
        await _supabase.from('users').insert({
          'id': userId,
          'email': email,
          'name': name,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
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

  Future<String?> signInWithKakao() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: kIsWeb ? null : 'io.supabase.lit_goal://login-callback',
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

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

  Future<void> updateNickname(String nickname) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('users')
        .update({'nickname': nickname}).eq('id', userId);
    // await fetchCurrentUser();
    notifyListeners();
  }

  Future<void> uploadAvatar(File file) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    final filePath = '$userId/avatar.png';
    await _supabase.storage.from('avatars').upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _supabase.storage.from('avatars').getPublicUrl(filePath);

    await _supabase.from('users').update({'avatar_url': url}).eq('id', userId);

    // await fetchCurrentUser();
    notifyListeners();
  }

  // Future<UserModel?> fetchCurrentUser() async {
  //   final userId = _supabase.auth.currentUser?.id;
  //   if (userId == null) return null;
  //   final data =
  //       await _supabase.from('users').select().eq('id', userId).single();
  //   _currentUser = UserModel.fromJson(data);
  //   notifyListeners();
  //   return _currentUser;
  // }

  Future<UserModel?> getCurrentUser() async {
    final user = await _supabase.auth.getUser();
    _currentUser = UserModel.fromUser(user.user!);
    notifyListeners();
    return _currentUser;
  }

  Future<bool> deleteAccount() async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return false;

      // 1. 사용자 데이터 삭제
      await _supabase.from('users').delete().eq('id', userId);

      // 2. 사용자 관련 데이터 삭제 (독서 기록, 목표 등)
      await _supabase.from('reading_goals').delete().eq('user_id', userId);
      await _supabase.from('reading_progress').delete().eq('user_id', userId);
      await _supabase.from('books').delete().eq('user_id', userId);

      // 3. 아바타 이미지 삭제
      try {
        await _supabase.storage.from('avatars').remove(['$userId/avatar.png']);
      } catch (e) {
        // 아바타가 없을 수 있으므로 무시
        print('아바타 삭제 중 오류 (무시됨): $e');
      }

      // 4. Supabase Auth에서 사용자 삭제
      await _supabase.auth.admin.deleteUser(userId);

      // 5. 로컬 상태 정리
      _currentUser = null;
      notifyListeners();

      return true;
    } catch (e) {
      print('계정 삭제 오류: $e');
      return false;
    }
  }
}
