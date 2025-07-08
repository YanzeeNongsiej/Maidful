import 'dart:ui'; // For ImageFilter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:intl/intl.dart';

// Helper for capitalizing strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Reusing existing buildScheduleSection, ensuring it uses buildTextInfo
Widget buildScheduleSection(String title, List<dynamic> schedule) {
  List<String> scheduleTypes = [
    GlobalVariables.instance.xmlHandler.getString('Live-in'),
    GlobalVariables.instance.xmlHandler.getString('Daily'),
    GlobalVariables.instance.xmlHandler.getString('Hourly'),
    GlobalVariables.instance.xmlHandler.getString('onetime')
  ];
  List<String> activeSchedules = [];

  for (int i = 0; i < schedule.length; i++) {
    if (schedule[i]) {
      activeSchedules.add(scheduleTypes[i]);
    }
  }

  return buildTextInfo(title, activeSchedules.join(", "));
}

// This buildContainer seems to be a generic wrapper.
// I will update its style to be more modern and professional.
Widget buildContainer(String title, Widget child) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20), // Increased padding
    margin: EdgeInsets.symmetric(
        vertical: 10, horizontal: 16), // Added horizontal margin
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16), // More rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200, // Lighter shadow
          blurRadius: 10,
          spreadRadius: 2,
          offset: Offset(0, 4), // More pronounced shadow
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20, // Larger title
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800, // Darker, professional color
            ),
          ),
        ),
        SizedBox(height: 15), // Increased spacing
        child,
      ],
    ),
  );
}

// Reusing existing buildWorkHistory, ensuring it uses buildContainer
Widget buildWorkHistory(List<dynamic> workHistory) {
  return buildContainer(
    GlobalVariables.instance.xmlHandler.getString('workhist'),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No work history available.',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        for (var i = 0; i < workHistory.length; i++)
          Padding(
            padding:
                const EdgeInsets.only(left: 10, bottom: 8), // Adjusted padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.green.shade600), // Added icon
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${i + 1}. ${workHistory[i]}",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

// Modern Text Info Widget - Enhanced for professional look
Widget buildTextInfo(String title, String value) {
  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      padding: EdgeInsets.symmetric(
          vertical: 14, horizontal: 20), // Increased padding
      margin: EdgeInsets.symmetric(vertical: 8), // Increased margin
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Lighter, professional background
        borderRadius: BorderRadius.circular(15), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5), // Subtle shadow
            blurRadius: 8,
            spreadRadius: 1,
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
              color: Colors.blueAccent.shade700, // Deeper blue
            ),
          ),
          SizedBox(width: 15), // More spacing
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16, // Consistent font size
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

// Modern Section Widget - Enhanced for professional look
Widget buildSection(String title, List<dynamic> items) {
  if (items == null || items.isEmpty)
    return SizedBox.shrink(); // Hide if no items

  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20), // Increased padding
      margin: EdgeInsets.symmetric(
          vertical: 10, horizontal: 16), // Added horizontal margin
      decoration: BoxDecoration(
        color: Colors.teal.shade50, // Soft teal background
        borderRadius: BorderRadius.circular(16), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.5), // Subtle shadow
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20, // Larger title
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700, // Deeper teal
              ),
            ),
          ),
          SizedBox(height: 15), // Increased spacing
          Wrap(
            spacing: 10, // Increased spacing between chips
            runSpacing: 10, // Increased vertical spacing
            children: items
                .map((item) => Chip(
                      label: Text(
                        (GlobalVariables.instance.xmlHandler.getString(item) ==
                                ''
                            ? item
                            : GlobalVariables.instance.xmlHandler
                                .getString(item)),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15, // Slightly larger chip text
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor:
                          Colors.teal.shade400, // Teal chip background
                      padding: EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12), // Larger chip padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded chip corners
                      ),
                      elevation: 2, // Subtle chip shadow
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  );
}

// Modern Long Text Section - Enhanced for professional look
Widget buildLongText(String title, String content) {
  if (content == null || content.isEmpty || content == 'N/A')
    return SizedBox.shrink(); // Hide if content is empty or N/A

  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20), // Increased padding
      margin: EdgeInsets.symmetric(
          vertical: 10, horizontal: 16), // Added horizontal margin
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light grey background
        borderRadius: BorderRadius.circular(16), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // Subtle shadow
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20, // Larger title
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          SizedBox(height: 15), // Increased spacing
          Text(
            content,
            style: TextStyle(
              fontSize: 16, // Consistent font size
              color: Colors.black87,
              height: 1.6, // Increased line height for readability
            ),
          ),
        ],
      ),
    ),
  );
}

// Modern Service Section - Enhanced for professional look
Widget buildServiceSection(String title, Map<String, dynamic> services) {
  if (services == null || services.isEmpty)
    return SizedBox.shrink(); // Hide if no services

  return FadeInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20), // Increased padding
      margin: EdgeInsets.symmetric(
          vertical: 10, horizontal: 16), // Added horizontal margin
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50, // Soft purple background
        borderRadius: BorderRadius.circular(16), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade100.withOpacity(0.5), // Subtle shadow
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20, // Larger title
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700, // Deeper purple
              ),
            ),
          ),
          SizedBox(height: 15), // Increased spacing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: services.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8), // Increased vertical padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key, // Capitalize service name
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17, // Slightly larger
                          color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${GlobalVariables.instance.xmlHandler.getString('rate')} ${entry.value[0]} ${entry.value[1]}",
                      style: TextStyle(
                          fontSize: 15, // Consistent font size
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
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

// Modern Active Service List - Enhanced for professional look
Widget buildActiveServiceList(item, what, context, userID) {
  // Logic for rating dialog (if applicable)
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
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> ratings =
            userData['rating'] as Map<String, dynamic>? ?? {};

        if (!ratings.containsKey(userID)) {
          // Assuming designOfRating is a function that shows a rating dialog
          // and needs to be defined elsewhere if not already.
          // For now, I'll just print a message.
          print(
              'User $userID has not rated $ratedUserId yet. Show rating dialog.');
          // designOfRating(ratedUserId, userID); // Uncomment if designOfRating is available
        }
      } else {
        print('User not found for rating. Still allow rating.');
        // designOfRating(ratedUserId, userID); // Uncomment if designOfRating is available
      }
    }).catchError((error) {
      print("Error fetching user rating: $error");
    });
  }

  return SingleChildScrollView(
    child: Column(
      children: [
        // Conditional display for start/completion dates
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
        // Reusing the professionally styled build methods
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

        // Action button for service completion (if applicable)
        if (GlobalVariables.instance.userrole == 2 &&
            [2, 6].contains(item.get('status')))
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                completeService(context, item);
              },
              icon: Icon(Icons.done_all,
                  color: Colors.white, size: 24), // Modern icon
              label: Text(
                'Complete Service',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600, // Green for completion
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded button
                ),
                elevation: 8, // Stronger shadow
              ),
            ),
          ),
      ],
    ),
  );
}

// Function to handle service completion (dialogs and status update)
void completeService(BuildContext context, item) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(GlobalVariables.instance.xmlHandler.getString('yousure'),
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to mark this service as complete? A request will be sent to the other party.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text(GlobalVariables.instance.xmlHandler.getString('no'),
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close confirmation dialog
              showCompleteDoneDialog(
                  context, item); // Proceed to show completion sent dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(GlobalVariables.instance.xmlHandler.getString('yes')),
          ),
        ],
      );
    },
  );
}

// Update service status in Firestore
updateStatus(int val, item) {
  FirebaseFirestore.instance
      .collection("acknowledgements")
      .doc(item.id)
      .update({
    "status": val,
  }).whenComplete(() {
    // No setState here as this is a utility function, UI refresh happens elsewhere
  });
}

// Show dialog after completion request is sent
void showCompleteDoneDialog(context, item) async {
  ChatController().sendMessage(
      item.get('receiverid'), "New Completion Request", item.id, false);
  updateStatus(4, item); // Update status to 4 (completion requested)
  String name = await getNameFromId(item.get('receiverid'));

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Completion Request Sent!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        content: Text(
          'A completion request has been successfully sent to $name. They will need to confirm the completion.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close this dialog
              Navigator.of(context).pop(); // Close the previous dialog (if any)
            },
            child: Text("OK", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      );
    },
  );
}

// Get name from user ID (utility function)

// Build image section for service/job listings
Widget buildImageSection(List<dynamic> imageUrls, context) {
  if (imageUrls == null || imageUrls.isEmpty) return SizedBox.shrink();

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade100.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 1,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Uploaded Images",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10.0, // Space between images
          runSpacing: 10.0, // Space between rows
          children: imageUrls.map((imageUrl) {
            return GestureDetector(
              onTap: () =>
                  viewFullImage(context, imageUrl), // Open enlarged view
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: Image.network(
                  imageUrl,
                  width: 100, // Larger thumbnail
                  height: 100, // Larger thumbnail
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image,
                          color: Colors.grey.shade400, size: 30),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

// Function to view full-screen image with modern effects
void viewFullImage(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Blurred Background Effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(
                      0.4), // Darker overlay for better blur contrast
                ),
              ),

              // Image Expanding View
              ScaleTransition(
                scale:
                    CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Responsive width
                  height: MediaQuery.of(context).size.height *
                      0.7, // Responsive height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // More rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38, // Stronger shadow
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Hero(
                      tag: imageUrl, // Hero animation tag
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain, // Fit to contain within bounds
                      ),
                    ),
                  ),
                ),
              ),

              // Close Button (Modern Floating)
              Positioned(
                top: 40, // More space from top
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.9), // Slightly less transparent
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(10), // Larger padding
                    child: Icon(Icons.close,
                        size: 28, color: Colors.black87), // Larger icon
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

// Function to delete unused images from job profile (existing functionality)
Future<void> deleteUnusedImagesFromJobProfile(String userId) async {
  try {
    CollectionReference jobProfiles =
        FirebaseFirestore.instance.collection('jobprofile');

    QuerySnapshot querySnapshot =
        await jobProfiles.where('userid', isEqualTo: userId).get();

    if (querySnapshot.docs.isEmpty) return;

    DocumentSnapshot jobProfileDoc = querySnapshot.docs.first;

    List<String> storedImageUrls =
        List<String>.from(jobProfileDoc.get('imageurl') ?? []);
    print('imageurl is $storedImageUrls');
    ListResult storageList =
        await FirebaseStorage.instance.ref('job_images/$userId/').listAll();

    for (var item in storageList.items) {
      String storageImageUrl = await item.getDownloadURL();
      print('Storage imageurl is $storageImageUrl');
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
