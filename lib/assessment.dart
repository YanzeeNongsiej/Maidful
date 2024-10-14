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
  List<Map<String, dynamic>>? questions;
  String? question;
  List<String>? options;
  String? answer;
  void initState() {
    // TODO: implement initState
    super.initState();
    _xmlHandler.loadStrings(gv.selected).then((a) {
      loadAllQuestions();
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

  void loadAllQuestions() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Get the specific skill document
    QuerySnapshot snapshot = await _firestore
        .collection('skills')
        .where(gv.selected, isEqualTo: skill.toString()) // Use the passed skill
        .get();
    DocumentSnapshot skillDoc = await _firestore
        .collection('skills')
        .doc(snapshot.docs.first.id) // Use the specific skill ID
        .get();

    if (skillDoc.exists) {
      // Now query the Questions subcollection
      QuerySnapshot questionsSnapshot = await _firestore
          .collection('skills')
          .doc(snapshot.docs.first.id) // Use the specific skill ID
          .collection('questions')
          .get();

      questions = [];

      for (var doc in questionsSnapshot.docs) {
        String qid = doc.id; // Get the question ID (e.g., Q1, Q2)
        String question = doc['English'];
        List<String> options = List<String>.from(doc['EnglishOptions']);
        String answer = doc['Ans']; // Get the answer (e.g., "0")

        questions!.add({
          'id': qid, // Include question ID
          'question': question,
          'options': options,
          'answer': answer, // Include the answer
        });
      }

      // Print or return the questions as needed
      for (var question in questions!) {
        print('ID: ${question['id']}');
        print('Question: ${question['question']}');
        print('Options: ${question['options']}');
        print('Answer: ${question['answer']}');
      }
    } else {
      print('No data found for the specified skill.');
    }
  }
}
