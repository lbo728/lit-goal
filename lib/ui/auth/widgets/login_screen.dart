import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_service.dart';
import 'package:lit_goal/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _name;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    String? errorMessage;

    if (_isSignUp) {
      errorMessage = await authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        name: _name,
      );
    } else {
      errorMessage = await authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapAuthError(errorMessage))),
      );
    }
  }

  Future<void> _handleSocialAuth(
      Future<String?> Function() signInMethod) async {
    setState(() => _isLoading = true);

    final errorMessage = await signInMethod();

    setState(() => _isLoading = false);

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapAuthError(errorMessage))),
      );
    } else if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  String mapAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (error.contains('Email not confirmed')) {
      return '이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요.';
    }
    if (error.contains('User already registered')) {
      return '이미 가입된 이메일입니다.';
    }
    if (error.contains('Password should be at least')) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? '회원가입' : '로그인'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isSignUp) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _name = value,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth,
                child: Text(_isSignUp ? '회원가입' : '로그인'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? '이미 계정이 있나요? 로그인' : '계정이 없나요? 회원가입'),
              ),
              const SizedBox(height: 24),
              const Text(
                '소셜 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: _isLoading
              //       ? null
              //       : () => _handleSocialAuth(
              //             context.read<AuthService>().signInWithKakao,
              //           ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFFFEE500),
              //     foregroundColor: Colors.black87,
              //   ),
              //   child: const Text('카카오로 계속하기'),
              // ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _handleSocialAuth(
                          context.read<AuthService>().signInWithGoogle,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Google로 계속하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
