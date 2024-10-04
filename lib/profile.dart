import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/jobprofile.dart';
import 'package:ibitf_app/jobresume.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          ProfileSections(),
        ],
      ),
    );
  }
}

class ProfileSections extends StatefulWidget {
  @override
  State<ProfileSections> createState() => _ProfileSectionsState();
}

class _ProfileSectionsState extends State<ProfileSections> {
  XMLHandler _xmlHandler = XMLHandler();
  GlobalVariables gv = GlobalVariables();
  String? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _xmlHandler.loadStrings(gv.selected).then((val) {
      setState(() {});
      user = gv.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('(link unavailable)'),
              ),
              SizedBox(height: 10),
              Text(
                user ?? "Usernsme",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'User Bio',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              (_xmlHandler.getString('active')).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
                              ((_xmlHandler.getString('myserv')).toString()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            _buildServiceList(),
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
                  )
                ],
              ),
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
                              (_xmlHandler.getString('posted')).toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            _buildJobProfileList(),
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
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildServiceList() {
    return FutureBuilder(
        future: fetchOwnServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("loading...");
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Text("No Services Yet");
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];
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
                                        TextSpan(
                                          text:
                                              "${item.get("time_from")}-${item.get("time_to")}",
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
            return const Text("No Services Yet");
          }
        });
  }

  Widget _buildJobProfileList() {
    return FutureBuilder(
        future: fetchOwnJobProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("loading...");
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Text("No Services Yet");
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];
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
                                        TextSpan(
                                          text:
                                              "${item.get("time_from")}-${item.get("time_to")}",
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
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const Text("No Services Yet");
          }
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
}

class ProfileSection extends StatelessWidget {
  final String title;
  final int count;

  ProfileSection({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            ' ',
            style: TextStyle(fontSize: 18),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
