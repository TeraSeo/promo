import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/commentDB_service.dart';
import 'package:uuid/uuid.dart';

class CommentService {

  final String? description;
  final String? postId;
  final String? commentId;

  CommentService({this.description, this.postId, this.commentId});

  String? name = ""; 

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("comment");

  Future postComment() async {
  
    try {

      await HelperFunctions.getUserNameFromSF().then((value) => {
        name = value
      });

      String commentId = Uuid().v4();
      
      CommentDBService commentDBService = new CommentDBService(username: name, description: description, commentId: commentId);
      await commentDBService.savingeCommentDBData();

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

  Future<List<dynamic>> getComments() async {

    List<dynamic> comments = [];

    final post = FirebaseFirestore.instance.collection("post").doc(postId);
    await post.get().then((value) {
      comments = value["comments"];
    });
    
    return comments;
   
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCommentInfo() async {
    
    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);
    DocumentSnapshot<Map<String, dynamic>> commentInfo = await comment.get();

    return commentInfo;
    
  }

  Future removeComment(String commentId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    comment.delete();

  }

}