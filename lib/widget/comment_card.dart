import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widget/edit_comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';

class CommentCard extends StatefulWidget {

  final int? likes;
  final bool? isCommentLike;
  final String? commentOwnerUid;
  final String? email;
  final String? name;
  final DateTime? posted;

  final String? commentId;
  final String? uId;
  final String? postId;

  const CommentCard({super.key, required this.likes, required this.isCommentLike, required this.commentOwnerUid, required this.email, required this.name, required this.posted, required this.commentId, required this.uId, required this.postId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  DocumentSnapshot<Map<String, dynamic>>? commentInfo;

  bool isLoading = true;

  String? profileUrl = "";
  
  bool isProfileLoading = true;

  DateTime? current;

  bool? isOwnComment;
  bool? isCommentLike;
  int? likes;

  String? diff = "";

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
        await DatabaseService().gettingUserData(widget.email!);

    Storage storage = new Storage();
    try {
      await storage.loadProfileFile(widget.email!, snapshot.docs[0]["profilePic"].toString()).then((value) => {
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
      logging.message_error(widget.name! + "'s error " + e.toString());
    }
  }

  getCommentInfo() async {
    CommentService commentService = new CommentService(commentId: widget.commentId);
    await commentService.getCommentInfo().then((value) => {
      commentInfo = value,
      if (mounted) {
        setState(() {

          isCommentLike = widget.isCommentLike!;
          likes = widget.likes;

          isOwnComment = widget.uId == widget.commentOwnerUid;
          current = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

          calcTime(current!, widget.posted!);

        })
      }
    });
  }

  calcTime(DateTime current, DateTime posted) {

    if (current.difference(posted).inSeconds < 60 && current.difference(posted).inSeconds >= 1) {
      diff = current.difference(posted).inSeconds.toString() + "s ago";
    } 
    else if (current.difference(posted).inMinutes < 60 && current.difference(posted).inMinutes >= 1) {
      diff = current.difference(posted).inMinutes.toString() + "m ago";
    } 
    else if (current.difference(posted).inHours < 24 && current.difference(posted).inHours >= 1) {
      diff = current.difference(posted).inHours.toString() + "h ago";
    }
    else if (current.difference(posted).inDays < 365 && current.difference(posted).inDays >= 1) {
      diff = current.difference(posted).inDays.toString() + "d ago";
    }
    else if (current.difference(posted).inDays >= 365) {
      diff = (current.difference(posted).inDays ~/ 365).toString() + "y ago";
    } 
    else {
      diff = "now";
    }

    setState(() {
      isLoading = false;
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

    try {

      return (isLoading || isProfileLoading)? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
      GestureDetector(
        onDoubleTap: () async {
          setState(() {
            if (isCommentLike!) {
              isCommentLike = false;
              likes = likes! - 1;
              commentService.removeCommentLikeUser(widget.uId!);
            } else {
              isCommentLike = true;
              likes = likes! + 1;
              commentService.addCommentLikeUser(widget.uId!);
            }
          });

          if (isCommentLike!) {
            await databaseService.plusCommentLike(widget.commentOwnerUid!);

          } else {
            await databaseService.minusCommentLike(widget.commentOwnerUid!);
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
                  nextScreen(context, OthersProfilePages(uId: widget.uId!, postOwnerUId: widget.commentOwnerUid!,));
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
                              text: " " + diff!,
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
          isOwnComment! ?
          Positioned(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.04,
                child: IconButton(onPressed: () async {
                  setState(() {
                    if (isCommentLike!) {
                      isCommentLike = false;
                      likes = likes! - 1;
                      commentService.removeCommentLikeUser(widget.uId!);
                      
                    } else {
                      isCommentLike = true;
                      likes = likes! + 1;
                      commentService.addCommentLikeUser(widget.uId!);
                    }
                  });

                  if (isCommentLike!) {
                    await databaseService.plusCommentLike(widget.uId!);

                  } else {
                    await databaseService.minusCommentLike(widget.uId!);
                  }
                }, icon: isCommentLike!? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
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
                    if (isCommentLike!) {
                      isCommentLike = false;
                      likes = likes! - 1;
                      commentService.removeCommentLikeUser(widget.uId!);
                    } else {
                      isCommentLike = true;
                      likes = likes! + 1;
                      commentService.addCommentLikeUser(widget.uId!);
                    }
                  });

                  if (isCommentLike!) {
                    await databaseService.plusCommentLike(widget.uId!);

                  } else {
                    await databaseService.minusCommentLike(widget.uId!);
                  }
                }, icon: isCommentLike!? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
              ),
            ],
          ), left: MediaQuery.of(context).size.width * 0.78,)
          ]
        ) 
        ),
      );

    } catch(e) {
      
      print(e);
      return Container();
    }

    
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
                    nextScreenReplace(context, EditCommentWidget(postId: widget.postId, uId: widget.uId, description: commentInfo!["description"], commentId: widget.commentId,));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove Comment'),
                  onTap: () async{
                    CommentService commentService = new CommentService();
                    await commentService.removeComment(widget.commentId!, widget.postId!).then((value) {
                      nextScreenReplace(context, CommentWidget(postId: widget.postId, uId: widget.uId,));
                    });
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