import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import "package:googleapis_auth/auth_io.dart";
import 'package:flutter/services.dart' show rootBundle;

Future<auth.AuthClient> getAuthClient() async {
  final serviceAccountJson =
      await rootBundle.loadString('assets/notifauth.json');
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

void notifyUser(String recipientUserId, title, body) async {
  String? token = await getUserFcmToken(recipientUserId);

  if (token != null) {
    sendPushNotification(token, title, body);
  } else {
    print("User's FCM token not found.");
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

  void listenToForegroundMessages(context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification received: ${message.notification?.title}");
      if (message.notification?.title == 'Completion Request') {
        showCompletion(context, message);
      }
    });
  }

  void handleNotificationClicks(context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on notification: ${message.notification?.title}");
      if (message.notification?.title == 'Completion Request') {
        showCompletion(context, message);
      }
    });
  }

  void showCompletion(context, message) {
    String? ti = message.notification?.title;
    String? bod = message.notification?.body;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(ti!),
              content: Row(
                children: [
                  Text(bod!),
                  Text('Are you sure you want to complete this service?'),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    // Add your "Yes" logic here
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    // Add your "No" logic here
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }
}
