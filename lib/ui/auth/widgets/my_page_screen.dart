import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/notification_service.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isEditingNickname = false;
  late TextEditingController _nicknameController;

  File? _pendingAvatarFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthService>().currentUser;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthService>().fetchCurrentUser());
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text(
            '정말로 계정을 삭제하시겠습니까?\n\n'
            '이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final authService = context.read<AuthService>();
      final success = await authService.deleteAccount();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정이 성공적으로 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정 삭제에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickNotificationTime(BuildContext context) async {
    final service = context.read<NotificationService>();
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      TimeOfDay initial = service.scheduledTime;
      final result = await showCupertinoModalPopup<TimeOfDay>(
        context: context,
        builder: (ctx) {
          TimeOfDay temp = initial;
          return Container(
            height: 300,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('취소'),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () => Navigator.of(ctx).pop(temp),
                          child: const Text('완료'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: DateTime(
                        0,
                        1,
                        1,
                        initial.hour,
                        initial.minute,
                      ),
                      onDateTimeChanged: (dt) {
                        temp = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (result != null) {
        await service.updateTime(result);
      }
    } else {
      final picked = await showTimePicker(
        context: context,
        initialTime: service.scheduledTime,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        ),
      );
      if (picked != null) {
        await service.updateTime(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final notificationService = context.watch<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await authService.fetchCurrentUser();

          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pendingAvatarFile != null
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (picked != null) {
                                    setState(() {
                                      _pendingAvatarFile = File(picked.path);
                                    });
                                  }
                                },
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipOval(
                              child: _pendingAvatarFile != null
                                  ? Image.file(
                                      _pendingAvatarFile!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : (user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty)
                                      ? Image.network(
                                          user.avatarUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.lightBlue[100],
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.blue,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.blue,
                                          ),
                                        ),
                            ),
                          ),
                        ),
                        if (_pendingAvatarFile != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_pendingAvatarFile != null) {
                                    print(
                                        '_pendingAvatarFile: $_pendingAvatarFile');
                                    await authService
                                        .uploadAvatar(_pendingAvatarFile!);
                                    setState(() {
                                      _pendingAvatarFile = null;
                                    });
                                  }
                                },
                                child: const Text('변경'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _pendingAvatarFile = null;
                                  });
                                },
                                child: const Text('취소'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _isEditingNickname
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nicknameController,
                                decoration: const InputDecoration(
                                  labelText: '닉네임',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await authService
                                    .updateNickname(_nicknameController.text);
                                setState(() {
                                  _isEditingNickname = false;
                                });
                              },
                              child: const Text('변경하기'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingNickname = false;
                                  _nicknameController.text =
                                      user.nickname ?? '';
                                });
                              },
                              child: const Text('취소'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.nickname ?? '닉네임 없음',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingNickname = true;
                                  _nicknameController.text =
                                      user.nickname ?? '';
                                });
                              },
                              child: const Text('닉네임 변경'),
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                  Text('이메일: ${user.email}'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  // 알림 설정 섹션
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '알림 설정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: notificationService.isEnabled,
                        onChanged: (v) =>
                            context.read<NotificationService>().setEnabled(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: notificationService.isEnabled ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: !notificationService.isEnabled,
                      child: Row(
                        children: [
                          const Text('알림 시간'),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _pickNotificationTime(context),
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              _formatTime(notificationService.scheduledTime),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await context
                                  .read<NotificationService>()
                                  .showTestNotification(
                                    delay: const Duration(seconds: 5),
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('5초 후 테스트 알림이 도착합니다.'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                            ),
                            label: const Text('테스트 알림'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<AuthService>().signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('로그아웃'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('계정 삭제'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
