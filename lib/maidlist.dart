import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/chatpage.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/service/auth.dart';

import 'package:ibitf_app/singleton.dart';

class MaidList extends StatefulWidget {
  const MaidList({super.key});

  @override
  _MaidListState createState() => _MaidListState();
}

class _MaidListState extends State<MaidList>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((a) {
      setState(() {});
    });
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
        break;
    }
  }

  getServiceDetail(item, servItem) {
    showDialog(
        context: context,
        builder: (context) {
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
                        Text(servItem.get("schedule")),
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
                                    child: Text("${servItem.get("days")[i]}"),
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
                          Text(
                              "${servItem.get("time_from")}-${servItem.get("time_to")}"),
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
                                  child: Text("${servItem.get("services")[i]}"),
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
                              Text(servItem.get("wage"),
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

  Future<QuerySnapshot> fetchUserData(String userId) async {
    QuerySnapshot qs = await Usersdao().getUserDetails(userId);
    return qs;
  }

  Future<QuerySnapshot> fetchServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot qs = await maidDao().getAllServices(userID);
    return qs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.red,
          title: const Text("Maids"),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: CircleAvatar(
                foregroundImage: NetworkImage(AuthMethods.user?.photoURL ?? ''),
              ),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Logout', 'Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            FutureBuilder(
                // StreamBuilder(
                future: fetchServices(),
                // stream: fetchChats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final servitem = snapshot.data!.docs[index];
                          // print("Service ID: ${servitem.id}");
                          return FutureBuilder(
                              future: fetchUserData(servitem.get("userid")),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final item = snapshot.data!.docs.first;
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          getServiceDetail(item, servitem);
                                        },
                                        child: Card(
                                          semanticContainer: true,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          // elevation: 10,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              foregroundImage: NetworkImage(
                                                  AuthMethods.user?.photoURL ??
                                                      ''),
                                            ),
                                            title: Text(item.get("name")),
                                            subtitle: Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_pin,
                                                  size: 15,
                                                ),
                                                Text(item.get("address")),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ChatPage(
                                                                name: item.get(
                                                                    "name"),
                                                                receiverID:
                                                                    item.get(
                                                                        "userid"),
                                                                postType:
                                                                    "services",
                                                                postTypeID:
                                                                    servitem
                                                                        .id)));
                                                  },
                                                  icon: const Icon(
                                                      Icons.chat_rounded),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text(snapshot.error.toString()));
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              });
                        });
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ));
  }
}
