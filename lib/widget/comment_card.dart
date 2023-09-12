import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/services/comment_service.dart';

class CommentCard extends StatefulWidget {

  final String? commentId;

  const CommentCard({super.key, required this.commentId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  DocumentSnapshot<Map<String, dynamic>>? commentInfo;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCommentInfo();
  }

  getCommentInfo() async {
    CommentService commentService = new CommentService(commentId: widget.commentId);
    await commentService.getCommentInfo().then((value) => {
      commentInfo = value,
      if (mounted) {
        setState(() {
          isLoading = false;
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    bool isTablet;
    double fontSize;
    double radiusWidth;
    double iconSize;

    if(Device.get().isTablet) {
      isTablet = true;
      fontSize = MediaQuery.of(context).size.width * 0.026;
      radiusWidth = MediaQuery.of(context).size.width * 0.026;
      iconSize = MediaQuery.of(context).size.width * 0.03;

    }
    else {
      isTablet = false;
      fontSize = MediaQuery.of(context).size.width * 0.037;
      radiusWidth = MediaQuery.of(context).size.width * 0.035;
      iconSize = MediaQuery.of(context).size.width * 0.038;


    }


    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.023,
        horizontal: MediaQuery.of(context).size.width * 0.03
      ),
      child:
       Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
            radius: radiusWidth,
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
                    commentInfo!["likes"].toString() + " likes",
                    style: TextStyle(
                      fontSize: fontSize * 0.9,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                )
              ],
            ),
          Spacer(),
          Container(
            child: Icon(Icons.favorite_border_outlined, size: iconSize),
          )
        ]
      ),
    );
  }
}