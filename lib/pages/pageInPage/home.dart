import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  Map<dynamic, dynamic>? posts;
  bool isLoading = true;
  bool isUIdLoading = true;
  DocumentSnapshot<Map<String, dynamic>>? postUser;

  String? uId; 

  PostService postService = new PostService();

  @override
  void initState() {
    super.initState();
    getPosts();
    getUId();
  }

  void getPosts() async {
    PostService postService = new PostService();
     await postService.getPosts().then((value) => {
      posts = value,
      if (this.mounted) {
          setState(() {
            isLoading = false;
          })
      }
    });
  }

   void getUId() async{
    await HelperFunctions.getUserUIdFromSF().then((value) => {
      uId = value,
      if (this.mounted) {
        setState(() {
          isUIdLoading = false;
        })
      }
    });

    final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

    final user = userCollection.doc(uId);
    postUser = await user.get() as DocumentSnapshot<Map<String, dynamic>>;
  }

 

  @override
  Widget build(BuildContext context) {
    return (isLoading || isUIdLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : SingleChildScrollView(
       child: 
       Column(
        children: 
        List.generate(posts!.length, (index) {
          return Container(
            child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],),
          );
        })
      )
    );
  }
}