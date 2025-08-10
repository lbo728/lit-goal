import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/book.dart';
import '../services/book_service.dart';

class NotificationService extends ChangeNotifier {
  NotificationService();

  static const String _prefEnabledKey = 'notification_enabled';
  static const String _prefHourKey = 'notification_hour';
  static const String _prefMinuteKey = 'notification_minute';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _enabled = false;
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 9, minute: 0);

  // 외부 네비게이션 콜백 및 네비게이터 키
  Future<void> Function(BuildContext context)? onOpenNotification;
  GlobalKey<NavigatorState>? navigatorKey;

  bool get isInitialized => _isInitialized;
  bool get isEnabled => _enabled;
  TimeOfDay get scheduledTime => _timeOfDay;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone init
    tz.initializeTimeZones();
    String localName = 'UTC';
    try {
      localName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      // iOS 빌드 직후/시뮬레이터 등에서 플러그인 미등록 시 폴백
      // 서비스 타깃이 한국이라면 Asia/Seoul이 합리적 기본값
      localName = 'Asia/Seoul';
    }
    tz.setLocalLocation(tz.getLocation(localName));

    // Plugin init
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      iOS: iosSettings,
      macOS: null,
      android: null,
      linux: null,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Load prefs
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefEnabledKey) ?? false;
    final hour = prefs.getInt(_prefHourKey);
    final minute = prefs.getInt(_prefMinuteKey);
    if (hour != null && minute != null) {
      _timeOfDay = TimeOfDay(hour: hour, minute: minute);
    }

    if (_enabled) {
      await _requestPermission();
      await scheduleDaily(_timeOfDay);
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, value);

    if (value) {
      await _requestPermission();
      await scheduleDaily(_timeOfDay);
    } else {
      await cancelAll();
    }
    notifyListeners();
  }

  Future<void> updateTime(TimeOfDay time) async {
    _timeOfDay = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHourKey, time.hour);
    await prefs.setInt(_prefMinuteKey, time.minute);
    if (_enabled) {
      await scheduleDaily(time);
    }
    notifyListeners();
  }

  Future<void> scheduleDaily(TimeOfDay time) async {
    // cancel previous schedule with same id
    await _plugin.cancel(0);

    final tz.TZDateTime next = _nextInstanceOf(time);

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const NotificationDetails details = NotificationDetails(
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      0,
      'LitGoal',
      '오늘의 독서 목표를 설정해보세요!',
      next,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_latest_active_book',
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showTestNotification({Duration? delay}) async {
    // 권한 미허용 상태 대비 재요청
    await _requestPermission();
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const NotificationDetails details = NotificationDetails(iOS: iosDetails);

    if (delay == null || delay.inSeconds <= 0) {
      await _plugin.show(
        999,
        'LitGoal 테스트',
        '이것은 테스트 알림입니다',
        details,
        payload: 'open_latest_active_book',
      );
      return;
    }

    final when = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      999,
      'LitGoal 테스트',
      '이것은 테스트 알림입니다',
      when,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      payload: 'open_latest_active_book',
    );
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.payload == 'open_latest_active_book') {
      final ctx = navigatorKey?.currentContext;
      if (ctx != null) {
        await onOpenNotification?.call(ctx);
      }
    }
  }

  // 헬퍼: 가장 최근 진행중 책 조회
  Future<Book?> fetchLatestActiveBook() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    final rows = await Supabase.instance.client
        .from('books')
        .select()
        .eq('user_id', userId)
        .lt('current_page', 'total_pages')
        .order('created_at', ascending: false)
        .limit(1);
    if (rows.isNotEmpty) {
      return Book.fromJson(rows.first);
    }
    return null;
  }

  Future<void> handleInitialLaunchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final launchedFromNotification = details?.didNotificationLaunchApp == true;
    final payload = details?.notificationResponse?.payload;
    if (launchedFromNotification && payload == 'open_latest_active_book') {
      final ctx = navigatorKey?.currentContext;
      if (ctx != null) {
        await onOpenNotification?.call(ctx);
      }
    }
  }
}
