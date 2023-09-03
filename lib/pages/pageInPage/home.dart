import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    getPosts();
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

  @override
  Widget build(BuildContext context) {
    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : SingleChildScrollView(
       child: 
       Column(
        children: List.generate(posts!.length, (index) {
          return Container(
            child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],),
          );
        })
      )
    );
  }
}