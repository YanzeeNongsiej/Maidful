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
        // "postType": newMessage.post_Type,
        // "postTypeID": newMessage.post_TypeID,
        "users": users,
        "timestamp": FieldValue.serverTimestamp(),
        "read_Msg": newMessage.read_Msg,
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
        "timestamp": FieldValue.serverTimestamp(),
        "read_Msg": newMessage.read_Msg,
      });
      return await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
      // return await FirebaseFirestore.instance
      //     .collection("chat_rooms")
      //     .doc(chatRoomID)
      //     .collection("messages")
      //     .doc()
      //     .update({"timestamp": FieldValue.serverTimestamp()});
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

  Future setMessage(
      Map<String, dynamic> serv, String messageID, String custommsg) async {
    List<String> ids = [
      serv['senderID'],
      serv['receiverID'],
    ];
    ids.sort();
    String chatRoomID = ids.join('_'), msg = "";
    return await FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID)
        .update({
      "message": custommsg,
    });
  }

  Future setAckStatus(Map<String, dynamic> serv, String ackID, int stat,
      String messageID) async {
    List<String> ids = [
      serv['senderID'],
      serv['receiverID'],
    ];
    ids.sort();
    String chatRoomID = ids.join('_'), msg = "";

    if (stat == 2 || stat == 3) {
      if (stat == 2) {
        msg = "Agreed";
      }
      if (stat == 3) {
        msg = "Rejected";
      }
      // await FirebaseFirestore.instance
      //     .collection("services")
      //     .doc(ackID)
      //     .update({
      //   "ack": ackn,
      // });

      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .doc(messageID)
          .update({
        "message": msg,
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
