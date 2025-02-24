import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ibitf_app/starrating.dart';
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
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:ibitf_app/rating.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/buildui.dart';
import 'package:ibitf_app/profile1.dart';
import 'package:ibitf_app/profile2.dart';
import 'package:ibitf_app/profile3.dart';

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
  final TextEditingController _languageController = TextEditingController();
  final dobcontroller = TextEditingController();
  String? usrname;
  DateTime dt = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  String dte = "Date of birth";
  Color _dobColor = const Color(0xFFb2b7bf);
  String name = "";
  List<String> allnames = [];
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
    //GlobalVariables.instance.addListener(fetchSkills);
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
                child: LinearPercentIndicator(
                  width: 150,
                  lineHeight: 20,
                  animation: true,
                  animationDuration: 1000,
                  percent: level / 100,
                  center: Text(
                    "${level.toInt()}%",
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: _getColor(level),
                  backgroundColor: Colors.grey[300]!,
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
              dense: true,
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.all(0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    skill == getSkillName(skill)
                        ? skillsWithNames.firstWhere((s) => s[0] == skill)[1]
                        : skill,
                    style: TextStyle(fontSize: 13),
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

  Future<List<String>> getActiveName(String receive) async {
    return await maidDao().getActiveName(receive);
  }

  void completeService(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure you want to complete the service?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the first dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the first dialog
                showCompleteDoneDialog(context, item); // Show the rating dialog
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => CompletionRequestWidget()),
                // );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void showCompleteDoneDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Completion Request Sent!",
                style: TextStyle(
                  fontSize: 18, // Slightly larger font for prominence
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'A completion request has been sent to $name',
                style: TextStyle(
                  fontSize: 14, // Slightly larger font for prominence
                  // Bold text for emphasis
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    notifyUser(item.get('receiver'), "Completion Request",
                        "A completion request was sent by $usrname", item.id);
                    updateStatus(4, item);

                    Navigator.of(context).pop();
                    //status=3 means the completion request has been sent

                    // Close the dialog
                    // showRatingConfirmation(
                    //     context, selectedRating); // Show thank-you message
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  updateStatus(int val, item) {
    FirebaseFirestore.instance
        .collection("acknowledgements")
        .doc(item.id)
        .update({
      "status": val,
    }).whenComplete(() {
      setState(() {});
    });
  }

  // void showRatingConfirmation(BuildContext context, int rating) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Thank you!"),
  //         content:
  //             Text("You rated the maid $rating star${rating > 1 ? 's' : ''}."),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the confirmation dialog
  //               showCompletionRequest(context);
  //             },
  //             child: Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void showCompletionRequest(BuildContext context) {
  //   int punctualityRating = 0, qualityRating = 0, professionalismRating = 0;
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           title: Text("Completion Request"),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Please rate the following:",
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 16),
  //                 _buildRatingRow("Punctuality:", punctualityRating, (rating) {
  //                   setState(() {
  //                     punctualityRating = rating;
  //                   });
  //                 }),
  //                 _buildRatingRow("Quality of Work:", qualityRating, (rating) {
  //                   setState(() {
  //                     qualityRating = rating;
  //                   });
  //                 }),
  //                 _buildRatingRow("Professionalism:", professionalismRating,
  //                     (rating) {
  //                   setState(() {
  //                     professionalismRating = rating;
  //                   });
  //                 }),
  //                 SizedBox(height: 20),
  //                 Text(
  //                   "Write a Review:",
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 8),
  //                 TextField(
  //                   controller: TextEditingController(),
  //                   maxLines: 4,
  //                   decoration: InputDecoration(
  //                     hintText: "Please enter your review",
  //                     border: OutlineInputBorder(),
  //                     contentPadding:
  //                         EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                   ),
  //                 ),
  //                 Text("Reason:"),
  //                 TextField(
  //                   controller: TextEditingController(),
  //                   decoration: InputDecoration(
  //                       hintText: "Please enter a reason",
  //                       border: OutlineInputBorder()),
  //                   style: TextStyle(fontWeight: FontWeight.w300),
  //                 ),
  //                 Text("Feedback:"),
  //                 TextField(
  //                   controller: TextEditingController(),
  //                   decoration: InputDecoration(
  //                       hintText:
  //                           "Please enter a feedback for the Service/Maid",
  //                       border: OutlineInputBorder()),
  //                   style: TextStyle(fontWeight: FontWeight.w300),
  //                   minLines: 3,
  //                   maxLines: 5,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Text(
  //               "*By clicking Submit, the Completion Request will be sent to the respective Maid/Employer for further actions.",
  //               style: TextStyle(fontSize: 12),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 // Close the confirmation dialog
  //               },
  //               child: Text("Submit"),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  Widget _buildActiveServiceList(item) {
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: item.get("schedule"),
                            ),
                            const TextSpan(
                              text: '\nTiming: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...List.generate(
                              (allShifts.length / 2).ceil(),
                              (i) => TextSpan(
                                text:
                                    '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            const TextSpan(
                              text: '\nDays: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: item.get("days").join(', '),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 15,
                          ))),
                    ],
                  ),
                ),
              ),
              if (GlobalVariables.instance.userrole == 2 &&
                  item.get('status') == 2)
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
                              completeService(context, item);
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.done_outline_rounded,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Complete Service',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
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
  }

  Widget _buildServiceList(item) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                buildTextInfo(
                    "Posted on",
                    DateFormat('dd MMM yyyy')
                        .format((item.get("timestamp") as Timestamp).toDate())),
                buildScheduleSection("Schedule", item.get("schedule")),
                buildServiceSection("Services", item.get("services")),
                buildSection("Timing", item.get("timing")),
                buildSection("Days Available", item.get("days")),
                buildTextInfo("Negotiable", item.get("negotiable")),
                buildSection("Work History", item.get("work_history")),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage1(),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.white),
                          const Text('P1',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage2(),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.red[400],
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.white),
                          const Text('P2',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage3(),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.red[400],
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.white),
                          const Text('P3',
                              style: TextStyle(color: Colors.white)),
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
    );
  }

  Widget _buildJobProfileList(item) {
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
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(
                            text: 'Schedule: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.get("schedule")),
                          const TextSpan(
                            text: '\nTiming: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List.generate(
                            (allShifts.length / 2).ceil(),
                            (i) => TextSpan(
                              text:
                                  '${allShifts[i * 2]} - ${allShifts[i * 2 + 1]}\n',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const TextSpan(
                            text: 'Posted on: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: DateFormat('dd-MMM-yyyy')
                                  .format((item.get('timestamp')).toDate())),
                          const TextSpan(
                            text: '\nDays: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.get("days").join(', ')),
                          const TextSpan(
                            text: '\nServices: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.get("services").join(', ')),
                          const TextSpan(
                            text: '\nWage: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.get("wage")),
                          const TextSpan(
                            text: '\nNegotiable: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.get("negotiable")),
                        ],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobResume(2),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.white),
                              const Text('Edit',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _confirmDelete(context, item.id, 'jobprofile');
                      },
                      child: Card(
                        color: Colors.red[400],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.white),
                              const Text('Remove',
                                  style: TextStyle(color: Colors.white)),
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
  }

  void _confirmDelete(BuildContext context, String docId, String kind) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to remove this service?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _removeService(docId, kind);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _removeService(String docId, String kind) {
    FirebaseFirestore.instance.collection(kind).doc(docId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service removed successfully!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
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
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.teal, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
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
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image == null) {
                                    return; // No image selected
                                  }

                                  // Upload to Firebase Storage
                                  File file = File(image.path);
                                  try {
                                    String fileName = image.name;
                                    List<String> separate = fileName.split('.');
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
                                            .where("userid", isEqualTo: userID)
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
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_3_rounded,
                            color: Colors.grey,
                          ),
                          Text(usrname ?? "Not Available",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_sharp,
                            color: Colors.grey,
                          ),
                          Text(
                            _myaddr ?? "Address",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      userDoc?['gender'] == 1
                          ? Text("Gender: Male",
                              style: TextStyle(color: Colors.white70))
                          : Text("Gender: Female",
                              style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Date of Birth: ",
                              style: const TextStyle(color: Colors.white70)),
                          Text("${userDoc?['dob']}",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Languages known: ",
                              style: const TextStyle(color: Colors.white70)),
                          Text("${userDoc?['language'].join(', ')}",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Implement edit profile functionality here
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String newaddr =
                                  _myaddr.toString(); // Use existing username
                              String newusrname = usrname.toString();
                              String newdob = _mydob.toString();
                              return AlertDialog(
                                title: Text('Edit Info'),
                                content: StatefulBuilder(
                                    builder: (context, StateSetter setState) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(GlobalVariables
                                                .instance.xmlHandler
                                                .getString('nam')),
                                            Expanded(
                                              child: TextField(
                                                onChanged: (value) {
                                                  newusrname =
                                                      value; // Update username from input
                                                },
                                                controller:
                                                    TextEditingController(
                                                        text: usrname),
                                                decoration: InputDecoration(
                                                    hintText: "Enter new Name"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(GlobalVariables
                                                .instance.xmlHandler
                                                .getString('addr')),
                                            Expanded(
                                              child: TextField(
                                                onChanged: (value) {
                                                  newaddr =
                                                      value; // Update username from input
                                                },
                                                controller:
                                                    TextEditingController(
                                                        text: _myaddr),
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Enter new Address"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text("Date of Birth:"),
                                            Expanded(
                                              child: TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please Select Date of Birth';
                                                  }
                                                  return _mydob;
                                                },
                                                controller: dobcontroller,

                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Select Date of Birth'),
                                                          content: SizedBox(
                                                            height: 200,
                                                            width: 300,
                                                            child:
                                                                CupertinoDatePicker(
                                                              mode:
                                                                  CupertinoDatePickerMode
                                                                      .date,
                                                              initialDateTime:
                                                                  _mydob == ''
                                                                      ? DateTime
                                                                          .now()
                                                                      : DateTime
                                                                          .parse(
                                                                              _mydob!),
                                                              onDateTimeChanged:
                                                                  (DateTime
                                                                      newDateTime) {
                                                                dt =
                                                                    newDateTime;
                                                                dte = dateFormat
                                                                    .format(dt);
                                                                dobcontroller
                                                                    .text = dte;
                                                                newdob =
                                                                    dobcontroller
                                                                        .text;
                                                                _dobColor =
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0);
                                                                // Do something
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          FocusNode());
                                                },

                                                // controller: passwordcontroller,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: _mydob,
                                                    hintStyle: TextStyle(
                                                        color: _dobColor,
                                                        fontSize: 18.0)),
                                                readOnly: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Languages:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 100,
                                          width: 300,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: languages?.length,
                                            itemBuilder: (context, index) {
                                              String language =
                                                  languages![index].toString();
                                              return ListTile(
                                                title: Text(language),
                                                trailing: IconButton(
                                                    icon: Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      setState(() {
                                                        languages
                                                            ?.remove(language);
                                                      });
                                                    }),
                                              );
                                            },
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _languageController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Add a new language',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                String newLanguage =
                                                    _languageController.text
                                                        .trim();
                                                if (newLanguage.isNotEmpty &&
                                                    !languages!.contains(
                                                        newLanguage)) {
                                                  setState(() {
                                                    languages?.add(newLanguage);
                                                  });
                                                  _languageController.clear();
                                                }
                                              },
                                              child: Text('Add'),
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
                                        GlobalVariables.instance.username =
                                            newusrname;
                                        usrname = newusrname;
                                        // Update username in UI
                                        _mydob = newdob;
                                      });
                                      if (userDocId!.isNotEmpty) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userDocId)
                                            .update({
                                          'address': newaddr,
                                          'name': newusrname,
                                          'dob': newdob,
                                          'language': languages,
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
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                        ),
                        child: Text("Edit Profile",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(height: 10, width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   children: [
                                    //     IconButton(
                                    //       icon: Icon(
                                    //         Icons.info_outline,
                                    //         color: Colors.grey,
                                    //       ),
                                    //       onPressed: () {
                                    //         showDialog(
                                    //           context: context,
                                    //           builder: (BuildContext context) {
                                    //             // Use existing username
                                    //             return AlertDialog(
                                    //               scrollable: true,
                                    //               titlePadding:
                                    //                   EdgeInsets.all(0),
                                    //               title: Container(
                                    //                 padding: EdgeInsets.all(16),
                                    //                 decoration: BoxDecoration(
                                    //                     color: Colors.blue,
                                    //                     borderRadius:
                                    //                         BorderRadius.only(
                                    //                             topLeft: Radius
                                    //                                 .circular(
                                    //                                     20),
                                    //                             topRight: Radius
                                    //                                 .circular(
                                    //                                     20))),
                                    //                 child: Row(
                                    //                   children: [
                                    //                     Icon(
                                    //                       Icons.info_outline,
                                    //                       size: 30,
                                    //                       color: Colors.white,
                                    //                     ),
                                    //                     SizedBox(width: 10),
                                    //                     Text(
                                    //                       'User\'s General Info',
                                    //                       style: TextStyle(
                                    //                           color:
                                    //                               Colors.white),
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ),
                                    //               content: Column(
                                    //                 crossAxisAlignment:
                                    //                     CrossAxisAlignment
                                    //                         .start,
                                    //                 children: [
                                    //                   Row(
                                    //                     children: [
                                    //                       Text(
                                    //                           GlobalVariables
                                    //                               .instance
                                    //                               .xmlHandler
                                    //                               .getString(
                                    //                                   'nam'),
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       Text("$usrname"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text("Username: ",
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       Text(
                                    //                           "${userDoc?['username']}"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text("Gender: ",
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       userDoc?['gender'] ==
                                    //                               1
                                    //                           ? Text("Male")
                                    //                           : Text("Female"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text(
                                    //                           "Date of Birth: ",
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       Text(
                                    //                           "${userDoc?['dob']}"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text(
                                    //                           GlobalVariables
                                    //                               .instance
                                    //                               .xmlHandler
                                    //                               .getString(
                                    //                                   'addr'),
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       Text(
                                    //                           "${userDoc?['address']}"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text("Primary Role: ",
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       userDoc?['role'] == 1
                                    //                           ? Text("Maid")
                                    //                           : Text(
                                    //                               "Home-Owner"),
                                    //                     ],
                                    //                   ),
                                    //                   Row(
                                    //                     children: [
                                    //                       Text(
                                    //                           "Language known: ",
                                    //                           style: const TextStyle(
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold)),
                                    //                       Text(
                                    //                           "${userDoc?['language'].toString()}"),
                                    //                     ],
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //               actions: <Widget>[
                                    //                 TextButton(
                                    //                   child: Text('Cancel'),
                                    //                   onPressed: () {
                                    //                     Navigator.of(context)
                                    //                         .pop(); // Close dialog
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             );
                                    //           },
                                    //         );
                                    //       },
                                    //     ),
                                    //     IconButton(
                                    //       icon: Icon(
                                    //         Icons.edit_outlined,
                                    //         color: Colors.grey,
                                    //       ),
                                    //       onPressed: () {

                                    //       },
                                    //     ),
                                    //   ],
                                    // ),
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
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                                await FirebaseFirestore.instance
                                                    .collection('skills')
                                                    .get();

                                            //fetch only skills from the user

                                            print(snapshot.docs.first.id);
                                            // print(myskills);
                                            for (var doc in snapshot.docs) {
                                              // Get the skill for the selected language

                                              if (doc[GlobalVariables
                                                          .instance.selected] !=
                                                      null &&
                                                  !myskills.contains(doc.id)) {
                                                options.add(doc[GlobalVariables
                                                    .instance.selected]);
                                              }
                                            }
                                            List<String> selectedOptions = [];

                                            await showDialog<List<String>>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Select Options"),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children:
                                                          options.map((option) {
                                                        return CheckboxListTile(
                                                          title: Text(option),
                                                          value: selectedOptions
                                                              .contains(option),
                                                          onChanged:
                                                              (bool? value) {
                                                            if (value == true) {
                                                              selectedOptions
                                                                  .add(option);
                                                            } else {
                                                              selectedOptions
                                                                  .remove(
                                                                      option);
                                                            }
                                                            // Update the UI
                                                            (context as Element)
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
                                    SizedBox(height: 8),
                                    FutureBuilder(
                                        future: getActiveServices(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text("loading...");
                                          }
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.isEmpty) {
                                              return Text(GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('noserv'));
                                            } else {
                                              return GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2),
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final item = snapshot
                                                      .data!.docs[index];

                                                  return SingleChildScrollView(
                                                    child: Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Card(
                                                              elevation:
                                                                  4, // Adds a slight shadow for a polished look
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12), // Smooth edges for the card
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                FutureBuilder<List<String>>(
                                                                              future: getActiveName(GlobalVariables.instance.userrole == 1 ? item.get('userid') : item.get('receiver')),
                                                                              builder: (context, snapshot) {
                                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                  return Row(
                                                                                    children: [
                                                                                      CircularProgressIndicator(),
                                                                                      SizedBox(width: 10),
                                                                                      Text("Loading Title..."),
                                                                                    ],
                                                                                  ); // Display a loading indicator in the title
                                                                                } else if (snapshot.hasError) {
                                                                                  return Text('Error: ${snapshot.error}');
                                                                                } else if (snapshot.hasData) {
                                                                                  return Row(
                                                                                    children: [
                                                                                      CircleAvatar(
                                                                                        radius: 12,
                                                                                        backgroundImage: NetworkImage(snapshot.data![1]),
                                                                                      ),
                                                                                      SizedBox(width: 7),
                                                                                      Expanded(
                                                                                          child: Text(
                                                                                        snapshot.data!.first,
                                                                                        style: TextStyle(fontSize: 20),
                                                                                      )),
                                                                                    ],
                                                                                  ); // Display the fetched title
                                                                                } else {
                                                                                  return Text('No Title Available');
                                                                                }
                                                                              },
                                                                            ),
                                                                            content:
                                                                                _buildActiveServiceList(item),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(false); // Return false
                                                                                },
                                                                                child: Text('Cancel'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }, // Action when tapped
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          16.0), // Adjust padding for better spacing
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Center(
                                                                            child:
                                                                                Text(
                                                                              '${GlobalVariables.instance.xmlHandler.getString('current')}${GlobalVariables.instance.userrole == 1 ? GlobalVariables.instance.xmlHandler.getString('employer') : GlobalVariables.instance.xmlHandler.getString('maiden')}',
                                                                              style: TextStyle(
                                                                                fontSize: 18, // Slightly larger font for prominence
                                                                                fontWeight: FontWeight.bold, // Bold text for emphasis
                                                                                color: Colors.black87, // Darker text for readability
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8), // Spacing between title and subtitle
                                                                          FutureBuilder<
                                                                              List<String>>(
                                                                            future: getActiveName(GlobalVariables.instance.userrole == 1
                                                                                ? item.get('userid')
                                                                                : item.get('receiver')), // Your future function
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                // While waiting for the result, show a loading indicator or text
                                                                                return CircularProgressIndicator();
                                                                              } else if (snapshot.hasError) {
                                                                                // If there's an error, show an error message
                                                                                return Text(
                                                                                  'Error: ${snapshot.error}',
                                                                                  style: TextStyle(fontSize: 14, color: Colors.red),
                                                                                );
                                                                              } else if (snapshot.hasData) {
                                                                                // If data is received, use the result from the snapshot

                                                                                name = snapshot.data![0];
                                                                                return Row(
                                                                                  children: [
                                                                                    CircleAvatar(
                                                                                      radius: 12,
                                                                                      backgroundImage: NetworkImage(snapshot.data![1]),
                                                                                    ),
                                                                                    SizedBox(width: 7),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        name,
                                                                                        style: TextStyle(
                                                                                          fontSize: 14, // Smaller font for supporting text
                                                                                          color: Colors.grey[700], // Subtle color for less emphasis
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              } else {
                                                                                // If no data is available, show a fallback message
                                                                                return Text(
                                                                                  'No data available',
                                                                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                                                                );
                                                                              }
                                                                            },
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  item.get('status') ==
                                                                          4
                                                                      ? Card(
                                                                          color:
                                                                              Colors.amber[300],
                                                                          child:
                                                                              Text(
                                                                            'Completion Request Pending',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.blueGrey,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Text('')
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            return Text(GlobalVariables
                                                .instance.xmlHandler
                                                .getString('noserv'));
                                          }
                                        }),

                                    //_buildActiveServiceList(),
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
                                      FutureBuilder(
                                        future: fetchOwnServices(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text("loading...");
                                          }
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.isEmpty) {
                                              return Text(GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('noserv'));
                                            } else {
                                              return GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 1,
                                                ),
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final item = snapshot
                                                      .data!.docs[index];
                                                  print(item.data());
                                                  return SingleChildScrollView(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Card(
                                                            elevation:
                                                                4, // Adds a slight shadow for a polished look
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12), // Smooth edges for the card
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Service Details'),
                                                                          content:
                                                                              _buildServiceList(item),
                                                                          actions: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => JobResume(2),
                                                                                    ),
                                                                                  ).whenComplete(() {
                                                                                    setState(() {});
                                                                                  });
                                                                                },
                                                                                child: Text('Edit')),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  _confirmDelete(context, item.id, 'services');
                                                                                },
                                                                                child: Text('Remove')),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop(false); // Return false
                                                                              },
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  }, // Action when tapped
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .all(
                                                                        16.0), // Adjust padding for better spacing
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Center(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              const Text('Posted on'),
                                                                              Text(
                                                                                DateFormat('dd-MMM-yyyy').format((item.get('timestamp')).toDate()),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          }
                                          return const SizedBox(); // Fallback in case of no data
                                        },
                                      ),

                                      //_buildServiceList(),
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
                                      //_buildJobProfileList(),
                                      FutureBuilder(
                                        future: fetchOwnJobProfile(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text("loading...");
                                          }
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.isEmpty) {
                                              return Text(GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('noserv'));
                                            } else {
                                              return GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 1,
                                                ),
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final item = snapshot
                                                      .data!.docs[index];
                                                  print(item.data());
                                                  return SingleChildScrollView(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Card(
                                                            elevation:
                                                                4, // Adds a slight shadow for a polished look
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12), // Smooth edges for the card
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Service Details'),
                                                                          content:
                                                                              _buildJobProfileList(item),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop(false); // Return false
                                                                              },
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  }, // Action when tapped
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .all(
                                                                        16.0), // Adjust padding for better spacing
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Center(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              const Text('Posted on'),
                                                                              Text(
                                                                                DateFormat('dd-MMM-yyyy').format((item.get('timestamp')).toDate()),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          }
                                          return const SizedBox(); // Fallback in case of no data
                                        },
                                      ),
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
