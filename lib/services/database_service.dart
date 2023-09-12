import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");
        final CollectionReference groupCollection =
            FirebaseFirestore.instance.collection("groups");

  // updating the user data
  Future savingeUserData(String name, String email) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString();
    int size = await userCollection.get()
        .then((value) => value.size);  // collection 크기 받기

    Map<String, dynamic> posts = {};
    return await userCollection.doc(uid).set({
      "name" : name,
      "email" : email,
      "profilePic" : "",
      "backgroundPic" : "",
      "uid" : uid,
      "likes" : [],
      "registered" : datetime,
      "intro" : "",
      "ranking" : size + 1,
      "posts" : posts,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot querySnapshot = await userCollection.where("email", isEqualTo: email).get();
    return querySnapshot;
  }

  Future<bool> checkExist(String name) async {       
    QuerySnapshot snapshot = await userCollection.where("name", isEqualTo: name).get();
    if (snapshot.docs.length == 0) {
      return true;
    }
    else {
      return false;
    }
  }

}