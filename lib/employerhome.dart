import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
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

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Chat tab is selected -> clear red dot
        GlobalVariables.instance.hasnewmsg = false;
        updateParentState();
      }
    });
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
      case 'Settings':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Terms()));
        break;
      case 'Contact':
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
  @override
  Widget build(BuildContext context) {
    print("hehe emplhome${GlobalVariables.instance.hasnewmsg}");
    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
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
              foregroundColor: Colors.black,
              surfaceTintColor: Colors.red,
              title: const Text('Maidful'),
              actions: <Widget>[
                PopupMenuButton(
                  icon: CircleAvatar(
                    foregroundImage: _downloadUrl != null
                        ? NetworkImage(_downloadUrl!)
                        : loadImage() as ImageProvider<Object>,
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
                      const PopupMenuItem(
                        value: "Contact",
                        child: Text("Contact Us"),
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

                                  GlobalVariables.instance.selected =
                                      lang[index];
                                  GlobalVariables.instance.xmlHandler
                                      .loadStrings(GlobalVariables
                                          .instance.selected
                                          .toString());
                                  //updateParentState();
                                });
                              },
                              children: const [Text('English'), Text('Khasi')],
                            )),
                          );
                        }),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.all(0),
                        value: "Role",
                        child: StatefulBuilder(builder: (context, setState) {
                          return SizedBox(
                            height: (Checkbox.width) * 1.5,
                            // width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: ToggleButtons(
                                isSelected: _isrs,
                                selectedColor: Colors.white,
                                fillColor: Colors.blue,
                                color: Colors.black,
                                // borderRadius: BorderRadius.circular(10),
                                borderColor: Colors.grey,
                                borderWidth: 0,
                                onPressed: (int index) {
                                  setState(() {
                                    if (index == 0) {
                                      _isrs[0] = true;
                                      _isrs[1] = false;
                                    } else {
                                      _isrs[0] = false;
                                      _isrs[1] = true;
                                    }

                                    GlobalVariables.instance.userrole =
                                        index + 1;
                                    GlobalVariables.instance.xmlHandler
                                        .loadStrings(GlobalVariables
                                            .instance.selected
                                            .toString());
                                  });
                                  updateSearchqs();
                                },
                                children: const [
                                  Text('Maid'),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: Text('Employer'),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ];
                  },
                ),
              ],
            ),
            bottomNavigationBar: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(
                    icon: Stack(
                  children: [
                    Icon(Icons.chat), // Chat icon
                    if (GlobalVariables.instance
                        .hasnewmsg) // Show red dot if there's a new message
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                  ],
                )),
                Tab(icon: Icon(Icons.person_2_sharp)),
              ],
              unselectedLabelColor: Colors.black,
              labelColor: _selectedColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: _selectedColor.withOpacity(0.2),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                LandingHomePage(uname: widget.uname.toString()),
                ChatListPage(),
                ProfilePage(),
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
              if (GlobalVariables.instance.urole == 1)
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
              if (GlobalVariables.instance.urole == 2)
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
