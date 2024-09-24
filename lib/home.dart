import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:multiselect/multiselect.dart';

//pages
import 'package:ibitf_app/employerhome.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/adminhome.dart';
import 'package:ibitf_app/maidhome.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/DAO/usersdao.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';
// import 'material_design_indicator.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> with SingleTickerProviderStateMixin {
  String address = "", dob = "";
  String? name, docid;

  final User? user = FirebaseAuth.instance.currentUser;
  final namecontroller = TextEditingController();
  final dobcontroller = TextEditingController();
  final addressController = TextEditingController();
  final remarksController = TextEditingController();
  XMLHandler _xmlHandler = XMLHandler();
  late TabController _tabController;
  int _selectedValue = 1;
  int _selectedRoleValue = 1;
  List<String> variantsList = [
    'English',
    "Khasi",
    "Hindi",
    "Garo",
    "Nepali",
    "Bengali"
  ];
  List<String> selectedCheckBoxValue = [];

  GlobalVariables gv = GlobalVariables();

  final _formkey = GlobalKey<FormState>();

  register() async {
    if (addressController.text != "" && dobcontroller.text != "") {
      await Usersdao().updateUserDetails(
          docid as String,
          _selectedRoleValue,
          _selectedValue,
          addressController.text,
          dobcontroller.text,
          selectedCheckBoxValue,
          remarksController.text);
      if (_selectedRoleValue == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MaidHome()));
      } else if (_selectedRoleValue == 2) {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EmployerHome(
                      uname: name,
                      uid: user!.uid,
                    )));
      }
    }
  }

  final _selectedColor = const Color(0xff1a73e8);
  DateTime dt = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  String dte = "Date of birth";
  Color _dobColor = const Color(0xFFb2b7bf);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _xmlHandler.loadStrings(gv.selected);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  getRole() async {
    String role;
    QuerySnapshot qs = await Usersdao().getUserDetails(user?.uid as String);
    if (qs.docs.isNotEmpty) {
      name = "${qs.docs[0]["name"]}";
      docid = qs.docs[0].id;
      role = "${qs.docs[0]["role"]}";
    } else {
      name = "Mary";
      role = "No role";
    }
    return role;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getRole(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final item = snapshot.data!;
              if (item == 'admin') {
                return const AdminHome();
              } else if (item == "2") {
                return EmployerHome(
                  uname: name,
                  uid: user!.uid,
                );
              } else if (item == "1") {
                return EmployerHome(
                  uname: name,
                  uid: user!.uid,
                );
                // return const MaidHome();
              } else {
                //create another page to finish setup for the below code
                return Scaffold(
                  appBar: AppBar(
                    leading: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          tooltip: MaterialLocalizations.of(context)
                              .openAppDrawerTooltip,
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
                          foregroundImage:
                              NetworkImage(AuthMethods.user?.photoURL ?? ''),
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
                  body: FutureBuilder(
                      future: getRole(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // final item = snapshot.data!;
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Finish Setting Up your profile",
                                          style: TextStyle(
                                              color: Color(0xFF8c8e98),
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFedf0f8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: TextFormField(
                                      controller: namecontroller,
                                      decoration: InputDecoration(
                                          enabled: false,
                                          border: InputBorder.none,
                                          labelText: name,
                                          labelStyle: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 18.0)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: 1,
                                                    groupValue:
                                                        _selectedRoleValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedRoleValue =
                                                            value!; // Update _selectedValue when option 1 is selected
                                                      });
                                                    }),
                                                const Expanded(
                                                  child: Text('Employee(Maid)'),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: 2,
                                                    groupValue:
                                                        _selectedRoleValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedRoleValue =
                                                            value!; // Update _selectedValue when option 1 is selected
                                                      });
                                                    }),
                                                const Expanded(
                                                    child: Text('Employer'))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: 1,
                                                    groupValue: _selectedValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedValue =
                                                            value!; // Update _selectedValue when option 1 is selected
                                                      });
                                                    }),
                                                const Expanded(
                                                  child: Text('Male'),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: 2,
                                                    groupValue: _selectedValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedValue =
                                                            value!; // Update _selectedValue when option 1 is selected
                                                      });
                                                    }),
                                                const Expanded(
                                                    child: Text('Female'))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFedf0f8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Address';
                                        }
                                        return null;
                                      },
                                      controller: addressController,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Address",
                                          hintStyle: TextStyle(
                                              color: Color(0xFFb2b7bf),
                                              fontSize: 18.0)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFedf0f8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Select Date of Birth';
                                        }
                                        return null;
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
                                                  child: CupertinoDatePicker(
                                                    mode:
                                                        CupertinoDatePickerMode
                                                            .date,
                                                    initialDateTime: dt,
                                                    onDateTimeChanged:
                                                        (DateTime newDateTime) {
                                                      dt = newDateTime;
                                                      dte =
                                                          dateFormat.format(dt);
                                                      dobcontroller.text = dte;
                                                      _dobColor =
                                                          const Color.fromARGB(
                                                              255, 0, 0, 0);
                                                      // Do something
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },

                                      // controller: passwordcontroller,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Date of Birth',
                                          hintStyle: TextStyle(
                                              color: _dobColor,
                                              fontSize: 18.0)),
                                      readOnly: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Language(s) known:",
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  DropDownMultiSelect(
                                    validator: ($selectedCheckBoxValue) {
                                      if (selectedCheckBoxValue.isEmpty) {
                                        return 'Please Select language';
                                      } else {
                                        return '';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      focusColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1.5)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 1.5,
                                          )),
                                      errorBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          borderSide: BorderSide(
                                              color: Colors.red, width: 1.5)),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1.5)),
                                    ),
                                    options: variantsList,
                                    selectedValues: selectedCheckBoxValue,
                                    onChanged: (List<String> value) {
                                      //   value = selectedCheckBoxValue;
                                    },
                                    whenEmpty: 'Select Language',
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFedf0f8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: TextFormField(
                                      controller: remarksController,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Remarks",
                                          hintStyle: TextStyle(
                                              color: Color(0xFFb2b7bf),
                                              fontSize: 18.0)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_formkey.currentState!.validate()) {
                                        setState(() {
                                          address = addressController.text;
                                          dob = dobcontroller.text;
                                          // password = passwordcontroller.text;
                                        });
                                      }
                                      register();
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13.0, horizontal: 30.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF273671),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: const Center(
                                            child: Text(
                                          "Save",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w500),
                                        ))),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                );
              }
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              print("circular");
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
