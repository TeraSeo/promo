import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/postDB_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';

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

      List<String> filePaths = [];
      List<String> fileNames = [];

      for (int i = 0; i < images.length; i++) {
        filePaths.add(images[i].path.toString());
        fileNames.add(images[i].path.split('/').last);
      }

      if (filePaths.length == fileNames.length) {
        PostDBService postDBService = new PostDBService(email: email, userName: name);
        await postDBService.savingePostDBData(description, category, tags, withComment, filePaths, fileNames);
        
      }

      return true;

    } catch(e) {
      return e; 
    }

  }

  Future updatePost(List<File> images, String description, String category, List<String> tags, bool withComment, String postId, String email) async {

    try {

      final post = FirebaseFirestore.instance.collection("post").doc(postId);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString() + "/" + tsdate.hour.toString() + ":" + tsdate.minute.toString();

      List<String> filePaths = [];
      List<String> fileNames = [];

      for (int i = 0; i < images.length; i++) {
        filePaths.add(images[i].path.toString());
        fileNames.add(images[i].path.split('/').last);
      }

      if (filePaths.length == fileNames.length) {
        Storage storage = new Storage();
        await storage.deletePostImages(email, postId);
        for (int i = 0; i < filePaths.length; i++) {
          await storage.uploadPostImage(filePaths[i], fileNames[i], email, postId);
        }          
      }

      post.update({
        "images" : fileNames,
        "description" : description,
        "category" : category,
        "tags" : tags,
        "withComment" : withComment,
        "posted" : tsdate
      });

    } catch(e) {
      print(e);
    }

  }

  Future removePost(String postId, String email) async {

    DatabaseService databaseService = new DatabaseService();

    try {

      final post = FirebaseFirestore.instance.collection("post").doc(postId);
      CommentService commentService = new CommentService();
      

      await post.get().then((value) =>  {
        databaseService.removePostInUser(value["likes"].length, value["uId"], postId),

        for (int i = 0; i < value["comments"].length; i++) {
          databaseService.removeCommentInUser(value["comments"][i], value["uId"]),
          commentService.removeCommentOnly(value["comments"][i]),
        },

        for (int i = 0; i < value["likes"].length; i++) {
          databaseService.removeLikeInUser(value["likes"][i], postId)
        },

        for (int i = 0; i < value["bookMarks"].length; i++) {
          databaseService.removeBookMarkInUser(postId, value["bookMarks"][i])
        }

      });

      Storage storage = new Storage();
      await storage.deletePostImages(email, postId);

      await post.delete();

    } catch(e) {
      print(e);
    }

  }

  Future updatePostWithOutImages(String description, String category, List<String> tags, bool withComment, String postId) async {

    try {

      final post = FirebaseFirestore.instance.collection("post").doc(postId);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString() + "/" + tsdate.hour.toString() + ":" + tsdate.minute.toString();

      post.update({
        "description" : description,
        "category" : category,
        "tags" : tags,
        "withComment" : withComment,
        "posted" : tsdate
      });

    } catch(e) {
      print(e);
    }

  }

  Future<Map<dynamic, dynamic>> getPosts() async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await postCollection.orderBy("postNumber", descending: true).limit(7).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        posts[i] = post;
        i += 1;
      })
    });

    return posts;

  }

  Future loadMore(int postNumber) async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await postCollection.where("postNumber", isLessThan: postNumber).orderBy("postNumber", descending: true).limit(7).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        posts[i] = post;
        i += 1;
      })
    });

    return posts;

  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getProfilePosts(List<dynamic> postIds) async {
    List<DocumentSnapshot<Map<String, dynamic>>> posts = [];

    for (int i = postIds.length - 1; i >= 0; i--) {
      final post = postCollection.doc(postIds[i].toString());
      DocumentSnapshot<Map<String, dynamic>> p = await post.get() as DocumentSnapshot<Map<String, dynamic>>;
      posts.add(p);
    }
    
    return posts;
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

  // Future addUserBookMark(String postId, bool isBookMark) async {

  //   try {

  //     final post = FirebaseFirestore.instance.collection("post").doc(postId);

  //     post.update({
  //       "isBookMark" : isBookMark
  //     });

  //     return true;

  //   } catch(e) {
  //     return e;
  //   }

  // }

  // Future removeUserMark(String postId, bool isBookMark) async {
    
  //   try {

  //     final post = FirebaseFirestore.instance.collection("post").doc(postId);

  //     post.update({
  //       "isBookMark" : isBookMark
  //     });

  //     return true;

  //   } catch(e) {
  //     return e;
  //   }

  // }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSpecificPost(String postId) async {

    final post = FirebaseFirestore.instance.collection("post").doc(postId);
    DocumentSnapshot<Map<String, dynamic>> thePost = await post.get();

    return thePost;

  }

  Future<int> getPostLikes(List<dynamic> postIds) async {

    try {
      int likes = 0;

      for (int i = 0; i < postIds.length; i++) {

        DocumentSnapshot<Map<String, dynamic>> posts = await getSpecificPost(postIds[i]);
        
        int like = posts["likes"].length;
        likes += like;

      }

      return likes;

    } catch(e) {
      print(e);
      return 0;
    }

  }

  Future changeWriterName(String writer, List<dynamic> postIds) async {
    
    try {

      for (int i = 0; i < postIds.length; i++) {

        final post = FirebaseFirestore.instance.collection("post").doc(postIds[i]);

        post.update({
          "writer" : writer
        });

      }

    } catch(e) {
      return e;
    }

  }

  Future addBookMark(String postId, String uId) async {

    final post = FirebaseFirestore.instance.collection("post").doc(postId);

    List<dynamic> bookMarks;

    post.get().then((value) => {

      bookMarks = value["bookMarks"],

      if (!bookMarks.contains(uId)) {
        bookMarks.add(uId)
      },

      post.update({
        "bookMarks" : bookMarks
      })
      
    });

  }

  Future removeBookMark(String postId, String uId) async {

    final post = FirebaseFirestore.instance.collection("post").doc(postId);

    List<dynamic> bookMarks;

    post.get().then((value) => {

      bookMarks = value["bookMarks"],

      if (bookMarks.contains(uId)) {
        bookMarks.remove(uId)
      },

      post.update({
        "bookMarks" : bookMarks
      })
      
    });
  }

  Future removeComment(String postId, String commentId) async {

    final post = FirebaseFirestore.instance.collection("post").doc(postId);
  
    List<dynamic> comments = [];

    post.get().then((value) =>  {

    comments = value["comments"],

    if (comments.contains(commentId)) {
      comments.remove(commentId)
    },

    post.update({
      "comments" : comments
    })

  });

  }

}
