import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ibitf_app/singleton.dart';

import 'dart:math';
import 'dart:async';
import 'package:ibitf_app/DAO/skilldao.dart';

String? skill;
int currentQuestionIndex = 0;
int timerDuration = 120; // 2 minutes in seconds
Timer? timer;
ValueNotifier<int>? timerNotifier;
List<int> random = [];
List<bool> ans = [];
bool canBack = false;
double percentage = 0;

class Assessment extends StatefulWidget {
  final VoidCallback onComplete;
  Assessment(String? s, {super.key, required this.onComplete}) {
    skill = s;
  }

  @override
  State<Assessment> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Assessment> {
  @override
  void initState() {
    super.initState();
    timerNotifier = ValueNotifier<int>(timerDuration);
    ans = [false, false, false, false, false];
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((onValue) {
      setState(() {});
    });
    canBack = false;
    startTimer();
  }

  Future<List<Map<String, dynamic>>> loadAllQuestions() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the specific skill document
    QuerySnapshot snapshot = await firestore
        .collection('skills')
        .where(GlobalVariables.instance.selected, isEqualTo: skill.toString())
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No skill found');
    }

    DocumentSnapshot skillDoc =
        await firestore.collection('skills').doc(snapshot.docs.first.id).get();

    if (!skillDoc.exists) {
      throw Exception('No data found for the specified skill.');
    }

    // Query the Questions subcollection
    QuerySnapshot questionsSnapshot = await firestore
        .collection('skills')
        .doc(snapshot.docs.first.id)
        .collection('questions')
        .get();

    List<Map<String, dynamic>> questions = [];

    for (var doc in questionsSnapshot.docs) {
      String qid = doc.id;
      String question = doc[GlobalVariables.instance.selected];
      List<String> options =
          List<String>.from(doc['${GlobalVariables.instance.selected}Options']);
      String answer = doc['Ans'];

      questions.add({
        'id': qid,
        'question': question,
        'options': options,
        'answer': answer,
      });
    }
    //generate random numbers for questions
    if (random.isEmpty) {
      random = generateRandomIntegers(5, 0, questions.length - 1);
    }

    return questions;
  }

  void processAnswers() {}
  List<int> generateRandomIntegers(int count, int min, int max) {
    final Random random = Random();

    // Generate a set of unique random integers
    final Set<int> randomIntegers = Set<int>.from(
        List.generate(count, (index) => min + random.nextInt(max - min + 1)));

    // If there are not enough unique integers, fill until the required count
    while (randomIntegers.length < count) {
      randomIntegers.add(min + random.nextInt(max - min + 1));
    }

    return randomIntegers.toList();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerNotifier!.value > 0) {
        timerNotifier!.value--;
      } else {
        timer.cancel();
        showTimeUpDialog();
      }
    });
  }

  void showTimeUpDialog() {
    if (mounted) {
      canBack = true;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          updateScoreToDB(GlobalVariables.instance.selected, skill, percentage);
          return AlertDialog(
            title:
                Text(GlobalVariables.instance.xmlHandler.getString('timeup')),
            content: Text("Score:${calcPercent()}%"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Optionally, navigate back or handle the end of assessment
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
    currentQuestionIndex = 0;
    selOpt = null;
  }

  double calcPercent() {
    int correct = 0;

    for (int i = 0; i < ans.length; i++) {
      if (ans[i] == true) {
        correct++;
      }
    }

    percentage = (correct / random.length) * 100;
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.red,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: timerNotifier!,
                  builder: (context, remainingTime, child) {
                    return Text(
                      "${GlobalVariables.instance.xmlHandler.getString('timeleft')}: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 16),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: loadAllQuestions(), // Call your fetch function here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              canBack = true;
              return Center(
                  child: Text(GlobalVariables.instance.xmlHandler
                      .getString('noquest')));
            }

            // Use the loaded questions to display in the UI
            List<Map<String, dynamic>> questions = snapshot.data!;
            Map<String, dynamic> currentQuestion =
                questions[random[currentQuestionIndex]];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.blueAccent[100],
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('ID: ${questions[0]['id']}'),

                      Text(
                        '${GlobalVariables.instance.xmlHandler.getString('quest')}: ${questions[random[currentQuestionIndex]]['question']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyOptions(currentQuestion),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selOpt != null) {
                              setState(() {
                                // Check if there are more questions
                                if (questions[random[currentQuestionIndex]]
                                            ['answer']
                                        .toString() ==
                                    selOpt.toString()) {
                                  ans[currentQuestionIndex] = true;
                                } else {
                                  ans[currentQuestionIndex] = false;
                                }
                                if (currentQuestionIndex < random.length - 1) {
                                  currentQuestionIndex++;
                                  selOpt = null;
                                  // Reset the selected option
                                } else {
                                  // Handle end of questions (e.g., show results)
                                  // For now, just show a dialog

                                  double percentage = calcPercent();
                                  updateScoreToDB(
                                      GlobalVariables.instance.selected,
                                      skill,
                                      percentage);
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(GlobalVariables
                                            .instance.xmlHandler
                                            .getString('completeass')),
                                        content: Text("Score:$percentage%"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              widget.onComplete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              });
                            }
                          },
                          child: Text(
                              (currentQuestionIndex == (random.length - 1)
                                  ? "Finish"
                                  : "Next")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Map<String, dynamic>? question;
String? selOpt;

// ignore: must_be_immutable
class MyOptions extends StatefulWidget {
  MyOptions(Map<String, dynamic> currentQuestion, {super.key}) {
    question = currentQuestion;
  }

  @override
  State<MyOptions> createState() => _MyOptionsState();
}

class _MyOptionsState extends State<MyOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 5,
          child: ListTile(
            title: Text(question!['options'][0]),
            leading: Radio<String>(
              value: '0',
              groupValue: selOpt,
              onChanged: (value) {
                setState(() {
                  selOpt = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          elevation: 5,
          child: ListTile(
            title: Text(question!['options'][1]),
            leading: Radio<String>(
              value: '1',
              groupValue: selOpt,
              onChanged: (value) {
                setState(() {
                  selOpt = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          elevation: 5,
          child: ListTile(
            title: Text(question!['options'][2]),
            leading: Radio<String>(
              value: '2',
              groupValue: selOpt,
              onChanged: (value) {
                setState(() {
                  selOpt = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          elevation: 5,
          child: ListTile(
            title: Text(question!['options'][3]),
            leading: Radio<String>(
              value: '3',
              groupValue: selOpt,
              onChanged: (value) {
                setState(() {
                  selOpt = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
