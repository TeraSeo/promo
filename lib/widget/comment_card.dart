import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {

  final String? commentId;

  const CommentCard({super.key, required this.commentId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  @override
  void initState() {
    super.initState();
    print(widget.commentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
            radius: 18,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "username",
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextSpan(
                        text: "some description to insert",
                        // style: TextStyle(fontWeight: FontWeight.bold)
                      )
                    ]
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "23/12/21",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 30),
            child: Icon(Icons.favorite_border_outlined, size: 16,),
          )
        ]
      ),
    );
  }
}