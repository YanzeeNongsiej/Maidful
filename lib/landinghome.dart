import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/chatpage.dart';

import 'package:ibitf_app/singleton.dart';

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

class _LandingHomePageState extends State<LandingHomePage> {
  String searchText = "Search by Address...";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      setState(() {});
    });
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
                  padding: const EdgeInsets.all(8.0),
                  child: SearchAnchor(
                      builder: (BuildContext context, SearchController sCont) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                      child: SearchBar(
                        controller: sCont,
                        hintText: searchText,
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.only(left: 8.0)),
                        onTap: () {
                          // controller.openView();
                        },
                        onChanged: (_) {
                          updateServiceList(sCont.text);
                          // controller.openView();
                        },
                        leading: const Icon(Icons.search),
                        trailing: <Widget>[
                          PopupMenuButton(
                            icon: const Icon(
                              Icons.list,
                            ),
                            // onSelected: handleClick,
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: "Logout",
                                  child: const Text("Search by Address"),
                                  onTap: () {
                                    setState(() {
                                      searchText = "Search by Address...";
                                      searchCriteria = 1;
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  value: "Settings",
                                  child: Text("Search by Name"),
                                  onTap: () {
                                    setState(() {
                                      searchText = "Search by Name...";
                                      searchCriteria = 2;
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  value: "Contact",
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
                        //old
                        // <Widget>[
                        //   Tooltip(
                        //     message: 'Search options',
                        //     child: IconButton(
                        //       isSelected: isDark,
                        //       onPressed: () {
                        //         print("Search options");

                        //         // setState(() {
                        //         //   isDark = !isDark;
                        //         // });
                        //       },
                        //       icon: const Icon(
                        //         Icons.list,
                        //       ),
                        //       // selectedIcon:
                        //       //     const Icon(Icons.brightness_2_outlined),
                        //     ),
                        //   )
                        // ],
                      ),
                    );
                  }, suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                    return List<ListTile>.generate(5, (int index) {
                      final String item = 'item $index';
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            controller.closeView(item);
                          });
                        },
                      );
                    });
                  })),

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
      var futures;
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
    if (GlobalVariables.instance.urole == 2) {
      aqs = fetchServices();
    } else if (GlobalVariables.instance.urole == 1) {
      aqs = fetchJobProfiles();
    }
    searchqs = aqs;
    aqs.then((QuerySnapshot s) {
      for (var i in s.docs) {
        print(i.get("userid"));
      }
    });
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

  void _onServiceListUpdated() {
    setState(() {
      // You can update your state here.
      print("Service list updated, now calling setState!");
    });
  }

  Widget showSkills(thisid) {
    return FutureBuilder<void>(
      future: fetchSkills(thisid), // Wait for fetchSkills to complete
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While fetchSkills is running, show a loading spinner
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle any errors from fetchSkills
          return Text('Error: ${snapshot.error}');
        }

        // After fetchSkills completes, return the actual widget
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.align_vertical_center,
                  color: Colors.blueAccent,
                ),
                Text(
                  GlobalVariables.instance.xmlHandler.getString('skills'),
                ),
              ],
            ),
            children: [
              if (selectedskills == null && myskills.isEmpty)
                Text(GlobalVariables.instance.xmlHandler.getString('noskills')),
              if (selectedskills == null && myskills.isNotEmpty)
                createSkillsFirst(myskills),
              if (selectedskills != null && myskills.isNotEmpty)
                Column(
                  children: [
                    createSkillsFirst(myskills),
                    createSkillsFirst(selectedskills!.toList()),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

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

  Color _getColor(double level) {
    if (level >= 75) {
      return Colors.green; // High skill
    } else if (level >= 50) {
      return Colors.orange; // Medium skill
    } else {
      return Colors.red; // Low skill
    }
  }

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

  Widget showLevels(currentSkill) {
    double level = 0;
    int res = 0;
    for (var s in skillsWithScores) {
      if (s['skill'] == currentSkill) {
        res = s['score'];
        // Return the score if found
      }
      level = res.toDouble().abs();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Container(
                width:
                    level * 1.5, // Scale the width according to level (0-300)
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _getColor(level),
                ),
              ),
              Center(
                child: Text(
                  '${level.toInt()}%',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createSkillsFirst(List<String> res) {
    return SingleChildScrollView(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Removes the divider line
        ),
        child: Column(
          children: res.map((skill) {
            // print("My skills is:$myskills");
            // print("Current skill is$skill");
            // print("$skillsWithScores is skills with scores");
            // print(
            //     "Is that skill in myskills?:${myskills.contains(getSkillName(skill))}");
            // print(
            //     "Myskills is $myskills and this skill is $skill and getskillname is ${skillsWithNames}");

            return ListTile(
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.all(0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      skill == getSkillName(skill)
                          ? skillsWithNames.firstWhere((s) => s[0] == skill)[1]
                          : skill,
                    ),
                  ),
                  myskills.contains(getSkillName(skill)) && checkVerified(skill)
                      ? showLevels(getSkillName(skill))
                      : Text('Unverified'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  getServiceDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
          Map<String, dynamic> time = servItem.get('timing');
          List<String> allShifts = [];
          time.forEach((key, value) {
            if (value is List<dynamic>) {
              allShifts.addAll(value.map((e) => e.toString()));
            }
          });
          return AlertDialog(
            scrollable: true,
            insetPadding: const EdgeInsets.only(left: 8, right: 8),
            title: Text(
                GlobalVariables.instance.xmlHandler.getString('maiddetails'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('nam'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("name")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('addr'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("address")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('sched'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(GlobalVariables.instance.xmlHandler
                            .getString(servItem.get("schedule"))),
                      ],
                    ),
                    if (servItem.get("schedule") == 'Hourly')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('day'),
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
                                    child: Text(GlobalVariables
                                        .instance.xmlHandler
                                        .getString(servItem.get("days")[i])),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    if (servItem.get("schedule") == 'Daily' ||
                        servItem.get("schedule") == 'Hourly')
                      Column(children: [
                        Row(children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('timing'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text.rich(TextSpan(
                                children: <InlineSpan>[
                                  ...List.generate(
                                    (allShifts.length / 2).ceil(),
                                    (i) => TextSpan(
                                      text:
                                          'Shift ${i + 1} : ${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                            ),
                          ],
                        )
                      ]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('serv'),
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
                                  child: Text(GlobalVariables
                                      .instance.xmlHandler
                                      .getString(servItem.get("services")[i])),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('workhist'),
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
                              Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('wage'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString(servItem.get("wage")),
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
                                          GlobalVariables.instance.xmlHandler
                                              .getString('hire'),
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
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('User Profile'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(item.get(
                                              'url')), // Replace with your image asset or network URL
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_2_outlined,
                                            color: Colors.blueAccent,
                                          ),
                                          Text('${item.get('name')}'),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.house_outlined,
                                            color: Colors.blueAccent,
                                          ),
                                          Text('${item.get('address')}'),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.group_rounded,
                                            color: Colors.blueAccent,
                                          ),
                                          Text(item.get('gender') == 1
                                              ? 'Female'
                                              : 'Male'),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            color: Colors.blueAccent,
                                          ),
                                          Text('${item.get('dob')}'),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.abc_outlined,
                                            color: Colors.blueAccent,
                                          ),
                                          Text(item
                                              .get('language')
                                              .toString()
                                              .replaceAll('[', '')
                                              .replaceAll(']', '')),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(height: 8),
                                      showSkills(item.get('userid')),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
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

  getJobProfileDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
          Map<String, dynamic> time = servItem.get('timing');
          List<String> allShifts = [];
          time.forEach((key, value) {
            if (value is List<dynamic>) {
              allShifts.addAll(value.map((e) => e.toString()));
            }
          });
          return AlertDialog(
            scrollable: true,
            insetPadding: const EdgeInsets.only(left: 8, right: 8),
            title: Text(
                GlobalVariables.instance.xmlHandler.getString('maiddetails'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('nam'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("name")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('addr'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.get("address")),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('sched'),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(GlobalVariables.instance.xmlHandler
                            .getString(servItem.get("schedule"))),
                      ],
                    ),
                    if (servItem.get("schedule") == 'Hourly')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('day'),
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
                                    child: Text(GlobalVariables
                                        .instance.xmlHandler
                                        .getString(servItem.get("days")[i])),
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
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('timing'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text.rich(TextSpan(
                            children: <InlineSpan>[
                              ...List.generate(
                                (allShifts.length / 2).ceil(),
                                (i) => TextSpan(
                                  text:
                                      '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('serv'),
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
                                  child: Text(GlobalVariables
                                      .instance.xmlHandler
                                      .getString(servItem.get("services")[i])),
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
                              Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('wage'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString(servItem.get("wage")),
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
                                          GlobalVariables.instance.xmlHandler
                                              .getString('hire'),
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
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('User Profile'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(item.get(
                                            'url')), // Replace with your image asset or network URL
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Icon(
                                      Icons.person_2_outlined,
                                      color: Colors.blueAccent,
                                    ),
                                    Text('${item.get('name')}'),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.house_outlined,
                                          color: Colors.blueAccent,
                                        ),
                                        Text('${item.get('address')}'),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.group_rounded,
                                          color: Colors.blueAccent,
                                        ),
                                        Text(item.get('gender') == 1
                                            ? 'Female'
                                            : 'Male'),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.abc_outlined,
                                          color: Colors.blueAccent,
                                        ),
                                        Text(item
                                            .get('language')
                                            .toString()
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
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

    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return Column(
            children: [
              if (GlobalVariables.instance.urole == 2)
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(color: Colors.grey),
                            top: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey)),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.blue,
                        // gradient: LinearGradient(
                        //     begin: Alignment.topCenter,
                        //     end: Alignment.bottomCenter,
                        //     colors: [Colors.lightBlueAccent, Colors.white]
                        //     ),
                      ),
                      child: Center(
                        child: Text(
                          'Available Services(Maids)',
                          style: TextStyle(fontSize: 15, color: Colors.white
                              // fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                    Container(
                        height: screenHeight * 0.70,
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 10.0),
                        child: TabBarView(
                            controller: _nestedTabController,
                            children: <Widget>[
                              FutureBuilder(
                                  // StreamBuilder(
                                  // future: fetchServices(),
                                  // stream: fetchChats(),
                                  future: searchqs,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.85),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final servitem =
                                                snapshot.data!.docs[index];
                                            return FutureBuilder(
                                                future: fetchUserData(
                                                    servitem.get("userid")),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final item = snapshot
                                                        .data!.docs.first;
                                                    return Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            getServiceDetail(
                                                                item, servitem);
                                                          },
                                                          child: Card(
                                                            semanticContainer:
                                                                true,
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            color: Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            // elevation: 10,
                                                            child: GridTile(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                child: Column(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      foregroundImage: item.get('url') ==
                                                                              null
                                                                          ? const AssetImage("assets/profile.png") as ImageProvider<
                                                                              Object>
                                                                          : NetworkImage(
                                                                              item.get('url')),
                                                                    ),
                                                                    Text(item.get(
                                                                        "name")),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_pin,
                                                                          size:
                                                                              15,
                                                                        ),
                                                                        Text(item
                                                                            .get("address")),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                        GlobalVariables
                                                                            .instance
                                                                            .xmlHandler
                                                                            .getString(
                                                                                'servoff'),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    for (var a
                                                                        in servitem.get(
                                                                            "services"))
                                                                      Text(GlobalVariables
                                                                          .instance
                                                                          .xmlHandler
                                                                          .getString(
                                                                              a)),
                                                                    // Text(
                                                                    //     servitem.get("services")
                                                                    //         as String),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        IconButton(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => ChatPage(name: item.get("name"), receiverID: item.get("userid"), postType: "services", postTypeID: servitem.id)));
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.chat_rounded),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(snapshot
                                                            .error
                                                            .toString()));
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                });
                                          });
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text(snapshot.error.toString()));
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  })
                            ]))
                  ],
                ),
              if (GlobalVariables.instance.urole == 1)
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(color: Colors.grey),
                            top: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey)),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.blue,
                        // gradient: LinearGradient(
                        //     begin: Alignment.topCenter,
                        //     end: Alignment.bottomCenter,
                        //     colors: [Colors.lightBlueAccent, Colors.white]),
                      ),
                      child: Center(
                        child: Text(
                          'Available Jobs',
                          style: TextStyle(fontSize: 15, color: Colors.white
                              // fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                    Container(
                        height: screenHeight * 0.70,
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 10.0),
                        child: TabBarView(
                            controller: _nestedTabController,
                            children: <Widget>[
                              FutureBuilder(
                                  // StreamBuilder(
                                  future: searchqs,
                                  // stream: fetchChats(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.85),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final servitem =
                                                snapshot.data!.docs[index];
                                            return FutureBuilder(
                                                future: fetchUserData(
                                                    servitem.get("userid")),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final item = snapshot
                                                        .data!.docs.first;
                                                    return Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            getJobProfileDetail(
                                                                item, servitem);
                                                          },
                                                          child: Card(
                                                            semanticContainer:
                                                                true,
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            color: Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            // elevation: 10,
                                                            child: GridTile(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                child: Column(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      foregroundImage: item.get('url') ==
                                                                              null
                                                                          ? const AssetImage("assets/profile.png") as ImageProvider<
                                                                              Object>
                                                                          : NetworkImage(
                                                                              item.get('url')),
                                                                    ),
                                                                    Text(item.get(
                                                                        "name")),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_pin,
                                                                          size:
                                                                              15,
                                                                        ),
                                                                        Text(item
                                                                            .get("address")),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                        GlobalVariables
                                                                            .instance
                                                                            .xmlHandler
                                                                            .getString(
                                                                                'servoff'),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    for (var a
                                                                        in servitem.get(
                                                                            "services"))
                                                                      Text(GlobalVariables
                                                                          .instance
                                                                          .xmlHandler
                                                                          .getString(
                                                                              a)),
                                                                    // Text(
                                                                    //     servitem.get("services")
                                                                    //         as String),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        IconButton(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => ChatPage(name: item.get("name"), receiverID: item.get("userid"), postType: "services", postTypeID: servitem.id)));
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.chat_rounded),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(snapshot
                                                            .error
                                                            .toString()));
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                });
                                          });
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text(snapshot.error.toString()));
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  })
                            ]))
                  ],
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
