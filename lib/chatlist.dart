import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  final ChatController chatcontroller = ChatController();
  Stream? ChatroomStream;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  ontheload() async {
    ChatroomStream = await chatcontroller.getChats(userID);
    print("Chatroom Data: ${ChatroomStream?.first}");
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
    //ads
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit ID
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    try {
      _bannerAd.load();
    } catch (e) {}
    ontheload();
    super.initState();
  }

  Future<QuerySnapshot> getUserinfo(DocumentSnapshot chatroomItem) async {
    userid = chatroomItem.id.replaceAll("_", "").replaceAll(userID, "");
    //.replaceAll(chatroomItem.get("postTypeID"), "");
    Future<QuerySnapshot<Object?>> qs = Usersdao().getUserDetails(userid);
    return qs;
  }

  AssetImage loadImage() {
    return const AssetImage("assets/profile.png");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isAdLoaded)
          SizedBox(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ),
        SizedBox(
          height: 4,
        ),
        StreamBuilder(
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
                      DocumentSnapshot chatRoomItem =
                          snapshot.data!.docs[index];
                      String lastMsg = "", lastTime = "";
                      String msg = chatRoomItem.get("lastMessage");

                      if (userID == chatRoomItem.get("lastSender")) {
                        if (msg == "@ck") {
                          lastMsg = "You:Acknowledgement Sent";
                        } else {
                          lastMsg = "You:$msg";
                        }
                      } else {
                        if (msg == "@ck") {
                          lastMsg = "Acknowledgement Received";
                        } else {
                          lastMsg = msg;
                        }
                      }

                      Timestamp? timestamp =
                          chatRoomItem.get("timestamp"); // Check for null
                      DateTime getDate = timestamp != null
                          ? timestamp.toDate()
                          : DateTime.now();
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
                                                  builder: (context) =>
                                                      ChatPage(
                                                        name: item.get("name"),
                                                        photo: item.get('url'),
                                                        receiverID:
                                                            item.get("userid"),
                                                        // postType: chatRoomItem
                                                        //     .get("postType"),
                                                        // postTypeID: chatRoomItem
                                                        //     .get("postTypeID"),
                                                        readMsg: chatRoomItem
                                                            .get('read_Msg'),
                                                      )));
                                        },
                                        child: ListTile(
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                          0.9), // Inner glow
                                                  blurRadius: 15,
                                                  spreadRadius: 0.1,
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey[200],
                                              foregroundImage: item
                                                          .get('url') ==
                                                      null
                                                  ? AssetImage(
                                                          "assets/profile.png")
                                                      as ImageProvider<Object>
                                                  : NetworkImage(
                                                      item.get('url')),
                                            ),
                                          ),
                                          title: Text(item.get("name")),
                                          subtitle: Text(
                                            lastMsg,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: chatRoomItem.get(
                                                              'read_Msg') ==
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
        ),
      ],
    );
  }

  void setRead(var chatRoomID) {
    FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .update({"read_Msg": true}).whenComplete(() {});
  }
}
