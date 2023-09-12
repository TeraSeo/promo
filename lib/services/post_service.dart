import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/database_service.dart';
import 'package:like_app/services/postDB_service.dart';

class PostService {
  String? email = ""; 
  String? name = "";

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");

  Future post(List<File> images, String description, String category, List<String> tags, bool withComment) async {
  
    try {
      
      await HelperFunctions.getUserEmailFromSF().then((value) => {
        email = value
      });

      await HelperFunctions.getUserNameFromSF().then((value) => {
        name = value
      });

      DatabaseService databaseService = new DatabaseService();
      QuerySnapshot snapshot = await databaseService.gettingUserData(email!);

      List<String> filePaths = [];
      List<String> fileNames = [];

      for (int i = 0; i < images.length; i++) {
        filePaths.add(images[i].path.toString());
        fileNames.add(images[i].path.split('/').last);
      }
      // storage -> image 저장 + images 저장 + user 저장
      if (filePaths.length == fileNames.length) {
        PostDBService postDBService = new PostDBService(email: email, profileFileName: snapshot.docs[0]['profilePic'], userName: name);
        await postDBService.savingePostDBData(description, category, tags, withComment, filePaths, fileNames);
      }

      return true;

    } catch(e) {
      return e; 
    }

  }

  Future<Map<dynamic, dynamic>> getPosts() async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await postCollection.where("postNumber", isGreaterThan: -1).orderBy("postNumber", descending: true).limit(18).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        posts[i] = post;
        i += 1;
      })
    });

    return posts;

  }

  Future updatePostComment(String postId) async {

  }

  Future postAddLike(String postId) async {

      try {
        
        String? uId; 
        await HelperFunctions.getUserUIdFromSF().then((value) => {
          uId = value
        });

        final post = FirebaseFirestore.instance.collection("post").doc(postId);

        post.get().then((value) {
          List<dynamic> likes = value["likes"];
          if (!likes.contains(uId)) {
            likes.add(uId!);
          }
          
          post.update({
            "likes" : likes
          });

        });

        return true;

      } catch(e) {
        return e;
      }
    
  }

  Future postRemoveLike(String postId) async {

      try {
        
        String? uId; 
        await HelperFunctions.getUserUIdFromSF().then((value) => {
          uId = value
        });

        final post = FirebaseFirestore.instance.collection("post").doc(postId);

        post.get().then((value) {
          List<dynamic> likes = value["likes"];
          if (likes.contains(uId)) {
            likes.remove(uId);
          }
          
          post.update({
            "likes" : likes
          });

        });

        return true;

      } catch(e) {
        return e;
      }
    
  }

  Future<bool> checkUserLike(String postId) async {
    try {

      String? uId; 
      await HelperFunctions.getUserUIdFromSF().then((value) => {
        uId = value
      });

      final post = FirebaseFirestore.instance.collection("post").doc(postId);

      post.get().then((value) {
        List<dynamic> likes = value["likes"];
        if (likes.contains(uId)) {
          return true;
        }
        else {
          return false;
        }

      });

      return false;

    } catch(e) {
      print(e);
      return false;
    }
  }

}