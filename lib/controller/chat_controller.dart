import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/model/chat.dart';
import 'package:ibitf_app/DAO/chatdao.dart';
import 'package:ibitf_app/notifservice.dart';

class ChatController extends ChangeNotifier {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> sendMessage(
      String receiverID,
      message,
      ackid,
      //  postType, postTypeID,
      readMsg) async {
    //get current user info
    final String currentUserID = user!.uid;
    final String currentUserEmail = user!.email as String;
    final timestamp = FieldValue.serverTimestamp();

    //create new message

    Chat chat;
    if (ackid == "") {
      chat = Chat(
          senderID: currentUserID,
          senderEmail: currentUserEmail,
          message: message,
          receiverID: receiverID,
          timestamp: timestamp,
          ackID: "",
          // post_Type: postType,
          // post_TypeID: postTypeID,
          read_Msg: readMsg);
    } else {
      chat = Chat(
          senderID: currentUserID,
          senderEmail: currentUserEmail,
          message: message,
          receiverID: receiverID,
          timestamp: timestamp,
          ackID: ackid,
          // post_Type: postType,
          // post_TypeID: postTypeID,
          read_Msg: readMsg);
    }

    //construct chatroom ID for two users(sorted)
    List<String> ids = [
      currentUserID, receiverID,
      // postTypeID
    ];
    ids.sort();
    String chatRoomID = ids.join('_');

    //add new message to database
    await Chatdao().addNewMessage(chatRoomID, chat).then((a) {});
    String name = await getNameFromId(currentUserID);
    notifyUser(receiverID, name, message);
  }

  // get messages
  Stream<QuerySnapshot> getMessages(
    String userID,
    otherUserID,
    // postType, postTypeID
  ) {
    List<String> ids = [
      userID, otherUserID,
      // postTypeID
    ];
    ids.sort();
    String chatRoomID = ids.join('_');
    return Chatdao().getMessages(chatRoomID);
  }

  Future<Stream<QuerySnapshot>> getChats(String userID) async {
    return Chatdao().getChats(userID);
  }
}
