import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/appPost.dart';
import 'package:like_app/widget/etcPost.dart';
import 'package:like_app/widget/webPost.dart';

class ShowBookmarkedPosts extends StatefulWidget {

  final List<dynamic> bookmarkedPosts;
  final String uId;
  final String preferredLanguage;
  const ShowBookmarkedPosts({super.key, required this.bookmarkedPosts, required this.uId, required this.preferredLanguage});

  @override
  State<ShowBookmarkedPosts> createState() => _ShowBookmarkedPostsState();
}

class _ShowBookmarkedPostsState extends State<ShowBookmarkedPosts> {

  Map<dynamic, dynamic>? bookmarkedPosts;
  bool isBookmarkedPostsLoading = true;
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
      bookmarkedPosts = value;
      if (this.mounted) {
        setState(() {
          isBookmarkedPostsLoading = false;
        });
      }
    });
  }

  Future<Map<dynamic, dynamic>> getLikedPosts() async {
    if (widget.bookmarkedPosts.length - i >= 0) {
      i = i + 10;
      return postService.getBookMarkedPosts(widget.bookmarkedPosts.getRange(0, 10).toList());
    }
    else {
      setState(() {
        isLoadingMorePostsPossible = false;
      });
      return postService.getBookMarkedPosts(widget.bookmarkedPosts.getRange(0, widget.bookmarkedPosts.length).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isBookmarkedPostsLoading || isCurrentUsernameLoading) ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.liked, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          try {
            if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && scrollNotification.metrics.atEdge && !isMoreLoading && isLoadingMorePostsPossible) {
              isMoreLoading = true;
              if (widget.bookmarkedPosts.length - i >= 10) {
                postService.getBookMarkedPosts(widget.bookmarkedPosts.getRange(i - 10, i).toList()).then((value) => {
                  if (this.mounted) {
                    for (int i = 0; i < value.length; i++) {
                      setState(() {
                        bookmarkedPosts![bookmarkedPosts!.length] = value[i];
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
                postService.getBookMarkedPosts(widget.bookmarkedPosts.getRange(i - 10, widget.bookmarkedPosts.length).toList()).then((value) => {
                if (this.mounted) {
                  for (int i = 0; i < value.length; i++) {
                    setState(() {
                      bookmarkedPosts![bookmarkedPosts!.length] = value[i];
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
              List.generate(bookmarkedPosts!.length, (index) {
                try {
                  return Container(
                    child:
                      bookmarkedPosts![index]["type"] == "App" ?
                     AppPostWidget(email: bookmarkedPosts![index]['email'], postID: bookmarkedPosts![index]['postId'], name: bookmarkedPosts![index]['writer'], image: bookmarkedPosts![index]['images'], description: bookmarkedPosts![index]['description'],isLike: bookmarkedPosts![index]['likes'].contains(widget.uId), likes: bookmarkedPosts![index]['likes'].length, uId: widget.uId, postOwnerUId: bookmarkedPosts![index]['uId'], withComment: bookmarkedPosts![index]["withComment"], isBookMark: bookmarkedPosts![index]["bookMarks"].contains(widget.uId), tags: bookmarkedPosts![index]["tags"], posted: bookmarkedPosts![index]["posted"],isProfileClickable: true, preferredLanguage: widget.preferredLanguage, likedPeople: bookmarkedPosts![index]["likes"], currentUsername: currentUsername!, category: bookmarkedPosts![index]["category"], appName: bookmarkedPosts![index]["appName"], pUrl: bookmarkedPosts![index]["pUrl"], aUrl: bookmarkedPosts![index]["aUrl"], type: bookmarkedPosts![index]["type"]) :
                      bookmarkedPosts![index]["type"] == "Web" ?
                     WebPostWidget(email: bookmarkedPosts![index]['email'], postID: bookmarkedPosts![index]['postId'], name: bookmarkedPosts![index]['writer'], image: bookmarkedPosts![index]['images'], description: bookmarkedPosts![index]['description'],isLike: bookmarkedPosts![index]['likes'].contains(widget.uId), likes: bookmarkedPosts![index]['likes'].length, uId: widget.uId, postOwnerUId: bookmarkedPosts![index]['uId'], withComment: bookmarkedPosts![index]["withComment"], isBookMark: bookmarkedPosts![index]["bookMarks"].contains(widget.uId), tags: bookmarkedPosts![index]["tags"], posted: bookmarkedPosts![index]["posted"],isProfileClickable: true, preferredLanguage: widget.preferredLanguage, likedPeople: bookmarkedPosts![index]["likes"], currentUsername: currentUsername!, category: bookmarkedPosts![index]["category"], webName: bookmarkedPosts![index]["webName"], webUrl: bookmarkedPosts![index]["webUrl"], type: bookmarkedPosts![index]["type"]) :
                     EtcPostWidget(email: bookmarkedPosts![index]['email'], postID: bookmarkedPosts![index]['postId'], name: bookmarkedPosts![index]['writer'], image: bookmarkedPosts![index]['images'], description: bookmarkedPosts![index]['description'],isLike: bookmarkedPosts![index]['likes'].contains(widget.uId), likes: bookmarkedPosts![index]['likes'].length, uId: widget.uId, postOwnerUId: bookmarkedPosts![index]['uId'], withComment: bookmarkedPosts![index]["withComment"], isBookMark: bookmarkedPosts![index]["bookMarks"].contains(widget.uId), tags: bookmarkedPosts![index]["tags"], posted: bookmarkedPosts![index]["posted"],isProfileClickable: true, preferredLanguage: widget.preferredLanguage, likedPeople: bookmarkedPosts![index]["likes"], currentUsername: currentUsername!, category: bookmarkedPosts![index]["category"], etcName: bookmarkedPosts![index]["etcName"], etcUrl: bookmarkedPosts![index]["etcUrl"], type: bookmarkedPosts![index]["type"]) 
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