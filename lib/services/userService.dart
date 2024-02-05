import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/storage.dart';

class DatabaseService {

  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  static DatabaseService get instance => _instance;
  
  final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

  Storage storage = Storage.instance;

  Future savingeUserData(String name, String email, String uid) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final fcmToken = await FirebaseMessaging.instance.getToken();

    return await userCollection.doc(uid).set({
      "name" : name,
      "email" : email,
      "token" : [fcmToken],
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
      "wholeLikes" : 0,
      "language" : "en",
      "isEmailVisible" : false
    });
  }

  Future<Map<dynamic, dynamic>> getLikedUser(List<dynamic> likedPeopleUId) async {

    try {

      Map likedPeople = new HashMap<int, Map<String, dynamic>>();
      int i = 0;

      await userCollection.
        where("uid", whereIn: likedPeopleUId).
        limit(30).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          likedPeople[i] = post;
          i += 1;
        })
      });

      return likedPeople;

    } catch(e) {
      return new HashMap<int, Map<String, dynamic>>();
    }

  }

  Future getUserData(String email) async {
    QuerySnapshot querySnapshot = await userCollection.where("email", isEqualTo: email).get();
    return querySnapshot;
  }

  Future<List<dynamic>> getUserToken(String uId) async {

    try {

      List<dynamic>? name;
      await userCollection.doc(uId).get().then((value) {
        name = value["token"];
      });
      return name!;

    } catch(e) {
      return [];
    }
    
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

  Future updateMessagingToken(String newToken, String uid) async {
    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      print(newToken + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      user.get().then((value) {

        List<dynamic> tokens = value["token"];
        tokens.add(newToken);
        user.update({
          "token" : tokens
        });

      });

    } catch(e) {
      print(e);
    }
  }

  Future addUserPost(String postId, String uid) async {

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

  Future addUserLike(String postId, String postOwnerUId, String uid) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      final postUser = FirebaseFirestore.instance.collection("user").doc(postOwnerUId);

      user.get().then((value) {
        List<dynamic> likes = value['likes'];

        if (!likes.contains(postId)) {
          likes.add(postId);

          user.update({
            "likes" : likes,
          });

          postUser.get().then((value) {
          int wholeLikes = value["wholeLikes"];

          postUser.update({
            "wholeLikes" : wholeLikes + 1
          });

      });
        }

      });

    } catch(e) {
      print(e);
    }
  }

  Future removeUserLike(String postId, String postOwnerUId, String uid) async {

    int wholeLikes;

    try {
      final user = FirebaseFirestore.instance.collection("user").doc(uid);

      final postUser = FirebaseFirestore.instance.collection("user").doc(postOwnerUId);


      user.get().then((value) {
        
        List<dynamic> likes = value['likes'];

        if (likes.contains(postId)) {
          likes.remove(postId);

          user.update({
            "likes" : likes,
          });

          postUser.get().then((value) {

          wholeLikes = value["wholeLikes"];

          postUser.update({
            "wholeLikes" : wholeLikes - 1
          });

        });
        }

      });

    } catch(e) {
      print(e);
    }
  }

  Future addUserBookMark(String postId, String uid) async {

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

  Future removeUserBookMark(String postId, String uid) async {
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
      
      HelperFunctions helperFunctions = HelperFunctions();

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "intro" : intro
      });

      helperFunctions.saveUserNameSF(name);

    } catch(e) {
      print(e);
    }

  }

  Future setUserLanguage(String uId, String language) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "language" : language
      });

    } catch(e) {
      print(e);
    }

  }

  Future setUserEmailVisibility(String uId, bool isEmailVisible) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await user.update({
        "isEmailVisible" : isEmailVisible
      });

    } catch(e) {
      print(e);
    }

  }
  
  Future setUserProfile(String uId, String path, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      // await user.update({
      //   "profilePicURL" : fileName
      // });
              
      await storage.uploadProfileImage(path, fileName, email);

      await setProfilePic(uId, fileName, email);

    } catch(e) {
      print(e);
    }

  }

  Future setProfilePic(String uId, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await storage.loadProfileFile(email, fileName).then((value) {
        user.update({
          "profilePic" : value
        });
      });

    } catch(e) {
      print(e);
    }

  }

  Future setUserBackground(String uId, String path, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      // await user.update({
      //   "backgroundPicURL" : fileName
      // });
              
      await storage.uploadProfileBackground(path, fileName, email);

      await setBackgroundPic(uId, fileName, email);

    } catch(e) {
      print(e);
    }

  }

  Future setBackgroundPic(String uId, String fileName, String email) async {

    try {

      final user = FirebaseFirestore.instance.collection("user").doc(uId);

      await storage.loadProfileBackground(email, fileName).then((value) {
        user.update({
          "backgroundPic" : value
        });
      });

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
          users[i] = user;
          i += 1;
        }
        
      })
    });

    return users;

  }

 Future<int> getRanking(String uId) async {
  try {
    final user = FirebaseFirestore.instance.collection("user").orderBy("wholeLikes", descending: true);
    final querySnapshot = await user.get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i]["uid"] == uId) {
        return i + 1;
      }
    }

    return 0;
  } catch (e) {
    return 0;
  }
}

getImages() {
  
}

}