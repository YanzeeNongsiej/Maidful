// library flutter_chat_bubble;

// import 'package:ibitf_app/model/chat.dart';
// import 'package:ibitf_app/model/chat_message_type.dart';
// import 'package:ibitf_app/formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_bubble/bubble_type.dart';
// import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';

class ChatBubble extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.data,
    required this.isCurrentUser,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    if (widget.data['message'] == "ack") {
      return Container(
        decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: widget.isCurrentUser
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(10))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10))),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: widget.isCurrentUser
            ? Column(
                children: [
                  const Text(
                    "Acknowledgement Sent",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      getAckDetail(widget.data['ackID']);
                    },
                    child: Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "View",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const Text(
                    "Acknowledgement Request",
                    style: TextStyle(color: Colors.white),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          getAckDetail(widget.data['ackID']);
                        },
                        child: Card(
                          color: Colors.blue,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "View",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          agreeAckDetail(widget.data['ackID']);
                        },
                        child: Card(
                          color: Colors.green,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Agree",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            color: widget.isCurrentUser ? Colors.green : Colors.grey.shade500,
            borderRadius: widget.isCurrentUser
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(10))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10))),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          widget.data['message'],
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }

  getAckDetail(ackID) async {
    DocumentSnapshot item = await maidDao().getAck(ackID);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Acknowledgement"),
          content: Card(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Schedule: ${item.get("schedule")}"),
                  ],
                ),
                if (item.get("schedule") == 'Hourly')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Days: ",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      for (var i = 0; i < item.get("days").length; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${i + 1}. "),
                              Expanded(
                                child: Text("${item.get("days")[i]}"),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (item.get("schedule") == 'Daily' ||
                    item.get("schedule") == 'Hourly')
                  Row(
                    children: [
                      Text("Timing: ",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${item.get("time_from")}-${item.get("time_to")}"),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Services: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    for (var i = 0; i < item.get("services").length; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${i + 1}. "),
                            Expanded(
                              child: Text("${item.get("services")[i]}"),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Row(
                        children: [
                          Text("Wage: ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          item.get("wage") == 1
                              ? Text("Weekly",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))
                              : Text("Monthly",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Rate: ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          Text("\u{20B9}${item.get("rate")}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                        ],
                      )
                    ])),
              ],
            ),
          ),
        );
      },
    );
  }

  agreeAckDetail(ackID) {
    print("Ack Details Agreed");
  }
}
