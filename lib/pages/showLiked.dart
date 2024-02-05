import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';

class ShowLikedPosts extends StatefulWidget {

  final List<dynamic> likedPosts;
  final String uId;
  final String preferredLanguage;
  const ShowLikedPosts({super.key, required this.likedPosts, required this.uId, required this.preferredLanguage});

  @override
  State<ShowLikedPosts> createState() => _ShowLikedPostsState();
}

class _ShowLikedPostsState extends State<ShowLikedPosts> {

  Map<dynamic, dynamic>? likedPosts;
  bool isLikedPostsLoading = true;
  bool isMoreLoading = false;
  bool isLoadingMorePostsPossible = true;
  PostService postService = PostService.instance;
  HelperFunctions helperFunctions = HelperFunctions();

  int i = 10;

  String? currentUsername;
  bool isCurrentUsernameLoading = true;
  
  void getCurrentUsername() {
    helperFunctions.getUserNameFromSF().then((value) {
      currentUsername = value;
      if (this.mounted) {
        setState(() {
          isCurrentUsernameLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUsername();
    getLikedPosts().then((value) {
      likedPosts = value;
      if (this.mounted) {
        setState(() {
          isLikedPostsLoading = false;
        });
      }
    });
  }

  Future<Map<dynamic, dynamic>> getLikedPosts() async {
    if (widget.likedPosts.length - i >= 0) {
      i = i + 10;
      return postService.getLikedPosts(widget.likedPosts.getRange(0, 10).toList());
    }
    else {
      setState(() {
        isLoadingMorePostsPossible = false;
      });
      return postService.getLikedPosts(widget.likedPosts.getRange(0, widget.likedPosts.length).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isLikedPostsLoading || isCurrentUsernameLoading) ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.liked, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          try {
            if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && scrollNotification.metrics.atEdge && !isMoreLoading && isLoadingMorePostsPossible) {
              isMoreLoading = true;
              if (widget.likedPosts.length - i >= 10) {
                postService.getLikedPosts(widget.likedPosts.getRange(i - 10, i).toList()).then((value) => {
                  if (this.mounted) {
                    for (int i = 0; i < value.length; i++) {
                      setState(() {
                        likedPosts![likedPosts!.length] = value[i];
                      })
                    }
                  },
                });
                i = i + 10;
              }
              else {
                setState(() {
                  isLoadingMorePostsPossible = false;
                });
                postService.getLikedPosts(widget.likedPosts.getRange(i - 10, widget.likedPosts.length).toList()).then((value) => {
                if (this.mounted) {
                  for (int i = 0; i < value.length; i++) {
                    setState(() {
                      likedPosts![likedPosts!.length] = value[i];
                    })
                  },
                },
              });
              }
              setState(() {
                isMoreLoading = false;
              });
            }
            return true;
          } catch(e) {
            if (this.mounted) {
              setState(() {
              });
            }
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children:
              List.generate(likedPosts!.length, (index) {
                try {
                  return Container(
                    child: PostWidget(email: likedPosts![index]['email'], postID: likedPosts![index]['postId'], name: likedPosts![index]['writer'], image: likedPosts![index]['images'], description: likedPosts![index]['description'],isLike: likedPosts![index]['likes'].contains(widget.uId), likes: likedPosts![index]['likes'].length, uId: widget.uId, postOwnerUId: likedPosts![index]['uId'], withComment: likedPosts![index]["withComment"], isBookMark: likedPosts![index]["bookMarks"].contains(widget.uId), tags: likedPosts![index]["tags"], posted: likedPosts![index]["posted"],isProfileClickable: true, preferredLanguage: widget.preferredLanguage, likedPeople: likedPosts![index]["likes"], currentUsername: currentUsername!,),
                  );
                } catch(e) {
                  return Container();
                }
              })
          ),
        ),
      ),
    );
  }
}