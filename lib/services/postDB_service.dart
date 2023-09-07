import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/services/storage.dart';
import 'package:uuid/uuid.dart';

class PostDBService {
  
  final String? email;
  final String? profileFileName;
  final String? userName;
  PostDBService({this.email, this.profileFileName, this.userName});

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");

  Future savingePostDBData(String description, String category, List<String> tags, bool withComment, List<String> filePaths, List<String> fileNames) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString() + "/" + tsdate.hour.toString() + ":" + tsdate.minute.toString();
    int size = await postCollection.get()
        .then((value) => value.size);  // collection 크기 받기
    String postId = Uuid().v4();

    Storage storage = new Storage();
    for (int i = 0; i < filePaths.length; i++) {
      storage.uploadPostImage(filePaths[i], fileNames[i], email!, postId);
    }  

    List<String> comments = [];
    return await postCollection.doc(postId).set({
      "postId" : postId,
      "email" : email,
      "images" : fileNames,
      "description" : description,
      "writer" : userName,
      "category" :  category,
      "tags" : tags,
      "comments" : comments,
      "likes" : 0,
      "posted" : datetime,
      "withComment" : withComment,
      'postNumber' : size,
      'profileFileName' : profileFileName
    });
  }
}