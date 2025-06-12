import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:intl/intl.dart';

Widget buildScheduleSection(String title, List<dynamic> schedule) {
  List<String> scheduleTypes = [
    GlobalVariables.instance.xmlHandler.getString('Live-in'),
    GlobalVariables.instance.xmlHandler.getString('Daily'),
    GlobalVariables.instance.xmlHandler.getString('Hourly'),
    GlobalVariables.instance.xmlHandler.getString('onetime')
  ];
  //List<String> scheduleTypes = ["Live-in", "Daily", "Hourly", "One-Time"];
  List<String> activeSchedules = [];

  for (int i = 0; i < schedule.length; i++) {
    if (schedule[i]) {
      activeSchedules.add(scheduleTypes[i]);
    }
  }

  return buildTextInfo(title, activeSchedules.join(", "));
}

Widget buildContainer(String title, Widget child) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12),
    margin: EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 5,
          spreadRadius: 1,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 5),
        child,
      ],
    ),
  );
}

Widget buildWorkHistory(List<dynamic> workHistory) {
  return buildContainer(
    GlobalVariables.instance.xmlHandler.getString('workhist'),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < workHistory.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${i + 1}. "),
                Expanded(child: Text(workHistory[i])),
              ],
            ),
          ),
      ],
    ),
  );
}

// Modern Text Info Widget
Widget buildTextInfo(String title, String value) {
  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Glassmorphism effect
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ),
  );
}

// Modern Section Widget
Widget buildSection(String title, List<dynamic> items) {
  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  );
}

// Modern Long Text Section
Widget buildLongText(String title, String content) {
  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// Modern Service Section
Widget buildServiceSection(String title, Map<String, dynamic> services) {
  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
          ),
          SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: services.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black)),
                    SizedBox(height: 2),
                    Text(
                        "${GlobalVariables.instance.xmlHandler.getString('rate')} ${entry.value[0]} ${entry.value[1]}",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget buildActiveServiceList(item, what, context, userID) {
  if (what == "Completed") {
    String ratedUserId = item.get('userid') == userID
        ? item.get('receiverid')
        : item.get('userid');
    FirebaseFirestore.instance
        .collection('users')
        .where('userid', isEqualTo: ratedUserId)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;

        // Cast to Map<String, dynamic> safely
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> ratings =
            userData['rating'] as Map<String, dynamic>? ?? {};

        // If the current user has not provided a rating, show the dialog
        if (!ratings.containsKey(userID)) {
          designOfRating(ratedUserId, userID);
        }
      } else {
        // User not found, still allow rating
        designOfRating(ratedUserId, userID);
      }
    }).catchError((error) {
      print("Error fetching user rating: $error");
    });
  }

  return SingleChildScrollView(
    child: Column(
      children: [
        if (what == "Completed")
          Column(
            children: [
              buildTextInfo(
                GlobalVariables.instance.xmlHandler.getString('starton'),
                item.data().containsKey("period") &&
                        item["period"].containsKey("start")
                    ? DateFormat('dd MMM yyyy').format(
                        (item.get("period.start") as Timestamp).toDate(),
                      )
                    : "Not available",
              ),
              buildTextInfo(
                GlobalVariables.instance.xmlHandler.getString('completeon'),
                item.data().containsKey("period") &&
                        item["period"].containsKey("end")
                    ? DateFormat('dd MMM yyyy').format(
                        (item.get("period.end") as Timestamp).toDate(),
                      )
                    : "Not available",
              ),
            ],
          ),
        buildScheduleSection(
            GlobalVariables.instance.xmlHandler.getString('sched'),
            item.get("schedule")),
        buildSection(GlobalVariables.instance.xmlHandler.getString('serv'),
            item.get("services")),
        buildSection(GlobalVariables.instance.xmlHandler.getString('timing'),
            item.get("timing")),
        buildSection(GlobalVariables.instance.xmlHandler.getString('day'),
            item.get("days")),
        buildLongText(GlobalVariables.instance.xmlHandler.getString('remark'),
            item.get("remarks")),
        if (GlobalVariables.instance.userrole == 2 &&
            [2, 6].contains(item.get('status')))
          Row(
            // mainAxisAlignment: MainAxisAlignment.end,

            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Card(
                  // elevation: 10,
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        completeService(context, item);
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.done_outline_rounded,
                            color: Colors.white,
                          ),
                          Text(
                            'Complete Service',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

void completeService(BuildContext context, item) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(GlobalVariables.instance.xmlHandler.getString('yousure')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('compsent'),
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  backgroundColor: Colors.indigo,
                  behavior: SnackBarBehavior
                      .floating, // Floating snackbar for modern look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 6,
                  duration: const Duration(
                      seconds: 3), // How long to display the Snackbar
                ),
              );
              showCompleteDoneDialog(context, item); // Show the rating dialog
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => CompletionRequestWidget()),
              // );
            },
            child: Text(GlobalVariables.instance.xmlHandler.getString('yes')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the first dialog
            },
            child: Text(GlobalVariables.instance.xmlHandler.getString('no')),
          ),
        ],
      );
    },
  );
}

updateStatus(int val, item) {
  FirebaseFirestore.instance
      .collection("acknowledgements")
      .doc(item.id)
      .update({
    "status": val,
  }).whenComplete(() {
    //setState(() {});
  });
}

void showCompleteDoneDialog(context, item) async {
  ChatController().sendMessage(
      item.get('receiverid'), "New Completion Request", item.id, false);
  updateStatus(4, item);
  String name = await getNameFromId(item.get('receiverid'));
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "",
              style: TextStyle(
                fontSize: 18, // Slightly larger font for prominence
                fontWeight: FontWeight.bold, // Bold text for emphasis
                color: Colors.black87,
              ),
            ),
            content: Text(
              'A completion request has been sent to $name',
              style: TextStyle(
                fontSize: 14, // Slightly larger font for prominence
                // Bold text for emphasis
                color: Colors.black87,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  //status=3 means the completion request has been sent

                  // Close the dialog
                  // showRatingConfirmation(
                  //     context, selectedRating); // Show thank-you message
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildImageSection(List<dynamic> imageUrls, context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Uploaded Images",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Wrap(
        spacing: 8.0, // Space between images
        runSpacing: 8.0, // Space between rows
        children: imageUrls.map((imageUrl) {
          return GestureDetector(
            onTap: () => viewFullImage(context, imageUrl), // Open enlarged view
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

void viewFullImage(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true, // Tap outside to close
    barrierLabel: "",
    transitionDuration: Duration(milliseconds: 300), // Smooth animation
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // **Blurred Background Effect**
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2), // Light overlay
                ),
              ),

              // **Image Expanding View**
              ScaleTransition(
                scale:
                    CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                child: Container(
                  width: 300, // Stylishly contained size
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: imageUrl,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // **Close Button (Modern Floating)**
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close, size: 24, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}

Future<void> deleteUnusedImagesFromJobProfile(String userId) async {
  try {
    CollectionReference jobProfiles =
        FirebaseFirestore.instance.collection('jobprofile');

    // Query Firestore to get the document where userid == userId
    QuerySnapshot querySnapshot =
        await jobProfiles.where('userid', isEqualTo: userId).get();

    if (querySnapshot.docs.isEmpty) return; // Exit if no matching document

    // Get the first matching document (assuming one profile per user)
    DocumentSnapshot jobProfileDoc = querySnapshot.docs.first;

    // Get the list of stored image URLs from Firestore
    List<String> storedImageUrls =
        List<String>.from(jobProfileDoc.get('imageurl') ?? []);
    print('imageurl is $storedImageUrls');
    // Get all image references from Firebase Storage
    ListResult storageList =
        await FirebaseStorage.instance.ref('job_images/$userId/').listAll();

    // Loop through storage items and get the download URLs
    for (var item in storageList.items) {
      String storageImageUrl = await item.getDownloadURL();
      print('Storage imageurl is $storageImageUrl');
      // If the URL is NOT in Firestore's imageurl list, delete the image from Storage
      if (!storedImageUrls.contains(storageImageUrl)) {
        try {
          await item.delete();
          print("✅ Deleted unused image: $storageImageUrl");
        } catch (e) {
          print("⚠️ Error deleting image: $storageImageUrl - $e");
        }
      }
    }
  } catch (e) {
    print("❌ Error fetching or deleting images: $e");
  }
}
