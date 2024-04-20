import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditInfo extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? postUser;

  const EditInfo({super.key, required this.postUser});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {

  final formKey = GlobalKey<FormState>();

  TextEditingController _controllerName = new TextEditingController();
  TextEditingController _controllerEmail = new TextEditingController();
  TextEditingController _controllerIntroduction = new TextEditingController();

  String changedName = "" ;
  String changedIntro = "";

  bool isInfoChanging = false;
  bool isErrorOccurred = false;

  late PostService postService;
  late DatabaseService databaseService;

  Logging logger = Logging();

  @override
  void initState() {
    super.initState();

    postService = PostService.instance;
    databaseService = DatabaseService.instance;

    try {
      _controllerName.text = widget.postUser!["name"].toString();
      _controllerEmail.text = widget.postUser!["email"].toString();
      _controllerIntroduction.text = widget.postUser!["intro"].toString();

      changedName = widget.postUser!["name"].toString();
      changedIntro = widget.postUser!["intro"].toString();
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.message_warning("Error occurred while getting edit informaiton");
    }
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerEmail.dispose();
    _controllerIntroduction.dispose();
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
                  });
                }
                try {
                  _controllerName.text = widget.postUser!["name"].toString();
                  _controllerEmail.text = widget.postUser!["email"].toString();
                  _controllerIntroduction.text = widget.postUser!["intro"].toString();

                  changedName = widget.postUser!["name"].toString();
                  changedIntro = widget.postUser!["intro"].toString();
                } catch(e) {
                  setState(() {
                    isErrorOccurred = true;
                  });
                }
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : 
  //     WillPopScope(
  // onWillPop: () async => false,
  // child:
   Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor, 
      toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      title: Text(AppLocalizations.of(context)!.editInfo, style: TextStyle(color: Colors.white),)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.012,
            ),
            getLabel(title: AppLocalizations.of(context)!.email),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            TextFormField(
              enabled: false,
              controller: _controllerEmail,
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),

              decoration: InputDecoration(hintText: "Email", labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.mail), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.035,),
            getLabel(title: AppLocalizations.of(context)!.name),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.007,
            ),
            TextFormField(
              // maxLength: 20,
              enabled: false,
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
              controller: _controllerName,
              validator: (val) {
                if (val!.isNotEmpty) {
                  return null;
                } else {
                  return "name can not be empty";
                }
              },
              onChanged: (val) {
                changedName = val;
              },
              decoration: InputDecoration(hintText: "Name", labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.account_box), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.035,),
            getLabel(title: AppLocalizations.of(context)!.intro),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.007,
            ),
            TextFormField(
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
              controller: _controllerIntroduction,
              maxLength: 200,
              maxLines: 8,
              onChanged: (val) {
                changedIntro = val;
              },
              validator: (val) {
                if (val!.split("\n").length > 10) {
                  return "introduction should be less than or equal to 10 lines";
                }
                else {
                  print(val!.split("\n").length);
                  return null;
                }
              },
              decoration: InputDecoration(hintText: "Introduction",labelStyle: TextStyle(color: Colors.black), prefixIcon: Icon(Icons.abc), enabledBorder: myinputborder(context), focusedBorder: myfocusborder(context), prefixIconColor: Theme.of(context).primaryColor),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.06,),
            Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.057,
                child: ElevatedButton(
                  onPressed: () async{
                    try {
                      if (!isInfoChanging) {
                        if (formKey.currentState!.validate()) {
                            setState(() {
                              isInfoChanging = true;
                            });
                            Future.delayed(Duration(seconds: 0),() async { 
                              await databaseService.setUserInfo(widget.postUser!["uid"].toString(), changedName, changedIntro);
                              nextScreen(context, HomePage(pageIndex: 3,));
                            });
                        }
                      }

                    } catch(e) {
                      if (this.mounted) {
                        setState(() {
                          isErrorOccurred = true;
                        });
                      }
                      logger.message_warning("Error occurred while editing information");
                    }
                    
                  }, 
                  child: Text(AppLocalizations.of(context)!.editInfo, style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
        // )
      ))
    );} catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                try {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = false;
                    });
                  }
                  try {
                    _controllerName.text = widget.postUser!["name"].toString();
                    _controllerEmail.text = widget.postUser!["email"].toString();
                    _controllerIntroduction.text = widget.postUser!["intro"].toString();

                    changedName = widget.postUser!["name"].toString();
                    changedIntro = widget.postUser!["intro"].toString();
                  } catch(e) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                } catch(e) {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                }
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
  }

  OutlineInputBorder myinputborder(BuildContext context){ 
    return OutlineInputBorder(
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
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
        child: Text(
            title, style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.015,
              fontWeight: FontWeight.w500
        )),
    );
  }

  Future<bool> existing(String accountName) async {
    try {
      return await databaseService.checkExist(accountName);
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      return true;
    }
  }  
}