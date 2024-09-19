import "package:cloud_firestore/cloud_firestore.dart";

class EmployerDao {
  Future<QuerySnapshot> getEmployer() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: 2)
        .get();
  }
}
