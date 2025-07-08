import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ibitf_app/chatpage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:ibitf_app/assessment.dart';
import 'package:ibitf_app/DAO/skilldao.dart';

import 'package:ibitf_app/jobresume.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:ibitf_app/buildui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _outerScrollController = ScrollController();
  final _innerScrollController = ScrollController();
  String? _downloadUrl;
  String? _myaddr, _mydob, thelangs;
  List<dynamic>? languages;
  String? userDocId;
  DocumentSnapshot? userDoc;
  final ImagePicker _picker = ImagePicker();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  final List<File> _documentImages = [];
  int? _documentVerifiedStatus;
  final TextEditingController _languageController = TextEditingController();
  final dobcontroller = TextEditingController();
  String? usrname;
  bool _isUploading = false;
  String? _uploadedDocumentUrl;
  DateTime dt = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  String dte = "Date of birth";
  Color _dobColor = const Color(0xFFb2b7bf);
  String name = "";
  List<String> allnames = [];
  List<String>? selectedskills;
  List<String> myskills = [];
  bool isExpanded = false;
  List<int>? myscores;
  List<Map<String, dynamic>> skillsWithScores = [];
  List<List<dynamic>> skillsWithNames = [];
  @override
  void initState() {
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((val) {
      print(GlobalVariables.instance.selected);

      usrname = GlobalVariables.instance.username;
    });
    _fetchUserDocId();
    _fetchUploadedDocumentUrl();
    fetchSkills();
    profilepic();

    super.initState();

    _innerScrollController.addListener(() {
      if (_innerScrollController.offset >=
              _innerScrollController.position.maxScrollExtent &&
          !_innerScrollController.position.outOfRange) {
        _outerScrollController.animateTo(
          _outerScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    _innerScrollController.dispose();
    super.dispose();
  }

  Future<void> profilepic() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("userid", isEqualTo: currentUser.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
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
          }
        });
      }
    }
  }

  AssetImage loadImage() {
    return const AssetImage("assets/profile.png");
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _documentImages.add(File(pickedImage.path));
      });
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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

  Future<void> _pickImageForDocuments() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      await _uploadDocumentToFirebase(File(pickedImage.path));
    }
  }

// Locate the `_uploadDocumentToFirebase` function and replace it with the following:
  Future<void> _fetchUploadedDocumentUrl() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('documents')
            .doc(currentUser.uid)
            .get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          if (mounted) {
            setState(() {
              _uploadedDocumentUrl = docSnapshot.get('url');
              // Ensure 'verified' field is treated as an int, default to 0 if not found or null
              _documentVerifiedStatus =
                  (docSnapshot.data() as Map<String, dynamic>)
                          .containsKey('verified')
                      ? docSnapshot.get('verified') as int
                      : 0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _uploadedDocumentUrl = null; // No document found
              _documentVerifiedStatus = null; // No status
            });
          }
        }
      } catch (e) {
        print('Error fetching uploaded document URL and status: $e');
        if (mounted) {
          setState(() {
            _uploadedDocumentUrl = null;
            _documentVerifiedStatus = null;
          });
        }
      }
    }
  }

// Locate the `_uploadDocumentToFirebase` function and replace it with the following:
  Future<void> _uploadDocumentToFirebase(File imageFile) async {
    // Set loading state to true
    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    }

    try {
      // Get current user ID
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showMessageBox('Error', 'No user logged in. Cannot upload document.',
            isError: true);
        return;
      }
      String userId = currentUser.uid;

      // Determine file extension
      String fileExtension = imageFile.path.split('.').last;
      String fileName =
          '$userId.$fileExtension'; // Rename image to userid.filetype

      // Compress the image file before uploading
      List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800, // Optional: resize width
        minHeight: 600, // Optional: resize height
        quality: 70, // Adjust compression quality (0-100)
      );

      if (compressedBytes == null) {
        _showMessageBox('Error', 'Failed to compress image.', isError: true);
        return;
      }

      // Create a temporary file from compressed bytes
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_compressed_$fileName');
      await tempFile.writeAsBytes(compressedBytes);

      // Create a reference to the Firebase Storage location
      final storageRef =
          FirebaseStorage.instance.ref().child('documents').child(fileName);

      // Upload the compressed file
      await storageRef.putFile(tempFile);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Create/Update an entry in Firestore
      await FirebaseFirestore.instance.collection('documents').doc(userId).set(
        {
          'url': downloadUrl,
          'verified': 0, // Set verified to 0 (Unverified) by default on upload
          'timestamp':
              FieldValue.serverTimestamp(), // Optional: add a timestamp
        },
        SetOptions(
            merge:
                true), // Use merge to update existing fields or create if not exists
      );

      // Clean up the temporary compressed file
      await tempFile.delete();

      // Update the _uploadedDocumentUrl and status state variables
      if (mounted) {
        setState(() {
          _uploadedDocumentUrl = downloadUrl;
          _documentVerifiedStatus =
              0; // Set to Unverified (0) after successful upload
        });
      }

      _showMessageBox('Success', 'Document uploaded and recorded successfully!',
          isError: false);
    } catch (e) {
      _showMessageBox('Error', 'Failed to upload document: $e', isError: true);
      print('Error uploading document: $e');
    } finally {
      // Set loading state to false regardless of success or failure
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

// Locate the `_buildGridViewForDocuments()` widget and replace it with the following:
  Widget _buildGridViewForDocuments() {
    if (_uploadedDocumentUrl != null) {
      IconData statusIcon;
      Color statusColor;
      String statusText;

      switch (_documentVerifiedStatus) {
        case 1: // Verified
          statusIcon = Icons.verified;
          statusColor = Colors.green.shade700;
          statusText = 'Verified';
          break;
        case -1: // Rejected
          statusIcon = Icons.cancel;
          statusColor = Colors.red.shade700;
          statusText = 'Rejected';
          break;
        case 0: // Unverified (default)
        default:
          statusIcon = Icons.info_outline;
          statusColor = Colors.orange.shade700;
          statusText = 'Unverified';
          break;
      }

      return Column(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for image
            child: Image.network(
              _uploadedDocumentUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200, // Fixed height for consistency
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              SizedBox(width: 5),
              Text(
                'Document Status: $statusText',
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0), // More padding for empty state
        child: Text(
          'No documents uploaded yet. Upload important certifications, IDs, or work samples.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
  }

// Locate the `showDocuments()` widget and replace it with the following:
  Widget showDocuments() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 8, // Stronger shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More rounded
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            // Use the updated _buildGridViewForDocuments directly
            _buildGridViewForDocuments(),
            SizedBox(height: 20),
            if (_documentVerifiedStatus != 1)
              _isUploading // Show progress indicator or button
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        strokeWidth: 4.0,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickImageForDocuments,
                      icon: Icon(Icons.upload_file, size: 24),
                      label: Text('Upload Document',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent, // Stronger color
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded button
                        ),
                        elevation: 5,
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  // Show documents section

  Future<void> _fetchUserDocId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userid', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userDocId = snapshot.docs.first.id;
        });
      }
    }
  }

  Widget showSkills() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          collapsedIconColor: Colors.cyan,
          title: Text(
            GlobalVariables.instance.xmlHandler.getString('skills').toString(),
            style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
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
          ]),
    );
  }

  Future<void> fetchSkills() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
            .collection("users")
            .where("userid", isEqualTo: currentUser.uid)
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

        if (mounted) {
          setState(() {
            myskills = querySnapshot.docs.map((doc) => doc.id).toList();
            skillsWithScores = querySnapshot.docs.map((doc) {
              return {
                'skill': doc.id,
                'score': doc['score'],
              };
            }).toList();
          });
        }
      } else {
        print('No user is currently logged in.');
        setState(() {});
      }
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  Color _getColor(double level) {
    if (level >= 75) {
      return Colors.green;
    } else if (level >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
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

  double getLevel(currentSkill) {
    double level = 0;
    int res = 0;
    for (var s in skillsWithScores) {
      if (s['skill'] == currentSkill) {
        res = s['score'];
      }
      level = res.toDouble().abs();
    }
    return level;
  }

  Widget showLevels(currentSkill) {
    double level = 0;
    int res = 0;
    for (var s in skillsWithScores) {
      if (s['skill'] == currentSkill) {
        res = s['score'];
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
                width: level * 1.5,
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
          dividerColor: Colors.transparent,
        ),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: myskills.length,
              itemBuilder: (context, index) {
                return _buildSkillItem(
                  res[index] == getSkillName(res[index])
                      ? skillsWithNames.firstWhere((s) => s[0] == res[index])[1]
                      : res[index],
                  (myskills.contains(getSkillName(res[index])) &&
                          checkVerified(res[index]))
                      ? getLevel(getSkillName(res[index])).toInt()
                      : 0,
                );
              },
            ),
          ],
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

  Future<QuerySnapshot> getCompletedServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getCompletedServices(userID);
    return qs;
  }

  Future<List<String>> getActiveName(String receive) async {
    return await maidDao().getActiveName(receive);
  }

  Widget _buildServiceList(item) {
    bool isAnimating = false;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification && !isAnimating) {
          isAnimating = true;
          if (_innerScrollController.offset >=
              _innerScrollController.position.maxScrollExtent) {
            _outerScrollController
                .animateTo(
                  _outerScrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                )
                .then((_) => isAnimating = false);
          } else if (_innerScrollController.offset <=
              _innerScrollController.position.minScrollExtent) {
            _outerScrollController
                .animateTo(
                  _outerScrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                )
                .then((_) => isAnimating = false);
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _innerScrollController,
        child: Column(
          children: [
            Column(
              children: [
                buildTextInfo(
                    GlobalVariables.instance.xmlHandler.getString('postedon'),
                    DateFormat('dd MMM yyyy')
                        .format((item.get("timestamp") as Timestamp).toDate())),
                buildScheduleSection(
                    GlobalVariables.instance.xmlHandler.getString('sched'),
                    item.get("schedule")),
                GlobalVariables.instance.userrole == 1
                    ? buildServiceSection(
                        GlobalVariables.instance.xmlHandler.getString('serv'),
                        item.get("services"))
                    : buildSection(
                        GlobalVariables.instance.xmlHandler.getString('serv'),
                        item.get("services")),
                if (GlobalVariables.instance.userrole == 2 &&
                    item.data().containsKey('imageurl') &&
                    item.get('imageurl') != null)
                  buildImageSection(item.get('imageurl'), context),
                buildSection(
                    GlobalVariables.instance.xmlHandler.getString('timing'),
                    item.get("timing")),
                buildSection(
                    GlobalVariables.instance.xmlHandler.getString('day'),
                    item.get("days")),
                buildTextInfo(
                    GlobalVariables.instance.xmlHandler.getString('nego'),
                    GlobalVariables.instance.xmlHandler.getString(
                        item.get("negotiable").toString().toLowerCase())),
                buildLongText(
                    GlobalVariables.instance.xmlHandler.getString('remarks'),
                    item.get("remarks")),
                SizedBox(
                  height: 10,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobResume(2),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    child: Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, color: Colors.white),
                            const Text('Edit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete, color: Colors.white),
                            const Text('Delete',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _removeService(docId, kind);
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Service Removed Successfully',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 6,
          duration: const Duration(seconds: 3),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    });
  }

  Widget showAssess(String skillName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.cyan, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      '${GlobalVariables.instance.xmlHandler.getString('assfor')} $skillName}'),
                  content: Text(GlobalVariables.instance.xmlHandler
                      .getString('confirmassess')),
                  actions: [
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close),
                        label: Text(GlobalVariables.instance.xmlHandler
                            .getString('no'))),
                    TextButton.icon(
                      onPressed: () {
                        selectedskills = [];

                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Assessment(skillName,
                                onComplete: updateParentState)));
                      },
                      icon: Icon(Icons.check),
                      label: Text(
                        GlobalVariables.instance.xmlHandler.getString('yes'),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            GlobalVariables.instance.xmlHandler.getString('assessment'),
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.cyan),
          )),
    );
  }

  Widget _buildSkillItem(String skillName, int percentage) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                skillName,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 4),
          percentage == 0
              ? showAssess(skillName)
              : Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 5),
                      width: double.infinity,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.teal,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          color: Colors.tealAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("$percentage%",
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey[800])),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _tabContent(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget showMyServices() {
    return FutureBuilder(
      future: GlobalVariables.instance.userrole == 1
          ? fetchOwnServices()
          : fetchOwnJobProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Text(
                GlobalVariables.instance.xmlHandler.getString('noserv'));
          } else {
            final item = snapshot.data!.docs.first;
            return _buildServiceList(item);
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget showActiveAndCompleteServices(String what) {
    return FutureBuilder(
      future: what == "Active" ? getActiveServices() : getCompletedServices(),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final item = snapshot.data!.docs[index];

                return GestureDetector(
                  onTap: () async {
                    if (item.get('status') == 4) {
                      List<String> res = await getActiveName(
                          GlobalVariables.instance.userrole == 1
                              ? item.get('userid')
                              : item.get('receiverid'));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    name: res[0],
                                    photo: res[1],
                                    receiverID: item.get("receiverid"),
                                    readMsg: true,
                                  )));
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: FutureBuilder<List<String>>(
                              future: getActiveName(
                                  GlobalVariables.instance.userrole == 1
                                      ? item.get('userid')
                                      : item.get('receiverid')),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 10),
                                      Text("Loading Title..."),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage:
                                            NetworkImage(snapshot.data![1]),
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          snapshot.data!.first,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Text('No Title Available');
                                }
                              },
                            ),
                            content: buildActiveServiceList(
                                item, what, context, userID),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<List<String>>(
                            future: getActiveName(
                                GlobalVariables.instance.userrole == 1
                                    ? item.get('userid')
                                    : item.get('receiverid')),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage:
                                          NetworkImage(snapshot.data![1]),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        snapshot.data![0],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Text(
                                  'No data available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          if (item.get('status') == 4)
                            Card(
                              color: Colors.amber[300],
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'Completion Request Pending',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
          return Text(GlobalVariables.instance.xmlHandler.getString('noserv'));
        }
      },
    );
  }

  Widget _tabItem(String title) {
    return Tab(
      child: Container(
        alignment: Alignment.center,
        height: 40,
        child: Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          SizedBox(width: 10),
          Text(
            text,
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // Show edit profile dialog
  void _showEditProfileDialog(BuildContext context) {
    String tempNewName = usrname ?? "";
    String tempNewAddress = _myaddr ?? "";
    String tempNewDob = _mydob ?? "";
    List<dynamic> tempLanguages = List.from(languages ?? []);
    TextEditingController tempDobController =
        TextEditingController(text: tempNewDob);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit Profile Information',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) => tempNewName = value,
                      controller: TextEditingController(text: tempNewName),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter new name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      onChanged: (value) => tempNewAddress = value,
                      controller: TextEditingController(text: tempNewAddress),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter new address',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: tempDobController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'Select date of birth',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(tempNewDob) ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            tempNewDob = dateFormat.format(pickedDate);
                            tempDobController.text = tempNewDob;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Languages Known:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: tempLanguages.map((lang) {
                        return Chip(
                          label: Text(lang.toString()),
                          onDeleted: () {
                            setState(() {
                              tempLanguages.remove(lang);
                            });
                          },
                          deleteIcon: Icon(Icons.cancel, size: 18),
                          backgroundColor: Colors.blue.shade50,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _languageController,
                            decoration: InputDecoration(
                              labelText: 'Add New Language',
                              hintText: 'e.g., Khasi',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            String newLang = _languageController.text.trim();
                            if (newLang.isNotEmpty &&
                                !tempLanguages.contains(newLang)) {
                              setState(() {
                                tempLanguages.add(newLang);
                              });
                              _languageController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save Changes'),
              onPressed: () async {
                if (userDocId != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userDocId)
                      .update({
                    'name': tempNewName,
                    'address': tempNewAddress,
                    'dob': tempNewDob,
                    'language': tempLanguages,
                  });
                  await profilepic(); // Re-fetch profile data to update UI
                  _showMessageBox('Profile Updated',
                      'Your profile information has been successfully updated.',
                      isError: false);
                  Navigator.of(dialogContext).pop();
                } else {
                  _showMessageBox('Error',
                      'Could not save profile. User document not found.',
                      isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessageBox(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : Colors.green),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
          return SingleChildScrollView(
            controller: _outerScrollController,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade400,
                          Colors.blueAccent.shade700
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 8))
                      ],
                    ),
                    padding: EdgeInsets.all(25), // Increased padding
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60, // Slightly larger avatar
                              backgroundColor: Colors.white.withOpacity(0.9),
                              backgroundImage: _downloadUrl != null
                                  ? NetworkImage(_downloadUrl!)
                                  : loadImage() as ImageProvider<Object>,
                              onBackgroundImageError: (exception, stackTrace) {
                                print('Image load error: $exception');
                              },
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final XFile? image = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image == null) return;

                                  File file = File(image.path);
                                  try {
                                    String fileName = image.name;
                                    String filetype = fileName.split('.').last;
                                    final ref = FirebaseStorage.instance
                                        .ref()
                                        .child(
                                            '${GlobalVariables.instance.username}/profile.$filetype');
                                    await ref.putFile(file);
                                    String downloadUrl =
                                        await ref.getDownloadURL();

                                    QuerySnapshot querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .where("userid", isEqualTo: userID)
                                            .get();

                                    if (querySnapshot.docs.isNotEmpty) {
                                      await querySnapshot.docs.first.reference
                                          .set(
                                        {'url': downloadUrl},
                                        SetOptions(merge: true),
                                      );
                                    }
                                    setState(() {
                                      _downloadUrl = downloadUrl;
                                    });
                                    _showMessageBox('Profile Picture Updated',
                                        'Your profile picture has been successfully updated.',
                                        isError: false);
                                  } catch (e) {
                                    _showMessageBox('Error',
                                        'Failed to update profile picture: $e',
                                        isError: true);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      color: Colors.blueAccent, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          usrname ?? "User Name",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2),
                        ),
                        SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.location_on, _myaddr ?? "Address Not Set"),
                        _buildInfoRow(Icons.calendar_today,
                            _mydob ?? "Date of Birth Not Set"),
                        _buildInfoRow(
                            Icons.transgender,
                            userDoc?['gender'] == 1
                                ? "Female"
                                : (userDoc?['gender'] == 2
                                    ? "Male"
                                    : "Not Set")),
                        _buildInfoRow(Icons.language,
                            languages?.join(', ') ?? "Languages Not Set"),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: () => _showEditProfileDialog(context),
                          icon: Icon(Icons.edit, color: Colors.teal),
                          label: Text("Edit Profile",
                              style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            backgroundColor: Colors.white,
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            elevation: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (GlobalVariables.instance.urole == 1)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white54,
                                            Colors.white60
                                          ],
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
                                      child: Column(
                                        children: [
                                          showSkills(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0,
                                                          right: 20,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      List<String> options = [];

                                                      QuerySnapshot snapshot =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'skills')
                                                              .get();

                                                      print(snapshot
                                                          .docs.first.id);

                                                      for (var doc
                                                          in snapshot.docs) {
                                                        if (doc[GlobalVariables
                                                                    .instance
                                                                    .selected] !=
                                                                null &&
                                                            !myskills.contains(
                                                                doc.id)) {
                                                          options.add(doc[
                                                              GlobalVariables
                                                                  .instance
                                                                  .selected]);
                                                        }
                                                      }
                                                      List<String>
                                                          selectedOptions = [];

                                                      await showDialog<
                                                          List<String>>(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Select Options"),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: ListBody(
                                                                children:
                                                                    options.map(
                                                                        (option) {
                                                                  return CheckboxListTile(
                                                                    title: Text(
                                                                        option),
                                                                    value: selectedOptions
                                                                        .contains(
                                                                            option),
                                                                    onChanged:
                                                                        (bool?
                                                                            value) {
                                                                      if (value ==
                                                                          true) {
                                                                        selectedOptions
                                                                            .add(option);
                                                                      } else {
                                                                        selectedOptions
                                                                            .remove(option);
                                                                      }

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
                                                                child: Text(
                                                                    "Cancel"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                    "Done"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
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
                                                                  setState(
                                                                      () {});
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ).then((result) {
                                                        if (result != null) {
                                                          print(
                                                              "Selected options: $result");
                                                          selectedskills =
                                                              result;
                                                        }
                                                      });
                                                    },
                                                    child: const Row(
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          color: Colors.cyan,
                                                        ),
                                                        Text(
                                                          'Add Skill',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.cyan,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  showDocuments(),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        width: 2,
                        color: Colors.transparent,
                      ),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 2,
                          color: Colors.transparent,
                        ),
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.blueAccent],
                        ),
                      ),
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.teal, Colors.blueAccent],
                                ),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: TabBar(
                                indicator: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                labelColor: Colors.teal,
                                unselectedLabelColor: Colors.white,
                                indicatorSize: TabBarIndicatorSize.tab,
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                tabs: [
                                  GlobalVariables.instance.userrole == 1
                                      ? _tabItem(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('myserv'))
                                      : _tabItem(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('posted')),
                                  _tabItem(GlobalVariables.instance.xmlHandler
                                      .getString('active')),
                                  _tabItem(GlobalVariables.instance.xmlHandler
                                      .getString('comserv')),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: isExpanded
                                  ? MediaQuery.of(context).size.height
                                  : 200,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(16)),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        showMyServices(),
                                        showActiveAndCompleteServices("Active"),
                                        showActiveAndCompleteServices(
                                            "Completed"),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isExpanded ? "Less" : "More",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal),
                                        ),
                                        Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.teal),
                                      ],
                                    ),
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
            ),
          );
        });
  }
}
