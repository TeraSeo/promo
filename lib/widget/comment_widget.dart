import 'package:flutter/material.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widget/comment_card.dart';
import 'package:like_app/widgets/widgets.dart';

class CommentWidget extends StatefulWidget {

  final String? postId;

  const CommentWidget({super.key, required this.postId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  String? content = "";
  List<dynamic>? comments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  getComments() async {
    CommentService commentService = new CommentService(postId: widget.postId);
    await commentService.getComments().then((value) => {
      comments = value,
      setState(() {
        isLoading = false;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants().primaryColor,
        title: Text("Comments", style: TextStyle(fontSize: 17),),
      ),
      body: 
      comments!.length > 0 ? 
      Container(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: comments!.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: CommentCard(commentId: comments![index],),
            );
          }
        )
      ) : Container(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: EdgeInsets.only(left: 20, top: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: TextField(
                    onChanged: (value) {
                      content = value;
                    },
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      suffixIcon: IconButton(
                        // color: Colors.blue,
                        disabledColor: Colors.black,
                        focusColor: Colors.blue,
                        onPressed: () async {
                          CommentService commnetService = new CommentService(description: content, postId: widget.postId);
                          await commnetService.postComment();
                          nextScreen(context, HomePage());
                        },
                        icon: Icon(Icons.post_add_rounded)
                      )
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