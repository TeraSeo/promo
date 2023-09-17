import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/animation/likeAnimation.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';
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
  final String? currentUserName;
  
  const PostWidget({super.key, required this.email, required this.postID, required this.name, required this.image, required this.description, required this.isLike, required this.likes, required this.uId, required this.currentUserName});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {

  bool isLikeAnimation = false;
  bool? isLike;
  int? likes;
  
  List<String>? images;

  bool isLoading = true;

  final pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  @override
  void initState() {
    super.initState();
    getImages();
    setState(() {
      isLike = widget.isLike;
      likes = widget.likes;
    });
  }

  void getImages() async {
    Storage storage = new Storage();
    await storage.loadPostImages(widget.email!, widget.postID!, widget.image!).then((value) => {
      images = value,
      if (this.mounted) {
        setState(() {
          isLoading = false;
        })
      }
    });
  }

  PostService postService = new PostService();

  @override
  Widget build(BuildContext context) {
    bool isTablet;
    double logoSize; 
    double logoSpaceBetween;
    double descriptionSize;
    double iconWidth;

    DatabaseService databaseService = DatabaseService(uid: widget.uId);

    if(Device.get().isTablet) {
      isTablet = true;
      logoSpaceBetween = MediaQuery.of(context).size.width * 0.65;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.035;
      iconWidth = MediaQuery.of(context).size.width * 0.07;
    }
    else {
      isTablet = false;
      logoSpaceBetween = MediaQuery.of(context).size.width * 0.585;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.053;
      iconWidth = MediaQuery.of(context).size.width * 0.093;
    }



    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Column(
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
      Container(
        child: Column(
          children: [
            isTablet ? 
            (Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.026,
                ),
                Container(
                  width: MediaQuery.of(context).size.height * 0.04,
                  height: MediaQuery.of(context).size.height * 0.04,
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: DecorationImage(
                      image: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
                    border: Border.all(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.height * 0.011,),
                Text(widget.name.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, fontStyle: FontStyle.normal, fontWeight: FontWeight.w500)),
                SizedBox(width: MediaQuery.of(context).size.width * 0.6),
                IconButton(onPressed: () {
                  _showOptionMenu();
                }, 
                  icon: Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.057)
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
                    Container(
                      width: MediaQuery.of(context).size.height * 0.045,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        color: const Color(0xff7c94b6),
                        image: DecorationImage(
                          image: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
                        border: Border.all(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.height * 0.005,
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
                          }, 
                            icon: isLike!? Icon(Icons.favorite, size: logoSize, color: Colors.red,) : Icon(Icons.favorite_outline, size: logoSize)
                          ),
                        )
                      ),
                      SizedBox(
                        width: iconWidth,
                        child: IconButton(onPressed: () {
                          nextScreen(context, CommentWidget(postId: widget.postID));
                        }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                      ),
                      SizedBox(
                        width: iconWidth,
                          child: IconButton(onPressed: () {}, 
                          icon: Icon(Icons.send_outlined, size: logoSize),
                        ),
                      ),
                      SizedBox(
                        width: logoSpaceBetween
                      ),
                      SizedBox(
                        width: iconWidth,
                          child: IconButton(onPressed: () {},
                        icon: Icon(Icons.bookmark_outline, size: logoSize),
                        )
                      ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              ],
            ) :
            Column(
              children: [
                  GestureDetector(
                    onDoubleTap: () async {
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
                          }, 
                            icon: isLike!? Icon(Icons.favorite, size: logoSize, color: Colors.red,) : Icon(Icons.favorite_outline, size: logoSize)
                          ),
                        )
                      ),
                      SizedBox(
                        width: iconWidth,
                        child: IconButton(onPressed: () {
                          nextScreen(context, CommentWidget(postId: widget.postID));
                        }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                      ),
                      SizedBox(
                        width: iconWidth,
                          child: IconButton(onPressed: () {
                          }, 
                          icon: Icon(Icons.send_outlined, size: logoSize),
                        ),
                      ),
                      SizedBox(
                        width: logoSpaceBetween
                      ),
                      SizedBox(
                        width: iconWidth,
                          child: IconButton(onPressed: () {},
                        icon: Icon(Icons.bookmark_outline, size: logoSize),
                        )
                      ),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
              ],
            )
          ],
        ),
      )
    ]
  );
  }

  void _showOptionMenu() {
    if (widget.name! == widget.currentUserName!) {
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
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove this post'),
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
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('About this account'),
                  onTap: () {
                    Navigator.pop(context);
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