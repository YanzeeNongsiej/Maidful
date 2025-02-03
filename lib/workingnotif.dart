import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:googleapis_auth/auth_io.dart";

/// Load Firebase Service Account JSON Key
Future<auth.AuthClient> getAuthClient() async {
  final serviceAccountJson =
      File("assets/authenticationapp-2f932-c274e2f57c60.json")
          .readAsStringSync();
  final credentials =
      auth.ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

  final client = http.Client();

  return await clientViaServiceAccount(
    credentials,
    ['https://www.googleapis.com/auth/firebase.messaging'],
  );
}

/// Send Push Notification
Future<void> sendPushNotification(
    String token, String title, String body) async {
  final client = await getAuthClient();

  final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/authenticationapp-2f932/messages:send');

  final payload = {
    "message": {
      "token": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      }
    }
  };

  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    print("Notification sent successfully!");
  } else {
    print("Failed to send notification: ${response.body}");
  }
}

Future<String?> getUserFcmToken(String userId) async {
  QuerySnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .where('userid', isEqualTo: userId)
      .get();
  return userDoc.docs.first['fcmtoken'];
}

void notifyUser(String recipientUserId) async {
  String? token = await getUserFcmToken(recipientUserId);

  if (token != null) {
    sendPushNotification(token, "New Message", "You have a new message!");
  } else {
    print("User's FCM token not found.");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User denied push notification permissions.");
    }
  }

  Future<void> getFCMToken() async {
    String? token = await _messaging.getToken();
    print("FCM Token: $token");
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification received: ${message.notification?.title}");
    });
  }

  void handleNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on notification: ${message.notification?.title}");
    });
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notificationService.requestPermission();
    _notificationService.getFCMToken();
    _notificationService.listenToForegroundMessages();
    _notificationService.handleNotificationClicks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FCM Push Notifications")),
      body: Center(
        child: Card(
          color: Colors.red,
          child: GestureDetector(
            child: Text('Send Notif'),
            onTap: () {
              sendPushNotification(
                  'cjd_RgmbQWSRt7L10ZXQiq:APA91bGAyzTwrsoxnVl8ByQOfA_0kSYkQe2Xgdj1BTHAgS-h7SUgN7sashQdnc-tLl3AUtotu-bVFjtBZEbtpMZ1yq8oUlMvG4liOrvgByZEqnLnw8pz3gg',
                  'teacher',
                  'enter');
            },
          ),
        ),
      ),
    );
  }
}
