import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/appbar.dart';
import 'package:ibitf_app/chatlist.dart';
import 'package:ibitf_app/jobprofile.dart';
import 'package:ibitf_app/jobresume.dart';
import 'package:ibitf_app/landinghome.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/terms.dart';
import 'package:ibitf_app/contact.dart';
import 'package:ibitf_app/profile.dart';
import 'package:ibitf_app/pricing.dart';

class EmployerHome extends StatefulWidget {
  final String? uname;
  final String? uid;

  const EmployerHome({super.key, @required this.uname, @required this.uid});
  @override
  _EmployerHomePageState createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends State<EmployerHome>
    with SingleTickerProviderStateMixin {
  // final serverUrl = 'http://192.168.82.8:3000';

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  ValueNotifier<String> languageNotifier = ValueNotifier<String>("");
  get uname => null;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  String newaddress = "", newname = "", userid = "";

  String? usrname;
  List<bool> _iss = [true, false], _isrs = [true, false];
  List<String> lang = ['English', 'Khasi'];
  Color scolor = Colors.white;
  // Stream<QuerySnapshot> fetchChats() {
  //   // Stream<QuerySnapshot<Object?>> qs = Chatdao().getChats(widget.uid as String);
  //   // return qs;
  // }
  String? _downloadUrl;

  bool isEditing = false;

  DocumentSnapshot? userDoc;
  Future<QuerySnapshot> fetchChats() async {
    QuerySnapshot qs = await maidDao().getAllMaids();
    return qs;
  }

  bool showMaids = true, showJobProfiles = false;
  void toggleMaids() {
    setState(() {
      showMaids = !showMaids;
      showJobProfiles = !showJobProfiles;
    });
  }

  //for the profilepic
  Future<void> profilepic() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Query the user's document
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("userid", isEqualTo: currentUser.uid) // Adjust as needed
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one matching document
        userDoc = querySnapshot.docs.first;
        setState(() {
          try {
            _downloadUrl = userDoc?['url'];
          } catch (e) {
            print("No profileimage yet");
          } // Fetch the URL field
        });
      }
    }
  }

  late TabController _tabController;
  final _selectedColor = const Color(0xff1a73e8);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    // _tabController.addListener(() {
    //   if (_tabController.index == 1) {
    //     // Chat tab is selected -> clear red dot
    //     GlobalVariables.instance.hasnewmsg = false;
    //     updateParentState();
    //   }
    // });
    super.initState();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      setState(() {});
      GlobalVariables.instance.username = widget.uname.toString();
      usrname = GlobalVariables.instance.username;
      GlobalVariables.instance.selected = "English";
      languageNotifier =
          ValueNotifier<String>(GlobalVariables.instance.selected);
    });
    profilepic();
    _isrs = [
      GlobalVariables.instance.userrole == 1 ? true : false,
      GlobalVariables.instance.userrole == 2 ? true : false
    ];
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
      case 'Pricing':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ServicePricingInsights()));
        break;
      case 'Contact Us':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HelpSupportPage()));
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

  AssetImage loadImage() {
    return const AssetImage("assets/profile.png");
  }

  // Document ID for the user in Firestore
  // Fetch the document ID based on the current user's UID
//  void changeRole(int role) {}

  Stream<int> getUnreadMessageCount(String currentUserId) {
    try {
      return FirebaseFirestore.instance
          .collection('chat_rooms')
          .snapshots()
          .map((snapshot) {
        int unreadCount = 0;

        for (var doc in snapshot.docs) {
          final docId = doc.id; // Get document ID
          if (docId.contains(currentUserId)) {
            // Check if user is in the chat
            final data = doc.data();
            if (data['lastSender'] != currentUserId &&
                data['read_Msg'] == false) {
              unreadCount++; // Increase count if unread
            }
          }
        }
        return unreadCount; // Return the number of unread messages
      });
    } catch (e) {
      print('Error fetching unread message count: $e');
      return Stream.value(0); // Return 0 on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return Scaffold(
            appBar: ModernAppBar(
              profileImageUrl: _downloadUrl,
              handleClick: handleClick,
            ),
            body: Stack(
              children: [
                /// TabBarView is the main content (Body)
                Positioned.fill(
                  child: TabBarView(
                    controller: _tabController,
                    // physics:
                    //     NeverScrollableScrollPhysics(), // Prevents swipe navigation
                    children: [
                      LandingHomePage(uname: widget.uname.toString()),
                      ChatListPage(),
                      ProfilePage(),
                    ],
                  ),
                ),

                /// Floating TabBar (No unwanted background)
                Positioned(
                  bottom: 15, // Adjust for floating effect
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                          0.95), // Slight transparency for floating effect
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 5,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(icon: Icon(Icons.home)),
                          Tab(
                            icon: Stack(
                              children: [
                                Icon(Icons.chat), // Chat icon
                                StreamBuilder<int>(
                                  stream: getUnreadMessageCount(userID),
                                  builder: (context, snapshot) {
                                    int unreadCount = snapshot.data ?? 0;
                                    if (unreadCount > 0) {
                                      return Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Center(
                                            child: Text(
                                              unreadCount > 9
                                                  ? '9+'
                                                  : unreadCount
                                                      .toString(), // Show '9+' if more than 9
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return SizedBox
                                        .shrink(); // Hide badge if no unread messages
                                  },
                                ),
                              ],
                            ),
                          ),
                          Tab(icon: Icon(Icons.person_2_sharp)),
                        ],
                        unselectedLabelColor: Colors.black,
                        labelColor: _selectedColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: _selectedColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: const FAB(),
          );
        });
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
  bool _isServicePresent = false;
  bool showOptions = false;
  void toggleOptions() {
    setState(() {
      showOptions =
          !showOptions; // Toggling the visibility of additional options
    });
  }

  Stream<bool> checkServiceExistenceStream() {
    return FirebaseFirestore.instance
        .collection(
            GlobalVariables.instance.userrole == 1 ? "services" : "jobprofile")
        .where("userid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.isNotEmpty);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: checkServiceExistenceStream(),
      builder: (context, snapshot) {
        bool isServicePresent = snapshot.data ?? false;

        return Visibility(
          visible: !isServicePresent,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Visibility(
                  visible: showOptions,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (GlobalVariables.instance.urole == 1)
                        FloatingActionButton.extended(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JobResume(1))),
                          heroTag: null,
                          label: Text(GlobalVariables.instance.xmlHandler
                              .getString('postaserv')),
                          icon: const Icon(Icons.person_add_rounded),
                        ),
                      const SizedBox(height: 16.0),
                      if (GlobalVariables.instance.urole == 2)
                        FloatingActionButton.extended(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JobResume(1))),
                          heroTag: null,
                          label: Text(GlobalVariables.instance.xmlHandler
                              .getString('postajob')),
                          icon: const Icon(Icons.add_card_sharp),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    toggleOptions();
                  },
                  heroTag: null,
                  shape: const CircleBorder(),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: showOptions
                      ? const Icon(Icons.close)
                      : const Icon(Icons.add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
