import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/chat_bubble.dart';
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/hiremaid.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/xmlhandle.dart';

// import 'package:marquee/marquee.dart';
final XMLHandler _xmlHandler = XMLHandler();
GlobalVariables gv = GlobalVariables();

class ChatPage extends StatefulWidget {
  final String name;
  final String receiverID;
  final String postType;
  final String postTypeID;
  const ChatPage(
      {super.key,
      required this.name,
      required this.receiverID,
      required this.postType,
      required this.postTypeID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool ownServ = false;
  String userID = FirebaseAuth.instance.currentUser!.uid;
// textController
  final TextEditingController _messageController = TextEditingController();

//chatController
  final ChatController chatcontroller = ChatController();

  //
  DocumentSnapshot? itemglobal;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkOwnServ().then((a) {
      _xmlHandler.loadStrings(gv.selected).then((a) {});
      setState(() {});
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await chatcontroller.sendMessage(widget.receiverID,
          _messageController.text, "", widget.postType, widget.postTypeID);
      _messageController.clear();
    }
  }

  Future<void> checkOwnServ() async {
    DocumentSnapshot ds = await maidDao().getService(widget.postTypeID);
    // var item = ds.data();
    if (userID == ds.get("userid")) {
      ownServ = false;
    } else {
      if (ds.get("ack") == true) {
        ownServ = false;
      } else {
        ownServ = true;
      }
    }
  }

// class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Text(
                    // overflow: TextOverflow.ellipsis,
                    widget.name,
                    style: TextStyle(fontSize: 15),
                    softWrap: true),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Card(
                    child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, bottom: 5, top: 5),
                  child: _buildPostDetails(),
                )),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            //display all messages
            Expanded(
              child: Card(
                  elevation: 5,
                  color: Colors.white,
                  child: _buildMessageList()),
            ),
            //user input
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: ownServ,
                      child: Card(
                        // elevation: 10,
                        color: Colors.green[500],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HireMaid(
                                          itemGlobal: itemglobal,
                                          name: widget.name)));
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.handshake,
                                  color: Colors.white,
                                ),
                                Text(
                                  _xmlHandler.getString('hire'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildUserInput(),
              ],
            ),
          ],
        ));
  }

  Widget _buildPostDetails() {
    if (widget.postType == "services") {
      return FutureBuilder(
        // StreamBuilder(
        future: getService(widget.postTypeID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("loading...");
          }
          //listview
          final item = snapshot.data!;
          itemglobal = item;
          return Column(
            children: [
              Text(
                "Schedule:${item.get("schedule")}\nTiming:${item.get("time_from")}-${item.get("time_to")}\nDays:${item.get("days")}",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      );
    } else {
      return Text(_xmlHandler.getString('nojob'));
    }
  }

  Future<DocumentSnapshot> getService(postTypeID) async {
    DocumentSnapshot qs = await maidDao().getService(postTypeID);
    return qs;
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: chatcontroller.getMessages(
          widget.receiverID, senderID, widget.postType, widget.postTypeID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }
        //listview
        return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList());
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data['senderID'] == FirebaseAuth.instance.currentUser!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: ChatBubble(data: data, isCurrentUser: isCurrentUser));
  }

  //build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
      child: Row(
        children: [
          // textfield
          Expanded(
            child: TextField(
              controller: _messageController,
              // hintText: "Type a Message",
              obscureText: false,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.grey)),
                hintText: "Type a Message",
              ),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          //button
          Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 37, 133, 40),
                  shape: BoxShape.circle),
              child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ))),
        ],
      ),
    );
  }
}
