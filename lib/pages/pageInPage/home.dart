import 'dart:collection';

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
      setState(() {
          isLoading = false;
      })
    });
  }

   void getUId() async{
    await HelperFunctions.getUserUIdFromSF().then((value) => {
      uId = value,
      setState(() {
        isUIdLoading = false;
      })
    });
  }


  @override
  Widget build(BuildContext context) {
    return (isLoading || isUIdLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : SingleChildScrollView(
       child: 
       Column(
        children: 
        // FutureBuilder(
        //   future: future, 
        //   builder: builder
        // )
        
        List.generate(posts!.length, (index) {
          return Container(
            child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId)),
          );
        })
      )
    );
  }
}