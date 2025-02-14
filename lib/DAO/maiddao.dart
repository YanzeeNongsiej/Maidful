import "package:cloud_firestore/cloud_firestore.dart";
import "package:ibitf_app/model/service.dart";
import "package:ibitf_app/singleton.dart";

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
        .where("ack", isEqualTo: false)
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
          timing: qss.get("timing"),
          userid: qss.get("userid"),
          wage: qss.get("wage"),
          work_history: List<String>.from(qss.get("work_history")),
          ack: qss.get("ack"));
      ser.add(serv);
    }
    return ser;
  }

  // Future<List<Service>> getActiveServices(String curUser) async {
  //   QuerySnapshot qs = await FirebaseFirestore.instance
  //       .collection("acknowledgements")
  //       .where(Filter.or(
  //         Filter("receiver", isEqualTo: curUser),
  //         Filter("sender", isEqualTo: curUser),
  //       ))
  //       .where("status", isEqualTo: 2)
  //       .get();

  //   List<Service> ser = [];
  //   for (var qss in qs.docs) {
  //     QuerySnapshot qs = await FirebaseFirestore.instance
  //         .collection("chat_rooms")
  //         .doc()
  //         .collection("messages")
  //         .where("ackID", isEqualTo: qss.id)
  //         .get();
  //     Service serv = Service(
  //         days: List<String>.from(qss.get("days")),
  //         rate: qss.get("rate"),
  //         schedule: qss.get("schedule"),
  //         services: List<String>.from(qss.get("services")),
  //         time_from: qss.get("time_from"),
  //         time_to: qss.get("time_to"),
  //         userid: qss.get("userid"),
  //         wage: qss.get("wage"),
  //         work_history: List<String>.from(qss.get("work_history")),
  //         ack: qss.get("ack"));
  //     ser.add(serv);
  //   }
  //   return ser;
  // }
  Future<List<String>> getActiveName(String receive) async {
    List<String> res = [];
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection("users")
        .where("userid", isEqualTo: receive)
        .get();

    res.add(qs.docs.first['name']);
    res.add(qs.docs.first['url']);
    return res;
  }

  Future<QuerySnapshot> getActiveServices(String curUser) async {
    // Query acknowledgements
    QuerySnapshot ackSnapshot;
    if (GlobalVariables.instance.userrole == 1) {
      ackSnapshot = await FirebaseFirestore.instance
          .collection("acknowledgements")
          .where("receiver", isEqualTo: curUser)
          .where("status", whereIn: [2, 4]).get();
    } else {
      ackSnapshot = await FirebaseFirestore.instance
          .collection("acknowledgements")
          .where("userid", isEqualTo: curUser)
          .where("status", whereIn: [2, 4]).get();
    }

    // Collect ack IDs to fetch messages in a batch
    List<String> ackIDs = ackSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch messages for each ack ID in parallel
    List<QuerySnapshot> messagesSnapshots =
        await Future.wait(ackIDs.map((ackID) async {
      return await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(ackID) // Adjust based on how your chat rooms are structured
          .collection("messages")
          .where("ackID", isEqualTo: ackID)
          .get();
    }));

    // Here you can process the messagesSnapshots as needed
    // For example, you could log or aggregate the data

    // Return the acknowledgements snapshot
    return ackSnapshot;
  }

  Future<QuerySnapshot> getOwnServices1(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("services")
        .where("userid", isEqualTo: curUser)
        .get(const GetOptions(source: Source.server));
  }

  Future<QuerySnapshot> getOwnJobProfile(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("jobprofile")
        .where("userid", isEqualTo: curUser)
        .get();
  }

  Future<DocumentSnapshot> getService(String postTypeID) async {
    print('PTID  $postTypeID');
    return await FirebaseFirestore.instance
        .collection("services")
        .doc(postTypeID)
        .get();
  }

  Future<DocumentSnapshot> getPosted(String postTypeID) async {
    print('PTID  $postTypeID');
    return await FirebaseFirestore.instance
        .collection("jobprofile")
        .doc(postTypeID)
        .get();
  }

  Future addService(Map<String, dynamic> serviceInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("services")
        .doc()
        .set(serviceInfoMap);
  }

  Future<DocumentSnapshot> getAck(String ackID) async {
    return await FirebaseFirestore.instance
        .collection("acknowledgements")
        .doc(ackID)
        .get();
  }

  Future<String> addAck(Map<String, dynamic> ackInfoMap) async {
    try {
      final newDoc =
          FirebaseFirestore.instance.collection("acknowledgements").doc();
      await newDoc.set(ackInfoMap);
      return newDoc.id;
    } catch (e) {
      print("Error adding acknowledgement: $e");
      return "null"; // or throw the error
    }
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

  Future<QuerySnapshot> getAllJobProfiles(String curUser) async {
    return await FirebaseFirestore.instance
        .collection("jobprofile")
        .where("ack", isEqualTo: false)
        .where("userid", isNotEqualTo: curUser)
        .get();
  }
}
