import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
            const Text(
              "At Maidful, we value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and safeguard your data.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "1. Information We Collect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We may collect personal information such as your name, contact details, and any grievances you submit. We also collect data related to app usage to improve our services.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "2. How We Use Your Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We use your information to: \n 1. Process and respond to your grievances.\n2. Improve app functionality and user experience. \n3. Communicate important updates or announcements.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "3. Data Sharing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We do not sell or share your personal data with third parties, except when required by law or when necessary to provide our services (e.g., technical support).",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "4. Security",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We implement industry-standard security measures to protect your data from unauthorized access, loss, or misuse.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "5. Your Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You have the right to access, update, or delete your personal information. Please contact us if you have any questions or requests regarding your data.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "6. Changes to This Policy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We may update this Privacy Policy from time to time. We encourage you to review it periodically to stay informed about how we protect your information.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "7. Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "If you have any questions about this Privacy Policy or how your data is handled, please let your know your grievances in the Help & Support page.",
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
