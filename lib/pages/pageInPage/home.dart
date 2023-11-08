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
  }

  void getPostLength() async {
    await postCollection.get().then((value) => {
      wholePostLength = value.docs.length,
      setState(() {
        isWholePostLengthLoading = false;
      }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      (isUIdLoading || isLoading || isWholePostLengthLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
        NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
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
                },
                child:  RefreshIndicator(
        onRefresh: () async {
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
        },
          child: SingleChildScrollView(
          child: 
          // FutureBuilder(
          //   future: FirebaseFirestore.instance.collection("post").
          //                 orderBy("posted", descending: true).limit(postNum).
          //                 get(), 
          //   builder: (context, snapshot) {

          //     if (!snapshot.hasData) {
          //         return Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //     else {

          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //       else {
          //         // snapshots = snapshot.data;

          //         // return Wrap(
          //         //   children: List.generate((snapshots! as dynamic).docs.length, (index) {
          //         //   return PostWidget(email: snapshots!.docs[index]["email"], postID: snapshots!.docs[index]["postId"], name: snapshots!.docs[index]["writer"], image: snapshots!.docs[index]["images"], description: snapshots!.docs[index]["description"],isLike: snapshots!.docs[index]["likes"].contains(uId!), likes: snapshots!.docs[index]["likes"].length, uId: uId!, postOwnerUId: snapshots!.docs[index]["uId"], withComment: snapshots!.docs[index]["withComment"], isBookMark: snapshots!.docs[index]["bookMarks"].contains(uId), tags: snapshots!.docs[index]["tags"], posted: snapshots!.docs[index]["posted"],);
          //         // }));

          //         return Wrap(
          //           children: List.generate((snapshot.data! as dynamic).docs.length, (index) {
          //             print(index);
          //           return PostWidget(email: snapshot.data!.docs[index]["email"], postID: snapshot.data!.docs[index]["postId"], name: snapshot.data!.docs[index]["writer"], image: snapshot.data!.docs[index]["images"], description: snapshot.data!.docs[index]["description"],isLike: snapshot.data!.docs[index]["likes"].contains(uId!), likes: snapshot.data!.docs[index]["likes"].length, uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uId"], withComment: snapshot.data!.docs[index]["withComment"], isBookMark: snapshot.data!.docs[index]["bookMarks"].contains(uId), tags: snapshot.data!.docs[index]["tags"], posted: snapshot.data!.docs[index]["posted"],);
          //         }));
          //       }
                  
          //     //     return PageStorage(bucket: pageBucket, 
          //     //     child: ListView.builder(
          //     //       key: PageStorageKey<String>( 
          //     // 'pageOne'),
          //     //       controller: ScrollController(),
          //     //       itemCount: (snapshot.data! as dynamic).docs.length,
          //     //       itemBuilder: (context, index) {
          //     //           return PostWidget(email: snapshot.data!.docs[index]["email"], postID: snapshot.data!.docs[index]["postId"], name: snapshot.data!.docs[index]["writer"], image: snapshot.data!.docs[index]["images"], description: snapshot.data!.docs[index]["description"],isLike: snapshot.data!.docs[index]["likes"].contains(uId!), likes: snapshot.data!.docs[index]["likes"].length, uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uId"], withComment: snapshot.data!.docs[index]["withComment"], isBookMark: snapshot.data!.docs[index]["bookMarks"].contains(uId), tags: snapshot.data!.docs[index]["tags"], posted: snapshot.data!.docs[index]["posted"],);
                        
          //     //       // },
          //     //   // );
          //     //   }));}
          //     }
          //     // },
          // // )
          // // Column(
          // //   children: 
          // //   List.generate(posts!.length, (index) {
          // //     return Container(
          // //       child: PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],),
          // //     );
          // //   })
          //   }
          // ),


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
    );
  }
  
}