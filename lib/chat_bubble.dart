// library flutter_chat_bubble;

// import 'package:ibitf_app/model/chat.dart';
// import 'package:ibitf_app/model/chat_message_type.dart';
// import 'package:ibitf_app/formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_bubble/bubble_type.dart';
// import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/chatdao.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/buildui.dart';
import 'package:ibitf_app/notifservice.dart';

import 'package:ibitf_app/singleton.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isCurrentUser;
  final String messageID;

  const ChatBubble({
    super.key,
    required this.data,
    required this.isCurrentUser,
    required this.messageID,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
// Future<DocumentSnapshot<Object?>> item = getAck(widget.data['ackID']);
  // late DocumentSnapshot ds;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((onValue) {
      setState(() {});
    });
  }

  Future<String> translateMessage(
      String message, String from, String to) async {
    final Uri url = Uri.parse(
      "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$from&tl=$to&dt=t&q=${Uri.encodeComponent(message)}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse[0][0][0]; // Extract translated text
    } else {
      return "Translation failed";
    }
  }

  void _showTranslationPopup(
      BuildContext context, String message, TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      shadowColor: Colors.transparent,
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlay.size.width - details.globalPosition.dx,
        0,
      ),
      color: Colors.transparent, // Makes the background transparent
      items: [
        PopupMenuItem(
          value: 'kha',
          child:
              _buildPopupItem(Icons.wrap_text_outlined, 'Translate to Khasi'),
        ),
        PopupMenuItem(
          value: 'en',
          child: _buildPopupItem(Icons.abc, 'Translate to English'),
        ),
      ],
    ).then((result) async {
      if (result != null) {
        String translatedText = await translateMessage(
            message, result == 'kha' ? 'en' : 'kha', result);
        _showTranslatedMessage(context, translatedText);
      }
    });
  }

  Widget _buildPopupItem(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showTranslatedMessage(BuildContext context, String translatedText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Translated Message'),
          content: Text(translatedText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data['ackID'] != "") {
      if (widget.data['message']
          .toString()
          .contains(RegExp(r'^(New|Old) Completion Request$'))) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("acknowledgements")
              .doc(widget.data['ackID'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Error", style: TextStyle(color: Colors.red)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ds = snapshot.data!;
            bool isAgreed = ds.get("status") == 5;
            bool isRejected = ds.get("status") == 6;
            String displayText = '';
            if (widget.isCurrentUser) {
              if (ds.get('status') == 4) {
                displayText = " Completion Request Sent";
              } else if (isRejected ||
                  widget.data['message'] == "Old Completion Request") {
                displayText = "Completion Rejected";
              } else if (isAgreed) {
                displayText = "Completion Agreed";
              }
            } else {
              if (ds.get('status') == 4) {
                displayText = "Completion Request Received";
              } else if (isRejected ||
                  widget.data['message'] == "Old Completion Request") {
                displayText = "Completion Rejected";
              } else if (isAgreed) {
                displayText = "Completion Agreed";
              }
            }
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isCurrentUser
                      ? [Colors.purple.shade700, Colors.purple.shade400]
                      : [Colors.purple.shade300, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 5, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayText,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Icon(
                        isRejected ||
                                widget.data['message'] ==
                                    "Old Completion Request"
                            ? Icons.cancel
                            : isAgreed
                                ? Icons.verified
                                : Icons.hourglass_bottom,
                        color: isRejected ||
                                widget.data['message'] ==
                                    "Old Completion Request"
                            ? Colors.redAccent
                            : isAgreed
                                ? Colors.greenAccent
                                : Colors.yellowAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (ds.get('status') == 5)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Service is Completed",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Completed Service"),
                              content: buildActiveServiceList(
                                  ds,
                                  "Completed",
                                  context,
                                  FirebaseAuth.instance.currentUser!.uid),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                          child: const Text("Go to Service"),
                        ),
                      ],
                    ),
                  if (![5].contains(ds.get("status")))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => getAckDetail(ds),
                          child: Chip(
                            label: const Text("View",
                                style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        if (ds.get("status") == 4 &&
                            !widget.isCurrentUser &&
                            widget.data['message'] !=
                                'Old Completion Request') ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              agreeAckDetail(ds.id, 5);
                              setDate(ds.id, "end");
                              String name1 =
                                  await getNameFromId(ds.get('userid'));
                              String name2 =
                                  await getNameFromId(ds.get('receiverid'));
                              designOfRating(
                                  ds.get('userid'), ds.get('receiverid'));
                              // notifyUser(
                              //     ds.get('receiverid'),
                              //     "Rate Your Experience",
                              //     "Please rate your experience with $name1.",
                              //     ratedUserId: ds.get('userid'));

                              notifyUser(
                                  ds.get('userid'),
                                  "Rate Your Experience",
                                  "Please rate your interaction with $name2.",
                                  ratedUserId: ds.get('receiverid'));
                            },
                            child: Chip(
                              label: const Text("Agree",
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              agreeAckDetail(ds.id, 6);
                              setMessage("Old Completion Request");
                            },
                            child: Chip(
                              label: const Text("Reject",
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ]
                      ],
                    ),
                ],
              ),
            );
          },
        );
      } else {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("acknowledgements")
              .doc(widget.data['ackID'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Error", style: TextStyle(color: Colors.red)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ds = snapshot.data!;
            bool isAgreed = [2, 4, 5, 6].contains(ds.get("status"));
            bool isRejected = ds.get("status") == 3;
            String displayText = '';
            if (widget.isCurrentUser) {
              if (isAgreed) {
                displayText = "Acknowledgement Agreed";
              } else if (isRejected) {
                displayText = "Acknowledgement Rejected";
              } else if (ds.get('status') == 1) {
                displayText = "Acknowledgement Request Sent";
              } else {}
            } else {
              if (isAgreed) {
                displayText = "Acknowledgement Agreed";
              } else if (isRejected) {
                displayText = "Acknowledgement Rejected";
              } else if (ds.get('status') == 1) {
                displayText = "Acknowledgement Request Received";
              } else {}
            }
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isCurrentUser
                      ? [Colors.teal.shade700, Colors.teal.shade400]
                      : [Colors.teal.shade700, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 5, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayText,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Icon(
                        isAgreed
                            ? Icons.check_circle
                            : isRejected
                                ? Icons.cancel
                                : Icons.hourglass_bottom,
                        color: isAgreed
                            ? Colors.greenAccent
                            : isRejected
                                ? Colors.redAccent
                                : Colors.yellowAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if ([2, 4].contains(ds.get("status")))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Service is active",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Active Service"),
                              content: buildActiveServiceList(
                                  ds,
                                  "Active",
                                  context,
                                  FirebaseAuth.instance.currentUser!.uid),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                          child: const Text("Go to Service"),
                        ),
                      ],
                    ),

                  // const SizedBox(height: 8),
                  if (![2, 4, 5].contains(ds.get("status")))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => getAckDetail(ds),
                          child: Chip(
                            label: const Text("View",
                                style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        if (ds.get("status") == 1 && !widget.isCurrentUser) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              String name = await getNameFromId(
                                  widget.data['receiverID']);
                              agreeAckDetail(ds.id, 2);
                              setDate(ds.id, "start");
                              notifyUser(
                                  widget.data['senderID'],
                                  'Acknowledgement Agreed',
                                  '$name has agreed to be hired by you');
                            },
                            child: Chip(
                              label: const Text("Agree",
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => agreeAckDetail(ds.id, 3),
                            child: Chip(
                              label: const Text("Reject",
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ]
                      ],
                    ),
                ],
              ),
            );
          },
        );
      }
    } else {
      return GestureDetector(
        onTapDown: (TapDownDetails details) =>
            _showTranslationPopup(context, widget.data['message'], details),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            gradient: widget.isCurrentUser
                ? const LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1)
            ],
          ),
          child: Text(
            widget.data['message'],
            style: TextStyle(
              color: widget.isCurrentUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Future<DocumentSnapshot> getAcknomledgement(String ackID) async {
    DocumentSnapshot ds = await maidDao().getAck(ackID);
    return ds;
  }

  setMessage(String msg) async {
    await Chatdao().setMessage(widget.data, widget.messageID, msg).then((a) {
      setState(() {});
    });
  }

  getAckDetail(ds) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            scrollable: true,
            title: Text("Service Details"),
            content: Column(
              children: [
                buildScheduleSection("Schedule", ds.get("schedule")),
                buildSection("Services", ds.get("services")),
                buildSection("Timing", ds.get("timing")),
                buildSection("Days Available", ds.get("days")),
                buildLongText("Remarks", ds.get("remarks")),
                SizedBox(
                  height: 10,
                )
                // buildSection("Work History", ds.get("work_history")),
              ],
            ));
      },
    );
  }

  agreeAckDetail(ackID, stat) async {
    await Chatdao()
        .setAckStatus(widget.data, ackID, stat, widget.messageID)
        .then((a) {
      setState(() {});
    });
  }

  Future<void> setDate(String id, String when) async {
    // if (when != "start" || when != "end") {
    //   throw ArgumentError("Invalid value for 'when'. Must be 'start' or 'end'.");
    // }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection("acknowledgements").doc(id);

    await docRef.set({
      "period": {when: FieldValue.serverTimestamp()}
    }, SetOptions(merge: true));
  }

  // int getAckStat(ackID) async {
  //   DocumentSnapshot item = await maidDao().getAck(ackID);

  // }
}
