import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//pages
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/maid.dart';
import 'package:ibitf_app/service/auth.dart';

// import 'material_design_indicator.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  final serverUrl = 'http://192.168.82.8:3000';

  final nameController = TextEditingController();
  final addressController = TextEditingController();

  Future<List<Maid>> fetchMaids() async {
    final response = await http.get(Uri.parse(serverUrl));
    if (response.statusCode == 200) {
      final List<dynamic> itemList = jsonDecode(response.body);
      final List<Maid> items = itemList.map((item) {
        return Maid.fromJson(item);
      }).toList();
      return items;
    } else {
      throw Exception("Failed to fetch Items!");
    }
  }

  late TabController _tabController;

  final _selectedColor = const Color(0xff1a73e8);

  final _iconTabs = [
    const Tab(icon: Icon(Icons.home)),
    const Tab(icon: Icon(Icons.group)),
    const Tab(icon: Icon(Icons.settings)),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
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
                  // return ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: snapshot.data!.length,
                  //     itemBuilder: (context, index) {
                  //       final item1 = snapshot.data![index];
                  //       final item = snapshot.data!.length;
                  //       return ListTile(
                  //         title: Text('length is $item'),
                  //       );
                  //     });

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
                      const Text(
                        "Welcome Admin",
                        style: TextStyle(
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
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return ListTile(
                          leading: CircleAvatar(
                            foregroundImage:
                                NetworkImage(AuthMethods.user?.photoURL ?? ''),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.address),
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
                                  await deleteItem(item.id);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.handshake),
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
                                                updateItem(item.id,
                                                    nameController.text);
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
          const Center(
            child: Text("This is the settings page"),
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
