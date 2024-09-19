import "package:cloud_firestore/cloud_firestore.dart";
import "package:ibitf_app/model/service.dart";

class maidDao {
  Future<QuerySnapshot> getAllMaids() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: 1)
        .get();
  }

  Future<QuerySnapshot> getAllServices(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("services")
        .where("userid", isNotEqualTo: curUser)
        .get();
  }

  Future<List<Service>> getOwnServices(String curUser) async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection("services")
        .where("userid", isEqualTo: curUser)
        .get();

    List<Service> ser = [];
    for (var qss in qs.docs) {
      Service serv = Service(
          days: List<String>.from(qss.get("days")),
          rate: qss.get("rate"),
          schedule: qss.get("schedule"),
          services: List<String>.from(qss.get("services")),
          time_from: qss.get("time_from"),
          time_to: qss.get("time_to"),
          userid: qss.get("userid"),
          wage: qss.get("wage"),
          work_history: List<String>.from(qss.get("work_history")));
      ser.add(serv);
    }
    return ser;
  }

  Future<QuerySnapshot> getOwnServices1(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("services")
        .where("userid", isEqualTo: curUser)
        .get();
  }

  Future<QuerySnapshot> getOwnJobProfile(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("jobprofile")
        .where("userid", isEqualTo: curUser)
        .get();
  }

  Future<DocumentSnapshot> getService(String postTypeID) async {
    return await FirebaseFirestore.instance
        .collection("services")
        .doc(postTypeID)
        .get();
  }

  Future addService(Map<String, dynamic> serviceInfoMap) async {
    // print("user id = $userId");
    return await FirebaseFirestore.instance
        // .collection("users")
        // .doc(userId)
        .collection("services")
        .doc()
        .set(serviceInfoMap);
  }

  Future addJobProfile(Map<String, dynamic> jobProfileInfoMap) async {
    // print("user id = $userId");
    return await FirebaseFirestore.instance
        // .collection("users")
        // .doc(userId)
        .collection("jobprofile")
        .doc()
        .set(jobProfileInfoMap);
  }
}
