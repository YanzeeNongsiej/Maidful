import "package:cloud_firestore/cloud_firestore.dart";
import "package:ibitf_app/model/chat.dart";

class Chatdao {
  Future addNewMessage(String chatRoomID, Chat newMessage) async {
    int isEmptyFlag = 1;
    final snapshot =
        await FirebaseFirestore.instance.collection(chatRoomID).get();
    if (snapshot.docs.isNotEmpty) {
      isEmptyFlag = 0;
    }
    if (isEmptyFlag == 1) {
      List<String> users = [newMessage.senderID, newMessage.receiverID];
      Map<String, dynamic> chatDetails = {
        "lastSender": newMessage.senderID,
        "lastMessage": newMessage.message,
        "postType": newMessage.post_Type,
        "postTypeID": newMessage.post_TypeID,
        "users": users,
        "timestamp": newMessage.timestamp,
      };
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .set(chatDetails);
      return await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } else {
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .update({
        "lastSender": newMessage.senderID,
        "lastMessage": newMessage.message,
        "timestamp": newMessage.timestamp
      });
      return await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    }
  }

  Stream<QuerySnapshot> getMessages(String chatRoomID) {
    return FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChats(String userID) async {
    return FirebaseFirestore.instance
        .collection("chat_rooms")
        .orderBy("timestamp", descending: true)
        .where("users", arrayContains: userID)
        .snapshots();
  }

  Future setAckStatus(String servID, String ackID, int stat) async {
    if (stat == 2) {
      await FirebaseFirestore.instance
          .collection("services")
          .doc(servID)
          .update({
        "ack": true,
      });
    }
    return await FirebaseFirestore.instance
        .collection("acknowledgements")
        .doc(ackID)
        .update({
      "status": stat,
    });
  }
}
