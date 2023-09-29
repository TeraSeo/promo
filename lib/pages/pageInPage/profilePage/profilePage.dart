import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/profilePage/editInfo.dart';
import 'package:like_app/pages/pageInPage/profilePage/editProfile.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widget/background_widget.dart';
import 'package:like_app/widget/numbers_widget.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:like_app/widget/profile_widget.dart';
import 'package:like_app/services/RestApi.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  DocumentSnapshot<Map<String, dynamic>>? postUser;

  DatabaseService databaseService = new DatabaseService();
  RestApi restApi = new RestApi();
  Storage storage = new Storage();

  bool _isImg = true;
  bool _isBackground = true;
  bool isPostLoading = true;
  bool isUIdLoading = true;
  bool isLikesLoading = true;

  Logging logging = new Logging();

  File image = new File("");

  String img_url = "";
  String background_url = "";
  int likes = 0;

  String? uID; 

  NetworkImage backgroundImg = NetworkImage("");

  List<DocumentSnapshot<Map<String, dynamic>>>? posts;

  CommentService commentService = new CommentService();

  Future pickImage(ImageSource source, String email, String uId, String usage) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = await storage.compressImage(File(image.path));

      setState(() {
        this.image = imageTemporary;
      });

      nextScreen(context, EditProfile(image: this.image,email: email, uId: uId, usage: usage));
    } on PlatformException catch(e) {
      print("Failed to pick image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async {
      await getUser();
    });
  }

  Future getUser() async {

    await HelperFunctions.getUserUIdFromSF().then((value) => {
        uID = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        }
      });

    final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("user");

    final user = userCollection.doc(uID);
    postUser = await user.get() as DocumentSnapshot<Map<String, dynamic>>;
    await getPosts();
    getPostLikes(postUser!["posts"]);
    getCommentLikes(postUser!["comments"]);
    getUserProfile();
    getUserBackground();
  }

  getPostLikes(List<dynamic> postIds) async {
    PostService postService = new PostService();
    await postService.getPostLikes(postIds).then((value) => {
      likes = likes + value,
      if (this.mounted) {
        setState(() {
          isLikesLoading = false;
        })
      }
    });
    int num = postUser!["removedLikes"];
    likes = likes + num;
  }

  getCommentLikes(List<dynamic> commentIds) async {
    for (int i = 0; i < commentIds.length; i++) {
      int num = await commentService.getCommentLikes(commentIds[i]);
      likes = likes + num;
    }
  }

  getPosts() async {
    PostService postService = new PostService();
     await postService.getProfilePosts(postUser!["posts"]).then((value) => {
      posts = value,
      if (this.mounted) {
        setState(() {
          isPostLoading = false;
        })
      }
    });
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
      logging.message_error(postUser!["name"].toString() + "'s error " + e.toString());
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
      logging.message_error(postUser!["name"].toString() + "'s error " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizedBoxinCard = MediaQuery.of(context).size.height * 0.026;
    double top = MediaQuery.of(context).size.height * 0.026;

    return (_isImg || _isBackground || isPostLoading || isUIdLoading || isLikesLoading)? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
    Container(
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
                    imagePath: img_url,   // user image
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
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.5 + MediaQuery.of(context).size.height * 0.047 * 3.1 / 5,),
              GestureDetector(
                child: buildEditIcon(Theme.of(context).primaryColor, context),
                onTap: _showShareMenu,
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.5,),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05 * postUser!["intro"].toString().split("\n").length,),


          Column(
            children: 
                List.generate(posts!.length, (index) {
                  return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uID), likes: posts![index]['likes'].length, uId: uID, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: postUser!["bookmarks"].contains(posts![index]["postId"]),);
                }
            )
          ),
        ],
      )
    ); 
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
                title: Text('Change profile picture'),
                onTap: () {
                  Navigator.pop(context);
                  _showPicMenu(postUser, "profile");
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Change background picture'),
                onTap: () {
                  Navigator.pop(context);
                  _showPicMenu(postUser, "background");
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit profile information'),
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(context, EditInfo(postUser: postUser,));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Setting'),
                onTap: () {
                  Navigator.pop(context);
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
                title: Text('From gallery'),
                onTap: () {
                  pickImage(ImageSource.gallery, post_user!["email"].toString(), post_user!["uid"].toString(), usage);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined),
                title: Text('From camera'),
                onTap: () {
                  pickImage(ImageSource.camera, post_user!["email"].toString(), post_user!["uid"].toString(), usage);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.backspace),
                title: Text('Back'),
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