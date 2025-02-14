import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import "package:googleapis_auth/auth_io.dart";
import 'package:flutter/services.dart' show rootBundle;
import 'package:ibitf_app/singleton.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
updateStatus(int val, itemid, context) {
  FirebaseFirestore.instance.collection("acknowledgements").doc(itemid).update({
    "status": val,
  }).whenComplete(() {
    Navigator.of(context).pop();
  });
}

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
    String token, String title, String body, itemid) async {
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
        "itemid": itemid,
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

void notifyUser(String recipientUserId, title, body, dynamic itemid) async {
  String? token = await getUserFcmToken(recipientUserId);

  if (token != null) {
    sendPushNotification(token, title, body, itemid);
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

  Future<void> setFCMToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    if (user != null && token != null) {
      FirebaseFirestore.instance
          .collection("users")
          .where("userid",
              isEqualTo: user.uid) // Find document where userid matches
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Get the existing document ID
          String docId = querySnapshot.docs.first.id;

          // Update the existing document with the new FCM token
          FirebaseFirestore.instance
              .collection("users")
              .doc(docId)
              .update({"fcmtoken": token}).then((_) {
            print("FCM token updated for user: ${user.uid}");
          }).catchError((error) {
            print("Error updating FCM token: $error");
          });
        }
      }).catchError((error) {
        print("Error querying user document: $error");
      });
    }
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification received: ${message.notification?.title}");
      // Show red dot on Chat icon
      GlobalVariables.instance.hasnewmsg = true;
      // if (message.notification?.title == 'Completion Request') {
      //   showCompletion(message);
      // }
    });
  }

  void handleNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on notification: ${message.notification?.title}");

      // if (message.notification?.title == 'Completion Request') {
      //   showCompletion(message);
      // }
    });
  }

  void showCompletion(message) {
    String? ti = message.notification?.title;
    String? bod = message.notification?.body;

    if (navigatorKey.currentContext == null) {
      showCompletion(message);
    } else {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(ti!),
                content: Row(
                  children: [
                    Text(bod!),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('Agree'),
                    onPressed: () {
                      updateStatus(5, message.data["itemid"], context);
                    },
                  ),
                  TextButton(
                    child: const Text('Disagree'),
                    onPressed: () {
                      // Add your "No" logic here
                      updateStatus(2, message.data["itemid"], context);
                    },
                  ),
                ]);
          });
    }
  }
}
