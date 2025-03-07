import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/chat_bubble.dart';
import 'package:ibitf_app/jobresume.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/hiremaid.dart';
import 'package:ibitf_app/singleton.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String receiverID;
  final bool readMsg;
  final String photo;

  const ChatPage({
    super.key,
    required this.name,
    required this.receiverID,
    required this.readMsg,
    required this.photo,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _messageController = TextEditingController();
  final ChatController chatcontroller = ChatController();
  bool ownServ = false;
  @override
  Widget build(BuildContext context) {
    if (GlobalVariables.instance.userrole == 1) {
      ownServ = false;
    } else {
      ownServ = true;
    }
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blueAccent.shade100,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.photo.isEmpty
                  ? AssetImage("assets/profile.png") as ImageProvider
                  : NetworkImage(widget.photo),
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildMessageList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: ownServ,
                child: Card(
                  elevation: 10,
                  color: Colors.blueAccent.shade700,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobResume(
                                      3,
                                      receiverID: widget.receiverID,
                                    )
                                // HireMaid(
                                //     name: widget.name)
                                ));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.handshake,
                            color: Colors.white,
                          ),
                          Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('hire'),
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
    );
  }

  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: chatcontroller.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            print('heyyyyy');
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data['senderID'] == FirebaseAuth.instance.currentUser!.uid;
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    String formattedTime = DateFormat('h:mm a').format(timestamp.toDate());

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(data: data, isCurrentUser: isCurrentUser, messageID: doc.id),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            formattedTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.emoji_emotions, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 25,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await chatcontroller.sendMessage(
          widget.receiverID, _messageController.text, "", false);
      _messageController.clear();
    }
  }
}
