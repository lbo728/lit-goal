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

  Future<UserModel?> fetchCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data =
        await _supabase.from('users').select().eq('id', userId).single();
    _currentUser = UserModel.fromJson(data);
    notifyListeners();
    return _currentUser;
  }

  Future<void> updateNickname(String nickname) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('users')
        .update({'nickname': nickname}).eq('id', userId);
    await fetchCurrentUser();
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

    final baseUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
    final urlWithBust = '$baseUrl?ts=${DateTime.now().millisecondsSinceEpoch}';

    await _supabase
        .from('users')
        .update({'avatar_url': urlWithBust}).eq('id', userId);

    await fetchCurrentUser();
    notifyListeners();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = await _supabase.auth.getUser();
    _currentUser = UserModel.fromUser(user.user!);
    notifyListeners();
    return _currentUser;
  }

  Future<bool> deleteAccount() async {
    try {
      final response = await _supabase.functions.invoke('delete-user');
      if (response.status == 200) {
        _currentUser = null;
        notifyListeners();
        await _supabase.auth.signOut();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('계정 삭제 오류: $e');
      return false;
    }
  }
}
