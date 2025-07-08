import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/chatpage.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> skillIds = [];
  String? selectedSkillId;
  String selectedSkillEn = '';
  String selectedSkillKs = '';
  final TextEditingController skillIdController = TextEditingController();
  final TextEditingController skillEnController = TextEditingController();
  final TextEditingController skillKsController = TextEditingController();

  final TextEditingController questionControllerEn = TextEditingController();
  final TextEditingController questionControllerKs = TextEditingController();
  final TextEditingController optionsEnController = TextEditingController();
  final TextEditingController optionsKsController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController targetSkillIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Increased length to 4 for the new "Documents" tab
    _tabController = TabController(length: 5, vsync: this);
    generateNextSkillId();
    loadSkillIds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadSkillIds() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();
    setState(() {
      skillIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> generateNextSkillId() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();
    final ids = snapshot.docs.map((doc) => doc.id).toList();

    int maxIndex = 0;
    for (var id in ids) {
      final match = RegExp(r'Skill(\d+)').firstMatch(id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxIndex) maxIndex = num;
      }
    }

    skillIdController.text = 'Skill${maxIndex + 1}';
  }

  Future<void> addSkill() async {
    await FirebaseFirestore.instance
        .collection('skills')
        .doc(skillIdController.text)
        .set({
      'English': skillEnController.text,
      'Khasi': skillKsController.text,
    });
    skillEnController.clear();
    skillKsController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Skill Added Successfully!', style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior:
            SnackBarBehavior.floating, // Floating snackbar for modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration:
            const Duration(seconds: 3), // How long to display the Snackbar
      ),
    );
    loadSkillIds();
    generateNextSkillId();
  }

  Future<void> addQuestion() async {
    final skillDoc =
        FirebaseFirestore.instance.collection('skills').doc(selectedSkillId);
    final questionsRef = FirebaseFirestore.instance
        .collection('skills')
        .doc(selectedSkillId)
        .collection('questions');

    final snapshot = await questionsRef.get();

    int maxQ = 0;
    for (var doc in snapshot.docs) {
      final match = RegExp(r'Q(\d+)').firstMatch(doc.id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxQ) maxQ = num;
      }
    }

    String newDocId = 'Q${maxQ + 1}';

    await questionsRef.doc(newDocId).set({
      'English': questionControllerEn.text,
      'Khasi': questionControllerKs.text,
      'EnglishOptions': optionsEnController.text.split(','),
      'KhasiOptions': optionsKsController.text.split(','),
      'Ans': answerController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Question Added Successfully!',
                style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior:
            SnackBarBehavior.floating, // Floating snackbar for modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration:
            const Duration(seconds: 3), // How long to display the Snackbar
      ),
    );
    questionControllerEn.clear();
    questionControllerKs.clear();
    optionsEnController.clear();
    optionsKsController.clear();
    answerController.clear();
  }

  Widget buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var userDoc = users[index];
            var user = userDoc.data() as Map<String, dynamic>;
            String docId = userDoc.id;

            final roleText = user['role'] == 1
                ? 'Maid'
                : user['role'] == 2
                    ? 'Employer'
                    : 'Admin';

            final roleColor = user['role'] == 1
                ? Colors.green
                : user['role'] == 2
                    ? Colors.blue
                    : Colors.orange;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage:
                      (user['url'] != null && user['url'].toString().isNotEmpty)
                          ? NetworkImage(user['url'])
                          : null,
                  child: (user['url'] == null || user['url'].toString().isEmpty)
                      ? Text(
                          (user['name'] ?? 'N')[0].toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        )
                      : null,
                ),
                title: Text(
                  user['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleText,
                        style: TextStyle(
                            fontSize: 12,
                            color: roleColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Address: ${user['address'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) async {
                    final usersRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId);
                    if (value == 'Promote to Admin') {
                      await usersRef.update({'role': 0});
                    } else if (value == 'Switch to Maid') {
                      await usersRef.update({'role': 1});
                    } else if (value == 'Switch to Employer') {
                      await usersRef.update({'role': 2});
                    } else if (value == 'Delete') {
                      final usersRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId);
                      final userSnapshot = await usersRef.get();
                      final data = userSnapshot.data();
                      final url = data?['url'];

                      if (url != null && url.toString().isNotEmpty) {
                        try {
                          final ref = FirebaseStorage.instance.refFromURL(url);
                          await ref.delete();
                        } catch (e) {
                          print('Failed to delete profile image: $e');
                        }
                      }

                      await usersRef.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Promote to Admin',
                      child: Text('Promote to Admin'),
                    ),
                    const PopupMenuItem(
                      value: 'Switch to Maid',
                      child: Text('Switch to Maid'),
                    ),
                    const PopupMenuItem(
                      value: 'Switch to Employer',
                      child: Text('Switch to Employer'),
                    ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: Text('Delete User',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // New Widget to build the Documents Tab
  Widget buildDocumentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('documents').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return const Center(
            child: Text(
              "No documents uploaded by users yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var doc = documents[index];
            var docData = doc.data() as Map<String, dynamic>;
            String userId = doc.id; // Document ID is the userId
            String? imageUrl = docData['url'];
            int verifiedStatus =
                docData['verified'] ?? 0; // Default to 0 (Unverified)

            IconData statusIcon;
            Color statusColor;
            String statusText;

            switch (verifiedStatus) {
              case 1: // Verified
                statusIcon = Icons.check_circle;
                statusColor = Colors.green;
                statusText = 'Verified';
                break;
              case -1: // Rejected
                statusIcon = Icons.cancel;
                statusColor = Colors.red;
                statusText = 'Rejected';
                break;
              case 0: // Unverified
              default:
                statusIcon = Icons.info;
                statusColor = Colors.orange;
                statusText = 'Unverified';
                break;
            }

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('userid', isEqualTo: userId)
                  .limit(1)
                  .get(),
              builder: (context, userSnapshot) {
                String userName = 'Unknown User';
                String? userProfilePicUrl;
                if (userSnapshot.hasData) {
                  final userData = userSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  userName = userData['name'];
                  print('hehe $userData');
                  userProfilePicUrl = userData['url'];
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: userProfilePicUrl != null &&
                                      userProfilePicUrl.isNotEmpty
                                  ? NetworkImage(userProfilePicUrl)
                                  : null,
                              child: (userProfilePicUrl == null ||
                                      userProfilePicUrl.isEmpty)
                                  ? Text(
                                      userName[0].toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'User ID: $userId',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        Text(
                          'Document:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              // Open image in full screen
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    child: Image.network(imageUrl,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image,
                                            color: Colors.grey, size: 40),
                                        Text('Image not available',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Text('No document image uploaded.',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Status: $statusText',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (verifiedStatus ==
                            0) // Only show buttons if unverified
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateDocumentStatus(
                                      userId, 1), // 1 for Verified
                                  icon: Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  label: Text('Accept',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateDocumentStatus(
                                      userId, -1), // -1 for Rejected
                                  icon: Icon(Icons.cancel_outlined,
                                      color: Colors.white),
                                  label: Text('Reject',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Function to update document verification status
  Future<void> _updateDocumentStatus(String userId, int status) async {
    try {
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(userId)
          .update({
        'verified': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Document status updated\n successfully!',
                  style: TextStyle(fontSize: 16)),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update document status: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error updating document status: $e');
    }
  }

  String _getOtherUserId(List<dynamic> users, String currentUserId) {
    return users.firstWhere((id) => id != currentUserId, orElse: () => '');
  }

  Widget buildChatTab() {
    final String? adminId = FirebaseAuth.instance.currentUser?.uid;

    if (adminId == null) {
      return const Center(
        child:
            Text("Admin not logged in.", style: TextStyle(color: Colors.red)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('users',
              arrayContains:
                  adminId) // Order by last message to show recent chats
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading chats: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No active chats yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final chatRooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatRooms.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var chatRoomDoc = chatRooms[index];
            var chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;

            List<dynamic> usersInRoom = chatRoomData['users'];
            String otherUserId = _getOtherUserId(usersInRoom, adminId);

            // Get last message and sender for notification logic
            String lastMessage =
                chatRoomData['lastMessage'] ?? 'No messages yet';
            String lastSenderId = chatRoomData['lastSender'] ?? '';
            bool readMsg = (chatRoomData['read_Msg'] is bool)
                ? chatRoomData['read_Msg']
                : true; // Default to true if field is missing or not bool

            // Determine if there are unread messages for the admin from this chat
            bool hasUnreadMessages =
                (lastSenderId != adminId && readMsg == false);

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('userid', isEqualTo: otherUserId)
                  .limit(1)
                  .get(),
              builder: (context, userSnapshot) {
                String displayUserName =
                    'Loading User...'; // Default loading state
                String? displayUserProfilePicUrl;
                bool userFound = false;

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Keep loading indicator if user data is still fetching
                  displayUserName = 'Loading User...';
                  displayUserProfilePicUrl = null; // No image while loading
                } else if (userSnapshot.hasError) {
                  // Handle error in fetching user data
                  displayUserName = 'User Info Error';
                  displayUserProfilePicUrl = null;
                  print('Error fetching user for chat: ${userSnapshot.error}');
                } else if (userSnapshot.hasData) {
                  // User data found
                  final userData = userSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  displayUserName = userData['name'] ?? 'Unknown User';
                  displayUserProfilePicUrl = userData['url'];
                  userFound = true;
                } else {
                  // User document does not exist
                  displayUserName = 'User Not Found';
                  displayUserProfilePicUrl = null;
                }

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo.shade100,
                      backgroundImage: displayUserProfilePicUrl != null &&
                              displayUserProfilePicUrl.isNotEmpty
                          ? NetworkImage(displayUserProfilePicUrl)
                          : null,
                      child: (displayUserProfilePicUrl == null ||
                              displayUserProfilePicUrl.isEmpty)
                          ? Text(
                              displayUserName[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            )
                          : null,
                    ),
                    title: Text(
                      displayUserName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasUnreadMessages ? Colors.black : Colors.grey,
                        fontWeight: hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Row(
                      // Use a Row for multiple trailing widgets
                      mainAxisSize: MainAxisSize
                          .min, // To make the row take minimum space
                      children: [
                        if (hasUnreadMessages)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'N', // Simple notification for new message
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          icon: const Icon(Icons.more_vert,
                              color: Colors.black87),
                          onSelected: (value) async {
                            if (value == 'Delete Chat') {
                              // Pass the otherUserId for recursive deletion
                              _deleteChatWithUser(context, otherUserId);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Delete Chat',
                              child: Text('Delete Chat',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Only allow chat if user data was successfully found
                      if (userFound) {
                        // Mark messages as read when admin opens the chat
                        if (hasUnreadMessages) {
                          FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(chatRoomDoc.id)
                              .update({
                            'read_Msg': true,
                          });
                        }
                        _startChatWithUser(context, otherUserId,
                            displayUserName, displayUserProfilePicUrl);
                      } else {
                        // Optionally show a message that chat cannot be opened
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Cannot open chat: User data not available.'),
                              backgroundColor: Colors.orange),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

// Function to delete all chat messages between admin and a specific user
// This function is now modified to recursively delete subcollections by finding the chatRoomId
  Future<void> _deleteChatWithUser(
      BuildContext context, String targetUserId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Admin not logged in.'), backgroundColor: Colors.red),
      );
      return;
    }
    String adminId = currentUser.uid;

    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Confirm Delete Chat'),
              content: Text(
                  'Are you sure you want to delete this chat and all its messages? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed

    if (!confirmDelete) {
      return;
    }

    try {
      // Find the chat room document ID using the 'users' array
      QuerySnapshot chatRoomsQuery = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('users', arrayContains: adminId)
          .get();

      String? chatRoomIdToDelete;
      for (var doc in chatRoomsQuery.docs) {
        List<dynamic> usersInRoom = doc['users'];
        if (usersInRoom.contains(targetUserId)) {
          chatRoomIdToDelete = doc.id;
          break;
        }
      }

      if (chatRoomIdToDelete == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Chat room not found for these users.'),
              backgroundColor: Colors.orange),
        );
        return;
      }

      // Get a reference to the chat room document using the found ID
      DocumentReference chatRoomRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomIdToDelete);

      // Get all messages in the 'messages' subcollection
      QuerySnapshot messagesSnapshot =
          await chatRoomRef.collection('messages').get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add all message deletion operations to the batch
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add the chat room document deletion operation to the batch
      batch.delete(chatRoomRef);

      // Commit the batch operations
      await batch.commit();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text('Chat and all messages deleted successfully!'),
      //       backgroundColor: Colors.green),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete chat: $e'),
            backgroundColor: Colors.red),
      );
      print('Error deleting chat: $e');
    }
  }

  void _startChatWithUser(BuildContext context, String receiverId,
      String receiverName, String? receiverPhotoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          name: receiverName,
          photo: receiverPhotoUrl!,
          receiverID: receiverId,
          readMsg: true, // Admin might want to read all messages
        ),
      ),
    );
  }

// Function to delete all chat messages between admin and a specific user

// Locate the `buildGrievancesTab()` method and replace it with the following:
  Widget buildGrievancesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grievances = snapshot.data!.docs;

        if (grievances.isEmpty) {
          return const Center(child: Text("No grievances submitted."));
        }

        return ListView.builder(
          itemCount: grievances.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var doc = grievances[index];
            var g = doc.data() as Map<String, dynamic>;
            final resolved = g['resolved'] == true;
            final String userId =
                g['userid']; // Assuming 'userid' field exists in grievance doc

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('userid', isEqualTo: userId)
                  .limit(1)
                  .get(),
              builder: (context, userSnapshot) {
                String userName = 'Unknown User';
                String? userProfilePicUrl;
                if (userSnapshot.hasData) {
                  final userData = userSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  userName = userData['name'];

                  userProfilePicUrl = userData['url'];
                }

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const ListTile(
                      leading: CircularProgressIndicator(strokeWidth: 2),
                      title: Text('Loading user info...'),
                    ),
                  );
                }

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo.shade100,
                      backgroundImage: userProfilePicUrl != null &&
                              userProfilePicUrl.isNotEmpty
                          ? NetworkImage(userProfilePicUrl)
                          : null,
                      child: (userProfilePicUrl == null ||
                              userProfilePicUrl.isEmpty)
                          ? Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            )
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          g['grievanceMessage'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          g['timestamp'] != null
                              ? (g['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                              : '',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        if (resolved)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text("Resolved",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green)),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onSelected: (value) async {
                        final ref = FirebaseFirestore.instance
                            .collection('grievances')
                            .doc(doc.id);

                        if (value == 'Resolve') {
                          await ref.update({'resolved': true});
                        } else if (value == 'Delete Grievance') {
                          await ref.delete();
                        } else if (value == 'Start Chat') {
                          _startChatWithUser(
                              context, userId, userName, userProfilePicUrl);
                        } else if (value == 'Delete Chat') {
                          _deleteChatWithUser(context, userId);
                        }
                      },
                      itemBuilder: (context) => [
                        if (!resolved)
                          const PopupMenuItem(
                            value: 'Resolve',
                            child: Text('Mark as Resolved'),
                          ),
                        const PopupMenuItem(
                          value: 'Start Chat',
                          child: Text('Start Chat'),
                        ),
                        const PopupMenuItem(
                          value: 'Delete Chat',
                          child: Text('Delete Chat',
                              style: TextStyle(color: Colors.red)),
                        ),
                        const PopupMenuItem(
                          value: 'Delete Grievance',
                          child: Text('Delete Grievance',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Skill",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: skillIdController,
            decoration: InputDecoration(labelText: 'Skill ID (Auto-generated)'),
            enabled: false,
          ),
          TextField(
              controller: skillEnController,
              decoration: InputDecoration(labelText: 'Skill Name (English)')),
          TextField(
              controller: skillKsController,
              decoration: InputDecoration(labelText: 'Skill Name (Khasi)')),
          ElevatedButton(onPressed: addSkill, child: const Text("Add Skill")),
          const Divider(),
          const Text("Add New Question",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: selectedSkillId,
            items: skillIds
                .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                .toList(),
            onChanged: (val) async {
              setState(() {
                selectedSkillId = val!;
              });

              // Fetch the selected skill's names
              final doc = await FirebaseFirestore.instance
                  .collection('skills')
                  .doc(selectedSkillId!)
                  .get();
              setState(() {
                selectedSkillEn = doc['English'] ?? '';
                selectedSkillKs = doc['Khasi'] ?? '';
              });
            },
            decoration: InputDecoration(labelText: 'Select Skill ID'),
          ),
          if (selectedSkillId != null) ...[
            SizedBox(height: 8),
            Text("English Name: $selectedSkillEn",
                style: TextStyle(color: Colors.black87)),
            Text("Khasi Name: $selectedSkillKs",
                style: TextStyle(color: Colors.black54)),
          ],
          TextField(
              controller: questionControllerEn,
              decoration: InputDecoration(labelText: 'Question (English)')),
          TextField(
              controller: questionControllerKs,
              decoration: InputDecoration(labelText: 'Question (Khasi)')),
          TextField(
              controller: optionsEnController,
              decoration: InputDecoration(
                  labelText: 'Options (English, comma separated)')),
          TextField(
              controller: optionsKsController,
              decoration: InputDecoration(
                  labelText: 'Options (Khasi, comma separated)')),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Correct Answer:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: List.generate(4, (index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: answerController.text == index.toString()
                          ? Colors.blueAccent
                          : Colors.grey,
                      minimumSize: Size(50, 50),
                    ),
                    onPressed: () {
                      setState(() {
                        answerController.text = index.toString();
                      });
                    },
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: addQuestion, child: const Text("Add Question")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Grievances'),
            Tab(text: 'Documents'),
            Tab(text: 'Chat'),
            Tab(text: 'Skills & Questions'),
            // New tab for documents
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildUsersTab(),
          buildGrievancesTab(),
          buildDocumentsTab(),
          buildChatTab(),
          buildSkillsTab(), // New tab content
        ],
      ),
    );
  }
}
