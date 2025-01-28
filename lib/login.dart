import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ibitf_app/DAO/usersDao.dart';

import 'package:ibitf_app/forgot_password.dart';
import 'package:ibitf_app/home.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "", phno = "";
  GlobalVariables gv = GlobalVariables();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController phnocontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final List<bool> _iss = [true, false];
  List<String> lang = ['English', 'Khasi'];
  final _formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    GlobalVariables.instance.xmlHandler.loadStrings('English').then((val) {
      setState(() {});
    });
  }

  Widget addImage(name) {
    return Stack(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              name,
              fit: BoxFit.fill,
            )),
        const SizedBox(
          height: 30.0,
        ),
      ],
    );
  }

  Widget restOfIt({zero, first, second, third}) {
    return Column(children: [
      const SizedBox(
        height: 10.0,
      ),
      SizedBox(
        height: (Checkbox.width) * 1.5,
        child: Center(
            child: ToggleButtons(
          isSelected: _iss,
          onPressed: (int index) {
            setState(() {
              if (index == 0) {
                _iss[0] = true;
                _iss[1] = false;
              } else {
                _iss[0] = false;
                _iss[1] = true;
              }

              GlobalVariables.instance.selected = lang[index];
              GlobalVariables.instance.xmlHandler
                  .loadStrings(GlobalVariables.instance.selected);
            });
          },
          selectedColor: Colors.white,
          fillColor: Colors.green,
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          borderColor: Colors.grey,
          borderWidth: 0,
          children: const [Text('English'), Text('Khasi')],
        )),
      ),
      const SizedBox(
        height: 20.0,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
              //   decoration: BoxDecoration(
              //       color: const Color(0xFFedf0f8),
              //       borderRadius: BorderRadius.circular(30)),
              //   child: TextFormField(
              //     validator: (value) {
              //       if (value == null || value.isEmpty) {
              //         return 'Please Enter Phone Number';
              //       }
              //       return null;
              //     },
              //     controller: phnocontroller,
              //     decoration: const InputDecoration(
              //         border: InputBorder.none,
              //         hintText: "Ph. No.",
              //         hintStyle:
              //             TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
              //   ),
              // ),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFedf0f8),
                    borderRadius: BorderRadius.circular(30)),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter E-mail';
                    }
                    return null;
                  },
                  controller: mailcontroller,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email",
                      hintStyle:
                          TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFedf0f8),
                    borderRadius: BorderRadius.circular(30)),
                child: TextFormField(
                  controller: passwordcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Password';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Password",
                      hintStyle:
                          TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0)),
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      phno = phnocontroller.text;
                      email = mailcontroller.text;
                      password = passwordcontroller.text;
                    });
                  }
                  userLogin();
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13.0, horizontal: 30.0),
                    decoration: BoxDecoration(
                        color: const Color(0xFF273671),
                        borderRadius: BorderRadius.circular(30)),
                    child: const Center(
                        child: Text(
                      "Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ))),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 20.0,
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ForgotPassword()));
        },
        child: Text(GlobalVariables.instance.xmlHandler.getString('forgot'),
            style: const TextStyle(
                color: Color(0xFF8c8e98),
                fontSize: 18.0,
                fontWeight: FontWeight.w500)),
      ),
      const SizedBox(
        height: 40.0,
      ),
      Text(
        GlobalVariables.instance.xmlHandler.getString('signin'),
        style: const TextStyle(
            color: Color(0xFF273671),
            fontSize: 22.0,
            fontWeight: FontWeight.w500),
      ),
      const SizedBox(
        height: 30.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              {
                try {
                  final user = await AuthMethods.loginWithGoogle();
                  // final User? user = FirebaseAuth.instance.currentUser;
                  if (await isNoUser(user?.uid as String)) {
                    print("no data for google sign in");
                    registerUser(user);
                  } else {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Home()));
                  }
                } on FirebaseAuthException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    error.message ?? "Something went wrong",
                  )));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    error.toString(),
                  )));
                }
              }
            },
            child: Image.asset(
              "assets/google.png",
              height: 45,
              width: 45,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 40.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(GlobalVariables.instance.xmlHandler.getString('noac'),
              style: const TextStyle(
                  color: Color(0xFF8c8e98),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500)),
          const SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUp()));
            },
            child: Text(
              GlobalVariables.instance.xmlHandler.getString('signup'),
              style: const TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      )
    ]);
  }

  Future<bool> isNoUser(uid) async {
    bool res;
    QuerySnapshot qs = await Usersdao().getUserDetails(uid as String);
    // String role = "${qs.docs[0]["role"]}";
    if (qs.docs.isEmpty) {
      res = true;
    } else {
      res = false;
    }
    return res;
  }

  registerUser(User? usr) async {
    Map<String, dynamic> uploadUser = {
      "userid": usr?.uid,
      "username": usr?.email,
      "name": usr?.displayName,
      "role": "No role",
      "gender": " ",
      "address": " ",
      "dob": "2024-01-01",
      "language": " ",
      "remarks": " ",
    };
    await Usersdao().addUserDetails(uploadUser).whenComplete(() =>
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home())));
  }

  Future<void> saveFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      // Save the token in Firestore under the user document
      try {
        // Reference to the Firestore collection
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Query the users collection to find the document with the given userId
        QuerySnapshot querySnapshot = await firestore
            .collection('users') // assuming 'users' is your collection name
            .where('userid', isEqualTo: userId) // querying by 'userid'
            .get();

        // Check if a document was found
        if (querySnapshot.docs.isNotEmpty) {
          // Get the first document from the query result
          DocumentSnapshot document = querySnapshot.docs.first;

          // Set the fcmtoken in the document
          await firestore.collection('users').doc(document.id).update({
            'fcmtoken': token, // Set the 'fcmtoken' field
          });

          print('FCM token updated successfully.');
        } else {
          print('No user found with the given userid.');
        }
      } catch (e) {
        print('Error setting FCM token: $e');
      }
    }
  }

  void handleTokenRefresh(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        // Reference to the Firestore collection
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Query the users collection to find the document with the given userId
        QuerySnapshot querySnapshot = await firestore
            .collection('users') // assuming 'users' is your collection name
            .where('userid', isEqualTo: userId) // querying by 'userid'
            .get();

        // Check if a document was found
        if (querySnapshot.docs.isNotEmpty) {
          // Get the first document from the query result
          DocumentSnapshot document = querySnapshot.docs.first;

          // Set the fcmtoken in the document
          await firestore.collection('users').doc(document.id).update({
            'fcmtoken': newToken, // Set the 'fcmtoken' field
          });

          print('FCM token updated successfully.');
        } else {
          print('No user found with the given userid.');
        }
      } catch (e) {
        print('Error setting FCM token: $e');
      }
    });
  }

  userLogin() async {
    try {
      //last code

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .whenComplete(() {
        saveFcmToken(FirebaseAuth.instance.currentUser!.uid);
        handleTokenRefresh(FirebaseAuth.instance.currentUser!.uid);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      });

      // Phone Authentication
      // await AuthMethods().phoneAuthentication(phno, context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              GlobalVariables.instance.xmlHandler.getString('nouser'),
              style: const TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              GlobalVariables.instance.xmlHandler.getString('wrongpass'),
              style: const TextStyle(fontSize: 18.0),
            )));
      } else {
        print("Error for Phone No Login: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: isPortrait
                    ? Column(children: [
                        addImage(
                            "assets/${GlobalVariables.instance.selected}.jpg"),
                        restOfIt(zero: 18, first: 18, second: 22, third: 32)
                      ])
                    : Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Col(
                              //   children: [
                              // LayoutBuilder(builder: (context, constraints) {
                              SizedBox(
                                //margin: EdgeInsets.fromLTRB(10, 50, 0, 0),
                                width: (MediaQuery.sizeOf(context).width) / 1.5,
                                height: MediaQuery.sizeOf(context).height,
                                child: addImage(
                                    "assets/${GlobalVariables.instance.selected}.jpg"),

                                // );
                                // }
                              ),
                              //   ],
                              // ),
                              Container(
                                  width:
                                      (MediaQuery.of(context).size.width) / 3.3,
                                  alignment: Alignment.center,
                                  child: restOfIt(zero: 12))
                            ]),
                      ),
              ),
            ],
          ),
        );
      });
}
