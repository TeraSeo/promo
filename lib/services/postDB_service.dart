import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:uuid/uuid.dart';

class PostDBService {
  
  final String? email;
  final String? userName;
  PostDBService({this.email, this.userName});

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");

  Future savingePostDBData(String description, String category, List<String> tags, bool withComment, List<String> filePaths, List<String> fileNames) async {

    HelperFunctions helperFunctions = HelperFunctions();
    Logging logger = Logging();

    try {

      String? uId;
      await helperFunctions.getUserUIdFromSF().then((value) => {
            uId = value
      });

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      int? size;
      await postCollection.orderBy("postNumber", descending: true).limit(1).get()
          .then((value)  {
            value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            size = post["postNumber"] + 1;
        });
      }); 
      
      String postId = Uuid().v4();

      Storage storage = Storage.instance;
      for (int i = 0; i < filePaths.length; i++) {
        await storage.uploadPostImage(filePaths[i], fileNames[i], email!, postId);
      }  
  
      DatabaseService databaseService = DatabaseService.instance;
      databaseService.addUserPost(postId, uId!);

      if (size == null) {
        size = 1;
      }
      List<String> images =  await storage.loadPostImages(email!, postId, fileNames);
      return await postCollection.doc(postId).set({
        "postId" : postId,
        "email" : email,
        "images" : images,
        "description" : description,
        "writer" : userName,
        "category" :  category,
        "tags" : tags,
        "comments" : [],
        "likes" : [],
        "posted" : tsdate,
        "withComment" : withComment,
        'postNumber' : size!,
        'uId' : uId,
        'bookMarks' : [],
        'wholeLikes' : 0
      });

    } catch(e) {
      logger.message_warning(e.toString());
    }
    
  }
}