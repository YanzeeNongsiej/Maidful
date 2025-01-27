import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _grievanceController = TextEditingController();
  bool _isSubmitting = false;

  void _submitGrievance() {
    if (_grievanceController.text.isNotEmpty) {
      setState(() => _isSubmitting = true);

      // Simulate grievance submission delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
          _grievanceController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grievance submitted successfully!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your grievance.')),
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
        title: Text("Help & Support"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search for help...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blueAccent),
              title: Text("Call Us"),
              subtitle: Text("1-800-123-4567"),
              onTap: () {
                // Add phone action
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blueAccent),
              title: Text("Email Us"),
              subtitle: Text("support@maidapp.com"),
              onTap: () {
                // Add email action
              },
            ),
            SizedBox(height: 20),
            Text(
              "Submit a Grievance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _grievanceController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your issue here...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitGrievance,
              style: ElevatedButton.styleFrom(
                iconColor: Colors.blueAccent,
              ),
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
