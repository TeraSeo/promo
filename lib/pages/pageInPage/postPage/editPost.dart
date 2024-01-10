import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:textfield_tags/textfield_tags.dart';

class EditPost extends StatefulWidget {
  final String postId;
  final String email;
  const EditPost({super.key, required this.postId, required this.email});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {

  DatabaseService? databaseService;
  PostService postService = new PostService();
  DocumentSnapshot<Map<String, dynamic>>? post;
  bool isPostLoading = true;

  bool isErrorOccurred = false;

  List<File> selectedImages = [];
  List<dynamic> images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getPost();
  }

  getPost() async {
    try {
    await postService.getSpecificPost(widget.postId).then((value) => {
      post = value,
      if (this.mounted) {
        setState(() {
          _controllerDescription.text = post!["description"];
          description = post!["description"];
          category = post!["category"];
          for (int i = 0; i < post!["tags"].length; i++) {
            tags.add(post!["tags"][i]);
          }
          withComment = post!["withComment"];
          isPostLoading = false;
          images = post!["images"];
        })
      }
    });} catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
  }

  final formKey = GlobalKey<FormState>();

  TextfieldTagsController _controllerTag = TextfieldTagsController();
  TextEditingController _controllerDescription = new TextEditingController();

  final items = [
    'News',
    'Entertainment',
    'Sports',
    'Food'
    'Economy',
    'Stock',
    'Shopping',
    'Science',
    'Etc.'
  ];

  String description = "";
  String category = "";
  List<String> tags = [];
  bool withComment = true;

  bool postAble = true;

  @override
  void dispose() {
    _controllerTag.dispose();
    _controllerDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
    return isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                    isErrorOccurred = false;
                    Navigator.of(context).pop();
                  });
                }
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : isPostLoading? Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
      appBar: AppBar(
        title: Text("Edit Post"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  getLabel(title: 'Images'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    width: 300,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // Background color
                        ),
                        onPressed: () {
                          _showPicMenu();
                        },
                        child: Row(
                            children: [
                                Icon(Icons.change_circle, color: Colors.white,),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.03,
                                ),
                                Text("Change images")
                            ]
                        )
                    )
                  ),
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
                      try {

                        if (_controllerTag.getTags!.contains(tag)) {
                          return 'you already entered that';
                        }
                        else if (_controllerTag.getTags!.length > 7) {
                          return 'too many tags';
                        }
                        return null;

                      } catch(e) {
                        if (this.mounted) {
                          setState(() {
                            isErrorOccurred = true;
                          });
                        }
                      }
                      
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
                    try {
                      if (formKey.currentState!.validate() && postAble) {
                        setState(() {
                          postAble = false;
                        });
                        tags = _controllerTag.getTags!;
                        
                        if (images.isEmpty) {
                          print(selectedImages);
                          PostService postService = new PostService();
                          await postService.updatePost(selectedImages, description, category, tags, withComment, widget.postId, widget.email);
                          nextScreen(context, HomePage(pageIndex: 0,));
                        }
                        else {
                          PostService postService = new PostService();
                          await postService.updatePostWithOutImages(description, category, tags, withComment, widget.postId);
                          nextScreen(context, HomePage(pageIndex: 0,));
                        }
                      }
                    } catch(e) {
                      if (this.mounted) {
                        setState(() {
                          isErrorOccurred = true;
                        });
                      }
                    }
                  }, 
                  child: Text("Edit Post", style: TextStyle(color: Colors.white),),
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
      )
    );} catch(e) { 
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                Navigator.of(context).pop();
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
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

  void _showPicMenu() {
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
                leading: Icon(Icons.picture_in_picture_alt),
                title: Text('No photo'),
                onTap: () {
                  setState(() {
                    images = [];
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text('Select photo'),
                onTap: () async{
                  await getImages();
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

  Future getImages() async {
    selectedImages = [];
    try {
      final pickedFile = await picker.pickMultiImage(
        imageQuality: 50, maxHeight: 1000, maxWidth: 1000);
        List<XFile> xfilePick = pickedFile;
        setState(
          () {
            if (xfilePick.isNotEmpty) {
              for (var i = 0; i < xfilePick.length; i++) {
                selectedImages.add(File(xfilePick[i].path));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing is selected')));
            }
            images = [];
          },
        );

    } catch (e) {
      if (this.mounted) {
      setState(() {
        isErrorOccurred = true;
      });
    }}
  }
}