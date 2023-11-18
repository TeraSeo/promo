import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';

class EditProfile extends StatefulWidget {

  final File image;
  final String email;
  final String uId;
  final String usage;

  const EditProfile ({ Key? key, required this.image, required this.email, required this.uId, required this.usage}): super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  File image = new File("");
  Storage storage = new Storage();
  DatabaseService databaseService = new DatabaseService();

  bool isProfileChanging = false;
  bool isErrorOccurred = false;

  var logger = Logger();

  Future pickImage(ImageSource source, String email, String uId, String usage) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = await storage.compressImage(File(image.path));
      setState(() {
        this.image = imageTemporary;

      });

      nextScreenReplace(context, EditProfile(image: this.image, email: email, uId: uId, usage: usage));
    } catch(e) {
      setState(() {
        if (this.mounted) {
          isErrorOccurred = true;
          Navigator.of(context).pop();
        }
      });
      logger.log(Level.error, "Error occurred while picking image\nerror: " + e.toString());

    }
  }
  

  @override 
  Widget build(BuildContext context) {

    double bigger = MediaQuery.of(context).size.width + MediaQuery.of(context).size.height * 0.35;
    double smaller = MediaQuery.of(context).size.height;

    try {
    return isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                setState(() {                  
                  if (this.mounted) {
                    isErrorOccurred = true;
                    Navigator.of(context).pop();
                  }
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      title: Text("EditProfile")),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Container(
          height: bigger > smaller? bigger : smaller,
          child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Column(
                children: [
                  Image.file(
                    widget.image,
                    cacheWidth: MediaQuery.of(context).size.width.toInt(),
                    cacheHeight: MediaQuery.of(context).size.width.toInt(),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.052,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      child: Text(
                        "Change image",
                        style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.016),
                      ),
                      onPressed: () {
                        pickImage(ImageSource.gallery, widget.email, widget.uId, widget.usage);
                      },
                    )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.052,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      child: Text(
                        "Retake photo",
                        style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.016),
                      ),
                      onPressed: () {
                        pickImage(ImageSource.camera, widget.email, widget.uId, widget.usage);
                      },
                    )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.052,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      child: Text(
                        "Confirm profile image",
                        style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.016),
                      ),
                      onPressed: () async{
                        try {if (!isProfileChanging) {
                          if (this.mounted) {
                          setState(() {
                            isProfileChanging = true;
                          });
                          }
                          Future.delayed(Duration(seconds: 0),() async {
                            if (widget.usage == "profile") {
                              await databaseService.setUserProfile(widget.uId, widget.image.path, widget.image.path.split('/').last, widget.email);
                            }
                            else if (widget.usage == "background") {
                              await databaseService.setUserBackground(widget.uId, widget.image.path, widget.image.path.split('/').last, widget.email);
                            }
                            nextScreen(context, HomePage(pageIndex: 3,));
                          });

                        }} catch(e) {
                          if (this.mounted) {
                            setState(() {
                              isErrorOccurred = true;
                            });
                          }
                        }
                      },
                    )
                  ),
                ],
              )
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8), BlendMode.srcOut), // This one will create the magic
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut), // This one will handle background + difference out
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
      )
    );} catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                setState(() {                  
                  if (this.mounted) {
                    isErrorOccurred = true;
                    Navigator.of(context).pop();
                  }
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
  }
}