import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:ibitf_app/assessment.dart';
import 'package:ibitf_app/DAO/skilldao.dart';
import 'package:ibitf_app/jobprofile.dart';
import 'package:ibitf_app/jobresume.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _downloadUrl;
  String? _myaddr, _mydob, thelangs;
  List<dynamic>? languages;
  String? userDocId;
  DocumentSnapshot? userDoc;
  final ImagePicker _picker = ImagePicker();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  final List<File> _documentImages = [];
  TextEditingController _languageController = TextEditingController();
  final dobcontroller = TextEditingController();
  String? usrname;
  DateTime dt = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  String dte = "Date of birth";
  Color _dobColor = const Color(0xFFb2b7bf);

  List<String>? selectedskills;
  List<String> myskills = [];

  List<int>? myscores;
  List<Map<String, dynamic>> skillsWithScores = [];
  List<List<dynamic>> skillsWithNames = [];
  @override
  void initState() {
    // TODO: implement initState
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      print(GlobalVariables.instance.selected);
      setState(() {});

      usrname = GlobalVariables.instance.username;
    });
    _fetchUserDocId();
    fetchSkills();
    profilepic();
    super.initState();
    GlobalVariables.instance.addListener(fetchSkills);
  }

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
            _myaddr = userDoc?['address'];
            _mydob = userDoc?['dob'];
            languages = userDoc?['language'];

            print("LANGUAGESZ IS:$languages");
          } catch (e) {
            print("No profileimage yet$e");
          } // Fetch the URL field
        });
      }
    }
  }

  AssetImage loadImage() {
    return const AssetImage("assets/profile.png");
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery); // or ImageSource.camera

    if (pickedImage != null) {
      setState(() {
        _documentImages.add(File(pickedImage.path));
      });
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // To disable scrolling inside grid
      itemCount: _documentImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.file(
              _documentImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _documentImages.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget showDocuments() {
    return Card(
      color: Colors.blueAccent[100],
      elevation: 5, // Adding some elevation to the card for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _documentImages.isNotEmpty
                ? _buildGridView()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'No documents uploaded.',
                      textAlign: TextAlign.center,
                    ),
                  ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload),
              label: Text('Upload Document'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserDocId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Query Firestore to get the document ID where 'uid' matches the current user's UID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userid',
              isEqualTo:
                  user.uid) // Assuming you store the UID in each user document
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userDocId = snapshot.docs.first.id; // Store the random document ID
        });
      }
    }
  }

  Widget showSkills() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          title: Text(GlobalVariables.instance.xmlHandler
              .getString('skills')
              .toString()),
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
          ]),
    );

    //
  }

  Future<void> fetchSkills() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Reference to the user's skills subcollection
        QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
            .collection("users")
            .where("userid", isEqualTo: currentUser.uid) // Adjust as needed
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
      } else {
        print('No user is currently logged in.');
        setState(() {
          //isLoading = false; // Update loading state
        });
      }
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
                      : ElevatedButton(
                          onPressed: () {
                            // Add assessment

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      '${GlobalVariables.instance.xmlHandler.getString('assfor')} ${skillsWithNames.firstWhere((s) => s[0] == skill)[1]}'),
                                  content: Text(GlobalVariables
                                      .instance.xmlHandler
                                      .getString('confirmassess')),
                                  actions: [
                                    TextButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.close),
                                        label: Text(GlobalVariables
                                            .instance.xmlHandler
                                            .getString('no'))),
                                    TextButton.icon(
                                      onPressed: () {
                                        // Add your confirm logic here
                                        selectedskills = [];

                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => Assessment(
                                                skillsWithNames.firstWhere(
                                                    (s) => s[0] == skill)[1],
                                                onComplete:
                                                    updateParentState))); // Close the dialog
                                      },
                                      icon: Icon(
                                          Icons.check), // Icon for confirmation
                                      label: Text(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('yes')),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('assessment'),
                          )),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void updateParentState() {
    setState(() {
      fetchSkills();
    });
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

  Future<QuerySnapshot> getActiveServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getActiveServices(userID);
    return qs;
  }

  Widget _buildActiveServiceList() {
    return FutureBuilder(
        future: getActiveServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("loading...");
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Text(
                  GlobalVariables.instance.xmlHandler.getString('noserv'));
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];

                  Map<String, dynamic> time = item.get('timing');
                  List<String> allShifts = [];
                  time.forEach((key, value) {
                    if (value is List<dynamic>) {
                      allShifts.addAll(value.map((e) => e.toString()));
                    }
                  });

                  return SingleChildScrollView(
                    child: Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(TextSpan(
                                        children: <InlineSpan>[
                                          const TextSpan(
                                            text: 'Schedule: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: item.get("schedule"),
                                          ),
                                          const TextSpan(
                                            text: '\nTiming: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          ...List.generate(
                                            (allShifts.length / 2).ceil(),
                                            (i) => TextSpan(
                                              text:
                                                  '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '\nDays: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: item.get("days").toString(),
                                          ),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ))),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.end,

                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Card(
                                    // elevation: 10,
                                    color: Colors.blue,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigator.pop(context);
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => ChatPage(
                                          //             name: item.get("name"),
                                          //             receiverID: item.get("userid"),
                                          //             postType: "services",
                                          //             postTypeID: servItem.id)));
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              'View',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  // return GestureDetector(
                  //   onTap: () => {},
                  //   child: Text(
                  //     item.get("rate"),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // );
                },
              );
            }
          } else {
            return Text(
                GlobalVariables.instance.xmlHandler.getString('noserv'));
          }
        });
  }

  Widget _buildServiceList() {
    return FutureBuilder(
        future: fetchOwnServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Text(
                  GlobalVariables.instance.xmlHandler.getString('noserv'));
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];
                  Map<String, dynamic> time = item.get('timing');
                  List<String> allShifts = [];
                  time.forEach((key, value) {
                    if (value is List<dynamic>) {
                      allShifts.addAll(value.map((e) => e.toString()));
                    }
                  });

                  return Expanded(
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () => {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(TextSpan(
                                      children: <InlineSpan>[
                                        const TextSpan(
                                          text: 'Schedule: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: item.get("schedule"),
                                        ),
                                        const TextSpan(
                                          text: '\nTiming: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ...List.generate(
                                          (allShifts.length / 2).ceil(),
                                          (i) => TextSpan(
                                            text:
                                                '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                        const TextSpan(
                                          text: '\nDays: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: item.get("days").toString(),
                                        ),
                                      ],
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ))),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.end,

                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Card(
                                  // elevation: 10,
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigator.pop(context);
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => ChatPage(
                                        //             name: item.get("name"),
                                        //             receiverID: item.get("userid"),
                                        //             postType: "services",
                                        //             postTypeID: servItem.id)));
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Edit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );

                  // return GestureDetector(
                  //   onTap: () => {},
                  //   child: Text(
                  //     item.get("rate"),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // );
                },
              );
            }
          } else {
            return Text(
                GlobalVariables.instance.xmlHandler.getString('noserv'));
          }
        });
  }

  Widget _buildJobProfileList() {
    return FutureBuilder(
        future: fetchOwnJobProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Text(
                  GlobalVariables.instance.xmlHandler.getString('noserv'));
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];
                  Map<String, dynamic> time = item.get('timing');
                  List<String> allShifts = [];
                  time.forEach((key, value) {
                    if (value is List<dynamic>) {
                      allShifts.addAll(value.map((e) => e.toString()));
                    }
                  });
                  return SingleChildScrollView(
                    child: Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(TextSpan(
                                        children: <InlineSpan>[
                                          const TextSpan(
                                            text: 'Schedule: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: item.get("schedule"),
                                          ),
                                          const TextSpan(
                                            text: '\nTiming: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          ...List.generate(
                                            (allShifts.length / 2).ceil(),
                                            (i) => TextSpan(
                                              text:
                                                  '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '\nDays: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: item.get("days").toString(),
                                          ),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ))),
                                  ],
                                ),
                              ),
                            ),
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
                                        // Navigator.pop(context);
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => ChatPage(
                                        //             name: item.get("name"),
                                        //             receiverID: item.get("userid"),
                                        //             postType: "services",
                                        //             postTypeID: servItem.id)));
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Edit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return Text(
                GlobalVariables.instance.xmlHandler.getString('noserv'));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: GlobalVariables.instance,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _downloadUrl != null
                                    ? NetworkImage(_downloadUrl!)
                                    : loadImage() as ImageProvider<Object>,
                                child: Align(
                                  alignment: Alignment
                                      .bottomRight, // Align icon to bottom right
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Card(
                                      margin: EdgeInsets.all(0),
                                      shape: CircleBorder(),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.grey,
                                          size: 25,
                                        ),
                                        onPressed: () async {
                                          // Your edit action here
                                          ImagePicker picker = ImagePicker();
                                          final XFile? image =
                                              await picker.pickImage(
                                                  source: ImageSource.gallery);
                                          if (image == null) {
                                            return; // No image selected
                                          }

                                          // Upload to Firebase Storage
                                          File file = File(image.path);
                                          try {
                                            String fileName = image.name;
                                            List<String> separate =
                                                fileName.split('.');
                                            String filetype = separate[1];
                                            final ref = FirebaseStorage.instance
                                                .ref()
                                                .child(
                                                    '${GlobalVariables.instance.username}/profile.$filetype');
                                            await ref.putFile(file);
                                            String downloadUrl =
                                                await ref.getDownloadURL();

                                            // Store URL in Firestore

                                            QuerySnapshot querySnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .where("userid",
                                                        isEqualTo: userID)
                                                    .get();

                                            // Check if we found any documents
                                            if (querySnapshot.docs.isNotEmpty) {
                                              // Assuming we want to update the first matching document
                                              DocumentSnapshot userDoc =
                                                  querySnapshot.docs.first;

                                              // Update the document with the new URL
                                              await userDoc.reference.set(
                                                {'url': downloadUrl},
                                                SetOptions(merge: true),
                                              );
                                            }

                                            setState(() {
                                              // Update state with the new URL
                                              _downloadUrl = downloadUrl;
                                            });
                                          } catch (e) {
                                            print('Error $e');
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10, width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_3_rounded,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          usrname ?? "Username",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_sharp,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          _myaddr ?? "Address",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // Use existing username
                                                return AlertDialog(
                                                  scrollable: true,
                                                  titlePadding:
                                                      EdgeInsets.all(0),
                                                  title: Container(
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20))),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.info_outline,
                                                          size: 30,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'User\'s General Info',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  content: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                              GlobalVariables
                                                                  .instance
                                                                  .xmlHandler
                                                                  .getString(
                                                                      'nam'),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text("$usrname"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("Username: ",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              "${userDoc?['username']}"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("Gender: ",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          userDoc?['gender'] ==
                                                                  1
                                                              ? Text("Male")
                                                              : Text("Female"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Date of Birth: ",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              "${userDoc?['dob']}"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              GlobalVariables
                                                                  .instance
                                                                  .xmlHandler
                                                                  .getString(
                                                                      'addr'),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              "${userDoc?['address']}"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("Primary Role: ",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          userDoc?['role'] == 1
                                                              ? Text("Maid")
                                                              : Text(
                                                                  "Home-Owner"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Language known: ",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              "${userDoc?['language'].toString()}"),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close dialog
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                String newaddr = _myaddr
                                                    .toString(); // Use existing username
                                                String newusrname =
                                                    usrname.toString();
                                                String newdob =
                                                    _mydob.toString();
                                                return AlertDialog(
                                                  title: Text('Edit Info'),
                                                  content: StatefulBuilder(
                                                      builder: (context,
                                                          StateSetter
                                                              setState) {
                                                    return SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(GlobalVariables
                                                                  .instance
                                                                  .xmlHandler
                                                                  .getString(
                                                                      'nam')),
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  onChanged:
                                                                      (value) {
                                                                    newusrname =
                                                                        value; // Update username from input
                                                                  },
                                                                  controller:
                                                                      TextEditingController(
                                                                          text:
                                                                              usrname),
                                                                  decoration:
                                                                      InputDecoration(
                                                                          hintText:
                                                                              "Enter new Name"),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(GlobalVariables
                                                                  .instance
                                                                  .xmlHandler
                                                                  .getString(
                                                                      'addr')),
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  onChanged:
                                                                      (value) {
                                                                    newaddr =
                                                                        value; // Update username from input
                                                                  },
                                                                  controller:
                                                                      TextEditingController(
                                                                          text:
                                                                              _myaddr),
                                                                  decoration:
                                                                      InputDecoration(
                                                                          hintText:
                                                                              "Enter new Address"),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Date of Birth:"),
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please Select Date of Birth';
                                                                    }
                                                                    return _mydob;
                                                                  },
                                                                  controller:
                                                                      dobcontroller,

                                                                  onTap: () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text('Select Date of Birth'),
                                                                            content:
                                                                                SizedBox(
                                                                              height: 200,
                                                                              width: 300,
                                                                              child: CupertinoDatePicker(
                                                                                mode: CupertinoDatePickerMode.date,
                                                                                initialDateTime: _mydob == '' ? DateTime.now() : DateTime.parse(_mydob!),
                                                                                onDateTimeChanged: (DateTime newDateTime) {
                                                                                  dt = newDateTime;
                                                                                  dte = dateFormat.format(dt);
                                                                                  dobcontroller.text = dte;
                                                                                  newdob = dobcontroller.text;
                                                                                  _dobColor = const Color.fromARGB(255, 0, 0, 0);
                                                                                  // Do something
                                                                                },
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            FocusNode());
                                                                  },

                                                                  // controller: passwordcontroller,
                                                                  decoration: InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          _mydob,
                                                                      hintStyle: TextStyle(
                                                                          color:
                                                                              _dobColor,
                                                                          fontSize:
                                                                              18.0)),
                                                                  readOnly:
                                                                      true,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            'Languages:',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 100,
                                                            width: 300,
                                                            child: ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  languages
                                                                      ?.length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                String
                                                                    language =
                                                                    languages![
                                                                            index]
                                                                        .toString();
                                                                return ListTile(
                                                                  title: Text(
                                                                      language),
                                                                  trailing:
                                                                      IconButton(
                                                                          icon: Icon(
                                                                              Icons.remove_circle,
                                                                              color: Colors.red),
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              languages?.remove(language);
                                                                            });
                                                                          }),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _languageController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Add a new language',
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  String
                                                                      newLanguage =
                                                                      _languageController
                                                                          .text
                                                                          .trim();
                                                                  if (newLanguage
                                                                          .isNotEmpty &&
                                                                      !languages!
                                                                          .contains(
                                                                              newLanguage)) {
                                                                    setState(
                                                                        () {
                                                                      languages
                                                                          ?.add(
                                                                              newLanguage);
                                                                    });
                                                                    _languageController
                                                                        .clear();
                                                                  }
                                                                },
                                                                child:
                                                                    Text('Add'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text('Save'),
                                                      onPressed: () {
                                                        setState(() {
                                                          _myaddr = newaddr;
                                                          GlobalVariables
                                                                  .instance
                                                                  .username =
                                                              newusrname;
                                                          usrname = newusrname;
                                                          // Update username in UI
                                                          _mydob = newdob;
                                                        });
                                                        if (userDocId!
                                                            .isNotEmpty) {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(userDocId)
                                                              .update({
                                                            'address': newaddr,
                                                            'name': newusrname,
                                                            'dob': newdob,
                                                            'language':
                                                                languages,
                                                          }); // Update Firebase
                                                        }
                                                        Navigator.of(context)
                                                            .pop(); // Close dialog
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //Row(children: [Expanded(child: showDocuments())]),
                if (GlobalVariables.instance.urole == 1)
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.blueAccent[100],
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Expanded(
                              child: Column(
                                children: [
                                  // _buildServiceList(),

                                  showSkills(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Card(
                                        // elevation: 10,
                                        color: Colors.blue,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              List<String> options = [];

                                              // Fetch skills from Firestore
                                              QuerySnapshot snapshot =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('skills')
                                                      .get();

                                              //fetch only skills from the user

                                              print(snapshot.docs.first.id);
                                              // print(myskills);
                                              for (var doc in snapshot.docs) {
                                                // Get the skill for the selected language

                                                if (doc[GlobalVariables.instance
                                                            .selected] !=
                                                        null &&
                                                    !myskills
                                                        .contains(doc.id)) {
                                                  options.add(doc[
                                                      GlobalVariables
                                                          .instance.selected]);
                                                }
                                              }
                                              List<String> selectedOptions = [];

                                              await showDialog<List<String>>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text("Select Options"),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: options
                                                            .map((option) {
                                                          return CheckboxListTile(
                                                            title: Text(option),
                                                            value:
                                                                selectedOptions
                                                                    .contains(
                                                                        option),
                                                            onChanged:
                                                                (bool? value) {
                                                              if (value ==
                                                                  true) {
                                                                selectedOptions
                                                                    .add(
                                                                        option);
                                                              } else {
                                                                selectedOptions
                                                                    .remove(
                                                                        option);
                                                              }
                                                              // Update the UI
                                                              (context
                                                                      as Element)
                                                                  .markNeedsBuild();
                                                            },
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text("Done"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          selectedskills =
                                                              selectedOptions;
                                                          for (var s
                                                              in selectedskills!
                                                                  .toList()) {
                                                            updateScoreToDB(
                                                                GlobalVariables
                                                                    .instance
                                                                    .selected,
                                                                s,
                                                                -1);
                                                          }
                                                          print(
                                                              "Selected skills: $selectedskills");
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ).then((result) {
                                                if (result != null) {
                                                  // Handle the selected options
                                                  print(
                                                      "Selected options: $result");
                                                  selectedskills = result;
                                                }
                                              });
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             const JobResume()));
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  'Add',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.blueAccent[100],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      (GlobalVariables.instance.xmlHandler
                                              .getString('active'))
                                          .toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                    _buildActiveServiceList(),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      if (GlobalVariables.instance.urole == 1)
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.blueAccent[100],
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        ((GlobalVariables.instance.xmlHandler
                                                .getString('myserv'))
                                            .toString()),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      _buildServiceList(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Card(
                                            // elevation: 10,
                                            color: Colors.blue,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const JobResume()));
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Add',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      if (GlobalVariables.instance.urole == 2)
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.blueAccent[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        (GlobalVariables.instance.xmlHandler
                                                .getString('posted'))
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      _buildJobProfileList(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Card(
                                            // elevation: 10,
                                            color: Colors.blue,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const JobProfile()));
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Add',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
