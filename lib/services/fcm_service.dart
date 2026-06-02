import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'pustu_hanua_channel',
    'Pustu Hanua Notification',
    description: 'Notifikasi layanan Pustu Hanua',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupLocalNotification();
    _listenForegroundNotification();
    _listenNotificationOpened();
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> _setupLocalNotification() async {
    const androidInit = AndroidInitializationSettings('ic_stat_pustu');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _localNotifications.initialize(initSettings);

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  static void _listenForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];

      if (title == null && body == null) return;

      _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? 'Notifikasi Pustu Hanua',
        body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pustu_hanua_channel',
            'Pustu Hanua Notification',
            channelDescription: 'Notifikasi layanan Pustu Hanua',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: 'ic_stat_pustu',
          ),
        ),
      );
    });
  }

  static void _listenNotificationOpened() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notifikasi dibuka: ${message.data}');
    });
  }

  static Future<void> subscribePatientTopicAndSaveToken({
    required String patientUid,
  }) async {
    if (kIsWeb) return;

    await _messaging.subscribeToTopic('pasien');

    final token = await _messaging.getToken();

    debugPrint('FCM TOKEN PASIEN: $token');

    if (token != null) {
      await FirebaseFirestore.instance
          .collection('patient_users')
          .doc(patientUid)
          .set({
        'fcm_token': token,
        'fcm_topic': 'pasien',
        'fcm_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
          .collection('patient_users')
          .doc(patientUid)
          .set({
        'fcm_token': newToken,
        'fcm_topic': 'pasien',
        'fcm_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> unsubscribePatientTopic() async {
    if (kIsWeb) return;

    await _messaging.unsubscribeFromTopic('pasien');
  }
}