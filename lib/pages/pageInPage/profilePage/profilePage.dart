import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/ImagePicker/StatelessPicker.dart';
import 'package:like_app/pages/pageInPage/profilePage/editInfo.dart';
import 'package:like_app/pages/pageInPage/settingPage.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widget/background_widget.dart';
import 'package:like_app/widget/numbers_widget.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:like_app/widget/profile_widget.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {

  final ScrollController scrollController;
  const ProfilePage({super.key, required this.scrollController});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  DocumentSnapshot<Map<String, dynamic>>? postUser;

  DatabaseService databaseService = new DatabaseService();
  Storage storage = new Storage();
  PostService postService = new PostService();

  bool _isImg = true;
  bool _isBackground = true;
  bool isPostLoading = true;
  bool isUIdLoading = true;
  bool isMoreLoading = false;

  Logging logging = new Logging();

  File image = new File("");

  String img_url = "";
  String background_url = "";
  int likes = 0;

  String? uID; 

  bool isErrorOccurred = false;
  
  bool isRankingLoading = true;

  int? ranking = 0;

  NetworkImage backgroundImg = NetworkImage("");

  List<DocumentSnapshot<Map<String, dynamic>>>? posts;

  CommentService commentService = new CommentService();

  var logger = Logger();

  Future pickImage(ImageSource source, String email, String uId, String usage) async {
    nextScreen(context, SinglePicker(usage: usage, uID: uId, email: email,));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async {
      await getUser();
      await getPosts();
      getUserProfile();
      getUserBackground();
    });
  }

  Future getUser() async {
    try {
      await HelperFunctions.getUserUIdFromSF().then((value) => {
        uID = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        },
      });

      await databaseService.getRanking(uID!).then((value) => {
        ranking = value,
        if (this.mounted) {
          setState(() {
            isRankingLoading = false;
          })
        }
      });
      

      final CollectionReference userCollection = 
          FirebaseFirestore.instance.collection("user");

      final user = userCollection.doc(uID);
      await user.get().then((value) => {
        postUser = value as DocumentSnapshot<Map<String, dynamic>>,
        likes = postUser!["wholeLikes"],
      });
    } catch(e) {
      if (this.mounted) {setState(() {
        isErrorOccurred = true;
      });}
      logger.log(Level.error, "Error occurred while getting user information");
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
          // isErrorOccurred = true;
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
          // isErrorOccurred = true;
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
    return
    isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    _isImg = true;
                    _isBackground = true;
                    isPostLoading = true;
                    isUIdLoading = true;
                    isRankingLoading = true;
                  }
                });
                Future.delayed(Duration.zero,() async {
                  await getUser();
                  await getPosts();
                  getUserProfile();
                  getUserBackground();
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
    (_isImg || _isBackground || isPostLoading || isUIdLoading || isRankingLoading)? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
      RefreshIndicator(
        child: SingleChildScrollView(
          controller: widget.scrollController,
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
                      imagePath: img_url,   // user image
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
                  width: MediaQuery.of(context).size.width * 0.95,
                  top: top + sizedBoxinCard * 5 + MediaQuery.of(context).size.height * 0.3,
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.5 + MediaQuery.of(context).size.height * 0.047 * 3.1 / 5,),
                GestureDetector(
                  child: buildEditIcon(Theme.of(context).primaryColor, context),
                  onTap: _showShareMenu,
                )
              ],
            ),
            SizedBox(height: top * 0.9),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05 * postUser!["intro"].toString().split("\n").length,),
            Column(
              children: 
                  List.generate(posts!.length, (index) {
                    try {

                    return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uID), likes: posts![index]['likes'].length, uId: uID, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: postUser!["bookmarks"].contains(posts![index]["postId"]), tags: posts![index]["tags"], posted: posts![index]["posted"], isProfileClickable: true,);
                    } catch(e) {

                      return Center(
            child: Column(
              children: [
                IconButton(onPressed: () {
                  try {
                    setState(() {
                      if (this.mounted) {
                        isErrorOccurred = false;
                        _isImg = true;
                        _isBackground = true;
                        isPostLoading = true;
                        isUIdLoading = true;
                        isRankingLoading = true;
                      }
                    });
                    Future.delayed(Duration.zero,() async {
                      await getUser();
                      await getPosts();
                      getUserProfile();
                      getUserBackground();
                    });
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
                  }
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
          try {
            setState(() {
            if (this.mounted) {
              _isImg = true;
              _isBackground = true;
              isPostLoading = true;
              isUIdLoading = true;
              isRankingLoading = true;
            }
            });
            Future.delayed(Duration.zero,() async {
              await getUser();
              await getPosts();
              getUserProfile();
              getUserBackground();
            });
          } catch(e) {
            if (this.mounted) {
              setState(() {
                isErrorOccurred = true;
              });
            }
            logger.log(Level.error, "Error occurred while refreshing\nerror: " + e.toString());
          }
          
        },
      );
    } catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                try {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = false;
                      _isImg = true;
                      _isBackground = true;
                      isPostLoading = true;
                      isUIdLoading = true;
                      isRankingLoading = true;
                    });
                  }
                  Future.delayed(Duration.zero,() async {
                    await getUser();
                    await getPosts();
                    getUserProfile();
                    getUserBackground();
                  });
                } catch(e) {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                }
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
          postUser!["isEmailVisible"] ? Text(
            user["email"].toString(),
            style: TextStyle(color: Colors.grey),
          ) : Text("")
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

  void _showShareMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)
        )
      ),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.changeProfile),
                onTap: () {
                  Navigator.pop(context);
                  _showPicMenu(postUser, "profile");
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.changeBackground),
                onTap: () {
                  Navigator.pop(context);
                  _showPicMenu(postUser, "background");
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editInfo),
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(context, EditInfo(postUser: postUser,));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.setting),
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(context, SettingPage(uId: postUser!["uid"]));
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
            ],
          ),
        );
      }
    );
  }

  void _showPicMenu(DocumentSnapshot<Map<String, dynamic>>? post_user, String usage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)
        )
      ),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              ListTile(
                leading: Icon(Icons.folder),
                title: Text(AppLocalizations.of(context)!.fromGallery),
                onTap: () {
                  pickImage(ImageSource.gallery, post_user!["email"].toString(), post_user!["uid"].toString(), usage);
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.camera_alt_outlined),
              //   title: Text('From camera'),
              //   onTap: () {
              //     pickImage(ImageSource.camera, post_user!["email"].toString(), post_user!["uid"].toString(), usage);
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text(AppLocalizations.of(context)!.cancel),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.backspace),
                title: Text(AppLocalizations.of(context)!.back),
                onTap: () {
                  Navigator.pop(context);
                  _showShareMenu();
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
            ],
          ),
        );
      }
    );
  }
}