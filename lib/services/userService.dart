import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

  // updating the user data
  Future savingeUserData(String name, String email) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString();
    int size = await userCollection.get()
        .then((value) => value.size);  // collection 크기 받기

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
      "posts" : [],
      "bookmarks" : []
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

  Future addUserPost(String postId) async {

    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        List<dynamic> posts = value['posts'];

        posts.add(postId);

        user.update({
          "posts" : posts
        });

      });

    } catch(e) {
      print(e);
    }
  }

  Future addUserLike(String postId) async {
    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        List<dynamic> likes = value['likes'];

        likes.add(postId);

        user.update({
          "likes" : likes
        });

      });

    } catch(e) {
      print(e);
    }
  }

  Future removeUserLike(String postId) async {
    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        
        List<dynamic> likes = value['likes'];

        if (likes.contains(postId)) {
          likes.remove(postId);
        }

        user.update({
          "likes" : likes
        });

      });

    } catch(e) {
      print(e);
    }
  }

  Future addUserBookMark(String postId) async {

    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        
        List<dynamic> bookmarks = value['bookmarks'];

        bookmarks.add(postId);

        user.update({
          "bookmarks" : bookmarks
        });

      });

    } catch(e) {
      print(e);
    }

  }

  Future removeUserBookMark(String postId) async {
    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        
        List<dynamic> bookmarks = value['bookmarks'];

        if (bookmarks.contains(postId)) {
          bookmarks.remove(postId);
        }

        user.update({
          "bookmarks" : bookmarks
        });

      });

    } catch(e) {
      print(e);
    }
  }

}