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
import 'package:shared_preferences/shared_preferences.dart';

class LandingHomePage extends StatefulWidget {
  final String? uname;

  const LandingHomePage({super.key, @required this.uname});

  @override
  State<LandingHomePage> createState() => _LandingHomePageState();
}

late Future<QuerySnapshot> aqs, searchqs;
int searchCriteria = 1;
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

  QuerySnapshot qs = await maidDao().getAllServices(userID);

  return qs;
}

Future<QuerySnapshot> fetchJobProfiles() async {
  String userID = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot qs = await maidDao().getAllJobProfiles(userID);
  return qs;
}

class _LandingHomePageState extends State<LandingHomePage> {
  bool _showOnboarding = true;

  // Search related states
  SearchController _searchController = SearchController();
  String searchText = "Search by Address...";
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      setState(() {});
    });
    _initializeNotifications();
    updateSearchqs(); // Initialize aqs and searchqs for LandingHomePage
  }

  Future<void> _checkFirstTime() async {
    // Check if user is new for onboarding
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time_landing') ??
        true; // Use a different key for LandingHomePage
    if (isFirstTime) {
      setState(() => _showOnboarding = true);
      await prefs.setBool('first_time_landing', false);
    }
  }

  void _initializeNotifications() {
    _notificationService.requestPermission();
    _notificationService.setFCMToken();
    _notificationService.listenToForegroundMessages();
    _notificationService.handleNotificationClicks();
  }

  Widget _buildOnboardingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore,
                size: 60,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Your Dashboard!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Here you can:\n• Browse and filter service providers\n• Chat with potential hires\n• Manage your profile\n• Post job requirements', // This text should probably be adjusted based on the role using LandingHomePage
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _showOnboarding = false),
                child: const Text('Got it!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent,
            Colors.cyan,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 18, // Slightly larger for impact
                        fontWeight: FontWeight.w800, // Make it bolder
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing:
                            1, // Increase letter spacing for a modern, airy feel
                        shadows: [
                          // Add a subtle text shadow
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(
                                0.4), // Darker shadow for definition
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.uname ?? 'User',
                      style: TextStyle(
                        fontSize: 22, // Slightly larger for impact
                        fontWeight: FontWeight.bold, // Make it bolder
                        color: Colors.white,
                        letterSpacing:
                            1.2, // Increase letter spacing for a modern, airy feel
                        shadows: [
                          // Add a subtle text shadow
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(
                                0.4), // Darker shadow for definition
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => setState(() => _showOnboarding = true),
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Modern search bar with filter dropdown
          SearchAnchor(
            searchController: _searchController,
            builder: (BuildContext context, SearchController controller) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: MediaQuery.of(context).size.height / 18,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  color: Colors.lightBlue[100], // ✅ Set light blue background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SearchBar(
                  textStyle: WidgetStateProperty.all(
                    TextStyle(color: Colors.black87),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors
                      .lightBlue[100]), // ✅ Match SearchBar with container
                  controller: controller,
                  hintText: searchText,
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(
                        color:
                            Colors.black54), // Make hint more visible on blue
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onTap: () {},
                  onChanged: (_) {
                    updateServiceList(controller.text);
                  },
                  leading: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.search,
                      key: ValueKey<bool>(true),
                      color: Colors.black54, // Slightly darker for contrast
                    ),
                  ),
                  trailing: <Widget>[
                    PopupMenuButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.black54,
                      ),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: "Address",
                            child: Text(GlobalVariables.instance.xmlHandler
                                .getString('sbyadd')),
                            onTap: () {
                              setState(() {
                                searchText =
                                    "${GlobalVariables.instance.xmlHandler.getString('sbyadd')}...";
                                searchCriteria = 1;
                                updateServiceList(_searchController.text);
                              });
                            },
                          ),
                          PopupMenuItem(
                            value: "Name",
                            child: Text(GlobalVariables.instance.xmlHandler
                                .getString('sbyname')),
                            onTap: () {
                              setState(() {
                                searchText =
                                    "${GlobalVariables.instance.xmlHandler.getString('sbyname')}...";
                                searchCriteria = 2;
                                updateServiceList(_searchController.text);
                              });
                            },
                          ),
                          PopupMenuItem(
                            value: "Service",
                            child: Text(GlobalVariables.instance.xmlHandler
                                .getString('sbyserv')),
                            onTap: () {
                              setState(() {
                                searchText =
                                    "${GlobalVariables.instance.xmlHandler.getString('sbyserv')}...";
                                searchCriteria = 3;
                                updateServiceList(_searchController.text);
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
              return List<ListTile>.generate(0, (int index) {
                return ListTile(); // No suggestions yet
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return Stack(
            // Changed from ListView to Stack
            children: <Widget>[
              // Main content of the LandingHomePage
              Positioned.fill(
                child: Column(
                  children: [
                    _buildModernHeader(),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      // Added Expanded to make NestedTabBar take available space
                      child: NestedTabBar(refreshCallback: () {
                        setState(() {});
                      }),
                    ),
                  ],
                ),
              ),
              // Onboarding overlay
              if (_showOnboarding)
                Positioned.fill(
                  // Added Positioned.fill to make it cover the entire stack
                  child: _buildOnboardingOverlay(),
                ),
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
        futures = s.docs.map((i) {
          return fetchUserData(i.get('userid')).then((QuerySnapshot temp) {
            List<QueryDocumentSnapshot> userDocs = temp.docs.where((doc) {
              return doc[searchBy]
                  .toString()
                  .toLowerCase()
                  .contains(searchVal.toLowerCase());
            }).toList();

            filteredRes.addAll(userDocs);
          });
        }).toList();
        Future<QuerySnapshot> usr;
        Future.wait(futures).then((_) {
          usr = Future.value(MockQuerySnapshot(filteredRes));

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
        }).catchError((e) {
          print('Error in fetchUserData: $e');
        });
      } else {
        List<String> usrServices = [];
        List<QueryDocumentSnapshot> userDocs = s.docs.where((doc) {
          bool flg = false;
          List<dynamic> size;
          if (GlobalVariables.instance.userrole == 1) {
            size = doc[searchBy];
          } else {
            size = doc[searchBy].keys.toList();
          }
          for (int j = 0; j < size.length; j++) {
            flg = false;

            if (size[j]
                .toString()
                .toLowerCase()
                .trim()
                .contains(searchVal.toLowerCase().trim())) {
              usrServices.add(size[j]);
              flg = true;
              break;
            }
          }
          return flg;
        }).toList();

        filteredRes.addAll(userDocs);
        Future<QuerySnapshot> finalres =
            Future.value(MockQuerySnapshot(filteredRes));
        finalres.then((data) {
          for (var i in data.docs) {
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
      }
    }).catchError((e) {
      print('Error in aqs.then: $e');
    });
    // Removed direct NestedTabBar call here as it's part of the build method
  }
}

class MockQuerySnapshot implements QuerySnapshot<Object?> {
  @override
  final List<QueryDocumentSnapshot<Object?>> docs;

  MockQuerySnapshot(this.docs);

  @override
  List<DocumentChange<Object?>> get docChanges => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
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
                                ? skillsWithNames.firstWhere(
                                    (s) => s[0] == skill,
                                    orElse: () =>
                                        ['', skill])[1] // Fallback if not found
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

  Future<void> fetchSkills(thisid) async {
    try {
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection("users")
          .where("userid", isEqualTo: thisid)
          .get();
      String myid = querySnapshot1.docs.first.id;
      CollectionReference skillsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .collection('skills');

      QuerySnapshot querySnapshot = await skillsCollection.get();

      final sc = FirebaseFirestore.instance.collection('skills');
      final qs = await sc.get();

      skillsWithNames = qs.docs.map((doc) {
        return [doc.id, doc[GlobalVariables.instance.selected]];
      }).toList();
      setState(() {
        myskills = querySnapshot.docs.map((doc) => doc.id).toList();
        skillsWithScores = querySnapshot.docs.map((doc) {
          return {
            'skill': doc.id,
            'score': doc['score'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  String getSkillName(String sName) {
    String s = sName;
    for (var skill in skillsWithNames) {
      if (skill[1] == sName) {
        s = skill[0];
      }
    }
    return s;
  }

  bool checkVerified(String skil) {
    bool res = true;
    for (var s in skillsWithScores) {
      if (s['skill'] == skil && s['score'] == -1) {
        res = false;
      }
    }
    return res;
  }

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

  Widget showWorkHistory(String id) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('acknowledgements')
          .where('receiverid', isEqualTo: id)
          .where('status', isEqualTo: 5)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No work history yet.',
              style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
          );
        }

        final workHistoryDocs = snapshot.data!.docs;
        final userIds =
            workHistoryDocs.map((doc) => doc['userid'] as String).toSet();

        return FutureBuilder<Map<String, String>>(
          future: _getUsernamesMap(userIds),
          builder: (context, nameSnapshot) {
            if (!nameSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final namesMap = nameSnapshot.data!;
            final dateFormat = DateFormat('dd MMM yyyy');

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GlobalVariables.instance.xmlHandler.getString('workhist'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...workHistoryDocs.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final data = entry.value.data() as Map<String, dynamic>;
                      final userId = data['userid'];
                      final start =
                          (data['period']['start'] as Timestamp).toDate();
                      final end = (data['period']['end'] as Timestamp).toDate();
                      final services =
                          List<String>.from(data['services'] ?? []);
                      final employerName = namesMap[userId] ?? 'Unknown';

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$index. ${GlobalVariables.instance.xmlHandler.getString('employedby')} $employerName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.date_range,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${GlobalVariables.instance.xmlHandler.getString('start')}: ${dateFormat.format(start)}',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.event,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${GlobalVariables.instance.xmlHandler.getString('end')}: ${dateFormat.format(end)}',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                GlobalVariables.instance.xmlHandler
                                    .getString('serv'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 6.0,
                                children: services.map((service) {
                                  return Chip(
                                    label: Text(service),
                                    backgroundColor: Colors.indigo[50],
                                    labelStyle: TextStyle(
                                      color: Colors.blueAccent.shade700,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _getUsernamesMap(Set<String> userIds) async {
    Map<String, String> nameMap = {};
    for (String userId in userIds) {
      final name = await getNameFromId(userId);
      nameMap[userId] = name;
    }
    return nameMap;
  }

  List<String> getDays(all) {
    List<String> res = [];
    for (var i in all) {
      res.add(GlobalVariables.instance.xmlHandler.getString(i));
    }
    return res;
  }

  Widget buildTextInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueAccent.shade700),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildServiceSection(String label, Map<String, dynamic> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent.shade700),
          ),
          ...services.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(
                '${(GlobalVariables.instance.xmlHandler.getString(entry.key) == '' ? entry.key : GlobalVariables.instance.xmlHandler.getString(entry.key))}: \$${entry.value}',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildSection(String label, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent.shade700),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: items.map((item) {
              return Chip(
                label: Text(
                  (GlobalVariables.instance.xmlHandler.getString(item) == ''
                          ? item
                          : GlobalVariables.instance.xmlHandler.getString(item))
                      .capitalize(),
                  style: TextStyle(fontSize: 14),
                ),
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                labelStyle: TextStyle(color: Colors.blueAccent.shade700),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildImageSection(List<dynamic> imageUrls, BuildContext context) {
    if (imageUrls.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          GlobalVariables.instance.xmlHandler.getString('images'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueAccent.shade700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100, // Fixed height for image scroll view
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrls[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  getServiceDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
          return FadeInLeft(
              duration: Duration(milliseconds: 300),
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
                      buildTextInfo(
                          GlobalVariables.instance.xmlHandler.getString('nam'),
                          item.get("name")),
                      buildTextInfo(
                          GlobalVariables.instance.xmlHandler.getString('addr'),
                          item.get("address")),
                      buildTextInfo(
                        GlobalVariables.instance.xmlHandler
                            .getString('postedon'),
                        DateFormat('dd MMM yyyy').format(
                            (servItem.get("timestamp") as Timestamp).toDate()),
                      ),
                      buildScheduleSection(
                          GlobalVariables.instance.xmlHandler
                              .getString('sched'),
                          servItem.get("schedule")),
                      GlobalVariables.instance.userrole == 2
                          ? buildServiceSection(
                              GlobalVariables.instance.xmlHandler
                                  .getString('serv'),
                              servItem.get("services"))
                          : buildSection(
                              GlobalVariables.instance.xmlHandler
                                  .getString('serv'),
                              servItem.get("services")),
                      if (GlobalVariables.instance.userrole == 1 &&
                          servItem.get('imageurl') != null &&
                          (servItem.get('imageurl') as List).isNotEmpty)
                        buildImageSection(servItem.get('imageurl'), context),
                      buildSection(
                          GlobalVariables.instance.xmlHandler
                              .getString('timing'),
                          servItem.get("timing")),
                      buildSection(
                          GlobalVariables.instance.xmlHandler.getString('day'),
                          getDays(servItem.get("days"))),
                      buildTextInfo(
                          GlobalVariables.instance.xmlHandler.getString('nego'),
                          GlobalVariables.instance.xmlHandler.getString(servItem
                              .get("negotiable")
                              .toString()
                              .toLowerCase())),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Card(
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: PreferredSize(
                                      preferredSize: const Size.fromHeight(60),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.teal,
                                              Colors.blueAccent
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: AppBar(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          title: const Text(
                                            'Profile',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          centerTitle: true,
                                          leading: IconButton(
                                            icon: const Icon(
                                                Icons
                                                    .arrow_back_ios_new_rounded,
                                                color: Colors.white),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    body: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Hero(
                                            tag:
                                                'profile-${item.get('userid')}',
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.9),
                                                    blurRadius: 15,
                                                    spreadRadius: 0.1,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 70,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                foregroundImage: item
                                                            .get('url') ==
                                                        null
                                                    ? const AssetImage(
                                                            "assets/profile.png")
                                                        as ImageProvider<Object>
                                                    : NetworkImage(
                                                        item.get('url')),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            item.get('name'),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildIconText(Icons.house_outlined,
                                              item.get('address')),
                                          _buildIconText(
                                            Icons.group_rounded,
                                            item.get('gender') == 1
                                                ? 'Female'
                                                : 'Male',
                                          ),
                                          _buildIconText(Icons.date_range,
                                              item.get('dob')),
                                          _buildIconText(
                                            Icons.abc,
                                            item
                                                .get('language')
                                                .toString()
                                                .replaceAll('[', '')
                                                .replaceAll(']', ''),
                                          ),
                                          if (item
                                                  .data()
                                                  .containsKey('rating') &&
                                              item.get('rating') is Map)
                                            _buildAverageRating(
                                                item.get('rating')),
                                          if (GlobalVariables
                                                  .instance.userrole ==
                                              2)
                                            showSkills(item.get('userid')),
                                          if (GlobalVariables
                                                  .instance.userrole ==
                                              2)
                                            showWorkHistory(item.get('userid')),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
                    ],
                  ),
                ],
              ));
        });
  }

  Widget _buildAverageRating(Map<String, dynamic> ratings) {
    if (ratings.isEmpty) return SizedBox();

    List<int> ratingValues = ratings.values.map((r) => r as int).toList();
    double avgRating =
        ratingValues.reduce((a, b) => a + b) / ratingValues.length;
    int serviceCount = ratingValues.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_border_purple500, color: Colors.blueAccent),
            SizedBox(width: 5),
            Text("Average Rating: ${avgRating.toStringAsFixed(2)}"),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < avgRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
            "${GlobalVariables.instance.xmlHandler.getString('servcomp')} $serviceCount",
            style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.465,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
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
                              ? GlobalVariables.instance.xmlHandler
                                  .getString('availjob')
                              : GlobalVariables.instance.xmlHandler
                                  .getString('availmaid'),
                          style: TextStyle(
                            fontSize: 20, // Slightly larger for impact
                            fontWeight: FontWeight.w800, // Make it bolder
                            color: Colors.white,
                            letterSpacing:
                                1.2, // Increase letter spacing for a modern, airy feel
                            shadows: [
                              // Add a subtle text shadow
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(
                                    0.4), // Darker shadow for definition
                              ),
                            ],
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
                                                                        0.9),
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
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
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
  }
}
