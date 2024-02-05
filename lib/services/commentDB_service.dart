import 'package:cloud_firestore/cloud_firestore.dart';

class CommentDBService {

  CommentDBService._privateConstructor();

  static final CommentDBService _instance = CommentDBService._privateConstructor();

  static CommentDBService get instance => _instance;

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("comment");

  Future savingeCommentDBData(String uID, String email, String postID, String username, String description, String commentId) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString() + "/" + tsdate.hour.toString() + ":" + tsdate.minute.toString();

    // int size = await postCollection.get()
    //     .then((value) => value.size);  // collection 크기 받기

    // Map<String, dynamic> comments = {};

    return await postCollection.doc(commentId).set({
      "commentId" : commentId,
      "username" : username,
      "description" : description,
      "posted" : tsdate,
      "likedUsers" : [],
      "uId" : uID,
      "postId" : postID,
      "email" : email
    });
  }

}