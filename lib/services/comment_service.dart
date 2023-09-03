import 'dart:async';
import 'dart:collection';
import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/datas/postDB.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/commentDB_service.dart';
import 'package:like_app/services/database_service.dart';
import 'package:uuid/uuid.dart';

class CommentService {

  final String? description;
  final String? postId;

  CommentService({this.description, this.postId});

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
        Map<String, dynamic> comments = value["comments"];
        comments.addAll(
          {
            commentId : name
          }
        );
        
        post.update({
          "comments" : comments
        });

      });

      return true;

    } catch(e) {
      return e; 
    }

  }

}