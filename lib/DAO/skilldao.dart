import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void updateScoreToDB(String lang, String? s, double p) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Query the user's document
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection("users")
        .where("userid", isEqualTo: currentUser.uid) // Adjust as needed
        .get();
    String myid = querySnapshot1.docs.first.id;

    //Query the skills document
    // Query the user's document
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection("skills")
        .where(lang, isEqualTo: s) // Adjust as needed
        .get();
    String myskillid = querySnapshot2.docs.first.id;

    //now setting the score
    DocumentReference skillDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(myid)
        .collection('skills')
        .doc(myskillid);

    // Add the score
    await skillDocRef.set({'score': p.toInt()});
  }
}
