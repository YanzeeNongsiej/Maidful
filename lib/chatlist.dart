import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/chatpage.dart';
import 'package:ibitf_app/controller/chat_controller.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String userid = "";
  final ChatController chatcontroller = ChatController();
  Stream? ChatroomStream;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  ontheload() async {
    ChatroomStream = await chatcontroller.getChats(userID);
    print("CHatroom Data: ${ChatroomStream?.first}");
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    // _xmlHandler.loadStrings(gv.selected).then((val) {
    //   setState(() {});

    //   usrname = gv.username;
    // });
    // _fetchUserDocId();
    // fetchSkills();
    //profilepic();
    ontheload();
    super.initState();
  }

  Future<QuerySnapshot> getUserinfo(DocumentSnapshot chatroomItem) async {
    userid = chatroomItem.id
        .replaceAll("_", "")
        .replaceAll(userID, "")
        .replaceAll(chatroomItem.get("postTypeID"), "");
    Future<QuerySnapshot<Object?>> qs = Usersdao().getUserDetails(userid);
    return qs;
  }

  AssetImage loadImage() {
    return const AssetImage("assets/profile.png");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ChatroomStream,
      builder: (context, AsyncSnapshot snapshot) {
        print("chat snaps: ${snapshot.data}");
        //errors
        if (snapshot.hasError) {
          return Text("Error ${snapshot.error}");
        }
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }
        //listview
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // print("item Count:${snapshot.data!.docs.length}");
                  // print("Chatroom id:${snapshot.data!.docs[index].id}");
                  DocumentSnapshot chatRoomItem = snapshot.data!.docs[index];
                  String lastMsg = "", lastTime = "";
                  if (userID == chatRoomItem.get("lastSender")) {
                    lastMsg = "You:${chatRoomItem.get("lastMessage")}";
                  } else {
                    lastMsg = "${chatRoomItem.get("lastMessage")}";
                  }

                  Timestamp? timestamp =
                      chatRoomItem.get("timestamp"); // Check for null
                  DateTime getDate =
                      timestamp != null ? timestamp.toDate() : DateTime.now();
                  final now = DateTime.now();
                  if (getDate.day == now.day &&
                      getDate.month == now.month &&
                      getDate.year == now.year) {
                    lastTime = "${getDate.hour}:${getDate.minute}";
                  } else {
                    String monthstr = "";
                    switch (getDate.month) {
                      case 1:
                        monthstr = "Jan";
                        break;
                      case 2:
                        monthstr = "Feb";
                        break;
                      case 3:
                        monthstr = "Mar";
                        break;
                      case 4:
                        monthstr = "Apr";
                        break;
                      case 5:
                        monthstr = "May";
                        break;
                      case 6:
                        monthstr = "Jun";
                        break;
                      case 7:
                        monthstr = "Jul";
                        break;
                      case 8:
                        monthstr = "Aug";
                        break;
                      case 9:
                        monthstr = "Sep";
                        break;
                      case 10:
                        monthstr = "Oct";
                        break;
                      case 11:
                        monthstr = "Nov";
                        break;
                      case 12:
                        monthstr = "Dec";
                        break;
                      default:
                        monthstr = "Jan";
                    }
                    lastTime = "${getDate.day} $monthstr";
                  }
                  return FutureBuilder(
                      future: getUserinfo(chatRoomItem),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final item = snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      //code to firebase to set read=true
                                      setRead(chatRoomItem.id);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                    name: item.get("name"),
                                                    receiverID:
                                                        item.get("userid"),
                                                    postType: chatRoomItem
                                                        .get("postType"),
                                                    postTypeID: chatRoomItem
                                                        .get("postTypeID"),
                                                    readMsg: chatRoomItem
                                                        .get('read_Msg'),
                                                  )));
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        foregroundImage: item.get('url') == null
                                            ? loadImage()
                                                as ImageProvider<Object>
                                            : NetworkImage(item.get('url')!),
                                      ),
                                      title: Text(item.get("name")),
                                      subtitle: Text(
                                        lastMsg,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: chatRoomItem
                                                          .get('read_Msg') ==
                                                      true ||
                                                  userID ==
                                                      chatRoomItem
                                                          .get("lastSender")
                                              ? FontWeight
                                                  .normal // Normal if user sent it
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            lastTime,
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              );
                      });
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  void setRead(var chatRoomID) {
    FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .update({"read_Msg": true}).whenComplete(() {});
  }
}
