import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:logger/logger.dart';

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

  bool isErrorOccurred = false;
  var logger = Logger();

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getPostsBySearchName(widget.searchedName);
      getPostsLength(widget.searchedName);
    });

    super.initState();
  }

  Future getPostsBySearchName(String searchedName) async {
    try {
      PostService postService = new PostService();
      await postService.getPostsBySearchName(searchedName).then((value) => {
        posts = value,
        if (this.mounted) {
            setState(() {
              isPostLoading = false;
            })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting posts by name\nerror: " + e.toString());
    }
  } 


  Future getMorePostsBySearchName(String searchedName, String postId) async {
    try {

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

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting more posts by name\nerror: " + e.toString());
    }
    
  }

  void getPostsLength(String searchedName) async {
    try {

      await FirebaseFirestore.instance.collection("post").
        where('description', isGreaterThanOrEqualTo: searchedName).get().then((value) => {
        wholePostsLength = value.docs.length,
        if (this.mounted) {
          setState(() {
            isWholePostLengthLoading = false;
          }),
        }
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting post length\nerror: " + e.toString());
    }
    
  }

  @override
  Widget build(BuildContext context) {
    try {

      return isErrorOccurred ? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isPostLoading = true;
                      isLoadingMorePostsPossible = true;
                      isWholePostLengthLoading = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getPostsBySearchName(widget.searchedName);
                  getPostsLength(widget.searchedName);
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (isPostLoading || isWholePostLengthLoading) ? Center(child: CircularProgressIndicator()) : NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMorePostsPossible && !isMoreLoading && wholePostsLength! > posts!.length) {
            isMoreLoading = true;

            getMorePostsBySearchName(posts![posts!.length - 1]['description'], posts![posts!.length - 1]['postId']);

          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            try {

              if (this.mounted) {
                setState(() {
                  isPostLoading = true;
                  isWholePostLengthLoading = true;
                });
              }
              await getPostsBySearchName(widget.searchedName);
              getPostsLength(widget.searchedName);

            } catch(e) {
              if (this.mounted) {
                setState(() {
                  isErrorOccurred = true;
                });
              }
              logger.log(Level.error, "error occurred while refreshing\nerror: " + e.toString());
            }
            
          },
          child: SingleChildScrollView(
            child: Wrap(children: List.generate(posts!.length, (index) { 
                try {
                 return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(widget.uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true,);
                } catch(e) {
                  return Center(
                        child: Column(
                          children: [
                            IconButton(onPressed: () {
                              if (this.mounted) {
                                setState(() {
                                    isErrorOccurred = false;
                                    isPostLoading = true;
                                    isLoadingMorePostsPossible = true;
                                    isWholePostLengthLoading = true;
                                  }
                                );
                              }
                              Future.delayed(Duration(seconds: 0)).then((value) async {
                                await getPostsBySearchName(widget.searchedName);
                                getPostsLength(widget.searchedName);
                              });
                            }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                            Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                          ],
                        )
                    );
                }
            }))
          )
        ));

    } catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isPostLoading = true;
                      isLoadingMorePostsPossible = true;
                      isWholePostLengthLoading = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getPostsBySearchName(widget.searchedName);
                  getPostsLength(widget.searchedName);
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
  }    
}