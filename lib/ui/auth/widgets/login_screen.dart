import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Future<void> _signInWithGoogle(BuildContext context) async {
  //   try {
  //     await Supabase.instance.client.auth.signInWithOAuth(
  //       OAuthProvider.google,
  //       redirectTo: kIsWeb ? null : 'litgoal://login-callback',
  //       authScreenLaunchMode: LaunchMode.externalApplication,
  //     );
  //   } on AuthException catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('구글 로그인 실패: ${e.message}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('구글 로그인 오류: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SupaEmailAuth(
              redirectTo: kIsWeb ? null : 'litgoal://login-callback',
              onSignInComplete: (_) {},
              onSignUpComplete: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('회원가입이 완료되었습니다. 이메일을 확인해주세요.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: '이름',
                  key: 'name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
            // const SizedBox(height: 24),
            // const Divider(),
            // const SizedBox(height: 12),
            // const Text(
            //   '소셜 로그인',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.black,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // ElevatedButton.icon(
            //   onPressed: () => _signInWithGoogle(context),
            //   icon: const Icon(Icons.login),
            //   label: const Text('Google로 계속하기'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     foregroundColor: Colors.black87,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //   ),
            // ),
            // SupaSocialsAuth(
            //   socialProviders: const [
            //     OAuthProvider.apple,
            //   ],
            //   colored: true,
            //   redirectUrl: kIsWeb ? null : 'litgoal://login-callback',
            //   onSuccess: (_) {},
            //   onError: (error) {},
            // ),
          ],
        ),
      ),
    );
  }
}
