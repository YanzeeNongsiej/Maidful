import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

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
            Text(
              GlobalVariables.instance.xmlHandler.getString('freq'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            buildFAQItem(
              GlobalVariables.instance.xmlHandler.getString('howgriev'),
              GlobalVariables.instance.xmlHandler.getString('anshowgriev'),
            ),
            buildFAQItem(
              GlobalVariables.instance.xmlHandler.getString('whocan'),
              GlobalVariables.instance.xmlHandler.getString('answhocan'),
            ),
            buildFAQItem(
              GlobalVariables.instance.xmlHandler.getString('dataprot'),
              GlobalVariables.instance.xmlHandler.getString('ansdataprot'),
            ),
            buildFAQItem(
              GlobalVariables.instance.xmlHandler.getString('caniup'),
              GlobalVariables.instance.xmlHandler.getString('anscaniup'),
            ),
            buildFAQItem(
              GlobalVariables.instance.xmlHandler.getString('howcust'),
              GlobalVariables.instance.xmlHandler.getString('anshowcust'),
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
