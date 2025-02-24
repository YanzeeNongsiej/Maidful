import 'package:flutter/material.dart';

class ProfilePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> skills = ['Flutter', 'Dart', 'UI Design'];
  final String currentEmployer = "Tech Solutions";
  final String currentEmployerName = "John Doe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Implement edit functionality here
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Profile Header Section with Gradient Effect

          SizedBox(height: 20),

          // Skills Section with Animated Chip Removal
          Text("Skills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: skills.map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                labelStyle: TextStyle(color: Colors.white),
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    skills.remove(skill);
                  });
                },
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add_circle, color: Colors.teal, size: 30),
              onPressed: () {
                // Implement add skill functionality
                setState(() {
                  skills.add("New Skill");
                });
              },
            ),
          ),
          Divider(),

          // Active Services Section with Interactive Details
          Text("Active Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: Text(currentEmployer,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text("Current Employer"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Employer Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  content: Text(
                      "Employer: $currentEmployerName\nPosition: Senior Developer"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    )
                  ],
                ),
              );
            },
          ),
          Divider(),

          // My Own Services Section with Card Layout
          Text("My Own Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildServiceCard("Freelance Developer",
              "Building mobile applications for clients"),
          _buildServiceCard("UI/UX Designer",
              "Designing user interfaces for web and mobile apps"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add new service functionality here
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildServiceCard(String title, String description) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      shadowColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
