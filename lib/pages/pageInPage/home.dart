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
  bool isMoreLoading = false;
  bool isWholePostLengthLoading = true;
  bool isErrorOccurred = false;

  int? wholePostLength;

  String? uId; 

  PostService postService = new PostService();

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");

  @override
  void initState() {
    super.initState();
    getUId();
    getPosts();
    getPostLength();
  }


  void getPosts() async {
    try {
      PostService postService = new PostService();
      await postService.getPosts().then((value) => {
        posts = value,
        if (this.mounted) {
            setState(() {
              isLoading = false;
            })
        }
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
  }

   void getUId() async{
    try {

      await HelperFunctions.getUserUIdFromSF().then((value) => {
        uId = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        }
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

  void getPostLength() async {
    try {
      
      await postCollection.get().then((value) => {
        wholePostLength = value.docs.length,
        setState(() {
          isWholePostLengthLoading = false;
        }),
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
    return 
      isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                    isErrorOccurred = false;
                    isUIdLoading = false;
                    isLoading = false;
                    isWholePostLengthLoading = false;
                  });
                }
                getUId();
                getPosts();
                getPostLength();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : 
      (isUIdLoading || isLoading || isWholePostLengthLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
        NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  try {
                    if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && scrollNotification.metrics.atEdge && !isMoreLoading && wholePostLength! > posts!.length) {
                      isMoreLoading = true;
                      postService.loadMore(posts![posts!.length - 1]['postNumber']).then((value) => {
                        for (int i = 0; i < value.length; i++) {
                          setState(() {
                            posts![posts!.length] = value[i];
                          })
                        },

                        setState(() {
                          isMoreLoading = false;
                        })
                        
                      });
                    }
                    return true;
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
                  }
                  return true;
                },
                child:  RefreshIndicator(
        onRefresh: () async {
          try {
            await Future.delayed(Duration(seconds: 1)).then((value) => {
              setState(() {
              if (this.mounted) {
                isUIdLoading = true;
                isLoading = true;
                isMoreLoading = false;
              }
            })
            });
            getUId();
            getPosts();
          } catch(e) {
            if (this.mounted) {
              setState(() {
                isErrorOccurred = true;
              });
            }
          }
        },
        child: SingleChildScrollView(
        child: 
        Column(
          children: [
          Column(
            children: 
            List.generate(posts!.length, (index) {
              return Container(
                child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true,),
              );
            })),
            isMoreLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Container()
            ],
          )
        )
      )
    );}
    catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                    isErrorOccurred = false;
                    isUIdLoading = false;
                    isLoading = false;
                    isWholePostLengthLoading = false;
                  });
                }
                getUId();
                getPosts();
                getPostLength();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );

    }
  }

}