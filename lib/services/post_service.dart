import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/postDB_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';

class PostService {

  PostService._privateConstructor();

  static final PostService _instance = PostService._privateConstructor();

  static PostService get instance => _instance;

  Logging logger = Logging();

  String? email = ""; 
  String? name = "";

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");

  Future post(List<dynamic> images, String description, String category, List<String> tags, bool withComment) async {
  
    try {
      HelperFunctions helperFunctions = HelperFunctions();
      PostDBService postDBService = PostDBService.instance;

      await helperFunctions.getUserEmailFromSF().then((value) => {
        email = value
      });

      await helperFunctions.getUserNameFromSF().then((value) => {
        name = value
      });

      List<String> filePaths = [];
      List<String> fileNames = [];

      for (int i = 0; i < images.length; i++) {
        filePaths.add(images[i].path.toString());
        fileNames.add(images[i].path.split('/').last);
      }

      if (filePaths.length == fileNames.length) {
        await postDBService.savingePostDBData(description, category, tags, withComment, filePaths, fileNames, email!, name!);
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

      List<String> filePaths = [];
      List<String> fileNames = [];

      for (int i = 0; i < images.length; i++) {
        filePaths.add(images[i].path.toString());
        fileNames.add(images[i].path.split('/').last);
      }

      Storage storage = Storage.instance;
      if (filePaths.length == fileNames.length) {
        await storage.deletePostImages(email, postId);
        for (int i = 0; i < filePaths.length; i++) {
          await storage.uploadPostImage(filePaths[i], fileNames[i], email, postId);
        }          
      }

      await storage.loadPostImages(email, postId, fileNames).then((value) {
        post.update({
        "images" : value,
        "description" : description,
        "category" : category,
        "tags" : tags,
        "withComment" : withComment,
        "posted" : tsdate
      });
      });

    } catch(e) {
      print(e);
    }

  }

  Future removePost(String postId, String email) async {

    DatabaseService databaseService = DatabaseService.instance;

    try {

      final post = FirebaseFirestore.instance.collection("post").doc(postId);
      CommentService commentService = CommentService.instance;

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

      Storage storage = Storage.instance;
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

  Future<Map<dynamic, dynamic>> getPosts(String sort) async {
    try {

      Map posts = new HashMap<int, Map<String, dynamic>>();
      int i = 0;

      if (sort == "Latest" || sort == "Neueste" || sort == "El último" || sort == "Dernière" || sort == "नवीनतम" || sort == "最新" || sort == "최신순") {
        await postCollection.
          orderBy("postNumber", descending: true).limit(7).get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            posts[i] = post;
            i += 1;
          })
        });
      } 
      else if (sort == "Oldest" || sort == "Alter Schuss" || sort == "Más antiguo" || sort == "Le plus ancien" || sort == "सबसे पुराने" || sort == "最古の" || sort == "오래된 순") {
        await postCollection.
          orderBy("postNumber", descending: false).limit(7).get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            posts[i] = post;
            i += 1;
          })
        });
      }
      else if (sort == "Popular" || sort == "Beliebt" || sort == "Populaire" || sort == "लोकप्रिय" || sort == "人気のある" || sort == "인기순") {
        await postCollection.
          orderBy("wholeLikes", descending: true).
            orderBy("postNumber", descending: true)
          .limit(7).get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            posts[i] = post;
            i += 1;
          })
        });
      }
      else if (sort == "Not popular" || sort == "Nicht populär" || sort == "No popular" || sort == "Pas populaire" || sort == "लोकप्रिय नहीं" || sort == "人気がない" || sort == "비인기 순") {
        await postCollection.
          orderBy("wholeLikes", descending: false).
            orderBy("postNumber", descending: true)
          .limit(7).get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            posts[i] = post;
            i += 1;
          })
        });
      }

      return posts;

    } catch(e) {
      print(e);
      return new HashMap<int, Map<String, dynamic>>();

    }

  }

  Future loadMore(int postNumber, String sort, int likesSum, String postId) async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;

    if (sort == "Latest" || sort == "Neueste" || sort == "El último" || sort == "Dernière" || sort == "नवीनतम" || sort == "最新" || sort == "최신순") {

      await postCollection.
        where("postNumber", isLessThan: postNumber).
        orderBy("postNumber", descending: true).
        limit(10).get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> post = element.data() as Map<String, dynamic>;
            posts[i] = post;
            i += 1;
          })
      });

    } 
    else if (sort == "Oldest" || sort == "Alter Schuss" || sort == "Más antiguo" || sort == "Le plus ancien" || sort == "सबसे पुराने" || sort == "最古の" || sort == "오래된순") {
      await postCollection.
            where("postNumber", isGreaterThan: postNumber).
            orderBy("postNumber", descending: false).
            limit(10).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          posts[i] = post;
          i += 1;
        })
      });
    }
    else if (sort == "Popular" || sort == "Beliebt" || sort == "Populaire" || sort == "लोकप्रिय" || sort == "人気のある" || sort == "인기순") {
      final lastPop = await postCollection.doc(postId).get();
      await postCollection.
            where("wholeLikes", isLessThanOrEqualTo: likesSum).
            orderBy("wholeLikes", descending: true).
            orderBy("postNumber", descending: true).
            startAfterDocument(lastPop).
            limit(10).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          posts[i] = post;
          i += 1;
        })
      });

    } 
    else if (sort == "Not popular" || sort == "Nicht populär" || sort == "No popular" || sort == "Pas populaire" || sort == "लोकप्रिय नहीं" || sort == "人気がない" || sort == "비인기순") {
      final lastPop = await postCollection.doc(postId).get();
      await postCollection.
            where("wholeLikes", isGreaterThanOrEqualTo: likesSum).
            orderBy("wholeLikes", descending: false).
            orderBy("postNumber", descending: true).
            startAfterDocument(lastPop).
            limit(10).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          posts[i] = post;
          i += 1;
        })
      });
    }
  
    return posts;

  }

  Future<Map<dynamic, dynamic>> getPostsBySearchName(String searchedName) async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await FirebaseFirestore.instance.collection("post").
      orderBy("description", descending: false).
      // orderBy("postNumber", descending: true).
      limit(40).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;
        if (post['description'].contains(searchedName)) {
          posts[i] = post;
          i += 1;
        }
      })
    });

    return posts;

  }

  Future<Map<dynamic, dynamic>> loadMorePostsPostsBySearchName(String searchedName, String postId, String searchedTxt) async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;

    await FirebaseFirestore.instance.collection("post").
      where('description', isGreaterThanOrEqualTo: searchedName).
      // orderBy('description', descending: false).
      limit(40).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> post = element.data() as Map<String, dynamic>;


        if (post["postId"] != postId) {
          if (post['description'].contains(searchedTxt)) {
            posts[i] = post;
            i += 1;
          }
        }
      })
    });

    return posts;

  }

  Future<Map<dynamic, dynamic>> getTagsBySearchName(String searchedName) async {
    Map tags = new HashMap<int, Map<String, dynamic>>();
    int i = 0;
    await FirebaseFirestore.instance.collection("post").
      where('tags', arrayContains: searchedName).
      orderBy("postNumber", descending: true).
      limit(50).get().then((value) => {
      value.docs.forEach((element) {
        Map<String, dynamic> tag = element.data() as Map<String, dynamic>;
        tags[i] = tag;
        i += 1;
      })
    });

    return tags;

  }

  Future<Map<dynamic, dynamic>> loadMoreTagsBySearchName(String searchedName, String postNumber) async {
    Map posts = new HashMap<int, Map<String, dynamic>>();
    int i = 0;

    await FirebaseFirestore.instance.collection("post")
      .where('tags', arrayContains: searchedName)
      .orderBy('postNumber', descending: true)
      .where('postNumber', isLessThan: int.parse(postNumber))
      .limit(7).get().then((value) => {
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
        HelperFunctions helperFunctions = HelperFunctions();
        String? uId; 
        // String? userName;
        // String? token;

        await helperFunctions.getUserUIdFromSF().then((value) => {
          uId = value
        });

        // final user = FirebaseFirestore.instance.collection("user").doc(uId);

        // user.get().then((value) => {

        //   userName = value["name"],
          
        // });

        final post = FirebaseFirestore.instance.collection("post").doc(postId);

        post.get().then((value) {
          List<dynamic> likes = value["likes"];
          if (!likes.contains(uId)) {
            likes.add(uId!);
          }
          
          post.update({
            "likes" : likes,
            "wholeLikes" : likes.length
          });

        });

        // FireStoreNotification().sendPushMessage("$userName liked your post!", "Like notification", token!);

        return true;

      } catch(e) {
        return e;
      }
    
  }

  Future postRemoveLike(String postId) async {

      try {
        HelperFunctions helperFunctions = HelperFunctions();
        
        String? uId; 
        await helperFunctions.getUserUIdFromSF().then((value) => {
          uId = value
        });

        final post = FirebaseFirestore.instance.collection("post").doc(postId);

        post.get().then((value) {
          List<dynamic> likes = value["likes"];
          if (likes.contains(uId)) {
            likes.remove(uId);
          }
          
          post.update({
            "likes" : likes,
            "wholeLikes" : likes.length
          });

        });

        return true;

      } catch(e) {
        return e;
      }
    
  }

  Future<bool> checkUserLike(String postId) async {
    try {
      HelperFunctions helperFunctions = HelperFunctions();

      String? uId; 
      await helperFunctions.getUserUIdFromSF().then((value) => {
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

  Future<Map<dynamic, dynamic>> getLikedPosts(List<dynamic> postIds) async {
    try {

      Map likedPosts = new HashMap<int, Map<String, dynamic>>();
      int i = 0;

      await postCollection.
        where("postId", whereIn: postIds).
        limit(10).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          likedPosts[i] = post;
          i += 1;
        })
      });

      return likedPosts;

    } catch(e) {

      return new HashMap<int, Map<String, dynamic>>();

    }

  }

  Future<Map<dynamic, dynamic>> getBookMarkedPosts(List<dynamic> postIds) async {
    try {

      Map bookmarkedPosts = new HashMap<int, Map<String, dynamic>>();
      int i = 0;

      await postCollection.
        where("postId", whereIn: postIds).
        limit(10).get().then((value) => {
        value.docs.forEach((element) {
          Map<String, dynamic> post = element.data() as Map<String, dynamic>;
          bookmarkedPosts[i] = post;
          i += 1;
        })
      });

      return bookmarkedPosts;

    } catch(e) {

      return new HashMap<int, Map<String, dynamic>>();

    }

  }

}
