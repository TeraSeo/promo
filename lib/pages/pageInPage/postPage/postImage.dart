import 'package:flutter/material.dart';

class PostImage extends StatefulWidget {
  const PostImage({super.key});

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      title: Text("EditProfile")),
      body: Container()
    );
  }
}