import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/storage.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

  Storage storage = new Storage();

  // updating the user data
  Future savingeUserData(String name, String email) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString();
    // int size = await userCollection.get()
    //     .then((value) => value.size);  // collection 크기 받기

    return await userCollection.doc(uid).set({
      "name" : name,
      "email" : email,
      "profilePic" : "",
      "backgroundPic" : "",
      "uid" : uid,
      "likes" : [],
      "registered" : tsdate,
      "intro" : "",
      "posts" : [],
      "bookmarks" : [],
      "comments" : [],
      "commentLikes" : 0,
      "wholeLikes" : 0
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

    int wholeLikes;

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        List<dynamic> likes = value['likes'];
        wholeLikes = value["wholeLikes"];

        likes.add(postId);

        user.update({
          "likes" : likes,
          "wholeLikes" : wholeLikes + 1
        });

      });

    } catch(e) {
      print(e);
    }
  }

  Future removeUserLike(String postId) async {

    int wholeLikes;

    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      user.get().then((value) {
        
        List<dynamic> likes = value['likes'];
        wholeLikes = value["wholeLikes"];

        if (likes.contains(postId)) {
          likes.remove(postId);
        }

        user.update({
          "likes" : likes,
          "wholeLikes" : wholeLikes - 1
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

      await user.get().then((value) {
        
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

  Future removePostInUser(int like, String theUId, String postId) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(theUId);

      await user.get().then((value) {
        List<dynamic> posts = value["posts"];

        for (int i = 0; i < posts.length; i++) {
          if (posts[i].toString() == postId) {
            posts.remove(posts[i].toString());
          }
        }

        user.update({
          "posts" : posts
        });
      });

    } catch(e) {
      print(e);
    }
  }

  Future setUserInfo(String uId, String name, String intro) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "name" : name,
        "intro" : intro
      });

      HelperFunctions.saveUserNameSF(name);

    } catch(e) {
      print(e);
    }

  }
  
  Future setUserProfile(String uId, String path, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "profilePic" : fileName
      });
              
      await storage.uploadProfileImage(path, fileName, email);


    } catch(e) {
      print(e);
    }

  }

  Future setUserBackground(String uId, String path, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "backgroundPic" : fileName
      });
              
      await storage.uploadProfileBackground(path, fileName, email);

    } catch(e) {
      print(e);
    }

  }

  Future removeLikeInUser(String uId, String postId) async {

    try {

      List<dynamic> likes;

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        likes = value["likes"], 

        if (likes.contains(postId)) {
          likes.remove(postId)
        },

        user.update({
          "likes" : likes
        })
        
      });

    } catch(e) {
      print(e);
    }

  }

  Future removeBookMarkInUser(String postId, String uId) async {

    try {

      List<dynamic> bookmarks;

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        bookmarks = value["bookmarks"], 

        if (bookmarks.contains(postId)) {
          bookmarks.remove(postId)
        },

        user.update({
          "bookmarks" : bookmarks
        })
        
      });

    } catch(e) {
      print(e);
    }

  }

  Future removeCommentInUser(String commentId, String uId) async {

    try {

      List<dynamic> comments;

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        comments = value["comments"], 

        if (comments.contains(commentId)) {
          comments.remove(commentId)
        },

        user.update({
          "comments" : comments
        })
        
      });

    } catch(e) {
      print(e);
    }


  }

  Future addComment(String uId, String commentId) async {

    try {

      List<dynamic> comments;

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        comments = value["comments"], 

        if (!comments.contains(commentId)) {
          comments.add(commentId)
        },

        user.update({
          "comments" : comments
        })
        
      });

    } catch(e) {
      print(e);
    }

  }

  Future removeComment(String uId, String commentId) async {

    try {

      List<dynamic> comments;

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        comments = value["comments"], 

        if (comments.contains(commentId)) {
          comments.remove(commentId)
        },

        user.update({
          "comments" : comments
        })
        
      });

    } catch(e) {
      print(e);
    }

  }

  Future plusCommentLike(String uId) async {

    int commentLikes;
    int wholeLikes;
    
    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        commentLikes = value["commentLikes"],
        wholeLikes = value["wholeLikes"], 

        user.update({
          "commentLikes" : commentLikes + 1,
          "wholeLikes" : wholeLikes + 1
        })
        
      });

    } catch(e) {
      print(e);
    }

  }

  Future minusCommentLike(String uId) async {

    int commentLikes;
    int wholeLikes;
    
    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.get().then((value) => {

        commentLikes = value["commentLikes"],
        wholeLikes = value["wholeLikes"], 

        commentLikes = commentLikes - 1,
        wholeLikes = wholeLikes - 1,

        user.update({
          "commentLikes" : commentLikes,
          "wholeLikes" : wholeLikes
        })
        
      });

    } catch(e) {
      print(e);
    }

    
  }

  Future getUserBySearchedName(String searchedName) async {

    Map users = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await FirebaseFirestore.instance.collection("user").
                          where('name', isGreaterThanOrEqualTo: searchedName).limit(20).
                          get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> user = element.data() as Map<String, dynamic>;
        users[i] = user;
        print(i);
        i += 1;
      })
    });

    return users;

  }

  Future loadMoreUsersBySearchedName(String searchedName, String uId) async {

    Map users = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await FirebaseFirestore.instance.collection("user").
                          where('name', isGreaterThanOrEqualTo: searchedName).limit(20).
                          get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> user = element.data() as Map<String, dynamic>;
        if (user['uid'] != uId) {
          print(user);
          users[i] = user;
          i += 1;
        }
        
      })
    });

    return users;

  }

}