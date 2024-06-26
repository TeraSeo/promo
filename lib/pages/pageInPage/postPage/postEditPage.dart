import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PostEditPage extends StatefulWidget {
  final String postId;
  final String email;
  final String category;
  final String type;
  const PostEditPage({super.key, required this.postId, required this.email, required this.category, required this.type});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {

  DatabaseService? databaseService;
  PostService postService = PostService.instance;
  DocumentSnapshot<Map<String, dynamic>>? post;
  HelperFunctions helperFunctions = HelperFunctions();

  bool isPstLoading = true;

  bool isErrorOccurred = false;
  bool isCategoryItemsLoading = true;

  List<dynamic> selectedImages = [];
  List<dynamic> images = [];
  final picker = ImagePicker();

  Logging logger = Logging();
  bool isImagesLoading = false;

  String appName = "";
  String aUrl = "";
  String pUrl = "";

  String webName = "";
  String webUrl = "";

  String etcName = "";
  String etcUrl = "";

  String? type;

  final postType = [
    "App",
    "Web",
    "Etc."
  ];

  @override
  void initState() {
  
    super.initState();
    type = widget.type;
    getPost();
    _controllerTag = new TextfieldTagsController();
    _controllerDescription = new TextEditingController();

  }

  TextEditingController _controllerAppName = new TextEditingController();
  TextEditingController _controllerPlayStoreURL = new TextEditingController();
  TextEditingController _controllerAppStoreURL = new TextEditingController();
  TextEditingController _controllerWebName = new TextEditingController();
  TextEditingController _controllerWebUrl = new TextEditingController();
  TextEditingController _controllerEtcName = new TextEditingController();
  TextEditingController _controllerEtcUrl = new TextEditingController();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setCategoryContents();
  }

  void setCategoryContents() {
    if (this.mounted) {
      setState(() {
        if (items == null) {
          items = [
            AppLocalizations.of(context)!.news,
            AppLocalizations.of(context)!.entertainment,
            AppLocalizations.of(context)!.sports,
            AppLocalizations.of(context)!.food,
            AppLocalizations.of(context)!.economy,
            AppLocalizations.of(context)!.stock,
            AppLocalizations.of(context)!.shopping,
            AppLocalizations.of(context)!.science,
            AppLocalizations.of(context)!.etc
          ];
        }
        if (category == null) {
          String cat = helperFunctions.changeCategoryToEnglish(widget.category);
          if (cat == "News") {
            category = AppLocalizations.of(context)!.news;
          }
          else if (cat == "Entertainment") {
            category = AppLocalizations.of(context)!.entertainment;
          }
          else if (cat == "Sports") {
            category = AppLocalizations.of(context)!.sports;
          }
          else if (cat == "Food") {
            category = AppLocalizations.of(context)!.food;
          }
          else if (cat == "Economy") {
            category = AppLocalizations.of(context)!.economy;
          }
          else if (cat == "Stock") {
            category = AppLocalizations.of(context)!.stock;
          }
          else if (cat == "Shopping") {
            category = AppLocalizations.of(context)!.shopping;
          }
          else if (cat == "Science") {
            category = AppLocalizations.of(context)!.science;
          }
          else {
            category = AppLocalizations.of(context)!.etc;
          }
        }
        
        isCategoryItemsLoading = false;
      });
    }
  }


  getPost() async {
    try {
      await postService.getSpecificPost(widget.postId).then((value) => {
        post = value,
        if (this.mounted) {
          setState(() {
            _controllerDescription.text = post!["description"];
            description = post!["description"];
            if (type == "App") {
              appName = post!["appName"];
              _controllerAppName.text = post!["appName"];
              pUrl = post!["pUrl"];
              _controllerPlayStoreURL.text = post!["pUrl"];
              aUrl = post!["aUrl"];
              _controllerAppStoreURL.text = post!["aUrl"];
            } 
            else if (type == "Web") {
              webName = post!["webName"];
              _controllerWebName.text = post!["webName"];
              webUrl = post!["webUrl"];
              _controllerWebUrl.text = post!["webUrl"];
            }
            else {
              etcName = post!["etcName"];
              _controllerEtcName.text = post!["etcName"];
              etcUrl = post!["etcUrl"];
              _controllerEtcUrl.text = post!["etcUrl"];
            }
            for (int i = 0; i < post!["tags"].length; i++) {
              tags.add(post!["tags"][i]);
            }
            withComment = post!["withComment"];
            isPstLoading = false;
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

  late TextfieldTagsController _controllerTag;
  late TextEditingController _controllerDescription;

  List<String>? items;

  String description = "";
  String? category;
  List<String> tags = [];
  bool withComment = true;

  bool isPostAble = true;

  @override
  void dispose() {
    try {
      super.dispose();
      _controllerTag.dispose();
      _controllerDescription.dispose();
      _controllerAppName.dispose();
      _controllerPlayStoreURL.dispose();
      _controllerAppStoreURL.dispose();
      _controllerWebName.dispose();
      _controllerWebUrl.dispose();
      _controllerEtcName.dispose();
      _controllerEtcUrl.dispose();
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
    return isErrorOccurred? 
       Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: () {
          if (this.mounted) {
            setState(() {
              isErrorOccurred = false;
              Navigator.of(context).pop();
            });
          }
        },
        icon: Icon(
          Icons.refresh,
          size: MediaQuery.of(context).size.width * 0.08,
          color: Colors.blueGrey,
        ),
      ),
      Text(
        AppLocalizations.of(context)!.loadFailed,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05,
          color: Colors.blueGrey,
        ),
      ),
    ],
  ),
) : 
isPstLoading? 
WillPopScope(
  onWillPop: () async => false,
  child: 
 Center(child: CircularProgressIndicator(color: Colors.white,),)) : 
  !isPostAble? WillPopScope(
  onWillPop: () async => false,
  child: Center(child: CircularProgressIndicator(color: Colors.white,),)) : 
  AbsorbPointer(
         absorbing: isImagesLoading || !isPostAble,
        child: Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editThisPost, style: TextStyle(color: Colors.white),),
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
                  getLabel(title: AppLocalizations.of(context)!.images),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    width: 300,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Background color
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
                                Text(AppLocalizations.of(context)!.changeImg)
                            ]
                        )
                    )
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.004)
                    ),
                    child: DropdownButton<String>(
                      value: type,
                      isExpanded: true,
                      items: postType.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        if (this.mounted) {
                          setState(() {
                            type = value!;
                          });
                        }
                      }
                    ),
                  ),
                  type == "App" ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.appName),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 25,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerAppName,
                      onChanged: (val) {
                        appName = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.appName, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.title), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  getLabel(title: AppLocalizations.of(context)!.appURLP),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 200,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerPlayStoreURL,
                      onChanged: (val) {
                        pUrl = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.url, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.app_registration), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  getLabel(title: AppLocalizations.of(context)!.appURLA),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 200,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerAppStoreURL,
                      onChanged: (val) {
                        aUrl = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.url, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.app_registration), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                    ],
                  ) :
                  type == "Web" ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.webName),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 25,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerWebName,
                      onChanged: (val) {
                        webName = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.webName, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.title), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  getLabel(title: AppLocalizations.of(context)!.webURL),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 200,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerWebUrl,
                      onChanged: (val) {
                        webUrl = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.webURL, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.app_registration), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                    ],
                  ) :
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.etcName),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 25,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerEtcName,
                      onChanged: (val) {
                        etcName = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.etcName, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.title), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  getLabel(title: AppLocalizations.of(context)!.etcUrl),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 200,
                      maxLines: 1,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerEtcUrl,
                      onChanged: (val) {
                        etcUrl = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.etcUrl, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.app_registration), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.description),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                      maxLength: 230,
                      maxLines: 7,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                      controller: _controllerDescription,
                      validator: (val) {
                        if (val!.isNotEmpty) {
                          return null;
                        } else {
                          return AppLocalizations.of(context)!.descriptionEmpty;
                        }
                      },
                      onChanged: (val) {
                        description = val;
                      },
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.description, labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.description), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.category),
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
                      items: items!.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        if (this.mounted) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  getLabel(title: AppLocalizations.of(context)!.tag),
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
                          return AppLocalizations.of(context)!.tagExist;
                        }
                        else if (_controllerTag.getTags!.length > 7) {
                          return AppLocalizations.of(context)!.maxTag;
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
                              hintText: _controllerTag.hasTags ? '' : AppLocalizations.of(context)!.enterTag,
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
                  getLabel(title: AppLocalizations.of(context)!.commentSetting),
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
                                    getLabel(title: AppLocalizations.of(context)!.comment),
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
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                  ),
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
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          if (this.mounted) {
                            isPostAble = false;
                          }
                        });
                        tags = _controllerTag.getTags!;
                        String cat = helperFunctions.changeCategoryToEnglish(category!);
                        if (!selectedImages.isEmpty) {
                          await postService.updatePost(selectedImages, description, cat, tags, withComment, widget.postId, widget.email, appName, pUrl, aUrl, type!, webName, webUrl, etcName,etcUrl);
                          nextScreen(context, HomePage(pageIndex: 0,));
                        }
                        else {
                          if (images.isEmpty) {
                            await postService.updatePost([], description, cat, tags, withComment, widget.postId, widget.email, appName, pUrl, aUrl, type!, webName, webUrl, etcName,etcUrl);
                            nextScreen(context, HomePage(pageIndex: 0,));
                          }
                          else {
                            await postService.updatePostWithOutImages(description, cat, tags, withComment, widget.postId, appName, pUrl, aUrl, type!, webName, webUrl, etcName,etcUrl);
                            nextScreen(context, HomePage(pageIndex: 0,));
                          }
                        }

                      }
                    } catch(e) {
                      nextScreen(context, HomePage(pageIndex: 0,));
                    }
                  }, 
                  child: Text(AppLocalizations.of(context)!.editThisPost, style: TextStyle(color: Colors.white),),
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
      ))
    );} catch(e) { 
      print(e);
      return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: () {
          if (this.mounted) {
            setState(() {
              isErrorOccurred = false;
              Navigator.of(context).pop();
            });
          }
        },
        icon: Icon(
          Icons.refresh,
          size: MediaQuery.of(context).size.width * 0.08,
          color: Colors.blueGrey,
        ),
      ),
      Text(
        AppLocalizations.of(context)!.loadFailed,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05,
          color: Colors.blueGrey,
        ),
      ),
    ],
  ),
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
                title: Text(AppLocalizations.of(context)!.noPhoto),
                onTap: () {
                  setState(() {
                    images = [];
                    selectedImages = [];
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text(AppLocalizations.of(context)!.selectPhoto),
                onTap: () async{
                  try {
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = true;
                      }
                    });
                    await getImages();
                    selectedImages = await cropImages(selectedImages);
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = false;
                      }
                    });

                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isImagesLoading = false;
                        isErrorOccurred = true;
                      });
                    }
                  }
                  // Navigator.pop(context);
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
        if (await Permission.photos.request().isGranted) {
          final pickedFile = await picker.pickMultiImage(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
                else {
                  for (var i = 0; i < xfilePick.length; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(AppLocalizations.of(context)!.nothingSelected)));
              }
            },
          );
        } 
        else if (await Permission.storage.request().isGranted) {
          final pickedFile = await picker.pickMultiImage(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
                else {
                  for (var i = 0; i < xfilePick.length; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(AppLocalizations.of(context)!.nothingSelected)));
              }
            },
          );
        } 
        else {
          openAppSettings();
        }

    } catch (e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
  }

  double getFileSize(XFile file) {
    return File(file.path).lengthSync() / (1024 * 1024);
  }

  Future<List<dynamic>> cropImages(List<dynamic> medias) async {
    try {

      List<dynamic> files = [];

      for (var media in medias) {
        bool isVideo = HelperFunctions().isVideoFile(media);
        if (!isVideo) {
          bool isHorizontal = await isImageHorizontal(media);
          var croppedFile = await ImageCropper().cropImage(
            sourcePath: media.path,
            // aspectRatio: isHorizontal? CropAspectRatio(ratioX: 1200, ratioY: 1200) : CropAspectRatio(ratioX: 900, ratioY: 1200),
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,),
              IOSUiSettings(
                title: 'Cropper',
                aspectRatioLockEnabled: true, 
                resetAspectRatioEnabled: false,
                aspectRatioPickerButtonHidden: true,
                rotateButtonsHidden: true
              ),
              WebUiSettings(
                context: context,
              ),
            ],
          );

          if (croppedFile != null) {
            files.add(croppedFile);
          }
        }
        else {
          files.add(media);
        }
        
      }

      return files;

    } catch(e) {

      setState(() {
        if (this.mounted) {
          isErrorOccurred = true;
          isImagesLoading = false;
        }
      });

      return [];

    }
    
  }

  Future<bool> isImageHorizontal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    return image!.width > image.height;
  }
}