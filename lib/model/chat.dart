import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String senderID;
  final String senderEmail;
  final String message;
  final String receiverID;
  final timestamp;
  final String ackID;
  // final String post_Type;
  // final String post_TypeID;
  final bool read_Msg;

  Chat(
      {required this.senderID,
      required this.senderEmail,
      required this.message,
      required this.receiverID,
      required this.timestamp,
      required this.ackID,
      // required this.post_Type,
      // required this.post_TypeID,
      required this.read_Msg});

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'message': message,
      'receiverID': receiverID,
      'timestamp': timestamp,
      'ackID': ackID,
      // 'post_Type': post_Type,
      // 'post_TypeID': post_TypeID,
      'read_Msg': read_Msg
    };
  }
}

// static List<Chat> generate() {
  //   return [
  //     Chat(
  //       message: "Hello!",
  //       type: ChatMessageType.sent,
  //       time: DateTime.now().subtract(const Duration(minutes: 5)),
  //     ),
  //     Chat(
  //       message: "Nice to meet you!",
  //       type: ChatMessageType.received,
  //       time: DateTime.now().subtract(const Duration(minutes: 4)),
  //     ),
  //     Chat(
  //       message: "The weather is nice today.",
  //       type: ChatMessageType.sent,
  //       time: DateTime.now().subtract(const Duration(minutes: 3)),
  //     ),
  //     Chat(
  //       message: "Yes, it's a great day to go out.",
  //       type: ChatMessageType.received,
  //       time: DateTime.now().subtract(const Duration(minutes: 2)),
  //     ),
  //     Chat(
  //       message: "Have a nice day!",
  //       type: ChatMessageType.sent,
  //       time: DateTime.now().subtract(const Duration(minutes: 1)),
  //     ),
  //   ];
  // }
// }