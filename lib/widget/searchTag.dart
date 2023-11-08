import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';

class SearchTag extends StatefulWidget {

  final String searchedName;
  final String uId;

  const SearchTag({super.key, required this.searchedName, required this.uId});

  @override
  State<SearchTag> createState() => _SearchTagState();
}

class _SearchTagState extends State<SearchTag> {

  Map<dynamic, dynamic>? tags;
  bool isTagLoading = true;
  bool isLoadingMoreTagsPossible = true;
  bool isMoreLoading = false;

  int? wholeTagsLength = 0;
  bool isWholeTagsLengthLoading = true;

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getTagsBySearchName(widget.searchedName);
      getTagsLength(widget.searchedName);
    });
    super.initState();
  }

  void getTagsLength(String searchedName) async {

    await FirebaseFirestore.instance.collection("post").
      where('tags', arrayContains: widget.searchedName).limit(7).
      get().then((value) => {
        wholeTagsLength = value.docs.length,
        if (this.mounted) {
          setState(() {
            isWholeTagsLengthLoading = false;
          }),
        }
    });
  }

  Future getTagsBySearchName(String searchedName) async {
    PostService postService = new PostService();
     await postService.getTagsBySearchName(searchedName).then((value) => {
      tags = value,
      if (this.mounted) {
          setState(() {
            isTagLoading = false;
          })
      }
    });
  }

  Future getMoreTagsBySearchName(String searchedName, String postNumber) async {
    PostService postService = new PostService();
     await postService.loadMoreTagsBySearchName(searchedName, postNumber).then((value) => {
      if (value.length == 0) {
        if (this.mounted) {
          setState(() {
            isLoadingMoreTagsPossible = false;
          })
        }
      }
      else {
        if (this.mounted) {
          for (int i = 0; i < value.length; i++) {
            setState(() {
              tags![tags!.length] = value[i];
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

  @override
  Widget build(BuildContext context) {
    return (isTagLoading || isWholeTagsLengthLoading) ? Center(child: CircularProgressIndicator()) :
       NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent  && isLoadingMoreTagsPossible && !isMoreLoading && wholeTagsLength! > tags!.length) {
                  isMoreLoading = true;

                  getMoreTagsBySearchName(widget.searchedName, tags![tags!.length - 1]['postNumber'].toString());
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  if (this.mounted) {
                    setState(() {
                      isTagLoading = true;
                      isWholeTagsLengthLoading = true;
                    });
                  }
                  await getTagsBySearchName(widget.searchedName);
                  getTagsLength(widget.searchedName);
                },
                child: SingleChildScrollView(
            child: Wrap(children: List.generate(tags!.length, (index) { 
                return PostWidget(email: tags![index]["email"], postID: tags![index]["postId"], name: tags![index]["writer"], image: tags![index]["images"], description: tags![index]["description"],isLike: tags![index]["likes"].contains(widget.uId), likes: tags![index]["likes"].length, uId: widget.uId, postOwnerUId: tags![index]["uId"], withComment: tags![index]["withComment"], isBookMark: tags![index]["bookMarks"].contains(widget.uId), tags: tags![index]["tags"], posted: tags![index]["posted"], isProfileClickable: true,);

            })))
       ));
  } 
}