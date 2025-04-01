import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            buildFAQItem(
              "How do I submit a grievance?",
              "You can submit a grievance by navigating to the Help & Support section and filling out the grievance form. Provide as many details as possible to help us address your issue quickly.",
            ),
            buildFAQItem(
              "Who can use this app?",
              "This app is designed for both homeowners and maids. Homeowners can find and hire maids, and maids can manage their job applications and profiles.",
            ),
            buildFAQItem(
              "How is my data protected?",
              "We take your privacy seriously and implement industry-standard security measures to protect your information. Please review our Privacy Policy for more details.",
            ),
            buildFAQItem(
              "Can I update or delete my account?",
              "Yes, you can update your profile details or delete your account in the Profile section of the app.",
            ),
            buildFAQItem(
              "How do I contact customer support?",
              "If you need assistance, you can submit a grievance or review our Privacy Policy and Terms & Conditions. Our support team will address your concerns as quickly as possible.",
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

  Widget buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
