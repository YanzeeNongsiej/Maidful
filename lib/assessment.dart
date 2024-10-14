import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/xmlhandle.dart';

String? skill;

class Assessment extends StatefulWidget {
  Assessment(String? s) {
    skill = s;
  }

  @override
  State<Assessment> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Assessment> {
  @override
  XMLHandler _xmlHandler = XMLHandler();
  GlobalVariables gv = GlobalVariables();
  void initState() {
    // TODO: implement initState
    super.initState();
    _xmlHandler.loadStrings(gv.selected).then((a) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.red,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(skill.toString(), style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Set your desired background color
          borderRadius: BorderRadius.circular(12),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          Card(
            color: Colors.blueAccent[100],
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('ello'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<String?> getQuestion() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await _firestore
        .collection('skills')
        .where(gv.selected, isEqualTo: skill.toString()) // Use the passed skill
        .get();

    // Check if any documents were found
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Return the first document ID
    } else {
      return null; // No matching skill found
    }
  }
}
