import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendPushNotification(
    String recipientUserId, String title, String body) async {
  // Retrieve User B's FCM token from Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(recipientUserId)
      .get();
  String? fcmToken = userDoc['fcmToken'];

  if (fcmToken != null) {
    // FCM HTTP API URL
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    // The Web Push Private Key generated from Firebase Console
    const String privateKey = 'YOUR_PRIVATE_KEY';

    // FCM message payload
    final payload = {
      "to": fcmToken,
      "notification": {
        "title": title,
        "body": body,
        "icon": "https://your-icon-url.png", // Optional
      },
      "priority": "high", // Optional
    };

    // Send the request to FCM using HTTP POST
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=$privateKey', // Using Web Push private key for authorization
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } else {
    print('User does not have a valid FCM token');
  }
}
