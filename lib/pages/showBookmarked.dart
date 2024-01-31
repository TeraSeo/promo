import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowBookmarkedPosts extends StatefulWidget {

  final List<dynamic> bookmarkedPosts;
  const ShowBookmarkedPosts({super.key, required this.bookmarkedPosts});

  @override
  State<ShowBookmarkedPosts> createState() => _ShowBookmarkedPostsState();
}

class _ShowBookmarkedPostsState extends State<ShowBookmarkedPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookmarked, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(),
    );
  }
}