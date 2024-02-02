import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widget/edit_comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  bool isProfileLoading = true;

  DateTime? current;

  bool? isOwnComment;
  bool? isCommentLike;
  int? likes;

  String? diff = "";
  
  var image;

  DatabaseService databaseService = DatabaseService.instance;
  CommentService commentService = CommentService.instance;

  Logging logger = Logging();
  bool isErrorOccurred = false;

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
        await databaseService.getUserData(widget.email!);

    try {
      if (snapshot.docs[0]["profilePic"].toString() == "" || snapshot.docs[0]["profilePic"].toString() == null) {
        if (this.mounted) {
          setState(() {
            image = AssetImage('assets/blank.avif');
            isProfileLoading = false;
          });
        }
      }
      else {
        image = NetworkImage(snapshot.docs[0]["profilePic"].toString());
        if (this.mounted) {
          setState(() {
            isProfileLoading = false;
          });
        }
      }
      // await storage.loadProfileFile(widget.email!, snapshot.docs[0]["profilePic"].toString()).then((value) => {
      //   image = NetworkImage(value),
      //   if (this.mounted) {
      //     setState(() {
      //       isProfileLoading = false;
      //     })
      //   }
      // });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          image = AssetImage('assets/blank.avif');
          isProfileLoading = false;
        });
      }
    }
  }

  getCommentInfo() async {
    try {

      await commentService.getCommentInfo(widget.commentId!).then((value) => {
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

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.message_warning("Error occurred while getting comments\nerror: " + e.toString());
    }
    
  }

  calcTime(DateTime current, DateTime posted) {

    try {

      if (current.difference(posted).inSeconds < 60 && current.difference(posted).inSeconds >= 1) {
        diff = current.difference(posted).inSeconds.toString() + AppLocalizations.of(context)!.s;
      } 
      else if (current.difference(posted).inMinutes < 60 && current.difference(posted).inMinutes >= 1) {
        diff = current.difference(posted).inMinutes.toString() + AppLocalizations.of(context)!.m;
      } 
      else if (current.difference(posted).inHours < 24 && current.difference(posted).inHours >= 1) {
        diff = current.difference(posted).inHours.toString() + AppLocalizations.of(context)!.h;
      }
      else if (current.difference(posted).inDays < 7 && current.difference(posted).inDays >= 1) {
        diff = current.difference(posted).inDays.toString() + AppLocalizations.of(context)!.d;
      }
      else if (current.difference(posted).inDays < 31 && current.difference(posted).inDays >= 7) {
        diff = (current.difference(posted).inDays ~/ 7).toInt().toString() + AppLocalizations.of(context)!.w;
      }
      else if (current.difference(posted).inDays < 365 && current.difference(posted).inDays >= 31) {
        diff = (current.difference(posted).inDays ~/ 31).toInt().toString() + AppLocalizations.of(context)!.month;
      }
      else if (current.difference(posted).inDays >= 365) {
        diff = (current.difference(posted).inDays ~/ 365).toString() + AppLocalizations.of(context)!.y;
      } 
      else {
        diff = "now";
      }

      setState(() {
        isLoading = false;
      });
    }
    catch(e) {
      diff = "";
    }

  }

  @override
  Widget build(BuildContext context) {

    double fontSize;
    double iconSize;

    if(Device.get().isTablet) {
      fontSize = MediaQuery.of(context).size.width * 0.026;
      iconSize = MediaQuery.of(context).size.width * 0.03;

    }
    else {
      fontSize = MediaQuery.of(context).size.width * 0.037;
      iconSize = MediaQuery.of(context).size.width * 0.038;
    }

    try {
      return isErrorOccurred ? Container() : (isLoading || isProfileLoading)? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
      GestureDetector(
        onDoubleTap: () async {
          try {
          setState(() {
              if (isCommentLike!) {
                isCommentLike = false;
                likes = likes! - 1;
                commentService.removeCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
              } else {
                isCommentLike = true;
                likes = likes! + 1;
                commentService.addCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
              }
            });

          } catch(e) {
            if (this.mounted) {
              setState(() {
                isErrorOccurred = true;
              });
            }
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
                      image: image,
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
                        likes! > 1 ?  
                        likes.toString() + " " + AppLocalizations.of(context)!.likes :
                        likes.toString() + " " + AppLocalizations.of(context)!.like,
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
                  try {

                    setState(() {
                      if (isCommentLike!) {
                        isCommentLike = false;
                        likes = likes! - 1;
                        commentService.removeCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
                        
                      } else {
                        isCommentLike = true;
                        likes = likes! + 1;
                        commentService.addCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
                      }
                    });

                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
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
                  try {
                    setState(() {
                      if (isCommentLike!) {
                        isCommentLike = false;
                        likes = likes! - 1;
                        commentService.removeCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
                      } else {
                        isCommentLike = true;
                        likes = likes! + 1;
                        commentService.addCommentLikeUser(widget.uId!, widget.commentOwnerUid!, widget.commentId!);
                      }
                    });

                    
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
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
                  title: Text(AppLocalizations.of(context)!.editCom),
                  onTap: () {
                    Navigator.pop(context);
                    nextScreenReplace(context, EditCommentWidget(postId: widget.postId, uId: widget.uId, description: commentInfo!["description"], commentId: widget.commentId,));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text(AppLocalizations.of(context)!.rmCom),
                  onTap: () async{
                    try {
                      await commentService.removeComment(widget.commentId!, widget.postId!).then((value) {
                        Navigator.pop(context);
                        nextScreenReplace(context, CommentWidget(postId: widget.postId, uId: widget.uId,));
                      });
                    } catch(e) {
                      logger.message_warning("Error occurred while removing comments\nerror: " + e.toString());
                    }
                    
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