import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/commentDB_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:uuid/uuid.dart';

class CommentService {

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("comment");

  CommentService._privateConstructor();

  static final CommentService _instance = CommentService._privateConstructor();

  static CommentService get instance => _instance;

  Future postComment(String uID, String email, String description, String postId) async {
    String? name = ""; 
    
    try {
      HelperFunctions helperFunctions = HelperFunctions();

      await helperFunctions.getUserNameFromSF().then((value) => {
        name = value
      });

      String commentId = Uuid().v4();
      
      CommentDBService commentDBService = CommentDBService.instance;
      await commentDBService.savingeCommentDBData(uID, email, postId!, name!, description, commentId);

      DatabaseService databaseService = DatabaseService.instance;
      await databaseService.addComment(uID, commentId);

      return true;

    } catch(e) {
      return e; 
    }

  }


  Future updateComment(String commentId, String description) async {
  
    try {

      final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);

      comment.update({
        "description" : description,
        "posted" : tsdate
      });

      return true;

    } catch(e) {
      return e; 
    }

  }

  Future<Map<dynamic, dynamic>> getComments(String postId) async {
    
    Map comments = new HashMap<int, Map<String, dynamic>>();
    int i = 0;

    await FirebaseFirestore.instance.collection("comment").
      orderBy("posted", descending: true).
      where("postId", isEqualTo: postId).
      limit(7).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        comments[i] = post;
        i += 1;
      })
    });

    return comments;

  }

  Future<Map<dynamic, dynamic>> getMoreComments(DateTime posted, String commentId, String postId) async {

    Map comments = new HashMap<int, Map<String, dynamic>>();
    int i = 0;

    await FirebaseFirestore.instance.collection("comment").
      where("postId", isEqualTo: postId).
      orderBy("posted", descending: true).
      where("posted", isLessThan: posted).
      limit(7).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        if (post["commentId"] != commentId) {
          comments[i] = post;
          i += 1;
        }
      })
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

  Future<DocumentSnapshot<Map<String, dynamic>>> getCommentInfo(String commentId) async {
    
    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);
    DocumentSnapshot<Map<String, dynamic>> commentInfo = await comment.get();

    return commentInfo;
    
  }

  Future removeComment(String commentId, String postId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    DatabaseService databaseService = DatabaseService.instance;
    PostService postService = PostService.instance;

    comment.get().then((value) async => {
      await databaseService.removeComment(value["uId"], commentId),
      await postService.removeComment(postId, commentId),
      await comment.delete()
    });

  }

  Future removeCommentOnly(String commentId) async {
    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    comment.delete();
    
  }

  Future addCommentLikeUser(String uId, String commentOwnerUid, String commentId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    List<dynamic> likedUsers;

    DatabaseService databaseService = DatabaseService.instance;

    comment.get().then((value) => {

      likedUsers = value["likedUsers"],

      if (!likedUsers.contains(uId)) {

        likedUsers.add(uId),
        databaseService.plusCommentLike(commentOwnerUid)

      },

      comment.update({
        "likedUsers" : likedUsers
      })
      
    });
  }

  Future removeCommentLikeUser(String uId, String commentOwnerUid, String commentId) async {

    final comment = FirebaseFirestore.instance.collection("comment").doc(commentId);

    DatabaseService databaseService = DatabaseService.instance;

    List<dynamic> likedUsers;

    comment.get().then((value) => {

      likedUsers = value["likedUsers"],

      if (likedUsers.contains(uId)) {

        likedUsers.remove(uId),

        databaseService.minusCommentLike(commentOwnerUid)

      },

      comment.update({
        "likedUsers" : likedUsers
      })
      
    });

  }

}