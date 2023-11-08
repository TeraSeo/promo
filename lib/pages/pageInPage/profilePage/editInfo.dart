import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';

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

  PostService postService = new PostService();
  DatabaseService databaseService = new DatabaseService();

  @override
  void initState() {
    super.initState();

    _controllerName.text = widget.postUser!["name"].toString();
    _controllerEmail.text = widget.postUser!["email"].toString();
    _controllerIntroduction.text = widget.postUser!["intro"].toString();

    changedName = widget.postUser!["name"].toString();
    changedIntro = widget.postUser!["intro"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      title: Text("Edit information")),
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
            getLabel(title: "Email"),
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
            getLabel(title: "Name"),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.007,
            ),
            TextFormField(
              maxLength: 20,
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
            getLabel(title: "Introduction"),
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
                    if (!isInfoChanging) {
                      if (formKey.currentState!.validate()) {
                        existing(changedName).then((value) async {
                        if (value == true || widget.postUser!["name"].toString() == changedName) {

                          setState(() {
                            isInfoChanging = true;
                          });

                        
                          Future.delayed(Duration(seconds: 0),() async { 
                            await databaseService.setUserInfo(widget.postUser!["uid"].toString(), changedName, changedIntro);
                            await postService.changeWriterName(changedName, widget.postUser!["posts"]);
                            nextScreen(context, HomePage(pageIndex: 3,));
                          });
                          }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Unavailable Name"))
                          );
                        }
                        });
                      }
                    }
                  }, 
                  child: Text("Edit Profile"),
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
        )
      )
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
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
        child: Text(
            title, style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.015,
              fontWeight: FontWeight.w500
        )),
    );
  }

  Future<bool> existing(String accountName) async {
    return await DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid).checkExist(accountName);
  }  
}