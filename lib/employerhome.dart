// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/chatpage.dart';
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/jobprofile.dart';
import 'package:ibitf_app/jobresume.dart';
//pages
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/maidlist.dart';
// import 'package:ibitf_app/maid.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/profile.dart';
// import 'material_design_indicator.dart';
// XMLHandler? _xmlHandler;

class EmployerHome extends StatefulWidget {
  final String? uname;
  final String? uid;

  const EmployerHome({Key? key, @required this.uname, @required this.uid})
      : super(key: key);
  @override
  _EmployerHomePageState createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends State<EmployerHome>
    with SingleTickerProviderStateMixin {
  // final serverUrl = 'http://192.168.82.8:3000';

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final ChatController chatcontroller = ChatController();
  Stream? ChatroomStream;
  get uname => null;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  String newaddress = "", newname = "", userid = "";
  final XMLHandler _xmlHandler = XMLHandler();
  GlobalVariables gv = GlobalVariables();

  final List<bool> _iss = [true, false];
  List<String> lang = ['English', 'Khasi'];
  Color scolor = Colors.white;
  // Stream<QuerySnapshot> fetchChats() {
  //   // Stream<QuerySnapshot<Object?>> qs = Chatdao().getChats(widget.uid as String);
  //   // return qs;
  // }

  Future<QuerySnapshot> fetchChats() async {
    QuerySnapshot qs = await maidDao().getAllMaids();
    return qs;
  }

  Future<QuerySnapshot> fetchOwnServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getOwnServices1(userID);
    return qs;
  }

  Future<QuerySnapshot> fetchOwnJobProfile() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getOwnJobProfile(userID);
    return qs;
  }

  bool showMaids = true, showJobProfiles = false;
  void toggleMaids() {
    setState(() {
      showMaids = !showMaids;
      showJobProfiles = !showJobProfiles;
    });
  }

  late TabController _tabController;

  final _selectedColor = const Color(0xff1a73e8);

  final _iconTabs = [
    const Tab(icon: Icon(Icons.home)),
    const Tab(icon: Icon(Icons.chat_rounded)),
    const Tab(icon: Icon(Icons.person_2_sharp)),
  ];

  ontheload() async {
    ChatroomStream = await chatcontroller.getChats(userID);
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    ontheload();
    super.initState();

    _xmlHandler.loadStrings(gv.selected).then((val) {
      setState(() {});
      gv.username = widget.uname.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Logout':
        await AuthMethods.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LogIn()));
        }
        break;
      case 'Settings':
        break;
    }
  }

  // bool showOptions = false;
  // void toggleOptions() {
  //   setState(() {
  //     showOptions =
  //         !showOptions; // Toggling the visibility of additional options
  //   });
  // }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: ChatroomStream,
      builder: (context, AsyncSnapshot snapshot) {
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
                  DateTime getDate = chatRoomItem.get("timestamp").toDate();
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
                      future: getUserinfo(chatRoomItem.id),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final item = snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  name: item.get("name"),
                                                  receiverID:
                                                      item.get("userid"),
                                                  postType: chatRoomItem
                                                      .get("post_type"),
                                                  postTypeID: chatRoomItem
                                                      .get("post_type_id"))))
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        foregroundImage: NetworkImage(
                                            AuthMethods.user?.photoURL ?? ''),
                                      ),
                                      title: Text(item.get("name")),
                                      subtitle: Text(
                                        lastMsg,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            lastTime,
                                            style:
                                                const TextStyle(fontSize: 13),
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

  Future<QuerySnapshot> getUserinfo(String usrId) async {
    userid = usrId.replaceAll("_", "").replaceAll(userID, "");
    Future<QuerySnapshot<Object?>> qs = Usersdao().getUserDetails(userid);
    return qs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/maidful__1_-removebg-preview.png",
                  fit: BoxFit.scaleDown,
                ));
          },
        ),
        // centerTitle: true,
        // backgroundColor: _selectedColor,
        // shadowColor: Colors.black,
        // elevation: 0.5,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.red,
        title: const Text('Maidful'),
        actions: <Widget>[
          PopupMenuButton(
            icon: CircleAvatar(
              foregroundImage: NetworkImage(AuthMethods.user?.photoURL ?? ''),
            ),
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "Logout",
                  child: Text("Logout"),
                ),
                const PopupMenuItem(
                  value: "Settings",
                  child: Text("Settings"),
                ),
                PopupMenuItem(
                  value: "Language",
                  child: StatefulBuilder(builder: (context, setState) {
                    return SizedBox(
                      height: (Checkbox.width) * 1.5,
                      child: Center(
                          child: ToggleButtons(
                        isSelected: _iss,
                        selectedColor: Colors.white,
                        fillColor: Colors.green,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        borderColor: Colors.grey,
                        borderWidth: 0,
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              _iss[0] = true;
                              _iss[1] = false;
                            } else {
                              _iss[0] = false;
                              _iss[1] = true;
                            }

                            gv.selected = lang[index];
                            _xmlHandler.loadStrings(gv.selected.toString());
                            updateParentState();
                          });
                        },
                        children: const [Text('English'), Text('Khasi')],
                      )),
                    );
                  }),
                )
              ];
            },
          ),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: _iconTabs,
        unselectedLabelColor: Colors.black,
        labelColor: _selectedColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: _selectedColor.withOpacity(0.2),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${_xmlHandler.getString('welc')}, ${widget.uname}",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.indigo[900],
                  ),
                ),
              ),
              NestedTabBar(),

              // const DefaultTabController(
              //   length: 2,
              //   child: TabBar(
              //       dividerColor: Colors.transparent,
              //       indicatorSize: TabBarIndicatorSize.tab,
              //       indicator: BoxDecoration(
              //           borderRadius: const BorderRadius.only(
              //               topLeft: Radius.circular(20),
              //               topRight: Radius.circular(20)),
              //           color: Colors.blue,
              //           gradient: LinearGradient(
              //               begin: Alignment.topCenter,
              //               end: Alignment.bottomCenter,
              //               // transform: GradientRotation(90),
              //               colors: [Colors.lightBlue, Colors.white])),
              //       tabs: [
              //         Tab(
              //           child: Text("maids"),
              //         ),
              //         Tab(child: Text("Job Profiles"))
              //       ]),
              // ),
              // Visibility(
              //     visible:
              //         showMaids, // Show the options only if showOptions is true
              //     child: Container(
              //       child: Text("maids"),
              //     )),
              // Visibility(
              //     visible: showJobProfiles,
              //     child: Container(
              //       child: Text("Job Profiles"),
              //     ))

              // Row(
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => const MaidList()))
              //         },
              //         child: Card(
              //           semanticContainer: true,
              //           clipBehavior: Clip.antiAliasWithSaveLayer,
              //           color: Colors.blueAccent[100],

              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10.0),
              //           ),
              //           elevation: 10,
              //           // margin: EdgeInsets.all(10),
              //           child: Column(
              //             children: [
              //               const Icon(
              //                 Icons.person_search_sharp,
              //                 size: 100,
              //                 color: Colors.white,
              //               ),
              //               // Image.asset(
              //               //   "assets/user.png",
              //               //   fit: BoxFit.scaleDown,
              //               // ),
              //               Text(
              //                 (_xmlHandler.getString('maid')).toString(),
              //                 style: const TextStyle(color: Colors.white),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Card(
              //         semanticContainer: true,
              //         clipBehavior: Clip.antiAliasWithSaveLayer,
              //         color: Colors.blueAccent[100],
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0),
              //         ),
              //         elevation: 5,

              //         // margin: EdgeInsets.all(10),
              //         child: Column(
              //           children: [
              //             const Icon(Icons.manage_search_outlined,
              //                 size: 100, color: Colors.white),
              //             Text(
              //               (_xmlHandler.getString('job')).toString(),
              //               style: const TextStyle(color: Colors.white),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
          _buildChatList(),
          Center(
            child: ProfilePage(),
          ),
        ],
      ),
      floatingActionButton: const FAB(),
    );
  }

  void updateParentState() {
    setState(() {});
  }
}

class FAB extends StatefulWidget {
  const FAB({super.key});

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  bool showOptions = false;
  void toggleOptions() {
    setState(() {
      showOptions =
          !showOptions; // Toggling the visibility of additional options
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: showOptions, // Show the options only if showOptions is true
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () => {
                  // Add your action for Option 1
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JobResume()))
                },
                heroTag: null,
                label: const Text(
                  "Post a Service (Maids)",
                ),
                icon: const Icon(Icons.person_add_rounded),
              ),
              const SizedBox(height: 16.0),
              FloatingActionButton.extended(
                onPressed: () => {
                  // Add your action for Option 1
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JobProfile()))
                },
                heroTag: null,
                label: const Text(
                  "Post a Job Profile",
                ),
                icon: const Icon(Icons.add_card_sharp),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        FloatingActionButton(
          onPressed: () {
            toggleOptions(); // When the main FAB is pressed, toggleOptions is called
          },
          heroTag: null,
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: showOptions ? const Icon(Icons.close) : const Icon(Icons.add),
        ),
      ],
    );
  }
}

class NestedTabBar extends StatefulWidget {
  NestedTabBar({super.key});

  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  final XMLHandler _xmlHandler = XMLHandler();

  late TabController _nestedTabController;
  @override
  void initState() {
    super.initState();
    _xmlHandler.loadStrings(gv.selected).then((val) {
      setState(() {});
      // gv.username = widget.uname.toString();
    });
    _nestedTabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  Future<QuerySnapshot> fetchServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getAllServices(userID);
    return qs;
  }

  Future<QuerySnapshot> fetchUserData(String userId) async {
    QuerySnapshot qs = await Usersdao().getUserDetails(userId);
    return qs;
  }

  getServiceDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            insetPadding: const EdgeInsets.only(left: 8, right: 8),
            title: Text(_xmlHandler.getString('maiddetails'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(_xmlHandler.getString('nam'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("name")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(_xmlHandler.getString('addr'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("address")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(_xmlHandler.getString('sched'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(servItem.get("schedule")),
                      ],
                    ),
                    if (servItem.get("schedule") == 'Hourly')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_xmlHandler.getString('day'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          for (var i = 0; i < servItem.get("days").length; i++)
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${i + 1}. "),
                                  Expanded(
                                    child: Text("${servItem.get("days")[i]}"),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    if (servItem.get("schedule") == 'Daily' ||
                        servItem.get("schedule") == 'Hourly')
                      Row(
                        children: [
                          Text(_xmlHandler.getString('timing'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "${servItem.get("time_from")}-${servItem.get("time_to")}"),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_xmlHandler.getString('serv'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        for (var i = 0;
                            i < servItem.get("services").length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${i + 1}. "),
                                Expanded(
                                  child: Text("${servItem.get("services")[i]}"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_xmlHandler.getString('workhist'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        for (var i = 0;
                            i < servItem.get("work_history").length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${i + 1}. "),
                                Expanded(
                                  child: Text(
                                      "${servItem.get("work_history")[i]}"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(_xmlHandler.getString('wage'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(servItem.get("wage"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(_xmlHandler.getString('rate'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25)),
                              Text("\u{20B9}${servItem.get("rate")}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                // elevation: 10,
                                color: Colors.green,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => ChatPage(
                                      //             name: item.get("name"),
                                      //             receiverID: item.get("userid"),
                                      //             postType: "services",
                                      //             postTypeID: servItem.id)));
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.handshake,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          _xmlHandler.getString('hire'),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              //     Card(
                              //       // elevation: 10,
                              //       color: Colors.amber[600],
                              //       child: Padding(
                              //         padding: const EdgeInsets.all(5.0),
                              //         child: GestureDetector(
                              //           onTap: () {
                              //             // Navigator.pop(context);
                              //           },
                              //           child: const Row(
                              //             children: [
                              //               Icon(Icons.threesixty_sharp),
                              //               Text('Counter'),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Card(
                    // elevation: 10,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      name: item.get("name"),
                                      receiverID: item.get("userid"),
                                      postType: "services",
                                      postTypeID: servItem.id)));
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                            Text(
                              'Chat',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    // elevation: 10,
                    color: Colors.orange,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.white),
                            Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Row(
                  //     children: [const Icon(Icons.chat), Text("chat")],
                  //   ),
                  // ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TabBar(
          controller: _nestedTabController,
          dividerColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const BoxDecoration(
              border: Border(
                  left: BorderSide(color: Colors.grey),
                  top: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey)),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.blue,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlue, Colors.white])),
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(
              text: "Maids(for Home Owners)",
            ),
            Tab(
              text: "Job Profiles(For Maids)",
            ),
          ],
        ),
        Container(
          height: screenHeight * 0.70,
          margin: EdgeInsets.only(left: 16.0, right: 16.0),
          child: TabBarView(
            controller: _nestedTabController,
            children: <Widget>[
              Column(
                children: [
                  FutureBuilder(
                      // StreamBuilder(
                      future: fetchServices(),
                      // stream: fetchChats(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final servitem = snapshot.data!.docs[index];
                                // print("Service ID: ${servitem.id}");
                                return FutureBuilder(
                                    future:
                                        fetchUserData(servitem.get("userid")),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final item = snapshot.data!.docs.first;
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                getServiceDetail(
                                                    item, servitem);
                                              },
                                              child: Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                // elevation: 10,
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    foregroundImage:
                                                        NetworkImage(AuthMethods
                                                                .user
                                                                ?.photoURL ??
                                                            ''),
                                                  ),
                                                  title: Text(item.get("name")),
                                                  subtitle: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.location_pin,
                                                        size: 15,
                                                      ),
                                                      Text(item.get("address")),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatPage(
                                                                      name: item
                                                                          .get(
                                                                              "name"),
                                                                      receiverID:
                                                                          item.get(
                                                                              "userid"),
                                                                      postType:
                                                                          "services",
                                                                      postTypeID:
                                                                          servitem
                                                                              .id)));
                                                        },
                                                        icon: const Icon(
                                                            Icons.chat_rounded),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                snapshot.error.toString()));
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    });
                              });
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ],
              ),
              Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8.0),
                //   color: Colors.blueGrey[300],
                // ),
                child: Text("Job Profiles"),
              ),
            ],
          ),
        )
      ],
    );
  }
}
