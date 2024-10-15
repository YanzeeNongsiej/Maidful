import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ibitf_app/DAO/employerdao.dart';
//pages
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/maid.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';
// import 'material_design_indicator.dart';

class MaidHome extends StatefulWidget {
  const MaidHome({super.key});

  @override
  _MaidHomePageState createState() => _MaidHomePageState();
}

class _MaidHomePageState extends State<MaidHome>
    with SingleTickerProviderStateMixin {
  final serverUrl = 'http://192.168.82.8:3000';

  final nameController = TextEditingController();
  final addressController = TextEditingController();

  Future<QuerySnapshot> fetchMaids() async {
    QuerySnapshot qs = await EmployerDao().getEmployer();
    return qs;
  }

  late TabController _tabController;

  final _selectedColor = const Color(0xff1a73e8);

  final _iconTabs = [
    const Tab(icon: Icon(Icons.home)),
    const Tab(icon: Icon(Icons.calendar_month)),
    const Tab(icon: Icon(Icons.settings)),
  ];
  final XMLHandler _xmlHandler = XMLHandler();
  GlobalVariables gv = GlobalVariables();
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _xmlHandler.loadStrings(gv.selected).then((a) {
      setState(() {});
    });
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
        break;
    }
  }

  Future<Maid> addItem(String name, String address) async {
    final response = await http.post(Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id': '0', 'name': name, 'address': address}));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic json = jsonDecode(response.body);
      print(Maid.fromJson(json));
      final Maid item = Maid.fromJson(json);

      return item;
    } else {
      throw Exception('Failed to add item');
    }
  }

  Future<void> updateItem(int id, String name) async {
    final response = await http.put(Uri.parse('$serverUrl/api/v1/items/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}));

    if (response.statusCode != 200) {
      throw Exception("Failed to update item");
    }
  }

  Future<void> deleteItem(int id) async {
    final response =
        await http.delete(Uri.parse('$serverUrl/api/v1/items/$id'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete item");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: _selectedColor,
        foregroundColor: Colors.white,
        title: const Text("Maidful"),
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
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: _iconTabs,
        unselectedLabelColor: Colors.black,
        labelColor: _selectedColor,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              spreadRadius: 5,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
          color: _selectedColor.withOpacity(0.2),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
              future: fetchMaids(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        child: Image.asset(
                          "assets/user.png",
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Text(
                        _xmlHandler.getString('welc'),
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          FutureBuilder(
              future: fetchMaids(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data!.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            foregroundImage:
                                NetworkImage(AuthMethods.user?.photoURL ?? ''),
                          ),
                          title: Text(item.get("name")),
                          subtitle: Text(item.get("address")),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // IconButton(
                              //   onPressed: () async {
                              //     await deleteItem(item.id);
                              //     setState(() {});
                              //   },
                              //   icon: const Icon(Icons.delete),
                              // ),
                              IconButton(
                                onPressed: () async {
                                  // Navigator.of(context).pushReplacement(
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ChatPage(
                                  //             name: item.get("name"))));

                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ChatPage(
                                  //             name: item.get("name"),
                                  //             receiverID: item.get("userid"))));
                                  // await deleteItem(item.id);
                                  // setState(() {});
                                },
                                icon: const Icon(Icons.chat_bubble),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Edit Item'),
                                          content: TextFormField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Item name',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // updateItem(item.id,
                                                //     nameController.text);
                                                setState(() {
                                                  nameController.clear();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Edit'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Center(
            child: Text(_xmlHandler.getString('setting')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Item'),
                  content: Column(children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                    )
                  ]),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        addItem(nameController.text, addressController.text);
                        setState(() {
                          nameController.clear();
                          addressController.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              });
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
