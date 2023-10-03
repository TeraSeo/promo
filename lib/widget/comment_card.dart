import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/edit_comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';

class CommentCard extends StatefulWidget {

  final String? commentId;
  final String? uId;
  final String? postId;

  const CommentCard({super.key, required this.commentId, required this.uId, required this.postId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  DocumentSnapshot<Map<String, dynamic>>? commentInfo;

  bool isLoading = true;
  bool isCommentLike = false;
  int likes = 0;
  String commentOwnerUid = "";

  String? profileUrl = "";
  
  bool isProfileLoading = true;

  bool isOwnComment = false;
  
  String email = "";
  String name = "";

  DatabaseService databaseService = new DatabaseService();

  Logging logging = new Logging();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0)).then((value) async => {
      await getCommentInfo(),
      await getOwnerProfile()
    });
  }

  getOwnerProfile() async {

    QuerySnapshot snapshot =
        await DatabaseService().gettingUserData(email);

    Storage storage = new Storage();
    try {
      await storage.loadProfileFile(email, snapshot.docs[0]["profilePic"].toString()).then((value) => {
        profileUrl = value,
        if (this.mounted) {
          setState(() {
            isProfileLoading = false;
          })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isProfileLoading = false;
        });
      }
      logging.message_error(name + "'s error " + e.toString());
    }
  }

  getCommentInfo() async {
    CommentService commentService = new CommentService(commentId: widget.commentId);
    await commentService.getCommentInfo().then((value) => {
      commentInfo = value,
      if (mounted) {
        setState(() {
          likes = commentInfo!["likedUsers"].length;
          isCommentLike = commentInfo!["likedUsers"].contains(widget.uId);
          commentOwnerUid = commentInfo!["uId"];
          isOwnComment = commentOwnerUid == widget.uId;

          email = commentInfo!["email"];
          name = commentInfo!["username"];

          isLoading = false;

        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double fontSize;
    double radiusWidth;
    double iconSize;

    CommentService commentService = new CommentService(commentId: widget.commentId);

    if(Device.get().isTablet) {
      fontSize = MediaQuery.of(context).size.width * 0.026;
      radiusWidth = MediaQuery.of(context).size.width * 0.026;
      iconSize = MediaQuery.of(context).size.width * 0.03;

    }
    else {
      fontSize = MediaQuery.of(context).size.width * 0.037;
      radiusWidth = MediaQuery.of(context).size.width * 0.035;
      iconSize = MediaQuery.of(context).size.width * 0.038;

    }

    return (isLoading || isProfileLoading)? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
    GestureDetector(
      onDoubleTap: () async {
        setState(() {
          if (isCommentLike) {
            isCommentLike = false;
            likes = likes - 1;
            commentService.removeCommentLikeUser(widget.uId!);
          } else {
            isCommentLike = true;
            likes = likes + 1;
            commentService.addCommentLikeUser(widget.uId!);
          }
        });

        if (isCommentLike) {
          await databaseService.plusCommentLike(commentOwnerUid);

        } else {
          await databaseService.minusCommentLike(commentOwnerUid);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.023,
          horizontal: MediaQuery.of(context).size.width * 0.03
        ),
        child:
       Stack(
        children: [
           Row(
          children: [
            InkWell(
              onTap: () {
                nextScreen(context, OthersProfilePages(uId: widget.uId!, postOwnerUId: commentOwnerUid,));
              },
              child: Container(
                width: MediaQuery.of(context).size.height * 0.05,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: DecorationImage(
                    image: NetworkImage(profileUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
                  border: Border.all(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.height * 0.005,
                  ),
                ),
              ),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.01),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: fontSize * 0.9),
                        children: [
                          TextSpan(
                            text: commentInfo!["username"],
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                            text: " " + commentInfo!["posted"],
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: fontSize * 0.9)
                          ),
                        ]
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.005),
                    child: RichText(text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: fontSize),
                      text: commentInfo!["description"],
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.008),
                    child: Text(
                      likes.toString() + " likes",
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
        isOwnComment ?
         Positioned(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.04,
              child: IconButton(onPressed: () async {
                setState(() {
                  if (isCommentLike) {
                    isCommentLike = false;
                    likes = likes - 1;
                    commentService.removeCommentLikeUser(widget.uId!);
                    
                  } else {
                    isCommentLike = true;
                    likes = likes + 1;
                    commentService.addCommentLikeUser(widget.uId!);
                  }
                });

                if (isCommentLike) {
                  await databaseService.plusCommentLike(widget.uId!);

                } else {
                  await databaseService.minusCommentLike(widget.uId!);
                }
              }, icon: isCommentLike? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
            ),
            IconButton(onPressed: () {
              _showOptionMenu();
            }, 
              icon: Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.04)
            ), 
          ],
         ), left: MediaQuery.of(context).size.width * 0.78,) :
         Positioned(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: IconButton(onPressed: () async {
                setState(() {
                  if (isCommentLike) {
                    isCommentLike = false;
                    likes = likes - 1;
                    commentService.removeCommentLikeUser(widget.uId!);
                  } else {
                    isCommentLike = true;
                    likes = likes + 1;
                    commentService.addCommentLikeUser(widget.uId!);
                  }
                });

                if (isCommentLike) {
                  await databaseService.plusCommentLike(widget.uId!);

                } else {
                  await databaseService.minusCommentLike(widget.uId!);
                }
              }, icon: isCommentLike? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
            ),
          ],
         ), left: MediaQuery.of(context).size.width * 0.78,)
        ]
       ) 
      ),
    );
  }

  void _showOptionMenu() {
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
                  leading: Icon(Icons.edit),
                  title: Text('Edit Comment'),
                  onTap: () {
                    nextScreen(context, EditCommentWidget(postId: widget.postId, uId: widget.uId, description: commentInfo!["description"], commentId: widget.commentId,));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove Comment'),
                  onTap: () async{
                    CommentService commentService = new CommentService();
                    commentService.removeComment(widget.commentId!, widget.postId!);
                    nextScreen(context, HomePage());
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