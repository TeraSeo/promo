import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/commentDB_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:uuid/uuid.dart';

class CommentService {

  final String? description;
  final String? postId;
  final String? commentId;

  CommentService({this.description, this.postId, this.commentId});

  String? name = ""; 

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("comment");

  Future postComment(String uID, String email) async {
  
    try {

      await HelperFunctions.getUserNameFromSF().then((value) => {
        name = value
      });

      String commentId = Uuid().v4();
      
      CommentDBService commentDBService = new CommentDBService(username: name, description: description, commentId: commentId);
      await commentDBService.savingeCommentDBData(uID, email);

      DatabaseService databaseService = new DatabaseService();
      await databaseService.addComment(uID, commentId);

      final post = FirebaseFirestore.instance.collection("post").doc(postId);

      post.get().then((value) {
        List<dynamic> comments = value["comments"];
        comments.add(commentId);
        
        post.update({
          "comments" : comments
        });

      });

      return true;

    } catch(e) {
      return e; 
    }

  }


  Future updateComment(String commentId) async {
  
    try {

      final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

      comment.update({
        "description" : description
      });

      return true;

    } catch(e) {
      return e; 
    }

  }

  Future<List<dynamic>> getComments() async {

    List<dynamic> comments = [];

    final post = FirebaseFirestore.instance.collection("post").doc(postId);
    await post.get().then((value) {
      comments = value["comments"];
    });
    
    return comments;
   
  }

  Future<int> getCommentLikes(String commentID) async {

    List<dynamic> likedUsers = [];

    int likes = 0;

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentID);
    await comment.get().then((value) {
      likedUsers = value["likedUsers"];

      likes = likedUsers.length;
    });
    
    return likes;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCommentInfo() async {
    
    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);
    DocumentSnapshot<Map<String, dynamic>> commentInfo = await comment.get();

    return commentInfo;
    
  }

  Future removeComment(String commentId, String postId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    DatabaseService databaseService = new DatabaseService();
    PostService postService = new PostService();

    String uId = "";

    comment.get().then((value) async => {

      uId = value["uId"],
      await databaseService.removeComment(value["uId"], commentId),
      await postService.removeComment(postId, commentId),
      await comment.delete()
    });

  }

  Future removeCommentOnly(String commentId) async {
    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    comment.delete();
    
  }

  Future addCommentLikeUser(String uId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    List<dynamic> likedUsers;

    comment.get().then((value) => {

      likedUsers = value["likedUsers"],

      if (!likedUsers.contains(uId)) {

        likedUsers.add(uId)

      },

      comment.update({
        "likedUsers" : likedUsers
      })
      
    });
  }

  Future removeCommentLikeUser(String uId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    List<dynamic> likedUsers;

    comment.get().then((value) => {

      likedUsers = value["likedUsers"],

      if (likedUsers.contains(uId)) {

        likedUsers.remove(uId)

      },

      comment.update({
        "likedUsers" : likedUsers
      })
      
    });

  }

}