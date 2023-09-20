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
  bool isCurrnetUserNameLoading = true;

  String? uId; 
  String? currentUserName;

  PostService postService = new PostService();

  @override
  void initState() {
    super.initState();
    getPosts();
    getUId();
    getCurrentUserName();
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

  void getCurrentUserName() async{
    await HelperFunctions.getUserNameFromSF().then((value) => {
      currentUserName = value,
      setState(() {
        isCurrnetUserNameLoading = false;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading || isUIdLoading || isCurrnetUserNameLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : SingleChildScrollView(
       child: 
       Column(
        children: 
        List.generate(posts!.length, (index) {
          return Container(
            child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId']),
          );
        })
      )
    );
  }
}