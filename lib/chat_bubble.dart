// library flutter_chat_bubble;

// import 'package:ibitf_app/model/chat.dart';
// import 'package:ibitf_app/model/chat_message_type.dart';
// import 'package:ibitf_app/formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_bubble/bubble_type.dart';
// import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/chatdao.dart';
import 'package:ibitf_app/DAO/maiddao.dart';

import 'package:ibitf_app/singleton.dart';

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

  @override
  Widget build(BuildContext context) {
    if (widget.data['ackID'] != "") {
      return FutureBuilder<DocumentSnapshot>(
          future: getAcknomledgement(widget.data['ackID']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }
            //loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("loading...");
            }
            final ds = snapshot.data!;
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
                            getAckDetail(ds);
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
                        if (ds.get("status") == 2)
                          Row(
                            children: [
                              Text(
                                // "Agreed"
                                widget.data['message'],
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        if (ds.get("status") == 3)
                          Row(
                            children: [
                              Text(
                                // "Rejected"
                                widget.data['message'],
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.close, color: Colors.white),
                            ],
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
                                getAckDetail(ds);
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
                            if (ds.get("status") == 1)
                              GestureDetector(
                                onTap: () {
                                  agreeAckDetail(ds.id, 2);
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
                            if (ds.get("status") == 1)
                              GestureDetector(
                                onTap: () {
                                  agreeAckDetail(ds.id, 3);
                                },
                                child: Card(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Reject",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            if (ds.get("status") == 2)
                              Row(
                                children: [
                                  Text(
                                    // "Agreed"
                                    widget.data['message'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(Icons.check, color: Colors.white),
                                ],
                              ),
                            if (ds.get("status") == 3)
                              Row(
                                children: [
                                  Text(
                                    // "Rejected"
                                    widget.data['message'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(Icons.close, color: Colors.white),
                                ],
                              ),
                          ],
                        )
                      ],
                    ),
              // if(widget.data['status'] == 1)
            );
          });
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

  Future<DocumentSnapshot> getAcknomledgement(String ackID) async {
    DocumentSnapshot ds = await maidDao().getAck(ackID);
    return ds;
  }

  getAckDetail(ds) async {
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
                    Text(
                        "${GlobalVariables.instance.xmlHandler.getString('sched')} ${GlobalVariables.instance.xmlHandler.getString(ds.get("schedule"))}"),
                  ],
                ),
                if (ds.get("schedule") == 'Hourly')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(GlobalVariables.instance.xmlHandler.getString('day'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      for (var i = 0; i < ds.get("days").length; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${i + 1}. "),
                              Expanded(
                                child: Text(GlobalVariables.instance.xmlHandler
                                    .getString(ds.get("days")[i])),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (ds.get("schedule") == 'Daily' ||
                    ds.get("schedule") == 'Hourly')
                  Row(
                    children: [
                      Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('timing'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${ds.get("time_from")}-${ds.get("time_to")}"),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(GlobalVariables.instance.xmlHandler.getString('serv'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    for (var i = 0; i < ds.get("services").length; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${i + 1}. "),
                            Expanded(
                              child: Text(GlobalVariables.instance.xmlHandler
                                  .getString(ds.get("services")[i])),
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
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('wage'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          ds.get("wage") == 1
                              ? Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('weekly'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))
                              : Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('monthly'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('rate'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          Text("\u{20B9}${ds.get("rate")}",
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

  agreeAckDetail(ackID, stat) async {
    await Chatdao()
        .setAckStatus(widget.data, ackID, stat, widget.messageID)
        .then((a) {
      setState(() {});
    });
  }

  // int getAckStat(ackID) async {
  //   DocumentSnapshot item = await maidDao().getAck(ackID);

  // }
}
