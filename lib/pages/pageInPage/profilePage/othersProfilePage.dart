import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widget/background_widget.dart';
import 'package:like_app/widget/numbers_widget.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:like_app/widget/profile_widget.dart';
import 'package:like_app/services/userService.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  Storage storage = Storage.instance;

  bool _isImg = true;
  bool _isBackground = true;
  bool isPostLoading = true;
  bool isLikesLoading = true;
  bool isErrorOccurred = false;
  bool isRankingLoading = true;

  CommentService commentService = CommentService.instance;

  int likes = 0;

  int? ranking = 0;

  Logging logging = new Logging();

  File image = new File("");

  String img_url = "";
  String background_url = "";

  NetworkImage backgroundImg = NetworkImage("");

  List<DocumentSnapshot<Map<String, dynamic>>>? posts;

  var logger = Logger();
  PostService postService = PostService.instance;

  String? preferredLanguage;
  bool isPreferredLanguageLoading = true;

  @override
  void initState() {
    super.initState();
    try {
      getUser();
      getRanking();
      setPreferredLanguageLoading();
    } catch(e) {
      setState(() {
        isErrorOccurred = true;
      });
    }
  }

  void setPreferredLanguageLoading() {
    HelperFunctions.getUserLanguageFromSF().then((value) {
      preferredLanguage = value;
      setState(() {
        if (this.mounted) {
          isPreferredLanguageLoading = false;
        }
      });
    }); 
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
      logger.log(Level.error, "Error occurred while getting user\nerror: " + e.toString());
    }
    
  }

  getRanking() async {
    await databaseService.getRanking(widget.uId).then((value) => {
        ranking = value,
        if (this.mounted) {
          setState(() {
            isRankingLoading = false;
          })
        }
      });
  }

  getPosts() async {
    try {
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
      logger.log(Level.error, "Error occurred while getting posts\nerror: " + e.toString());
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
          img_url = 'assets/blank.avif';
        });
      }
      logger.log(Level.error, "Error occurred while getting profiles\nerror: " + e.toString());
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
          background_url = 'assets/backgroundDef.jpeg';
        });
      }
      logger.log(Level.error, "Error occurred while getting background profiles\nerror: " + e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {

    double sizedBoxinCard = MediaQuery.of(context).size.height * 0.026;
    double top = MediaQuery.of(context).size.width - (MediaQuery.of(context).size.height * 0.047 * 3.1 / 2); 

    try {
    return isErrorOccurred? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    _isImg = true;
                    _isBackground = true;
                    isPostLoading = true;
                    isRankingLoading = true;
                    isPreferredLanguageLoading = true;
                  }
                });
                Future.delayed(Duration.zero,() async {
                  await getUser();
                  getRanking();
                  setPreferredLanguageLoading();
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (_isImg || _isBackground || isPostLoading || isRankingLoading || isPreferredLanguageLoading)? Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white), 
            backgroundColor: Colors.black, 
          ),
        ) ,
      ): 
    Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Constants().iconColor),
        backgroundColor: Colors.black,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white, size: MediaQuery.of(context).size.width * 0.06,),
        //   onPressed: () => Navigator.of(context).pop(),
        // )
      ),
      body: 
      RefreshIndicator(
        child:
      SingleChildScrollView(
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
                    ProfileWidget(
                    imagePath: img_url, 
                    onClicked: () async {},
                    ),
                    SizedBox(height: sizedBoxinCard),
                    buildName(postUser!),
                    SizedBox(height: sizedBoxinCard),
                    SizedBox(height: sizedBoxinCard),
                    NumbersWidget(postUser!, likes, ranking!),
                    SizedBox(height: sizedBoxinCard * 2),
                  ],
                ),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width,
                top: MediaQuery.of(context).size.height * 0.3 + top + sizedBoxinCard * 5,
                child: Column(
                  children: [
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
          SizedBox(height: top * 0.9,),
          postUser!["intro"].toString().split("\n").length <= 4 ?
          SizedBox(height: MediaQuery.of(context).size.height * 0.32) :
          SizedBox(height: MediaQuery.of(context).size.height * 0.08 * postUser!["intro"].toString().split("\n").length,),

          Column(
            children: 
                List.generate(posts!.length, (index) {
                  try {
                    return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: postUser!["bookmarks"].contains(posts![index]["postId"]), tags: posts![index]["tags"], posted: posts![index]["posted"], isProfileClickable: false, preferredLanguage: preferredLanguage!);
                  } catch(e) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () {
                                setState(() {
                                if (this.mounted) {
                                  isErrorOccurred = false;
                                  _isImg = true;
                                  _isBackground = true;
                                  isPostLoading = true;
                                  isRankingLoading = true;
                                }
                              });
                              Future.delayed(Duration.zero,() async {
                                await getUser();
                              });

                            }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                            Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                          ],
                        )
                    );
                  }
                }
            )
          ),
        ],
      )
    ),
    onRefresh: () async {

      if (this.mounted) {
        setState(() {
          isErrorOccurred = false;
          _isImg = true;
          _isBackground = true;
          isPostLoading = true;
          isRankingLoading = true;
          isPreferredLanguageLoading = true;
        });
      }

      try {
        getUser();
        getRanking();
        setPreferredLanguageLoading();
      } catch(e) {
        setState(() {
          isErrorOccurred = true;
        });
      }


    }
    )
    );} catch(e) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    _isImg = true;
                    _isBackground = true;
                    isPostLoading = true;
                    isRankingLoading = true;
                  }
                });
                Future.delayed(Duration.zero,() async {
                  await getUser();
                  getRanking();
                  
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
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
            user["isEmailVisible"]? 
            user["email"].toString() : 
            "",
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