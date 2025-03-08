import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ibitf_app/singleton.dart';

Widget buildScheduleSection(String title, List<dynamic> schedule) {
  List<String> scheduleTypes = ["Live-in", "Daily", "Hourly"];
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
    duration: Duration(milliseconds: 300),
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
    duration: Duration(milliseconds: 400),
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
    duration: Duration(milliseconds: 400),
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
                    Text("Rate: ${entry.value[0]} ${entry.value[1]}",
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
