import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> skillIds = [];
  String? selectedSkillId;
  String selectedSkillEn = '';
  String selectedSkillKs = '';
  final TextEditingController skillIdController = TextEditingController();
  final TextEditingController skillEnController = TextEditingController();
  final TextEditingController skillKsController = TextEditingController();

  final TextEditingController questionControllerEn = TextEditingController();
  final TextEditingController questionControllerKs = TextEditingController();
  final TextEditingController optionsEnController = TextEditingController();
  final TextEditingController optionsKsController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController targetSkillIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    generateNextSkillId();
    loadSkillIds();
  }

  Future<void> loadSkillIds() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();
    setState(() {
      skillIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> generateNextSkillId() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();
    final ids = snapshot.docs.map((doc) => doc.id).toList();

    int maxIndex = 0;
    for (var id in ids) {
      final match = RegExp(r'Skill(\d+)').firstMatch(id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxIndex) maxIndex = num;
      }
    }

    skillIdController.text = 'Skill${maxIndex + 1}';
  }

  Future<void> addSkill() async {
    await FirebaseFirestore.instance
        .collection('skills')
        .doc(skillIdController.text)
        .set({
      'English': skillEnController.text,
      'Khasi': skillKsController.text,
    });
    skillEnController.clear();
    skillKsController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Skill Added Successfully!', style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior:
            SnackBarBehavior.floating, // Floating snackbar for modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration:
            const Duration(seconds: 3), // How long to display the Snackbar
      ),
    );
    loadSkillIds();
    generateNextSkillId();
  }

  Future<void> addQuestion() async {
    final skillDoc =
        FirebaseFirestore.instance.collection('skills').doc(selectedSkillId);
    final questionsRef = FirebaseFirestore.instance
        .collection('skills')
        .doc(selectedSkillId)
        .collection('questions');

    final snapshot = await questionsRef.get();

    int maxQ = 0;
    for (var doc in snapshot.docs) {
      final match = RegExp(r'Q(\d+)').firstMatch(doc.id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxQ) maxQ = num;
      }
    }

    String newDocId = 'Q${maxQ + 1}';

    await questionsRef.doc(newDocId).set({
      'English': questionControllerEn.text,
      'Khasi': questionControllerKs.text,
      'EnglishOptions': optionsEnController.text.split(','),
      'KhasiOptions': optionsKsController.text.split(','),
      'Ans': answerController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Question Added Successfully!',
                style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior:
            SnackBarBehavior.floating, // Floating snackbar for modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration:
            const Duration(seconds: 3), // How long to display the Snackbar
      ),
    );
    questionControllerEn.clear();
    questionControllerKs.clear();
    optionsEnController.clear();
    optionsKsController.clear();
    answerController.clear();
  }

  Widget buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var userDoc = users[index];
            var user = userDoc.data() as Map<String, dynamic>;
            String docId = userDoc.id;

            final roleText = user['role'] == 1
                ? 'Maid'
                : user['role'] == 2
                    ? 'Employer'
                    : 'Admin';

            final roleColor = user['role'] == 1
                ? Colors.green
                : user['role'] == 2
                    ? Colors.blue
                    : Colors.orange;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage:
                      (user['url'] != null && user['url'].toString().isNotEmpty)
                          ? NetworkImage(user['url'])
                          : null,
                  child: (user['url'] == null || user['url'].toString().isEmpty)
                      ? Text(
                          (user['name'] ?? 'N')[0].toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        )
                      : null,
                ),
                title: Text(
                  user['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleText,
                        style: TextStyle(
                            fontSize: 12,
                            color: roleColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Address: ${user['address'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) async {
                    final usersRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId);
                    if (value == 'Promote to Admin') {
                      await usersRef.update({'role': 0});
                    } else if (value == 'Switch to Maid') {
                      await usersRef.update({'role': 1});
                    } else if (value == 'Switch to Employer') {
                      await usersRef.update({'role': 2});
                    } else if (value == 'Delete') {
                      final usersRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId);
                      final userSnapshot = await usersRef.get();
                      final data = userSnapshot.data();
                      final url = data?['url'];

                      if (url != null && url.toString().isNotEmpty) {
                        try {
                          final ref = FirebaseStorage.instance.refFromURL(url);
                          await ref.delete();
                        } catch (e) {
                          print('Failed to delete profile image: $e');
                        }
                      }

                      await usersRef.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Promote to Admin',
                      child: Text('Promote to Admin'),
                    ),
                    const PopupMenuItem(
                      value: 'Switch to Maid',
                      child: Text('Switch to Maid'),
                    ),
                    const PopupMenuItem(
                      value: 'Switch to Employer',
                      child: Text('Switch to Employer'),
                    ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: Text('Delete User',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildGrievancesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grievances = snapshot.data!.docs;

        if (grievances.isEmpty) {
          return const Center(child: Text("No grievances submitted."));
        }

        return ListView.builder(
          itemCount: grievances.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var doc = grievances[index];
            var g = doc.data() as Map<String, dynamic>;
            final resolved = g['resolved'] == true;

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Icon(
                  resolved ? Icons.check_circle_outline : Icons.error_outline,
                  color: resolved ? Colors.green : Colors.redAccent,
                ),
                title: Text(
                  g['name'] ?? 'Anonymous',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      g['grievanceMessage'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      g['timestamp'] != null
                          ? (g['timestamp'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString()
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (resolved)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("Resolved",
                            style:
                                TextStyle(fontSize: 12, color: Colors.green)),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onSelected: (value) async {
                    final ref = FirebaseFirestore.instance
                        .collection('grievances')
                        .doc(doc.id);

                    if (value == 'Resolve') {
                      await ref.update({'resolved': true});
                    } else if (value == 'Delete') {
                      await ref.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!resolved)
                      const PopupMenuItem(
                        value: 'Resolve',
                        child: Text('Mark as Resolved'),
                      ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Skill",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: skillIdController,
            decoration: InputDecoration(labelText: 'Skill ID (Auto-generated)'),
            enabled: false,
          ),
          TextField(
              controller: skillEnController,
              decoration: InputDecoration(labelText: 'Skill Name (English)')),
          TextField(
              controller: skillKsController,
              decoration: InputDecoration(labelText: 'Skill Name (Khasi)')),
          ElevatedButton(onPressed: addSkill, child: const Text("Add Skill")),
          const Divider(),
          const Text("Add New Question",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: selectedSkillId,
            items: skillIds
                .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                .toList(),
            onChanged: (val) async {
              setState(() {
                selectedSkillId = val!;
              });

              // Fetch the selected skill's names
              final doc = await FirebaseFirestore.instance
                  .collection('skills')
                  .doc(selectedSkillId!)
                  .get();
              setState(() {
                selectedSkillEn = doc['English'] ?? '';
                selectedSkillKs = doc['Khasi'] ?? '';
              });
            },
            decoration: InputDecoration(labelText: 'Select Skill ID'),
          ),
          if (selectedSkillId != null) ...[
            SizedBox(height: 8),
            Text("English Name: $selectedSkillEn",
                style: TextStyle(color: Colors.black87)),
            Text("Khasi Name: $selectedSkillKs",
                style: TextStyle(color: Colors.black54)),
          ],
          TextField(
              controller: questionControllerEn,
              decoration: InputDecoration(labelText: 'Question (English)')),
          TextField(
              controller: questionControllerKs,
              decoration: InputDecoration(labelText: 'Question (Khasi)')),
          TextField(
              controller: optionsEnController,
              decoration: InputDecoration(
                  labelText: 'Options (English, comma separated)')),
          TextField(
              controller: optionsKsController,
              decoration: InputDecoration(
                  labelText: 'Options (Khasi, comma separated)')),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Correct Answer:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: List.generate(4, (index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: answerController.text == index.toString()
                          ? Colors.blueAccent
                          : Colors.grey,
                      minimumSize: Size(50, 50),
                    ),
                    onPressed: () {
                      setState(() {
                        answerController.text = index.toString();
                      });
                    },
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: addQuestion, child: const Text("Add Question")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Grievances'),
            Tab(text: 'Skills & Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildUsersTab(),
          buildGrievancesTab(),
          buildSkillsTab(),
        ],
      ),
    );
  }
}

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// //pages
// import 'package:ibitf_app/login.dart';
// import 'package:ibitf_app/maid.dart';
// import 'package:ibitf_app/service/auth.dart';

// // import 'material_design_indicator.dart';

// class AdminHome extends StatefulWidget {
//   const AdminHome({super.key});

//   @override
//   _AdminHomePageState createState() => _AdminHomePageState();
// }

// class _AdminHomePageState extends State<AdminHome>
//     with SingleTickerProviderStateMixin {
//   final serverUrl = 'http://192.168.82.8:3000';

//   final nameController = TextEditingController();
//   final addressController = TextEditingController();

//   Future<List<Maid>> fetchMaids() async {
//     final response = await http.get(Uri.parse(serverUrl));
//     if (response.statusCode == 200) {
//       final List<dynamic> itemList = jsonDecode(response.body);
//       final List<Maid> items = itemList.map((item) {
//         return Maid.fromJson(item);
//       }).toList();
//       return items;
//     } else {
//       throw Exception("Failed to fetch Items!");
//     }
//   }

//   late TabController _tabController;

//   final _selectedColor = const Color(0xff1a73e8);

//   final _iconTabs = [
//     const Tab(icon: Icon(Icons.home)),
//     const Tab(icon: Icon(Icons.group)),
//     const Tab(icon: Icon(Icons.settings)),
//   ];

//   @override
//   void initState() {
//     _tabController = TabController(length: 3, vsync: this);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _tabController.dispose();
//   }

//   void handleClick(String value) async {
//     switch (value) {
//       case 'Logout':
//         await AuthMethods.signOut();
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => const LogIn()));
//         }
//         break;
//       case 'Settings':
//         break;
//     }
//   }

//   Future<Maid> addItem(String name, String address) async {
//     final response = await http.post(Uri.parse(serverUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'id': '0', 'name': name, 'address': address}));
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dynamic json = jsonDecode(response.body);
//       final Maid item = Maid.fromJson(json);
//       return item;
//     } else {
//       throw Exception('Failed to add item');
//     }
//   }

//   Future<void> updateItem(int id, String name) async {
//     final response = await http.put(Uri.parse('$serverUrl/api/v1/items/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'name': name}));

//     if (response.statusCode != 200) {
//       throw Exception("Failed to update item");
//     }
//   }

//   Future<void> deleteItem(int id) async {
//     final response =
//         await http.delete(Uri.parse('$serverUrl/api/v1/items/$id'));

//     if (response.statusCode != 200) {
//       throw Exception("Failed to delete item");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
//             );
//           },
//         ),
//         centerTitle: true,
//         backgroundColor: _selectedColor,
//         foregroundColor: Colors.white,
//         title: const Text("Maidful"),
//         actions: <Widget>[
//           PopupMenuButton<String>(
//             icon: CircleAvatar(
//               foregroundImage: NetworkImage(AuthMethods.user?.photoURL ?? ''),
//             ),
//             onSelected: handleClick,
//             itemBuilder: (BuildContext context) {
//               return {'Logout', 'Settings'}.map((String choice) {
//                 return PopupMenuItem<String>(
//                   value: choice,
//                   child: Text(choice),
//                 );
//               }).toList();
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar: TabBar(
//         controller: _tabController,
//         tabs: _iconTabs,
//         unselectedLabelColor: Colors.black,
//         labelColor: _selectedColor,
//         indicator: BoxDecoration(
//           borderRadius: BorderRadius.circular(5.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.7),
//               spreadRadius: 5,
//               blurRadius: 5,
//               offset: const Offset(2, 2),
//             ),
//           ],
//           color: _selectedColor.withOpacity(0.2),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           FutureBuilder(
//               future: fetchMaids(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   // return ListView.builder(
//                   //     shrinkWrap: true,
//                   //     itemCount: snapshot.data!.length,
//                   //     itemBuilder: (context, index) {
//                   //       final item1 = snapshot.data![index];
//                   //       final item = snapshot.data!.length;
//                   //       return ListTile(
//                   //         title: Text('length is $item'),
//                   //       );
//                   //     });

//                   return ListView(
//                     children: <Widget>[
//                       Card(
//                         semanticContainer: true,
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         elevation: 5,
//                         margin: const EdgeInsets.all(10),
//                         child: Image.asset(
//                           "assets/user.png",
//                           fit: BoxFit.scaleDown,
//                         ),
//                       ),
//                       const Text(
//                         "Welcome Admin",
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text(snapshot.error.toString()));
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               }),
//           FutureBuilder(
//               future: fetchMaids(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final item = snapshot.data![index];
//                         return ListTile(
//                           leading: CircleAvatar(
//                             foregroundImage:
//                                 NetworkImage(AuthMethods.user?.photoURL ?? ''),
//                           ),
//                           title: Text(item.name),
//                           subtitle: Text(item.address),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // IconButton(
//                               //   onPressed: () async {
//                               //     await deleteItem(item.id);
//                               //     setState(() {});
//                               //   },
//                               //   icon: const Icon(Icons.delete),
//                               // ),
//                               IconButton(
//                                 onPressed: () async {
//                                   await deleteItem(item.id);
//                                   setState(() {});
//                                 },
//                                 icon: const Icon(Icons.handshake),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.edit),
//                                 onPressed: () {
//                                   showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           title: const Text('Edit Item'),
//                                           content: TextFormField(
//                                             controller: nameController,
//                                             decoration: const InputDecoration(
//                                               labelText: 'Item name',
//                                             ),
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                               },
//                                               child: const Text('Cancel'),
//                                             ),
//                                             TextButton(
//                                               onPressed: () {
//                                                 updateItem(item.id,
//                                                     nameController.text);
//                                                 setState(() {
//                                                   nameController.clear();
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                               child: const Text('Edit'),
//                                             ),
//                                           ],
//                                         );
//                                       });
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       });
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text(snapshot.error.toString()));
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               }),
//           const Center(
//             child: Text("This is the settings page"),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//               context: context,
//               builder: (context) {
//                 return AlertDialog(
//                   title: const Text('Add Item'),
//                   content: Column(children: <Widget>[
//                     TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Name',
//                       ),
//                     ),
//                     TextFormField(
//                       controller: addressController,
//                       decoration: const InputDecoration(
//                         labelText: 'Address',
//                       ),
//                     )
//                   ]),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         addItem(nameController.text, addressController.text);
//                         setState(() {
//                           nameController.clear();
//                           addressController.clear();
//                         });
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Add'),
//                     ),
//                   ],
//                 );
//               });
//         },
//         tooltip: 'Add Item',
//         child: const Icon(Icons.filter_list),
//       ),
//     );
//   }
// }

// List<Widget> list = <Widget>[
//   new ListTile(
//     title: new Text('CineArts at the Empire',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('85 W Portal Ave'),
//     leading: new Icon(
//       Icons.person,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('The Castro Theater',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('429 Castro St'),
//     leading: new Icon(
//       Icons.theaters,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('Alamo Drafthouse Cinema',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('2550 Mission St'),
//     leading: new Icon(
//       Icons.theaters,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('Roxie Theater',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('3117 16th St'),
//     leading: new Icon(
//       Icons.theaters,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('United Artists Stonestown Twin',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('501 Buckingham Way'),
//     leading: new Icon(
//       Icons.theaters,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('AMC Metreon 16',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('135 4th St #3000'),
//     leading: new Icon(
//       Icons.theaters,
//       color: Colors.blue[500],
//     ),
//   ),
//   new Divider(),
//   new ListTile(
//     title: new Text('K\'s Kitchen',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('757 Monterey Blvd'),
//     leading: new Icon(
//       Icons.restaurant,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('Emmy\'s Restaurant',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('1923 Ocean Ave'),
//     leading: new Icon(
//       Icons.restaurant,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('Chaiya Thai Restaurant',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('272 Claremont Blvd'),
//     leading: new Icon(
//       Icons.restaurant,
//       color: Colors.blue[500],
//     ),
//   ),
//   new ListTile(
//     title: new Text('La Ciccia',
//         style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
//     subtitle: new Text('291 30th St'),
//     leading: new Icon(
//       Icons.restaurant,
//       color: Colors.blue[500],
//     ),
//   ),
// ];
