import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:ibitf_app/DAO/usersdao.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/terms.dart';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  final String phone;
  const SignUp({super.key, required this.phone});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final dobController = TextEditingController();
  String? gender;
  String? role;
  List<String> selectedLanguages = [];
  final List<String> languages = [
    'English',
    "Khasi",
    "Hindi",
    "Garo",
    "Nepali",
    "Bengali"
  ];

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void _toggleLanguage(String lang) {
    setState(() {
      if (selectedLanguages.contains(lang)) {
        selectedLanguages.remove(lang);
      } else {
        selectedLanguages.add(lang);
      }
    });
  }

  void register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a user ID (if needed, e.g., Firestore auto-ID)
        String userId = FirebaseAuth.instance.currentUser!.uid;

        final uploadUser = {
          'userid': userId,
          'name': nameController.text.trim(),
          'username': widget.phone,
          'address': addressController.text.trim(),
          'phone': widget.phone, // Phone from postLoginRoute
          'role': role == 'Maid' ? 1 : 2,
          'gender': gender == "Male" ? 2 : 1,
          'language': selectedLanguages,
          'dob': dobController.text.trim(),
          'url':
              "https://firebasestorage.googleapis.com/v0/b/authenticationapp-2f932.appspot.com/o/finalprofile.png?alt=media&token=f8c430f2-5a49-452e-a51c-3010b9db4211"
        };

        await Usersdao().addUserDetails(uploadUser).whenComplete(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    GlobalVariables.instance.xmlHandler.getString('regsuck'),
                    style: TextStyle(fontSize: 16),
                  ),
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

          // Navigate to Home or wherever after registration
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (_) => const Home()),
          //   (route) => false,
          // );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Terms(uname: nameController.text.trim(), uid: userId)));
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Registration failed: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel("Phone Number:"),
                    const SizedBox(height: 12),
                    _buildTextField(
                        "Phone", TextEditingController(text: widget.phone),
                        readOnly: true),
                    const SizedBox(height: 20),
                    _buildTextField("Name", nameController),
                    const SizedBox(height: 12),
                    _buildTextField("Address", addressController),
                    const SizedBox(height: 12),
                    _buildTextField("Date of Birth", dobController,
                        readOnly: true, onTap: _selectDate),
                    const SizedBox(height: 12),
                    _buildLabel("Role:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRadio("Maid", "Maid", role),
                        const SizedBox(width: 10),
                        _buildRadio("Employer", "Employer", role),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLabel("Gender:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRadio("Female", "Female", gender),
                        const SizedBox(width: 10),
                        _buildRadio("Male", "Male", gender),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLabel("Languages Known:"),
                    Wrap(
                      spacing: 8,
                      children: languages.map((lang) {
                        return FilterChip(
                          label: Text(lang,
                              style: const TextStyle(color: Colors.black)),
                          selected: selectedLanguages.contains(lang),
                          onSelected: (_) => _toggleLanguage(lang),
                          selectedColor: Colors.blueAccent.withOpacity(0.6),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                      ),
                      child: const Text("Register",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRadio(String label, String value, String? groupValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: (val) =>
              setState(() => groupValue == role ? role = val : gender = val),
          activeColor: Colors.white,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}


// import 'package:ibitf_app/home.dart';
// import 'package:ibitf_app/login.dart';
// import 'package:ibitf_app/DAO/usersDao.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ibitf_app/singleton.dart';

// class SignUp extends StatefulWidget {
//   const SignUp({super.key});

//   @override
//   State<SignUp> createState() => _SignUpState();
// }

// class _SignUpState extends State<SignUp> {
//   String email = "", password = "", name = "";
//   TextEditingController namecontroller = TextEditingController();
//   TextEditingController passwordcontroller = TextEditingController();
//   TextEditingController mailcontroller = TextEditingController();

//   final _formkey = GlobalKey<FormState>();
//   final serverUrl = 'http://192.168.82.8:3000';

//   registration() async {
//     if (password != "" &&
//         namecontroller.text != "" &&
//         mailcontroller.text != "") {
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(email: email, password: password);
//         final User? user = FirebaseAuth.instance.currentUser;
//         Map<String, dynamic> uploadUser = {
//           "userid": user?.uid,
//           "username": mailcontroller.text,
//           "name": namecontroller.text,
//           "role": "No role",
//           "gender": "",
//           "address": "",
//           "dob": "2024-01-01",
//           "language": "",
//           "remarks": "",
          
//         };
        // await Usersdao().addUserDetails(uploadUser).whenComplete(() {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Row(
        //         children: [
        //           Icon(Icons.check_circle_outline, color: Colors.white),
        //           SizedBox(width: 10),
        //           Text(GlobalVariables.instance.xmlHandler.getString('regsuck'),
        //               style: TextStyle(fontSize: 16)),
        //         ],
        //       ),
        //       backgroundColor: Colors.indigo,
        //       behavior: SnackBarBehavior
        //           .floating, // Floating snackbar for modern look
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //       elevation: 6,
        //       duration: const Duration(
        //           seconds: 3), // How long to display the Snackbar
        //     ),
        //   );
        // });
//         try {
//           await FirebaseAuth.instance
//               .signInWithEmailAndPassword(email: email, password: password);
//           Navigator.push(
//               context, MaterialPageRoute(builder: (context) => const Home()));
//         } on FirebaseAuthException catch (e) {
//           if (e.code == 'user-not-found') {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                 backgroundColor: Colors.orangeAccent,
//                 content: Text(
//                   "No User Found for that Email",
//                   style: TextStyle(fontSize: 18.0),
//                 )));
//           } else if (e.code == 'wrong-password') {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                 backgroundColor: Colors.orangeAccent,
//                 content: Text(
//                   "Wrong Password Provided by User",
//                   style: TextStyle(fontSize: 18.0),
//                 )));
//           }
//         }
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               backgroundColor: Colors.orangeAccent,
//               content: Text(
//                 "Password Provided is too Weak",
//                 style: TextStyle(fontSize: 18.0),
//               )));
//         } else if (e.code == "email-already-in-use") {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               backgroundColor: Colors.orangeAccent,
//               content: Text(
//                 "Account Already exists",
//                 style: TextStyle(fontSize: 18.0),
//               )));
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: Image.asset(
//                   "assets/car.jpg",
//                   fit: BoxFit.cover,
//                 )),
//             const SizedBox(
//               height: 30.0,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//               child: Form(
//                 key: _formkey,
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFedf0f8),
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Name';
//                           }
//                           return null;
//                         },
//                         controller: namecontroller,
//                         decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Name",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFedf0f8),
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Email';
//                           }
//                           return null;
//                         },
//                         controller: mailcontroller,
//                         decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Email",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFedf0f8),
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Password';
//                           }
//                           return null;
//                         },
//                         controller: passwordcontroller,
//                         decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Password",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                         obscureText: true,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (_formkey.currentState!.validate()) {
//                           setState(() {
//                             email = mailcontroller.text;
//                             name = namecontroller.text;
//                             password = passwordcontroller.text;
//                           });
//                         }
//                         registration();
//                       },
//                       child: Container(
//                           width: MediaQuery.of(context).size.width,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 13.0, horizontal: 30.0),
//                           decoration: BoxDecoration(
//                               color: const Color(0xFF273671),
//                               borderRadius: BorderRadius.circular(30)),
//                           child: const Center(
//                               child: Text(
//                             "Sign Up",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22.0,
//                                 fontWeight: FontWeight.w500),
//                           ))),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 40.0,
//             ),
//             const SizedBox(
//               height: 40.0,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Already have an account?",
//                     style: TextStyle(
//                         color: Color(0xFF8c8e98),
//                         fontSize: 18.0,
//                         fontWeight: FontWeight.w500)),
//                 const SizedBox(
//                   width: 5.0,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const LogIn()));
//                   },
//                   child: const Text(
//                     "LogIn",
//                     style: TextStyle(
//                         color: Color(0xFF273671),
//                         fontSize: 20.0,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
