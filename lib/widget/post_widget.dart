import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/animation/likeAnimation.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/pageInPage/postPage/editPost.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/widget/searchByTag.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostWidget extends StatefulWidget {
  final String? email;
  final String? postID;
  final String? name;
  final List<dynamic>? image;
  final String? description;
  final bool? isLike;
  final int? likes;
  final String? uId;
  final String? postOwnerUId;
  final bool? withComment;
  final bool? isBookMark;
  final List<dynamic> tags;
  final Timestamp posted;

  final bool isProfileClickable;
  
  const PostWidget({super.key, required this.email, required this.postID, required this.name, required this.image, required this.description, required this.isLike, required this.likes, required this.uId, required this.postOwnerUId, required this.withComment, required this.isBookMark, required this.tags, required this.posted, required this.isProfileClickable});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {

  bool isLikeAnimation = false;
  bool? isLike;
  bool isProfileLoading = true;
  int? likes;
  String? profileFileName = "";
  String? profileUrl = "";
  Logging logging = new Logging();
  
  List<String>? images;

  bool isLoading = true;
  bool? isBookMark;

  bool isErrorOccurred = false;

  final pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  String timeDiff = "";

  var logger = Logger();

  @override
  void initState() {
    super.initState();

    calTimeDiff();

    getImages();
    if (this.mounted) {
      setState(() {
        isLike = widget.isLike;
        likes = widget.likes;
        isBookMark = widget.isBookMark;
      });
    }
    
    getOwnerProfile();
  }

  calTimeDiff() {

    try {

      DateTime current = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
      DateTime posted = DateTime.fromMicrosecondsSinceEpoch(widget.posted.microsecondsSinceEpoch);

      if (current.difference(posted).inSeconds < 60 && current.difference(posted).inSeconds >= 1) {
        timeDiff = current.difference(posted).inSeconds.toString() + "s ago";
      } 
      else if (current.difference(posted).inMinutes < 60 && current.difference(posted).inMinutes >= 1) {
        timeDiff = current.difference(posted).inMinutes.toString() + "m ago";
      } 
      else if (current.difference(posted).inHours < 24 && current.difference(posted).inHours >= 1) {
        timeDiff = current.difference(posted).inHours.toString() + "h ago";
      }
      else if (current.difference(posted).inDays < 365 && current.difference(posted).inDays >= 1) {
        timeDiff = current.difference(posted).inDays.toString() + "d ago";
      }
      else if (current.difference(posted).inDays >= 365) {
        timeDiff = (current.difference(posted).inDays ~/ 365).toString() + "y ago";
      } 
      else {
        timeDiff = "now";
      }

    } catch(e) {
      setState(() {
        if (this.mounted) {
          isErrorOccurred = true;
        }
      });
    }

  }

  getOwnerProfile() async {
 
    QuerySnapshot snapshot =
        await DatabaseService().gettingUserData(widget.email!);

    Storage storage = new Storage();
    try {
      await storage.loadProfileFile(widget.email.toString(), snapshot.docs[0]["profilePic"].toString()).then((value) => {
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
      logging.message_error(widget.name.toString() + "'s error " + e.toString());
    }
  }

  void getImages() async {
    try {
      Storage storage = new Storage();
      await storage.loadPostImages(widget.email!, widget.postID!, widget.image!).then((value) => {
        images = value,
        if (this.mounted) {
          setState(() {
            isLoading = false;
          })
        }
      });
    } catch(e) {
      setState(() {
        isErrorOccurred = true;
      });
    }
    
  }

  PostService postService = new PostService();

  @override
  Widget build(BuildContext context) {
    bool isTablet;
    double logoSize; 
    double bookMarkLeft;
    double descriptionSize;
    double iconWidth;

    DatabaseService databaseService = DatabaseService(uid: widget.uId);

    if(Device.get().isTablet) {
      isTablet = true;
      bookMarkLeft = MediaQuery.of(context).size.width * 0.90;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.035;
      iconWidth = MediaQuery.of(context).size.width * 0.07;
    }
    else {
      isTablet = false;
      bookMarkLeft = MediaQuery.of(context).size.width * 0.87;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.053;
      iconWidth = MediaQuery.of(context).size.width * 0.093;
    }

    try {
      return isErrorOccurred? Container() : (isLoading || isProfileLoading) ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
          Container(
            child: Column(
              children: [
                isTablet ? 
                (Stack(
                  children: [
                    (Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.height * 0.016,
                        ),
                        InkWell(
                          onTap: () {
                            if (widget.isProfileClickable) {
                              nextScreen(context, OthersProfilePages(uId: widget.uId!, postOwnerUId: widget.postOwnerUId!,));
                            }
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
                        SizedBox(width: MediaQuery.of(context).size.height * 0.011,),
                        Text(widget.name.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, fontStyle: FontStyle.normal, fontWeight: FontWeight.w500)),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.6),
                      ],
                    )), 
                    Positioned(child: IconButton(onPressed: () {
                          _showOptionMenu();
                        }, 
                          icon: Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.04)
                        ), 
                      left: MediaQuery.of(context).size.width * 0.9,
                    )
                  ],
                )) : 
                Stack(
                  children: [
                    (Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.height * 0.016,
                        ),
                        InkWell(
                          onTap: () {
                            if (widget.isProfileClickable) {
                              nextScreen(context, OthersProfilePages(uId: widget.uId!, postOwnerUId: widget.postOwnerUId!,));
                            }
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
                        SizedBox(width: MediaQuery.of(context).size.height * 0.011,),
                        Text(widget.name.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, fontStyle: FontStyle.normal, fontWeight: FontWeight.w500)),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.6),
                      ],
                    )), 
                    Positioned(child: IconButton(onPressed: () {
                          _showOptionMenu();
                        }, 
                          icon: Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.057)
                        ), 
                      left: MediaQuery.of(context).size.width * 0.85,
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013
                ),
                images!.length == 0 ? Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.012,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(widget.description.toString(), style: TextStyle(fontSize: descriptionSize),)
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
                      Stack(
                        children: [
                          Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          SizedBox(
                            width: iconWidth,
                            child: LikeAnimation(
                              isAnimating: true,
                              smallLike: false,
                              child: IconButton(
                              onPressed: () async {
                                try {
                                  setState(()  {
                                    if (!isLike!) {
                                      isLikeAnimation = true;
                                      isLike = true;
                                      likes = likes! + 1;
                                    }
                                    else {
                                      isLike = false;
                                      likes = likes! - 1;
                                    }
                                  });
                                  if (isLike!) {
                                    await postService.postAddLike(widget.postID!);
                                    await databaseService.addUserLike(widget.postID!);
                                  }
                                  else {
                                    await postService.postRemoveLike(widget.postID!);
                                    await databaseService.removeUserLike(widget.postID!);
                                  }
                                } catch(e) {
                                  logger.log(Level.error, "error occurred while user likes post\nerror : " + e.toString());
                                }
                              }, 
                                icon: isLike!? Icon(Icons.favorite, size: logoSize, color: Colors.red,) : Icon(Icons.favorite_outline, size: logoSize)
                              ),
                            )
                          ),
                          widget.withComment! ? 
                          SizedBox(
                            width: iconWidth,
                            child: IconButton(onPressed: () {
                              nextScreen(context, CommentWidget(postId: widget.postID, uId: widget.uId,));
                            }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                          ) : SizedBox()
                        ],
                      ),
                      Positioned(
                            left: bookMarkLeft,
                            child: SizedBox(
                            width: iconWidth,
                              child: IconButton(onPressed: () async {
                                try {
                                  setState(() {
                                    if (isBookMark!) {
                                      isBookMark = false;
                                    }
                                    else {
                                      isBookMark = true;
                                    }
                                  });

                                  if (isBookMark!) {

                                    await databaseService.addUserBookMark(widget.postID!);
                                    await postService.addBookMark(widget.postID!, widget.uId!);

                                  } else {
                                    await databaseService.removeUserBookMark(widget.postID!);
                                    await postService.removeBookMark(widget.postID!, widget.uId!);
                                  }
                                } catch(e) {
                                  logger.log(Level.error, "error occurred while user bookmarks post\nerror : " + e.toString());
                                }
                              },
                              icon: isBookMark!? Icon(Icons.bookmark, size: logoSize) : Icon(Icons.bookmark_outline, size: logoSize),
                            )
                          ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(likes!.toString() + " likes", style: TextStyle(fontSize: descriptionSize * 0.8, fontWeight: FontWeight.bold),)
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Row(
                            children:List.generate(widget.tags.length, (index) {
                              return Row(
                                children: [
                                  GestureDetector(
                                    child: Text("#" + widget.tags[index].toString(), style: TextStyle(fontSize: descriptionSize, color: Colors.blueGrey),),
                                    onTap: () {
                                      nextScreen(context, SearchByTag(searchText: widget.tags[index].toString()));
                                    }, 
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.02,
                                  ),
                                ],
                              );
                            })                   
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(timeDiff, style: TextStyle(fontSize: descriptionSize * 0.8, color: Colors.grey),)
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                  ],
                ) :
                Column(
                  children: [
                      GestureDetector(
                        onDoubleTap: () async {
                          try {
                            setState(()  {
                              if (!isLike!) {
                                  isLikeAnimation = true;
                                  isLike = true;
                                  likes = likes! + 1;
                                }
                                else {
                                  isLike = false;
                                  likes = likes! - 1;
                                }
                              });
                              if (isLike!) {
                                await postService.postAddLike(widget.postID!);
                                await databaseService.addUserLike(widget.postID!);
                              }
                              else {
                                await postService.postRemoveLike(widget.postID!);
                                await databaseService.removeUserLike(widget.postID!);
                              }
                          } catch(e) {
                            logger.log(Level.error, "error occurred while user bookmarks post\nerror : " + e.toString());
                          }
                        }, 
                        child: Stack(
                          alignment: Alignment.center ,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.38,
                              child: PageView.builder(
                                controller: pageController,
                                itemBuilder: (_, index) {
                                  return AnimatedBuilder(
                                    animation: pageController,
                                    builder: (ctx, child) {
                                      return SizedBox(
                                        child: Image(
                                          image: NetworkImage(images![index]),fit: BoxFit.fill
                                        ));
                                    }
                                  );
                                },
                                itemCount: images!.length
                              )
                            ),
                            AnimatedOpacity(
                              opacity: isLikeAnimation? 1: 0, 
                              duration: const Duration(milliseconds: 200),
                              child: LikeAnimation(
                                child: const Icon(Icons.favorite, color: Colors.white, size: 100), 
                                isAnimating: isLikeAnimation,
                                duration: const Duration(
                                  milliseconds: 400
                                ),
                                onEnd: () {
                                  setState(() {
                                    isLikeAnimation = false;
                                  });
                                },
                              )  
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.012,),
                      images!.length == 1 ? Container(height: 0,) :  
                      Column(children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                        SmoothPageIndicator(
                          controller: pageController, 
                          count: images!.length,
                          effect: SwapEffect(
                            activeDotColor: Colors.black,
                            dotHeight: MediaQuery.of(context).size.height * 0.01,
                            dotWidth: MediaQuery.of(context).size.height * 0.01,
                            spacing:  MediaQuery.of(context).size.height * 0.005,
                          ),
                        ),
                      ],),
                      Stack(
                        children: [
                          Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          SizedBox(
                            width: iconWidth,
                            child: LikeAnimation(
                              isAnimating: true,
                              smallLike: false,
                              child: IconButton(
                              onPressed: () async {
                                try {
                                  setState(()  {
                                    if (!isLike!) {
                                      isLikeAnimation = true;
                                      isLike = true;
                                      likes = likes! + 1;
                                    }
                                    else {
                                      isLike = false;
                                      likes = likes! - 1;
                                    }
                                  });
                                  if (isLike!) {
                                    await postService.postAddLike(widget.postID!);
                                    await databaseService.addUserLike(widget.postID!);
                                  }
                                  else {
                                    await postService.postRemoveLike(widget.postID!);
                                    await databaseService.removeUserLike(widget.postID!);
                                  }
                                } catch(e) {
                                  logger.log(Level.error, "error occurred while user likes post\nerror : " + e.toString());
                                }
                              }, 
                                icon: isLike!? Icon(Icons.favorite, size: logoSize, color: Colors.red,) : Icon(Icons.favorite_outline, size: logoSize)
                              ),
                            )
                          ),
                          widget.withComment! ? 
                          SizedBox(
                            width: iconWidth,
                            child: IconButton(onPressed: () {
                              nextScreen(context, CommentWidget(postId: widget.postID, uId: widget.uId,));
                            }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                          ) : SizedBox()
                        ],
                      ),
                      Positioned(
                            left: bookMarkLeft,

                            child: SizedBox(
                            width: iconWidth,
                              child: IconButton(onPressed: () async {
                                try {
                                  setState(() {
                                    if (isBookMark!) {
                                      isBookMark = false;
                                    }
                                    else {
                                      isBookMark = true;
                                    }
                                  });

                                  if (isBookMark!) {

                                    await databaseService.addUserBookMark(widget.postID!);
                                    await postService.addBookMark(widget.postID!, widget.uId!);

                                  } else {
                                    await databaseService.removeUserBookMark(widget.postID!);
                                    await postService.removeBookMark(widget.postID!, widget.uId!);
                                  }
                                } catch(e) {
                                  logger.log(Level.error, "error occurred while user bookmarks post\nerror : " + e.toString());
                                }
                              },
                              icon: isBookMark!? Icon(Icons.bookmark, size: logoSize) : Icon(Icons.bookmark_outline, size: logoSize),
                            )
                          ),
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(likes!.toString() + " likes", style: TextStyle(fontSize: descriptionSize * 0.9, fontWeight: FontWeight.bold),)
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.003,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(widget.description.toString(), style: TextStyle(fontSize: descriptionSize),)
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Row(
                            children:List.generate(widget.tags.length, (index) {
                              return Row(
                                children: [
                                  GestureDetector(
                                    child: Text("#" + widget.tags[index].toString(), style: TextStyle(fontSize: descriptionSize, color: Colors.blueGrey),),
                                    onTap: () {
                                      nextScreen(context, SearchByTag(searchText: widget.tags[index].toString()));
                                    }, 
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.02,
                                  ),
                                ],
                              );
                            })                   
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Text(timeDiff, style: TextStyle(fontSize: descriptionSize * 0.8, color: Colors.grey),)
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
                  ],
                )
              ],
            ),
          )
        ]
      );

    } catch(e) {
      return Container();
    }
    
  }

  void _showOptionMenu() {
    if (widget.uId! == widget.postOwnerUId!) {
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
                  title: Text('Edit this post'),
                  onTap: () {
                    nextScreen(context, EditPost(postId: widget.postID!, email: widget.email!,));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove this post'),
                  onTap: () async {
                    try {

                      await postService.removePost(widget.postID!, widget.email!);
                      nextScreen(context, HomePage(pageIndex: 0,));

                    } catch(e) {
                      if (this.mounted) {
                        setState(() {
                          isErrorOccurred = true;
                          logger.log(Level.error, "error occurred while user removes post\nerror : " + e.toString());
                        });
                      }
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
    else {
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
                  leading: Icon(Icons.favorite),
                  title: Text('Like this post'),
                  onTap: () async{
                    try {
                      DatabaseService databaseService = DatabaseService(uid: widget.uId);
                      setState(()  {
                          if (!isLike!) {
                              isLikeAnimation = true;
                              isLike = true;
                              likes = likes! + 1;
                            }
                            else {
                              isLike = false;
                              likes = likes! - 1;
                            }
                          });
                          if (isLike!) {
                            await postService.postAddLike(widget.postID!);
                            await databaseService.addUserLike(widget.postID!);
                          }
                          else {
                            await postService.postRemoveLike(widget.postID!);
                            await databaseService.removeUserLike(widget.postID!);
                          }
                      Navigator.pop(context);
                    } catch(e) {
                      logger.log(Level.error, "error occurred while user likes post\nerror : " + e.toString());
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Bookmark this post'),
                  onTap: () async{
                    try {
                      DatabaseService databaseService = DatabaseService(uid: widget.uId);
                      setState(()  {
                          if (isBookMark!) {
                            isBookMark = false;
                          }
                          else {
                            isBookMark = true;
                          }
                        });

                        if (isBookMark!) {

                          await databaseService.addUserBookMark(widget.postID!);
                          await postService.addBookMark(widget.postID!, widget.uId!);

                        } else {
                          await databaseService.removeUserBookMark(widget.postID!);
                          await postService.removeBookMark(widget.postID!, widget.uId!);
                        }
                        
                      Navigator.pop(context);
                    } catch(e) {
                      logger.log(Level.error, "error occurred while user bookmarks post\nerror : " + e.toString());
                    }
                  }
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('About this account'),
                  onTap: () {
                    if (widget.isProfileClickable) {
                      nextScreen(context, OthersProfilePages(uId: widget.uId!, postOwnerUId: widget.postOwnerUId!,));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report, color: Colors.red,),
                  title: Text('Report this account'),
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
  }
}