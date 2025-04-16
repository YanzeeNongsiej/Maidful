import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/faq.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/privacy.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/terms.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _grievanceController = TextEditingController();
  bool _isSubmitting = false;

  void _submitGrievance() async {
    if (_grievanceController.text.isNotEmpty) {
      setState(() => _isSubmitting = true);

      try {
        // Get current user details (Firebase Authentication)
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Get user ID and name
          String uid = user.uid;
          String name = await getNameFromId(uid); // Use displayName if set

          // Upload grievance to Firestore
          await FirebaseFirestore.instance.collection('grievances').add({
            'userid': uid,
            'name': name,
            'grievanceMessage': _grievanceController.text,
            'timestamp': FieldValue.serverTimestamp(), // Add timestamp
          });

          setState(() {
            _isSubmitting = false;
            _grievanceController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                      GlobalVariables.instance.xmlHandler
                          .getString('grievsucc'),
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              backgroundColor: Colors.indigo,
              behavior: SnackBarBehavior
                  .floating, // Floating snackbar for modern look
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 6,
              duration: const Duration(
                  seconds: 3), // How long to display the Snackbar
            ),
          );
        } else {
          // Handle if user is not signed in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                      GlobalVariables.instance.xmlHandler
                          .getString('grieverror'),
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 6,
            ),
          );

          setState(() => _isSubmitting = false);
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                    GlobalVariables.instance.xmlHandler.getString('grieverror'),
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 6,
          ),
        );

        setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(GlobalVariables.instance.xmlHandler.getString('grieventer'),
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 6,
        ),
      );
    }
  }

  @override
  void dispose() {
    _grievanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Help & Support"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Submit a Grievance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "If you have encountered any issues or need support, please describe your problem in detail. Our team will review and address your grievance promptly.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _grievanceController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Describe your issue here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitGrievance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit Grievance",
                              style: TextStyle(color: Colors.indigo),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Links",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading:
                          const Icon(Icons.help_outline, color: Colors.indigo),
                      title: const Text("FAQs"),
                      onTap: () {
                        // Navigate to FAQs page
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FAQsPage()));
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.book_outlined, color: Colors.indigo),
                      title: const Text("Terms & Conditions"),
                      onTap: () {
                        // Navigate to Terms & Conditions
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Terms(
                                  when: 2,
                                )));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined,
                          color: Colors.indigo),
                      title: const Text("Privacy Policy"),
                      onTap: () {
                        // Navigate to Privacy Policy
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
