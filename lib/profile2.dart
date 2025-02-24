import 'package:flutter/material.dart';

class ProfilePage2 extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage2> {
  final List<String> skills = ['Flutter', 'Dart', 'UI Design'];
  final String currentEmployer = "Tech Solutions";
  final String currentEmployerName = "John Doe";
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background with Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueGrey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Main Content
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Profile Card with Floating Effect
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage("https://www.example.com/profile.jpg"),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "John Doe",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "123 Main St, Springfield, IL",
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Gender: Male",
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "DOB: 01 Jan 1990",
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Languages: English, Spanish",
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Implement edit profile functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                        ),
                        child: Text("Edit Profile",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Skills Section with Animated Chips
                Text("Skills",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return GestureDetector(
                      onTap: () {
                        // Remove skill on tap
                        setState(() {
                          skills.remove(skill);
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(skill, style: TextStyle(color: Colors.white)),
                            Icon(Icons.cancel, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
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

                // Active Services Section
                Text("Active Services",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text(currentEmployer,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: Text("Current Employer"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        backgroundColor:
                            isDarkMode ? Colors.grey[850] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Employer Details",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text("Employer: $currentEmployerName"),
                              Text("Position: Senior Developer"),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Close"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Divider(),

                // My Own Services Section
                Text("My Own Services",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildServiceCard("Freelance Developer",
                    "Building mobile applications for clients"),
                _buildServiceCard("UI/UX Designer",
                    "Designing user interfaces for web and mobile apps"),
              ],
            ),
            // Floating Action Button for adding new service
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Implement add new service functionality
                },
                backgroundColor: Colors.teal,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
