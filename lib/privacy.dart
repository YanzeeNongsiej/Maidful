import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              GlobalVariables.instance.xmlHandler.getString('atmaid'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('infocol'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('ansinfocol'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('infohow'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('ansinfohow'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('datashar'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('ansdatashar'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('secur'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('anssecur'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('urright'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('ansurright'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('changepol'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('anschangepol'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              GlobalVariables.instance.xmlHandler.getString('contus'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              GlobalVariables.instance.xmlHandler.getString('anscontus'),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade200,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Back to Help & Support",
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
