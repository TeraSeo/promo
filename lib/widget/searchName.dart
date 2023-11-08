import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';

class SearchName extends StatefulWidget {

  final String searchedName;
  final String uId;

  const SearchName({super.key, required this.searchedName, required this.uId});

  @override
  State<SearchName> createState() => _SearchNameState();
}


class _SearchNameState extends State<SearchName> {

  Map<dynamic, dynamic>? posts;

  bool isPostLoading = true;
  bool isMoreLoading = false;
  bool isLoadingMorePostsPossible = true;

  int? wholePostsLength = 0;
  bool isWholePostLengthLoading = true;

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getPostsBySearchName(widget.searchedName);
      getPostsLength(widget.searchedName);
    });

    super.initState();
  }

  Future getPostsBySearchName(String searchedName) async {
    PostService postService = new PostService();
     await postService.getPostsBySearchName(searchedName).then((value) => {
      posts = value,
      if (this.mounted) {
          setState(() {
            isPostLoading = false;
          })
      }
    });
  }


  Future getMorePostsBySearchName(String searchedName, String postId) async {
    PostService postService = new PostService();
     await postService.loadMorePostsPostsBySearchName(searchedName, postId).then((value) => {
      if (value.length == 0) {
        if (this.mounted) {
          setState(() {
            isLoadingMorePostsPossible = false;
          })
        }
      }
      else {
        if (this.mounted){
          for (int i = 0; i < value.length; i++) {
            setState(() {
              posts![posts!.length] = value[i];
            })
          },
        }
      },
      if (this.mounted) {
        setState(() {
          isMoreLoading = false;
        })
      }
    });
  }

  void getPostsLength(String searchedName) async {
    await FirebaseFirestore.instance.collection("post").
      where('description', isGreaterThanOrEqualTo: searchedName).get().then((value) => {
      wholePostsLength = value.docs.length,
      if (this.mounted) {
        setState(() {
          isWholePostLengthLoading = false;
        }),
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isPostLoading || isWholePostLengthLoading) ? Center(child: CircularProgressIndicator()) : NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMorePostsPossible && !isMoreLoading && wholePostsLength! > posts!.length) {
            isMoreLoading = true;

            getMorePostsBySearchName(posts![posts!.length - 1]['description'], posts![posts!.length - 1]['postId']);

          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (this.mounted) {
              setState(() {
                isPostLoading = true;
                isWholePostLengthLoading = true;
              });
            }
            await getPostsBySearchName(widget.searchedName);
            getPostsLength(widget.searchedName);
          },
          child: SingleChildScrollView(
            child: Wrap(children: List.generate(posts!.length, (index) { 
                return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(widget.uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true,);
            }))
          )
        ));
    }
}