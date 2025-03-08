import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/chatpage.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/buildui.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';

class LandingHomePage extends StatefulWidget {
  final String? uname;
  // Callback function passed from NestedTabBar

  const LandingHomePage({super.key, @required this.uname});

  @override
  State<LandingHomePage> createState() => _LandingHomePageState();
}

late Future<QuerySnapshot> aqs, searchqs;
int searchCriteria = 1; //1=Address,2=Name,3=Service
SearchController? sCont;

void updateSearchqs() {
  if (GlobalVariables.instance.userrole == 2) {
    aqs = fetchServices();
  } else if (GlobalVariables.instance.userrole == 1) {
    aqs = fetchJobProfiles();
  }
  searchqs = aqs;
  aqs.then((QuerySnapshot s) {});
}

Future<QuerySnapshot> fetchServices() async {
  String userID = FirebaseAuth.instance.currentUser!.uid;
  // QuerySnapshot? tempqs;
  QuerySnapshot qs = await maidDao().getAllServices(userID);
  // tempqs = qs;
  // for (var i in qs.docs) {

  // }
  // qs.forEach((doc) => {});
  return qs;
}

Future<QuerySnapshot> fetchJobProfiles() async {
  String userID = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot qs = await maidDao().getAllJobProfiles(userID);
  return qs;
}

class _LandingHomePageState extends State<LandingHomePage> {
  String searchText = "Search by Address...";
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      setState(() {});
    });
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notificationService.requestPermission();
    _notificationService.setFCMToken();
    _notificationService.listenToForegroundMessages();
    _notificationService.handleNotificationClicks();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${GlobalVariables.instance.xmlHandler.getString('welc')}, ${widget.uname}",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.indigo[900],
                  ),
                ),
              ),

//search button
              Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SearchAnchor(
                    builder: (BuildContext context, SearchController sCont) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: MediaQuery.of(context).size.height / 18,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: Offset(0, 10),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade300,
                              Colors.blue.shade300
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SearchBar(
                          textStyle: WidgetStateProperty.all(
                              TextStyle(color: Colors.white)),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          controller: sCont,
                          hintText: searchText,
                          hintStyle: WidgetStateProperty.all(
                              TextStyle(color: Colors.white38)),
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onTap: () {
                            // Add a smooth expansion effect
                          },
                          onChanged: (_) {
                            updateServiceList(sCont.text);
                          },
                          leading: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              Icons.search,
                              key: ValueKey<bool>(true),
                              color: Colors.white,
                            ),
                          ),
                          trailing: <Widget>[
                            PopupMenuButton(
                              icon: Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: "Address",
                                    child: Text("Search by Address"),
                                    onTap: () {
                                      setState(() {
                                        searchText = "Search by Address...";
                                        searchCriteria = 1;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    value: "Name",
                                    child: Text("Search by Name"),
                                    onTap: () {
                                      setState(() {
                                        searchText = "Search by Name...";
                                        searchCriteria = 2;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    value: "Service",
                                    child: Text("Search by Service"),
                                    onTap: () {
                                      setState(() {
                                        searchText = "Search by Service...";
                                        searchCriteria = 3;
                                      });
                                    },
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'Item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    },
                  )),

              NestedTabBar(refreshCallback: () {
                setState(() {}); // Call setState of NestedTabBar
              }),

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
              //                 (GlobalVariables.instance.xmlHandler.getString('maid')).toString(),
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
              //               (GlobalVariables.instance.xmlHandler.getString('job')).toString(),
              //               style: const TextStyle(color: Colors.white),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          );
        });
  }

  void updateServiceList(String searchVal) {
    aqs.then((QuerySnapshot s) {
      List<QueryDocumentSnapshot> filteredRes = [];
      String searchBy = 'address';
      if (searchCriteria == 1) {
        searchBy = 'address';
      } else if (searchCriteria == 2) {
        searchBy = 'name';
      } else {
        searchBy = 'services';
      }
      List<Future<Null>> futures;
      if (searchCriteria == 1 || searchCriteria == 2) {
        // Loop through each document in the initial QuerySnapshot
        futures = s.docs.map((i) {
          return fetchUserData(i.get('userid')).then((QuerySnapshot temp) {
            // Filter the documents based on the search value
            List<QueryDocumentSnapshot> userDocs = temp.docs.where((doc) {
              return doc[searchBy]
                  .toString()
                  .toLowerCase()
                  .startsWith(searchVal.toLowerCase());
            }).toList();
            // Add filtered docs to the result listM
            filteredRes.addAll(userDocs);
          });
        }).toList();
        Future<QuerySnapshot> usr;
        Future.wait(futures).then((_) {
          usr = Future.value(MockQuerySnapshot(filteredRes));
          // Update state with filtered results
          usr.then((data) {
            List<String> usrUserIds = [];
            for (var i in data.docs) {
              usrUserIds.add(i.get('userid'));
            }
            List<QueryDocumentSnapshot> filteredSearchQs = [];

            aqs.then((a) {
              for (var doc in a.docs) {
                if (usrUserIds.contains(doc.get('userid'))) {
                  filteredSearchQs.add(doc);
                }
              }
            });
            searchqs = Future.value(MockQuerySnapshot(filteredSearchQs));
            print("filtered");
            setState(() {
              searchqs.then((a) {});
            });
          });

          // Step 2: Filter searchqs based on common 'userid' with usr

          // print(searchqs); // For debugging: print the filtered results
        }).catchError((e) {
          print('Error in fetchUserData: $e');
        });
      } else {
        // return aqs.then((QuerySnapshot temp) {
        // Filter the documents based on the search value
        List<String> usrServices = [];
        List<QueryDocumentSnapshot> userDocs = s.docs.where((doc) {
          bool flg = false;
          List<dynamic> size = doc[searchBy];
          for (int j = 0; j < size.length; j++) {
            flg = false;
            if (doc[searchBy][j]
                .toString()
                .toLowerCase()
                .trim()
                .startsWith(searchVal.toLowerCase().trim())) {
              usrServices.add(doc[searchBy][j]);
              flg = true;
              break;
            }
          }
          return flg;
          // return doc[searchBy]
          //     .toString()
          //     .toLowerCase()
          //     .startsWith(searchVal.toLowerCase());
        }).toList();
        // Add filtered docs to the result listM
        filteredRes.addAll(userDocs);
        Future<QuerySnapshot> finalres =
            Future.value(MockQuerySnapshot(filteredRes));
        finalres.then((data) {
          for (var i in data.docs) {
            // usrServices.add(i.get(searchBy));
            usrServices.add(i.id);
          }
          List<QueryDocumentSnapshot> filteredSearchQs = [];

          aqs.then((a) {
            for (var doc in a.docs) {
              String vari = doc.id;
              if (usrServices.contains(vari)) {
                filteredSearchQs.add(doc);
              }
            }
          });
          searchqs = Future.value(MockQuerySnapshot(filteredSearchQs));
          setState(() {
            searchqs.then((a) {});
          });
        });
        // });
      }
      // After all fetch operations are complete, update the UI
    }).catchError((e) {
      print('Error in aqs.then: $e');
    });
    NestedTabBar(refreshCallback: () {
      setState(() {}); // Call setState of NestedTabBar
    });
  }
}

class MockQuerySnapshot implements QuerySnapshot<Object?> {
  @override
  final List<QueryDocumentSnapshot<Object?>> docs;

  MockQuerySnapshot(this.docs);

  @override
  // TODO: implement docChanges
  List<DocumentChange<Object?>> get docChanges => throw UnimplementedError();

  @override
  // TODO: implement metadata
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  // TODO: implement size
  int get size => throw UnimplementedError();
}

Future<QuerySnapshot> fetchUserData(String userId) async {
  QuerySnapshot qs = await Usersdao().getUserDetails(userId);
  return qs;
}

class NestedTabBar extends StatefulWidget {
  final Function refreshCallback;

  const NestedTabBar({super.key, required this.refreshCallback});
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late TabController _nestedTabController;
  // late Future<QuerySnapshot> qs;

  List<String>? selectedskills;
  List<String> myskills = [];

  List<int>? myscores;
  List<Map<String, dynamic>> skillsWithScores = [];
  List<List<dynamic>> skillsWithNames = [];
  @override
  void initState() {
    super.initState();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      setState(() {});
      // GlobalVariables.instance.username = widget.uname.toString();
    });
    updateSearchqs();
    _nestedTabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  void refresh() {
    widget.refreshCallback();
  }

  void _onServiceListUpdated() {
    setState(() {
      // You can update your state here.
      print("Service list updated, now calling setState!");
    });
  }

  Widget showSkills(thisid) {
    return FutureBuilder<void>(
      future: fetchSkills(thisid),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.redAccent, fontSize: 14)),
          );
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          shadowColor: Colors.black26,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              collapsedBackgroundColor: Colors.blueAccent.withOpacity(0.1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(Icons.build_circle_outlined,
                      color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    GlobalVariables.instance.xmlHandler.getString('skills'),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
              children: [
                if (selectedskills == null && myskills.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      GlobalVariables.instance.xmlHandler.getString('noskills'),
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                if (selectedskills == null && myskills.isNotEmpty)
                  createSkillsList(myskills),
                if (selectedskills != null && myskills.isNotEmpty)
                  Column(
                    children: [
                      createSkillsList(myskills),
                      createSkillsList(selectedskills!.toList()),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createSkillsList(List<String> res) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.29,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Assessment',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
            Column(
              children: res.map((skill) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            skill == getSkillName(skill)
                                ? skillsWithNames
                                    .firstWhere((s) => s[0] == skill)[1]
                                : skill,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        myskills.contains(getSkillName(skill)) &&
                                checkVerified(skill)
                            ? showSkillLevel(getSkillName(skill))
                            : Text(
                                'Unverified',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget showSkillLevel(String currentSkill) {
    double level = 0;
    int res = 0;
    for (var s in skillsWithScores) {
      if (s['skill'] == currentSkill) {
        res = s['score'];
      }
      level = res.toDouble().abs();
    }

    return CircularPercentIndicator(
      radius: 24.0,
      lineWidth: 5.0,
      animation: true,
      percent: level / 100,
      center: Text(
        "${level.toInt()}%",
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[300]!,
      linearGradient: LinearGradient(
        colors: [_getSkillColor(level), Colors.blueAccent.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Color _getSkillColor(double level) {
    if (level >= 75) return Colors.greenAccent.shade700;
    if (level >= 50) return Colors.yellowAccent.shade700;
    if (level >= 25) return Colors.orangeAccent.shade700;
    return Colors.redAccent.shade700;
  }

  // Widget showSkills(thisid) {
  //   return FutureBuilder<void>(
  //     future: fetchSkills(thisid), // Wait for fetchSkills to complete
  //     builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         // While fetchSkills is running, show a loading spinner
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         // Handle any errors from fetchSkills
  //         return Text('Error: ${snapshot.error}');
  //       }

  //       // After fetchSkills completes, return the actual widget
  //       return Theme(
  //         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
  //         child: ExpansionTile(
  //           title: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(
  //                 Icons.align_vertical_center,
  //                 color: Colors.blueAccent,
  //               ),
  //               Text(
  //                 GlobalVariables.instance.xmlHandler.getString('skills'),
  //                 style: TextStyle(fontSize: 14),
  //               ),
  //             ],
  //           ),
  //           children: [
  //             if (selectedskills == null && myskills.isEmpty)
  //               Text(GlobalVariables.instance.xmlHandler.getString('noskills')),
  //             if (selectedskills == null && myskills.isNotEmpty)
  //               createSkillsFirst(myskills),
  //             if (selectedskills != null && myskills.isNotEmpty)
  //               Column(
  //                 children: [
  //                   createSkillsFirst(myskills),
  //                   createSkillsFirst(selectedskills!.toList()),
  //                 ],
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> fetchSkills(thisid) async {
    try {
      // Reference to the user's skills subcollection
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection("users")
          .where("userid", isEqualTo: thisid) // Adjust as needed
          .get();
      String myid = querySnapshot1.docs.first.id;
      CollectionReference skillsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .collection('skills');

      // Get all documents in the skills subcollection
      QuerySnapshot querySnapshot = await skillsCollection.get();
      // Get all documents in the skills subcollection

      final sc = FirebaseFirestore.instance.collection('skills');
      final qs = await sc.get();

      skillsWithNames = qs.docs.map((doc) {
        return [
          doc.id,
          doc[GlobalVariables.instance.selected]
        ]; // Get skill ID and English name
      }).toList();
      setState(() {
        myskills = querySnapshot.docs.map((doc) => doc.id).toList();
        skillsWithScores = querySnapshot.docs.map((doc) {
          return {
            'skill': doc.id, // Document ID (e.g., Skill1)
            'score': doc['score'], // Get the score field
          };
        }).toList();

        // Get skill document IDs
        //isLoading = false; // Update loading state
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  // Color _getColor(double level) {
  //   if (level >= 75) {
  //     return Colors.green; // High skill
  //   } else if (level >= 50) {
  //     return Colors.orange; // Medium skill
  //   } else {
  //     return Colors.red; // Low skill
  //   }
  // }

  String getSkillName(String sName) {
    String s = sName;
    for (var skill in skillsWithNames) {
      if (skill[1] == sName) {
        // Check if the English name matches
        s = skill[0]; // Return the corresponding skill name (e.g., Skill1)
      }
    }
    return s;
  }

  bool checkVerified(String skil) {
    bool res = true;
    for (var s in skillsWithScores) {
      if (s['skill'] == skil && s['score'] == -1) {
        res = false;
        // Return the score if found
      }
    }
    return res;
  }

  // Widget showLevels(currentSkill) {
  //   double level = 0;
  //   int res = 0;
  //   for (var s in skillsWithScores) {
  //     if (s['skill'] == currentSkill) {
  //       res = s['score'];
  //       // Return the score if found
  //     }
  //     level = res.toDouble().abs();
  //   }
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Container(
  //         width: 150,
  //         height: 20,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           color: Colors.grey[300],
  //         ),
  //         child: Stack(
  //           children: [
  //             Container(
  //               width:
  //                   level * 1.5, // Scale the width according to level (0-300)
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: _getColor(level),
  //               ),
  //             ),
  //             Center(
  //               child: LinearPercentIndicator(
  //                 width: 150,
  //                 lineHeight: 20,
  //                 animation: true,
  //                 animationDuration: 1000,
  //                 percent: level / 100,
  //                 center: Text(
  //                   "${level.toInt()}%",
  //                   style: TextStyle(color: Colors.black, fontSize: 13),
  //                 ),
  //                 linearStrokeCap: LinearStrokeCap.roundAll,
  //                 progressColor: _getColor(level),
  //                 backgroundColor: Colors.grey[300]!,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget createSkillsFirst(List<String> res) {
  //   return SingleChildScrollView(
  //     child: Theme(
  //       data: Theme.of(context).copyWith(
  //         dividerColor: Colors.transparent, // Removes the divider line
  //       ),
  //       child: Column(
  //         children: res.map((skill) {
  //           // print("My skills is:$myskills");
  //           // print("Current skill is$skill");
  //           // print("$skillsWithScores is skills with scores");
  //           // print(
  //           //     "Is that skill in myskills?:${myskills.contains(getSkillName(skill))}");
  //           // print(
  //           //     "Myskills is $myskills and this skill is $skill and getskillname is ${skillsWithNames}");

  //           return ListTile(
  //             dense: true,
  //             minVerticalPadding: 0,
  //             contentPadding: EdgeInsets.all(0),
  //             title: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     skill == getSkillName(skill)
  //                         ? skillsWithNames.firstWhere((s) => s[0] == skill)[1]
  //                         : skill,
  //                   ),
  //                 ),
  //                 myskills.contains(getSkillName(skill)) && checkVerified(skill)
  //                     ? showLevels(getSkillName(skill))
  //                     : Text('Unverified'),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  getServiceDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
          return FadeInLeft(
              duration: Duration(milliseconds: 500),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                scrollable: true,
                insetPadding: const EdgeInsets.all(10),
                title: Center(
                  child: Text(
                    GlobalVariables.instance.userrole == 2
                        ? GlobalVariables.instance.xmlHandler
                            .getString('maiddetails')
                        : GlobalVariables.instance.xmlHandler
                            .getString('jobdetails'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextInfo("Name", item.get("name")),
                      buildTextInfo("Address", item.get("address")),
                      buildTextInfo(
                        "Posted on",
                        DateFormat('dd MMM yyyy').format(
                            (servItem.get("timestamp") as Timestamp).toDate()),
                      ),
                      buildScheduleSection(
                          "Schedule", servItem.get("schedule")),
                      GlobalVariables.instance.userrole == 2
                          ? buildServiceSection(
                              "Services", servItem.get("services"))
                          : buildSection("Services", servItem.get("services")),
                      buildSection("Timing", servItem.get("timing")),
                      buildSection("Days Available", servItem.get("days")),
                      buildTextInfo("Negotiable", servItem.get("negotiable")),
                      SizedBox(height: 10),
                      buildWorkHistory(servItem.get("work_history")),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Card(
                        // elevation: 10,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: Colors.transparent,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Refined Background Card
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 30),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.white.withOpacity(
                                                0.9), // More solid background
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Profile Image with a Soft Glow Effect
                                              Hero(
                                                tag:
                                                    'profile-${item.get('userid')}',
                                                child: Container(
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
                                                    radius: 50,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    foregroundImage: item
                                                                .get('url') ==
                                                            null
                                                        ? AssetImage(
                                                                "assets/profile.png")
                                                            as ImageProvider<
                                                                Object>
                                                        : NetworkImage(
                                                            item.get('url')),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Name
                                              Text(
                                                item.get('name'),
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .blueAccent.shade700,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              // Address
                                              _buildIconText(
                                                  Icons.house_outlined,
                                                  item.get('address')),

                                              // Gender
                                              _buildIconText(
                                                  Icons.group_rounded,
                                                  item.get('gender') == 1
                                                      ? 'Female'
                                                      : 'Male'),

                                              // Date of Birth
                                              _buildIconText(Icons.date_range,
                                                  item.get('dob')),

                                              // Languages Spoken
                                              _buildIconText(
                                                Icons.abc,
                                                item
                                                    .get('language')
                                                    .toString()
                                                    .replaceAll('[', '')
                                                    .replaceAll(']', ''),
                                              ),

                                              // 🌟 Average Rating Section 🌟
                                              if (item
                                                      .data()
                                                      .containsKey('rating') &&
                                                  item.get('rating') is Map)
                                                _buildAverageRating(
                                                    item.get('rating')),

                                              // Show Skills (Only for certain users)
                                              if (GlobalVariables
                                                      .instance.userrole ==
                                                  2)
                                                showSkills(item.get('userid')),
                                            ],
                                          ),
                                        ),

                                        // Close Button with a Floating Effect
                                        Positioned(
                                          top: -10,
                                          right: -10,
                                          child: GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).pop(),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.redAccent,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red
                                                        .withOpacity(0.3),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  )
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 24),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

// Utility function for icons & text
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.person_3_rounded,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Profile',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                            photo: item.get('url'),
                                            receiverID: item.get("userid"),
                                            // postType: "services",
                                            // postTypeID: servItem.id,
                                            readMsg: true,
                                          )));
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
              ));
        });
  }

  Widget _buildAverageRating(Map<String, dynamic> ratings) {
    if (ratings.isEmpty) return SizedBox(); // No ratings available

    // Convert ratings to a list of values & calculate average
    List<int> ratingValues = ratings.values.map((r) => r as int).toList();
    double avgRating =
        ratingValues.reduce((a, b) => a + b) / ratingValues.length;

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.star_border_purple500, color: Colors.blueAccent),
            SizedBox(width: 5),
            Text("Average Rating: ${avgRating.toStringAsFixed(2)}"),
          ],
        ),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < avgRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
        ),
      ],
    );
  }

  // getJobProfileDetail(item, servItem) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         Map<String, dynamic> time = servItem.get('timing');
  //         List<String> allShifts = [];
  //         time.forEach((key, value) {
  //           if (value is List<dynamic>) {
  //             allShifts.addAll(value.map((e) => e.toString()));
  //           }
  //         });
  //         return AlertDialog(
  //           scrollable: true,
  //           insetPadding: const EdgeInsets.only(left: 8, right: 8),
  //           title: Text(
  //               GlobalVariables.instance.xmlHandler.getString('servdetails'),
  //               style: const TextStyle(fontWeight: FontWeight.bold)),
  //           content: Card(
  //             elevation: 5,
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                           GlobalVariables.instance.xmlHandler
  //                               .getString('nam'),
  //                           style:
  //                               const TextStyle(fontWeight: FontWeight.bold)),
  //                       Text(item.get("name")),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Text(
  //                           GlobalVariables.instance.xmlHandler
  //                               .getString('addr'),
  //                           style:
  //                               const TextStyle(fontWeight: FontWeight.bold)),
  //                       Text(item.get("address")),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Text(
  //                           GlobalVariables.instance.xmlHandler
  //                               .getString('sched'),
  //                           style:
  //                               const TextStyle(fontWeight: FontWeight.bold)),
  //                       Text(GlobalVariables.instance.xmlHandler
  //                           .getString(servItem.get("schedule"))),
  //                     ],
  //                   ),
  //                   if (servItem.get("schedule") == 'Hourly')
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                             GlobalVariables.instance.xmlHandler
  //                                 .getString('day'),
  //                             style:
  //                                 const TextStyle(fontWeight: FontWeight.bold)),
  //                         for (var i = 0; i < servItem.get("days").length; i++)
  //                           Padding(
  //                             padding: const EdgeInsets.only(left: 30),
  //                             child: Row(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text("${i + 1}. "),
  //                                 Expanded(
  //                                   child: Text(GlobalVariables
  //                                       .instance.xmlHandler
  //                                       .getString(servItem.get("days")[i])),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                       ],
  //                     ),
  //                   if (servItem.get("schedule") == 'Daily' ||
  //                       servItem.get("schedule") == 'Hourly')
  //                     Row(
  //                       children: [
  //                         Text(
  //                             GlobalVariables.instance.xmlHandler
  //                                 .getString('timing'),
  //                             style:
  //                                 const TextStyle(fontWeight: FontWeight.bold)),
  //                         Text.rich(TextSpan(
  //                           children: <InlineSpan>[
  //                             ...List.generate(
  //                               (allShifts.length / 2).ceil(),
  //                               (i) => TextSpan(
  //                                 text:
  //                                     '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
  //                                 style: const TextStyle(color: Colors.black),
  //                               ),
  //                             ),
  //                           ],
  //                         ))
  //                       ],
  //                     ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                           GlobalVariables.instance.xmlHandler
  //                               .getString('serv'),
  //                           style:
  //                               const TextStyle(fontWeight: FontWeight.bold)),
  //                       for (var i = 0;
  //                           i < servItem.get("services").length;
  //                           i++)
  //                         Padding(
  //                           padding: const EdgeInsets.only(left: 30),
  //                           child: Row(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text("${i + 1}. "),
  //                               Expanded(
  //                                 child: Text(GlobalVariables
  //                                     .instance.xmlHandler
  //                                     .getString(servItem.get("services")[i])),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Text(
  //                                 GlobalVariables.instance.xmlHandler
  //                                     .getString('wage'),
  //                                 style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 15)),
  //                             Text(
  //                                 GlobalVariables.instance.xmlHandler
  //                                     .getString(servItem.get("wage")),
  //                                 style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 15)),
  //                           ],
  //                         ),
  //                         Row(
  //                           children: [
  //                             Text(
  //                                 GlobalVariables.instance.xmlHandler
  //                                     .getString('rate'),
  //                                 style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 25)),
  //                             Text("\u{20B9}${servItem.get("rate")}",
  //                                 style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 25)),
  //                           ],
  //                         ),
  //                         // Row(
  //                         //   mainAxisAlignment: MainAxisAlignment.center,
  //                         //   children: [
  //                         //     Card(
  //                         //       // elevation: 10,
  //                         //       color: Colors.green,
  //                         //       child: Padding(
  //                         //         padding: const EdgeInsets.all(5.0),
  //                         //         child: GestureDetector(
  //                         //           onTap: () {
  //                         //             Navigator.pop(context);
  //                         //             // Navigator.push(
  //                         //             //     context,
  //                         //             //     MaterialPageRoute(
  //                         //             //         builder: (context) => ChatPage(
  //                         //             //             name: item.get("name"),
  //                         //             //             receiverID: item.get("userid"),
  //                         //             //             postType: "services",
  //                         //             //             postTypeID: servItem.id)));
  //                         //           },
  //                         //           child: Row(
  //                         //             children: [
  //                         //               const Icon(
  //                         //                 Icons.handshake,
  //                         //                 color: Colors.white,
  //                         //               ),
  //                         //               Text(
  //                         //                 GlobalVariables.instance.xmlHandler
  //                         //                     .getString('hire'),
  //                         //                 style: const TextStyle(
  //                         //                     color: Colors.white),
  //                         //               ),
  //                         //             ],
  //                         //           ),
  //                         //         ),
  //                         //       ),
  //                         //     ),
  //                         //     //     Card(
  //                         //     //       // elevation: 10,
  //                         //     //       color: Colors.amber[600],
  //                         //     //       child: Padding(
  //                         //     //         padding: const EdgeInsets.all(5.0),
  //                         //     //         child: GestureDetector(
  //                         //     //           onTap: () {
  //                         //     //             // Navigator.pop(context);
  //                         //     //           },
  //                         //     //           child: const Row(
  //                         //     //             children: [
  //                         //     //               Icon(Icons.threesixty_sharp),
  //                         //     //               Text('Counter'),
  //                         //     //             ],
  //                         //     //           ),
  //                         //     //         ),
  //                         //     //       ),
  //                         //     //     ),
  //                         //   ],
  //                         // ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 Card(
  //                   // elevation: 10,
  //                   color: Colors.blue,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(5.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         showDialog(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return AlertDialog(
  //                               title: const Text('User Profile'),
  //                               content: Column(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Center(
  //                                     child: CircleAvatar(
  //                                       radius: 40,
  //                                       backgroundImage: NetworkImage(item.get(
  //                                           'url')), // Replace with your image asset or network URL
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 16),
  //                                   Icon(
  //                                     Icons.person_2_outlined,
  //                                     color: Colors.blueAccent,
  //                                   ),
  //                                   Text('${item.get('name')}'),
  //                                   SizedBox(height: 8),
  //                                   Row(
  //                                     children: [
  //                                       Icon(
  //                                         Icons.house_outlined,
  //                                         color: Colors.blueAccent,
  //                                       ),
  //                                       Text('${item.get('address')}'),
  //                                     ],
  //                                   ),
  //                                   SizedBox(height: 8),
  //                                   Row(
  //                                     children: [
  //                                       Icon(
  //                                         Icons.group_rounded,
  //                                         color: Colors.blueAccent,
  //                                       ),
  //                                       Text(item.get('gender') == 1
  //                                           ? 'Female'
  //                                           : 'Male'),
  //                                     ],
  //                                   ),
  //                                   SizedBox(height: 8),
  //                                   Row(
  //                                     children: [
  //                                       Icon(
  //                                         Icons.abc_outlined,
  //                                         color: Colors.blueAccent,
  //                                       ),
  //                                       Text(item
  //                                           .get('language')
  //                                           .toString()
  //                                           .replaceAll('[', '')
  //                                           .replaceAll(']', '')),
  //                                     ],
  //                                   ),
  //                                 ],
  //                               ),
  //                               actions: [
  //                                 TextButton(
  //                                   onPressed: () {
  //                                     Navigator.of(context).pop();
  //                                   },
  //                                   child: const Text('Close'),
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         );
  //                       },
  //                       child: const Row(
  //                         children: [
  //                           Icon(
  //                             Icons.person_3_rounded,
  //                             color: Colors.white,
  //                           ),
  //                           Text(
  //                             'Profile',
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Card(
  //                   // elevation: 10,
  //                   color: Colors.green,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(5.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) => ChatPage(
  //                                       name: item.get("name"),
  //                                       receiverID: item.get("userid"),
  //                                       postType: "services",
  //                                       postTypeID: servItem.id,
  //                                       readMsg: true,
  //                                     )));
  //                       },
  //                       child: const Row(
  //                         children: [
  //                           Icon(
  //                             Icons.chat,
  //                             color: Colors.white,
  //                           ),
  //                           Text(
  //                             'Chat',
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Card(
  //                   // elevation: 10,
  //                   color: Colors.orange,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(5.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Row(
  //                         children: [
  //                           Icon(Icons.cancel, color: Colors.white),
  //                           Text(
  //                             'Cancel',
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 // TextButton(
  //                 //   onPressed: () {
  //                 //     Navigator.pop(context);
  //                 //   },
  //                 //   child: Row(
  //                 //     children: [const Icon(Icons.chat), Text("chat")],
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return Column(
            children: [
              Container(
                height: screenHeight * 0.80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.blueAccent.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 600),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        ),
                        child: Text(
                          GlobalVariables.instance.userrole == 1
                              ? 'Available Jobs'
                              : 'Available Maids',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _nestedTabController,
                        children: <Widget>[
                          FutureBuilder(
                            future: searchqs,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.80,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final servitem = snapshot.data!.docs[index];
                                    return FutureBuilder(
                                      future:
                                          fetchUserData(servitem.get("userid")),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final item =
                                              snapshot.data!.docs.first;
                                          return GestureDetector(
                                            onTap: () => getServiceDetail(
                                                item, servitem),
                                            child: Card(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              elevation: 8,
                                              shadowColor: Colors.blueAccent
                                                  .withOpacity(0.2),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.9), // Inner glow
                                                                blurRadius: 15,
                                                                spreadRadius:
                                                                    0.1,
                                                              ),
                                                            ],
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 20,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[200],
                                                            foregroundImage: item
                                                                        .get(
                                                                            'url') ==
                                                                    null
                                                                ? AssetImage(
                                                                        "assets/profile.png")
                                                                    as ImageProvider<
                                                                        Object>
                                                                : NetworkImage(
                                                                    item.get(
                                                                        'url')),
                                                          ),
                                                        ),
                                                        // Spacing
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            item.get("name"),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  16, // Initial max font size
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //     height:
                                                        //         4), // Spacing
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .location_pin,
                                                                size: 14,
                                                                color: Colors
                                                                    .blueAccent),
                                                            SizedBox(width: 3),
                                                            Flexible(
                                                              child: Text(
                                                                item.get(
                                                                    "address"),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(
                                                        color:
                                                            Colors.grey[300]),
                                                    // SizedBox(height: 5),
                                                    Text(
                                                      GlobalVariables.instance
                                                                  .userrole ==
                                                              1
                                                          ? GlobalVariables
                                                              .instance
                                                              .xmlHandler
                                                              .getString(
                                                                  'servreq')
                                                          : GlobalVariables
                                                              .instance
                                                              .xmlHandler
                                                              .getString(
                                                                  'servoff'),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                    ),
                                                    // SizedBox(height: 1),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: GlobalVariables
                                                                  .instance
                                                                  .userrole ==
                                                              1
                                                          ? servitem
                                                              .get("services")
                                                              .take(2)
                                                              .map<Widget>(
                                                                  (service) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                2),
                                                                        child:
                                                                            Text(
                                                                          // ignore: prefer_interpolation_to_compose_strings
                                                                          "• " +
                                                                              (GlobalVariables.instance.xmlHandler.getString(service) == '' ? service : GlobalVariables.instance.xmlHandler.getString(service)),
                                                                          style:
                                                                              TextStyle(fontSize: 12),
                                                                        ),
                                                                      ))
                                                              .toList()
                                                          : servitem
                                                              .get("services")
                                                              .keys
                                                              .take(2)
                                                              .map<Widget>(
                                                                  (service) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                2),
                                                                        child:
                                                                            Text(
                                                                          // ignore: prefer_interpolation_to_compose_strings
                                                                          "• " +
                                                                              (GlobalVariables.instance.xmlHandler.getString(service) == '' ? service : GlobalVariables.instance.xmlHandler.getString(service)),
                                                                          style:
                                                                              TextStyle(fontSize: 12),
                                                                        ),
                                                                      ))
                                                              .toList(),
                                                    ),
                                                    if (servitem
                                                            .get('services')
                                                            .length >
                                                        2)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'and more...',
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                        ],
                                                      ),
                                                    // Spacer(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              "Error: ${snapshot.error}",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}",
                                      style: TextStyle(color: Colors.red)),
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });

    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: <Widget>[
    //     TabBar(
    //       controller: _nestedTabController,
    //       dividerColor: Colors.grey,
    //       indicatorSize: TabBarIndicatorSize.tab,
    //       indicator: const BoxDecoration(
    //           border: Border(
    //               left: BorderSide(color: Colors.grey),
    //               top: BorderSide(color: Colors.grey),
    //               right: BorderSide(color: Colors.grey)),
    //           borderRadius: BorderRadius.only(
    //               topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    //           color: Colors.blue,
    //           gradient: LinearGradient(
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               colors: [Colors.lightBlue, Colors.white])),
    //       unselectedLabelColor: Colors.black54,
    //       tabs: [
    //         if (GlobalVariables.instance.urole == 1)
    //           Tab(
    //             text: "Maids(for Home Owners)",
    //           ),
    //         if (GlobalVariables.instance.urole == 2)
    //           Tab(
    //             text: "Job Profiles(For Maids)",
    //           ),
    //       ],
    //     ),
    //     Container(
    //       height: screenHeight * 0.70,
    //       margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
    //       child: TabBarView(
    //         controller: _nestedTabController,
    //         children: <Widget>[
    //           FutureBuilder(
    //               // StreamBuilder(
    //               future: fetchServices(),
    //               // stream: fetchChats(),
    //               builder: (context, snapshot) {
    //                 if (snapshot.hasData) {
    //                   return GridView.builder(
    //                       gridDelegate:
    //                           const SliverGridDelegateWithFixedCrossAxisCount(
    //                               crossAxisCount: 2, childAspectRatio: 0.85),
    //                       shrinkWrap: true,
    //                       itemCount: snapshot.data!.docs.length,
    //                       itemBuilder: (context, index) {
    //                         final servitem = snapshot.data!.docs[index];
    //                         return FutureBuilder(
    //                             future: fetchUserData(servitem.get("userid")),
    //                             builder: (context, snapshot) {
    //                               if (snapshot.hasData) {
    //                                 final item = snapshot.data!.docs.first;
    //                                 return Column(
    //                                   children: [
    //                                     GestureDetector(
    //                                       onTap: () {
    //                                         getServiceDetail(item, servitem);
    //                                       },
    //                                       child: Card(
    //                                         semanticContainer: true,
    //                                         clipBehavior:
    //                                             Clip.antiAliasWithSaveLayer,
    //                                         color: Colors.white,
    //                                         shape: RoundedRectangleBorder(
    //                                           borderRadius:
    //                                               BorderRadius.circular(10.0),
    //                                         ),
    //                                         // elevation: 10,
    //                                         child: GridTile(
    //                                           child: Padding(
    //                                             padding: const EdgeInsets.only(
    //                                                 top: 8.0),
    //                                             child: Column(
    //                                               children: [
    //                                                 CircleAvatar(
    //                                                   foregroundImage: item
    //                                                               .get('url') ==
    //                                                           null
    //                                                       ? const AssetImage(
    //                                                               "assets/profile.png")
    //                                                           as ImageProvider<
    //                                                               Object>
    //                                                       : NetworkImage(
    //                                                           item.get('url')),
    //                                                 ),
    //                                                 Text(item.get("name")),
    //                                                 Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment
    //                                                           .center,
    //                                                   children: [
    //                                                     const Icon(
    //                                                       Icons.location_pin,
    //                                                       size: 15,
    //                                                     ),
    //                                                     Text(item
    //                                                         .get("address")),
    //                                                   ],
    //                                                 ),
    //                                                 Text(
    //                                                     GlobalVariables.instance.xmlHandler.getString(
    //                                                         'servoff'),
    //                                                     style: TextStyle(
    //                                                         fontWeight:
    //                                                             FontWeight
    //                                                                 .bold)),
    //                                                 for (var a in servitem
    //                                                     .get("services"))
    //                                                   Text(GlobalVariables.instance.xmlHandler
    //                                                       .getString(a)),
    //                                                 // Text(
    //                                                 //     servitem.get("services")
    //                                                 //         as String),
    //                                                 Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment.end,
    //                                                   children: [
    //                                                     IconButton(
    //                                                       onPressed: () async {
    //                                                         Navigator.push(
    //                                                             context,
    //                                                             MaterialPageRoute(
    //                                                                 builder: (context) => ChatPage(
    //                                                                     name: item.get(
    //                                                                         "name"),
    //                                                                     receiverID:
    //                                                                         item.get(
    //                                                                             "userid"),
    //                                                                     postType:
    //                                                                         "services",
    //                                                                     postTypeID:
    //                                                                         servitem.id)));
    //                                                       },
    //                                                       icon: const Icon(Icons
    //                                                           .chat_rounded),
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 );
    //                               } else if (snapshot.hasError) {
    //                                 return Center(
    //                                     child: Text(snapshot.error.toString()));
    //                               } else {
    //                                 return const Center(
    //                                   child: CircularProgressIndicator(),
    //                                 );
    //                               }
    //                             });
    //                       });
    //                   // return ListView.builder(
    //                   //     shrinkWrap: true,
    //                   //     itemCount: snapshot.data!.docs.length,
    //                   //     itemBuilder: (context, index) {
    //                   //       final servitem = snapshot.data!.docs[index];
    //                   //       // print("Service ID: ${servitem.id}");
    //                   //       return FutureBuilder(
    //                   //           future:
    //                   //               fetchUserData(servitem.get("userid")),
    //                   //           builder: (context, snapshot) {
    //                   //             if (snapshot.hasData) {
    //                   //               final item = snapshot.data!.docs.first;
    //                   //               return Column(
    //                   //                 children: [
    //                   //                   GestureDetector(
    //                   //                     onTap: () {
    //                   //                       getServiceDetail(
    //                   //                           item, servitem);
    //                   //                     },
    //                   //                     child: Card(
    //                   //                       semanticContainer: true,
    //                   //                       clipBehavior:
    //                   //                           Clip.antiAliasWithSaveLayer,
    //                   //                       color: Colors.white,
    //                   //                       shape: RoundedRectangleBorder(
    //                   //                         borderRadius:
    //                   //                             BorderRadius.circular(
    //                   //                                 10.0),
    //                   //                       ),
    //                   //                       // elevation: 10,
    //                   //                       child: ListTile(
    //                   //                         leading: CircleAvatar(
    //                   //                           foregroundImage:
    //                   //                               NetworkImage(AuthMethods
    //                   //                                       .user
    //                   //                                       ?.photoURL ??
    //                   //                                   ''),
    //                   //                         ),
    //                   //                         title: Text(item.get("name")),
    //                   //                         subtitle: Row(
    //                   //                           children: [
    //                   //                             const Icon(
    //                   //                               Icons.location_pin,
    //                   //                               size: 15,
    //                   //                             ),
    //                   //                             Text(item.get("address")),
    //                   //                           ],
    //                   //                         ),
    //                   //                         trailing: Row(
    //                   //                           mainAxisSize:
    //                   //                               MainAxisSize.min,
    //                   //                           children: [
    //                   //                             IconButton(
    //                   //                               onPressed: () async {
    //                   //                                 Navigator.push(
    //                   //                                     context,
    //                   //                                     MaterialPageRoute(
    //                   //                                         builder: (context) => ChatPage(
    //                   //                                             name: item
    //                   //                                                 .get(
    //                   //                                                     "name"),
    //                   //                                             receiverID:
    //                   //                                                 item.get(
    //                   //                                                     "userid"),
    //                   //                                             postType:
    //                   //                                                 "services",
    //                   //                                             postTypeID:
    //                   //                                                 servitem
    //                   //                                                     .id)));
    //                   //                               },
    //                   //                               icon: const Icon(
    //                   //                                   Icons.chat_rounded),
    //                   //                             ),
    //                   //                           ],
    //                   //                         ),
    //                   //                       ),
    //                   //                     ),
    //                   //                   ),
    //                   //                 ],
    //                   //               );
    //                   //             } else if (snapshot.hasError) {
    //                   //               return Center(
    //                   //                   child: Text(
    //                   //                       snapshot.error.toString()));
    //                   //             } else {
    //                   //               return const Center(
    //                   //                 child: CircularProgressIndicator(),
    //                   //               );
    //                   //             }
    //                   //           });
    //                   //     });
    //                 } else if (snapshot.hasError) {
    //                   return Center(child: Text(snapshot.error.toString()));
    //                 } else {
    //                   return const Center(
    //                     child: CircularProgressIndicator(),
    //                   );
    //                 }
    //               }),
    //           Container(
    //             // decoration: BoxDecoration(
    //             //   borderRadius: BorderRadius.circular(8.0),
    //             //   color: Colors.blueGrey[300],
    //             // ),
    //             child: const Text("Job Profiles"),
    //           ),
    //         ],
    //       ),
    //     )
    //   ],
    // );
  }
}
