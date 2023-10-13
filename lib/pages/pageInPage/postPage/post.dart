import 'dart:io';

import 'package:flutter/material.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:textfield_tags/textfield_tags.dart';

class Post extends StatefulWidget {
  final List<File> files;
  const Post({super.key, required this.files});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  DatabaseService? databaseService;
  String? uId;

  @override
  void initState() {
    super.initState();
  }


  final formKey = GlobalKey<FormState>();

  TextfieldTagsController _controllerTag = TextfieldTagsController();
  TextEditingController _controllerDescription = new TextEditingController();

  final items = [
    'News',
    'Entertainment',
    'Sports',
    'Economy',
    'Stock',
    'Shopping',
    'Science',
    'Etc.'
  ];

  String description = "";
  String category = "Etc.";
  List<String> tags = [];
  bool withComment = true;

  bool postAble = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getLabel(title: 'Images'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: "Description"),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 20,
                      maxLines: 7,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerDescription,
                      validator: (val) {
                        if (val!.isNotEmpty) {
                          return null;
                        } else {
                          return "description can not be empty";
                        }
                      },
                      onChanged: (val) {
                        description = val;
                      },
                      decoration: InputDecoration(hintText: "Description", labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.description), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: 'Category'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.002)
                    ),
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      items: items.map(buildMenuItem).toList(),
                      onChanged: (value) => setState(() => {
                        category = value!
                      }),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  getLabel(title: 'Tag'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFieldTags(
                    textfieldTagsController: _controllerTag,
                    initialTags: tags,
                    textSeparators: const [' ', ','],
                    letterCase: LetterCase.normal,
                    validator: (String tag) {
                      if (_controllerTag.getTags!.contains(tag)) {
                        return 'you already entered that';
                      }
                      else if (_controllerTag.getTags!.length > 7) {
                        return 'too many tags';
                      }
                      return null;
                    },
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        return Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: tec,
                            focusNode: fn,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Constants().primaryColor,
                                  width: 3.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Constants().primaryColor,
                                  width: 3.0,
                                ),
                              ),
                              helperStyle: TextStyle(
                                color: Constants().primaryColor,
                              ),
                              hintText: _controllerTag.hasTags ? '' : "Enter tag...",
                              errorText: error,
                              prefixIconConstraints:
                                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                              prefixIcon: tags.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller: sc,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                          children: tags.map((String tag) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            color: Constants().primaryColor,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Text(
                                                  '#$tag',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onTap: () {
                                                  print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(
                                                      255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  onTagDelete(tag);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                    )
                                  : null,
                            ),
                            onChanged: onChanged,
                            onSubmitted: onSubmitted
                          ),
                        );
                      });
                    },
                  ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  getLabel(title: 'Settings'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.002)
                    ),
                      child: Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    getLabel(title: 'Comment'),
                                    Switch(
                                      value: withComment,
                                      onChanged: (value) {
                                      setState(() {
                                      withComment = value;
                                    });
                                      },
                                      activeTrackColor: Theme.of(context).primaryColor,
                                      activeColor: Colors.white,
                                    ),
                                  ]            
                                ),
                              ],
                            )
                    ),
                  )
                ]            
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.06,),
            Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.057,
                child: ElevatedButton(
                  onPressed: () async{
                    if (formKey.currentState!.validate() && postAble) {
                      setState(() {
                        postAble = false;
                      });
                      tags = _controllerTag.getTags!;
                      PostService postService = new PostService();
                      await postService.post(widget.files, description, category, tags, withComment);
                      Future.delayed(Duration(seconds: 2)).then((value) => {
                        nextScreen(context, HomePage())
                      });
                    }
                  }, 
                  child: Text("Post"),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  OutlineInputBorder myinputborder(BuildContext context){ //return type is OutlineInputBorder
    return OutlineInputBorder( //Outline border type for TextFeild
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
          color:Theme.of(context).primaryColor,
          width: MediaQuery.of(context).size.width * 0.005, 
        )
    );
  }

  OutlineInputBorder myfocusborder(BuildContext context){
    return OutlineInputBorder(
      borderSide: BorderSide(
          color:Theme.of(context).primaryColor,
          width: MediaQuery.of(context).size.height * 0.003,
        )
    );
  }

  Widget getLabel({required String title}) {
    return Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
        child: Text(
            title, style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.015,
              fontWeight: FontWeight.w600
        )),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
    )
  );

}