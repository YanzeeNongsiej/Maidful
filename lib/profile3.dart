import 'package:flutter/material.dart';

class ProfilePage3 extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage3> {
  final List<Map<String, dynamic>> skills = [
    {'name': 'Grocery Shopping', 'percentage': 90},
    {'name': 'Garden Cleaning', 'percentage': 80},
    {'name': 'UI/UX Design', 'percentage': 70},
    {'name': 'React', 'percentage': 75},
    {'name': 'JavaScript', 'percentage': 70},
    {'name': 'Node.js', 'percentage': 65},
    {'name': 'Python', 'percentage': 60},
  ];
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
            // Background with Blue Gradient
            Positioned.fill(
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Main Profile Content
            ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Profile Header Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Image & Name
                      Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://www.w3schools.com/w3images/avatar2.png', // Default avatar image URL
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "John Doe",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Senior Developer",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Profile Info
                      _buildInfoRow("Location", "123 Main St, Springfield, IL"),
                      _buildInfoRow("Gender", "Not Specified"),
                      _buildInfoRow("DOB", "01 Jan 1990"),
                      _buildInfoRow("Languages", "English, Spanish"),
                      SizedBox(height: 16),
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
                            style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Skills Section with Smooth Animation for Percentage
                Text("Skills",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),

                // Skills in a GridView
                GridView.builder(
                  shrinkWrap:
                      true, // Important to make it fit inside the ListView
                  physics:
                      NeverScrollableScrollPhysics(), // Disable grid scroll as ListView handles it
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 4 columns for a compact layout
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio:
                        1.5, // Aspect ratio to make skills smaller
                  ),
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    return _buildSkillItem(skills[index]['name'] as String,
                        skills[index]['percentage'] as int);
                  },
                ),

                // Add Skill Button
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Logic to add a new skill (can be customized)
                        skills.add({
                          'name': 'New Skill',
                          'percentage': 0
                        }); // Adding a dummy new skill
                      });
                    },
                    child: Text("Add Skill"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                  ),
                ),
                Divider(),

                // Active Services with Expandable View
                Text("Active Services",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(currentEmployer,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text("Current Employer",
                      style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showServiceDetails(context);
                  },
                ),
                Divider(),

                // Personal Services Section with Card Layout
                Text("My Services",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildServiceCard("Freelance Developer",
                    "Building custom mobile apps for clients."),
                _buildServiceCard("UI/UX Designer",
                    "Designing intuitive and engaging user interfaces."),
              ],
            ),
            // Floating Action Button
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Implement action here
                },
                backgroundColor: Colors.teal,
                child: Icon(Icons.add, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility function to build info rows for profile
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  // Modal for showing more service details
  void _showServiceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Employer Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        );
      },
    );
  }

  // Service card for displaying personal services
  Widget _buildServiceCard(String title, String description) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(description, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // Skill Item with Percentage Animation
  // Skill Section with Horizontal Scrolling

// Skill Item (Compact Card with Animation)
  Widget _buildSkillItem(String skillName, int percentage) {
    return Container(
      padding: EdgeInsets.all(8), // Reduced padding to make skill card smaller
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use Expanded to allow the text to take as much space as needed
          Expanded(
            child: Align(
              alignment: Alignment.center, // Optional: for centering the text
              child: Text(
                skillName,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, // Ensures text is centered
              ),
            ),
          ),
          SizedBox(height: 4),
          AnimatedContainer(
            duration: Duration(seconds: 2),
            width: double.infinity,
            height: 5, // Reduced height of the progress bar
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.teal,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                color: Colors.tealAccent,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text("$percentage%",
              style: TextStyle(
                  fontSize: 10, color: Colors.grey)), // Smaller font size
        ],
      ),
    );
  }
}
