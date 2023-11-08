import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widget/comment_card.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';

class EditCommentWidget extends StatefulWidget {

  final String? postId;
  final String? uId;
  final String? description;
  final String? commentId;

  const EditCommentWidget({super.key, required this.postId, required this.uId, required this.description, required this.commentId});

  @override
  State<EditCommentWidget> createState() => _EditCommentWidgetState();
}

class _EditCommentWidgetState extends State<EditCommentWidget> {

  String? content = "";
  Map<dynamic, dynamic>? comments;

  bool isLoading = true;
  bool isCommentSubmitting = false;
  bool isMoreLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      content = widget.description;
    });
    getComments();
    getCommentLength();
  }

  getComments() async {
    CommentService commentService = new CommentService(postId: widget.postId);
    await commentService.getComments(widget.postId!).then((value) => {
      comments = value,
      if (this.mounted) {
        setState(() {
          isLoading = false;
        })
      }
    });
  }

  getMoreComments() async {
    CommentService commentService = new CommentService(postId: widget.postId);
    await commentService.getMoreComments(DateTime.fromMicrosecondsSinceEpoch(comments![comments!.length - 1]["posted"].microsecondsSinceEpoch) ,widget.postId!).then((value) => {
      for (int i = 0; i < value.length; i++) {
        setState(() {
          comments![comments!.length] = value[i];
        })
      },
      if (this.mounted) {
        setState(() {
          isMoreLoading = false;
        })
      }
    });
  }

  final CollectionReference commentCollection = 
        FirebaseFirestore.instance.collection("comment");

  int? wholeCommentLength;
  bool isWholeCommentLengthLoading = true;

  void getCommentLength() async {
    await commentCollection.get().then((value) => {
      wholeCommentLength = value.docs.length,
      setState(() {
        isWholeCommentLengthLoading = false;
      }),
    });
  }

  @override
  Widget build(BuildContext context) {

    bool isTablet;
    double logoSize; 
    double commentPadLeft;
    double commentPadTop;
    double commentPadRight;
    double barFontSize;
    double iconSize;
    double kTooHeight;
    double hintSize;
    double radiusWidth;

    if(Device.get().isTablet) {
      isTablet = true;
      logoSize = MediaQuery.of(context).size.width * 0.035;
      commentPadLeft = MediaQuery.of(context).size.width * 0.035 * 0.6;
      commentPadRight = MediaQuery.of(context).size.width * 0.035 * 0.6 * 0.8;
      commentPadTop = 0;
      barFontSize = MediaQuery.of(context).size.width * 0.025;
      iconSize = MediaQuery.of(context).size.width * 0.03;
      kTooHeight = MediaQuery.of(context).size.width * 0.06;
      hintSize = MediaQuery.of(context).size.width * 0.025;
      radiusWidth = MediaQuery.of(context).size.width * 0.026;

    }
    else {
      isTablet = false;
      logoSize = MediaQuery.of(context).size.width * 0.053;
      commentPadLeft = MediaQuery.of(context).size.width * 0.03;
      commentPadRight = MediaQuery.of(context).size.width * 0.035;
      commentPadTop = 0;
      barFontSize = MediaQuery.of(context).size.width * 0.042;
      iconSize = MediaQuery.of(context).size.width * 0.06;
      kTooHeight = MediaQuery.of(context).size.width * 0.1;
      hintSize = MediaQuery.of(context).size.width * 0.043;
      radiusWidth = MediaQuery.of(context).size.width * 0.045;

    }

    return isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        backgroundColor: Constants().primaryColor,
        title: Text("Comments", style: TextStyle(fontSize: barFontSize),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize,),
          onPressed: () => nextScreen(context, HomePage()),
        ), 
      ),
      body: 
      comments!.length > 0 ? 
      Container(
        child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && !isMoreLoading && wholeCommentLength! > comments!.length) {
            isMoreLoading = true;

            getMoreComments();

          }
          return true;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: comments!.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: CommentCard(likes: comments![index]["likedUsers"].length, isCommentLike: comments![index]["likedUsers"].contains(widget.uId),
                                 commentOwnerUid: comments![index]["uId"], email: comments![index]["email"], name: comments![index]["username"], 
                                 posted: DateTime.fromMicrosecondsSinceEpoch(comments![index]["posted"].microsecondsSinceEpoch), 
                                 commentId: comments![index]["commentId"], uId: widget.uId, postId: widget.postId,),
            );
          }
        ))
      ) : Container(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kTooHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: EdgeInsets.only(left: commentPadLeft, top: commentPadTop, right: commentPadRight),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                radius: radiusWidth,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: commentPadLeft, right: commentPadTop * 0.5),
                  child: SizedBox(
                    child: TextField(
                      controller: TextEditingController(text: content),
                      style: TextStyle(fontSize: hintSize),
                      onChanged: (value) {
                        content = value;
                      },
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        suffixIcon: IconButton(
                          disabledColor: Colors.black,
                          focusColor: Colors.blue,
                          onPressed: () async {
                            if (!isCommentSubmitting) {
                              if (content!.length > 0) {
                                setState(() {
                                isCommentSubmitting = true;
                                });
                                CommentService commnetService = new CommentService(description: content);
                                await commnetService.updateComment(widget.commentId!);
                                Future.delayed(Duration(seconds: 1)).then((value) => {
                                  nextScreen(context, CommentWidget(postId: widget.postId, uId: widget.uId,))
                                });
                              }
                            }
                          },
                          icon: Icon(Icons.post_add_rounded, size: logoSize,)
                        )
                      ),
                    ),
                  )
                )
              ),
            ],
          ),
        )),
    );
  }
}