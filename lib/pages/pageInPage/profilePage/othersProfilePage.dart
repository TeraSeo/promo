import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widget/background_widget.dart';
import 'package:like_app/widget/numbers_widget.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:like_app/widget/profile_widget.dart';
import 'package:like_app/services/userService.dart';

class OthersProfilePages extends StatefulWidget {

  final String uId;
  final String postOwnerUId;

  const OthersProfilePages({super.key, required this.uId, required this.postOwnerUId});

  @override
  State<OthersProfilePages> createState() => _OthersProfilePagesState();
}

class _OthersProfilePagesState extends State<OthersProfilePages> {

  DocumentSnapshot<Map<String, dynamic>>? postUser;

  DatabaseService databaseService = new DatabaseService();
  Storage storage = new Storage();

  bool _isImg = true;
  bool _isBackground = true;
  bool isPostLoading = true;
  bool isLikesLoading = true;

  bool isErrorOccurred = false;

  CommentService commentService = new CommentService();

  int likes = 0;

  Logging logging = new Logging();

  File image = new File("");

  String img_url = "";
  String background_url = "";

  NetworkImage backgroundImg = NetworkImage("");

  List<DocumentSnapshot<Map<String, dynamic>>>? posts;

  @override
  void initState() {
    super.initState();
    try {
      getUser();
    } catch(e) {
      setState(() {
        isErrorOccurred = true;
      });
    }
  }

  Future getUser() async {
    try {
      final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

      final docOwner = userCollection.doc(widget.postOwnerUId);
      postUser = await docOwner.get() as DocumentSnapshot<Map<String, dynamic>>;
      getPosts();
      likes = postUser!["wholeLikes"];
      getUserProfile();
      getUserBackground();

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

  getPosts() async {
    try {
      PostService postService = new PostService();
      await postService.getProfilePosts(postUser!["posts"]).then((value) => {
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
    }
    
  }

  getUserProfile() async {
    try {
      await storage.loadProfileFile(postUser!["email"].toString(), postUser!["profilePic"].toString()).then((value) => {
        img_url = value,
        if (this.mounted) {
          setState(() {
            _isImg = false;
          })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          _isImg = false;
        });
      }
    }
  }

  getUserBackground() async {
    try {
      await storage.loadProfileBackground(postUser!["email"].toString(), postUser!["backgroundPic"].toString()).then((value) => {
        background_url = value,
        if (this.mounted) {
          setState(() {
            _isBackground = false;
          })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          _isBackground = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    double sizedBoxinCard = MediaQuery.of(context).size.height * 0.026;
    double top = MediaQuery.of(context).size.height * 0.026;
    try {
    return isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    _isImg = true;
                    _isBackground = true;
                    isPostLoading = true;
                  }
                });
                Future.delayed(Duration.zero,() async {
                  await getUser();
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (_isImg || _isBackground || isPostLoading)? Center(child: CircularProgressIndicator(color: Colors.white),) : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: MediaQuery.of(context).size.width * 0.06,),
          onPressed: () => Navigator.of(context).pop(),
        )
      ),
      body: SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              BackgroundWidget(background_url: background_url),
              Positioned(
                top: top,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.18,),
                    ProfileWidget(
                    imagePath: img_url, 
                    onClicked: () async {},
                    ),
                    SizedBox(height: sizedBoxinCard),
                    buildName(postUser!),
                    SizedBox(height: sizedBoxinCard),
                    SizedBox(height: sizedBoxinCard),
                    NumbersWidget(postUser!, likes),
                    SizedBox(height: sizedBoxinCard * 2),
                  ],
                ),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width,
                top: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    SizedBox(height: sizedBoxinCard * 1.5),
                    Card(
                      shape: RoundedRectangleBorder( 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: (MediaQuery.of(context).size.height * 0.026) / 6, 
                      child: Column(
                        children: [
                          buildAbout(postUser!),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1, width: MediaQuery.of(context).size.width,)
                        ]
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05
                    ),
                    Row(
                      children: <Widget>[
                          Expanded(
                            child: Divider(   
                              indent: 20.0,
                              endIndent: 10.0,
                              thickness: 1,
                            ),
                          ),     
                          Text("Posts"),        
                          Expanded(
                            child: Divider(
                              indent: 20.0,
                              endIndent: 10.0,
                              thickness: 1,
                            ),
                          ),    
                      ]
                    ),
                    SizedBox(height: 30,),
                  ]
                )
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          SizedBox(height: MediaQuery.of(context).size.height * 0.5,),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05 * postUser!["intro"].toString().split("\n").length,),

          Column(
            children: 
                List.generate(posts!.length, (index) {
                  return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: postUser!["bookmarks"].contains(posts![index]["postId"]), tags: posts![index]["tags"], posted: posts![index]["posted"], isProfileClickable: false,);
                }
            )
          ),
        ],
      )
    )
    );} catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    _isImg = true;
                    _isBackground = true;
                    isPostLoading = true;
                  }
                });
                Future.delayed(Duration.zero,() async {
                  await getUser();
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
  }

  Widget buildName(DocumentSnapshot<Map<String, dynamic>> user) => Column(
        children: [
          Text(
            user["name"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.026),
          ),
          SizedBox(height: (MediaQuery.of(context).size.height * 0.026) / 6),
          Text(
            user["email"].toString(),
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildAbout(DocumentSnapshot<Map<String, dynamic>> user) => Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.052),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.0173),
            Text(
              'About',
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.026, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0173),
            Text(
              user!["intro"],
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.0173, height: MediaQuery.of(context).size.height * 0.0015),
            ),
          ],
        ),
      );
  
  Widget buildEditIcon(Color color, BuildContext context) => buildCircle(
        color: Colors.white,
        all: MediaQuery.of(context).size.height * 0.002,
        child: buildCircle(
          color: color,
          all: MediaQuery.of(context).size.height * 0.008,
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: MediaQuery.of(context).size.height * 0.022,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

}