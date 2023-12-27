import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:logger/logger.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  Map<dynamic, dynamic>? posts;
  bool isLoading = true;
  bool isUIdLoading = true;
  bool isMoreLoading = false;
  bool isErrorOccurred = false;
  bool isLoadingMorePostsPossible = true;

  String? uId; 

  final sortItems = [
    'Latest',
    'Oldest',
    'Popular',
    'Not popular',
  ];


  String sort = "Latest";

  PostService postService = new PostService();

  final CollectionReference postCollection = 
        FirebaseFirestore.instance.collection("post");


  var logger = Logger();

  @override
  void initState() {
    super.initState();
    getUId();
    getPosts();
  }


  void getPosts() async {
    try {
      PostService postService = new PostService();
      await postService.getPosts(sort).then((value) => {
        posts = value,
        if (this.mounted) {
            setState(() {
              isLoading = false;
            })
        },
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting posts\nerror: " + e.toString());
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
      logger.log(Level.error, "Error occurred while getting uId\nerror: " + e.toString());
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
                    isLoadingMorePostsPossible = true;
                  });
                }
                getUId();
                getPosts();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : 
      (isUIdLoading || isLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
        NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  try {
                    if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && scrollNotification.metrics.atEdge && !isMoreLoading && isLoadingMorePostsPossible) {
                      isMoreLoading = true;
                      postService.loadMore(posts![posts!.length - 1]['postNumber'], sort, posts![posts!.length - 1]['likes'].length, posts![posts!.length - 1]['postId']).then((value) => {
                        if (value.length == 0) {
                          if (this.mounted) {
                            setState(() {
                              isLoadingMorePostsPossible = false;
                            })
                          }
                        }
                        else {
                          for (int i = 0; i < value.length; i++) {
                            setState(() {
                              posts![posts!.length] = value[i];
                            })
                          },
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
                    logger.log(Level.error, "error occurred while getting more posts\nerror: " + e.toString());
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
                isLoadingMorePostsPossible = true;
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
            logger.log(Level.error, "error occurred while refreshing\nerror: " + e.toString());
          }
        },
        child: SingleChildScrollView(
          controller: widget.scrollController,
        child: 
        Column(
          children: [
            Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.04,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.002)
                    ),
                    child: DropdownButton<String>(
                      value: sort,
                      isExpanded: true,
                      items: sortItems.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        if (this.mounted) {
                          setState(() {
                            sort = value!;
                            isLoading = true;
                            isLoadingMorePostsPossible = true;
                          });
                        }
                        getPosts();
                      } 
                    ),
                  ),

                ],
              ),
          Column(
            children: 
            List.generate(posts!.length, (index) {
              try {
                return Container(
                  child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true,),
                );
              } catch(e) {
                return Center(
                    child: Column(
                      children: [
                        IconButton(onPressed: () {
                          if (this.mounted) {
                            setState(() {
                              isErrorOccurred = false;
                              isUIdLoading = false;
                              isLoading = false;
                            });
                          }
                          getUId();
                          getPosts();
                          
                        }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                        Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                      ],
                    )
                );
              }
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
                    isLoadingMorePostsPossible = true;
                  });
                }
                getUId();
                getPosts();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );

    }
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
    )
  );

}