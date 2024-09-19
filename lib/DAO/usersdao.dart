import 'package:cloud_firestore/cloud_firestore.dart';

class Usersdao {
  Future addUserDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc()
        .set(userInfoMap);
  }

  Future<QuerySnapshot> getUserDetails(String uid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("userid", isEqualTo: uid)
        .get();
  }

  Future updateUserDetails(String id, int role, int gender, String address,
      String dob, List<String> language, String remarks) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).update({
      "role": role,
      "gender": gender,
      "address": address,
      "dob": dob,
      "language": language,
      "remarks": remarks
    });
  }
}
