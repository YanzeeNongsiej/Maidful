import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ibitf_app/DAO/usersDao.dart';
import 'package:ibitf_app/OTPScreen.dart';

import 'package:ibitf_app/forgot_password.dart';
import 'package:ibitf_app/home.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:ibitf_app/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';

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

  // Future<bool> isNoUser(uid) async {
  //   bool res;
  //   QuerySnapshot qs = await Usersdao().getUserDetails(uid as String);

  //   if (qs.docs.isEmpty) {
  //     res = true;
  //   } else {
  //     res = false;
  //   }
  //   return res;
  // }

  // registerUser(User? usr) async {
  //   Map<String, dynamic> uploadUser = {
  //     "userid": usr?.uid,
  //     "username": usr?.email,
  //     "name": usr?.displayName,
  //     "role": "No role",
  //     "gender": " ",
  //     "address": " ",
  //     "dob": "2024-01-01",
  //     "language": " ",
  //     "remarks": " ",
  //   };
  //   await Usersdao().addUserDetails(uploadUser).whenComplete(() =>
  //       Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => const Home())));
  // }

  // userLogin() async {
  //   try {
  //     await AuthMethods().phoneAuthentication(phno, context);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           backgroundColor: Colors.orangeAccent,
  //           content: Text(
  //             GlobalVariables.instance.xmlHandler.getString('nouser'),
  //             style: const TextStyle(fontSize: 18.0),
  //           )));
  //     }
  //     // else if (e.code == 'wrong-password') {
  //     //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //       backgroundColor: Colors.orangeAccent,
  //     //       content: Text(
  //     //         GlobalVariables.instance.xmlHandler.getString('wrongpass'),
  //     //         style: const TextStyle(fontSize: 18.0),
  //     //       )));
  //     // }
  //     else {
  //       print("Error for Phone No Login: $e");
  //     }
  //   }
  // }
  Future<void> postLoginRoute(String phone) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users');
      final result =
          await userRef.where('phone', isEqualTo: phone).limit(1).get();

      if (result.docs.isNotEmpty) {
        // User exists, go to Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
          (route) => false,
        );
      } else {
        // User doesn't exist, go to Signup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignUp()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error checking user: $e");
    }
  }

  Future<void> userLogin() async {
    String phone = phnocontroller.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: "Enter phone number");
      return;
    }

    String fullPhone = "+91$phone"; // assuming India

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification works on Android
        await FirebaseAuth.instance.signInWithCredential(credential);
        await postLoginRoute(phone);
      },
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: "Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phone: phone,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Widget restOfIt() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToggleButtons(
                  isSelected: _iss,
                  onPressed: (int index) {
                    setState(() {
                      _iss[0] = index == 0;
                      _iss[1] = index == 1;
                      GlobalVariables.instance.selected = lang[index];
                      GlobalVariables.instance.xmlHandler
                          .loadStrings(GlobalVariables.instance.selected);
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: Colors.blueAccent,
                  color: Colors.white,
                  borderColor: Colors.white70,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("English"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Khasi"),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: phnocontroller,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please Enter Phone Number'
                      : null,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Ph. No.",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        phno = phnocontroller.text;
                        email = mailcontroller.text;
                        password = passwordcontroller.text;
                      });
                      userLogin();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF48B2FE), // Light blue top
                  Color(0xFF1897FE), // BlueAccent bottom
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: isPortrait
                    ? Column(
                        children: [
                          Image.asset(
                            "assets/${GlobalVariables.instance.selected}.jpg",
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: restOfIt(),
                          ),
                          const SizedBox(height: 40), // Add some bottom spacing
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                "assets/${GlobalVariables.instance.selected}.jpg",
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: restOfIt(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
