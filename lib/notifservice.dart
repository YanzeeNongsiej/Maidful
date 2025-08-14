import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import "package:googleapis_auth/auth_io.dart";
import 'package:flutter/services.dart' show rootBundle;
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/upipayment.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
Future<void> sendPushNotification(String token, String title, String body,
    {String? ratedUserId}) async {
  final client = await getAuthClient();

  final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/authenticationapp-2f932/messages:send');

  // Create the "data" payload
  final Map<String, String> dataPayload = {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
  };

  // Only add ratedUserId if it's not null
  if (ratedUserId != null) {
    dataPayload["ratedUserId"] = ratedUserId;
  }

  final payload = {
    "message": {
      "token": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": dataPayload, // Ensuring ratedUserId is inside "data"
    }
  };

  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    print("Notification sent successfully to $title");
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

void notifyUser(String recipientUserId, String title, String body,
    {String? ratedUserId}) async {
  String? token = await getUserFcmToken(recipientUserId);

  if (token != null) {
    sendPushNotification(token, title, body, ratedUserId: ratedUserId);
  } else {
    print("User's FCM token not found.");
  }
}

Future<String> getNameFromId(String userId) async {
  try {
    QuerySnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('userid', isEqualTo: userId)
        .limit(1)
        .get();

    if (userDoc.docs.isNotEmpty) {
      return userDoc.docs.first['name'] ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  } catch (e) {
    print("Error fetching name: $e");
    return 'Unknown';
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
      //GlobalVariables.instance.hasnewmsg = true;
      if (message.notification?.title == "Rate Your Experience") {
        showRatingPopup(message);
      }
      // if (message.notification?.title == 'Completion Request') {
      //   showCompletion(message);
      // }
    });
  }

  void handleNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on notification: ${message.notification?.title}");
      if (message.notification?.title == "Rate Your Experience") {
        showRatingPopup(message);
      }
      // if (message.notification?.title == 'Completion Request') {
      //   showCompletion(message);
      // }
    });
  }

  void showRatingPopup(RemoteMessage message) {
    String ratedUserId =
        message.data['ratedUserId']; // Get user ID from notification data
    String raterUserId = FirebaseAuth.instance.currentUser!.uid;
    designOfRating(ratedUserId, raterUserId);
  }
}

// --- MODIFIED designOfRating function ---
void designOfRating(String ratedUserId, String raterUserId) {
  int selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title:
                Text(GlobalVariables.instance.xmlHandler.getString('rating1')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(GlobalVariables.instance.xmlHandler.getString('rating2')),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return Flexible(
                      child: IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < selectedRating
                              ? Colors.yellow
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter your review...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (selectedRating > 0) {
                    // Pass the review text here
                    submitRating(selectedRating, _reviewController.text,
                        ratedUserId, raterUserId);
                    Navigator.pop(context);
                  }
                },
                child: Text("Submit"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> submitRating(
    int rating, String review, String ratedUserId, String raterUserId) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  BuildContext? context =
      navigatorKey.currentContext; // Get the current context

  if (context == null) return; // Prevent execution if context is null

  try {
    // Find the document where 'userid' matches 'ratedUserId'
    QuerySnapshot querySnapshot = await usersCollection
        .where('userid', isEqualTo: ratedUserId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference userRef = querySnapshot.docs.first.reference;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          // Get the existing 'ratings' map, or create an empty one if it doesn't exist
          // Renamed from 'rating' to 'ratings' to better represent multiple reviews
          Map<String, dynamic> ratings =
              userData['ratings'] as Map<String, dynamic>? ?? {};

          // Store both rating and review under the raterUserId
          ratings[raterUserId] = {
            'rating': rating,
            'review': review,
            'timestamp':
                FieldValue.serverTimestamp(), // Optional: add a timestamp
          };

          transaction.update(
              userRef, {'ratings': ratings}); // Update the 'ratings' field
        }
      });

      // ✅ Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(GlobalVariables.instance.xmlHandler.getString('rating3')),
          backgroundColor: Colors.green,
        ),
      );
      if (GlobalVariables.instance.userrole == 2) {
        // Assuming showPaymentModePrompt is defined elsewhere in your code
        // showPaymentModePrompt(context);
      }
      print(
          "Rating: $rating, Review: '$review' submitted by $raterUserId for $ratedUserId");
    } else {
      print("User not found with userid: $ratedUserId");

      // ❌ Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not found!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error) {
    print("Error submitting rating and review: $error");

    // ❌ Show error SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(GlobalVariables.instance.xmlHandler.getString('rating4')),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void showPaymentModePrompt(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.money, color: Colors.green),
              title: Text("Cash"),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: Text("UPI (BHIM / GPay)"),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpiPaymentPage()),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
