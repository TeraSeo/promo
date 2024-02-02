import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/firebaseNotification.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailVerification extends StatefulWidget {

  final String email;
  const EmailVerification({super.key, required this.email});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {

  bool isEmailVerified = false;
  Timer? timer;
  bool isHomePageAble = false;

  DatabaseService databaseService = DatabaseService.instance;
  FirebaseNotification firebaseNotification = FirebaseNotification.instance;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser!.reload();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {

      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 7), (timer) async {
          checkEmailVerified();
          if (isEmailVerified) {
            QuerySnapshot snapshot =
              await databaseService.getUserData(widget.email);
            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(widget.email);
            await HelperFunctions.saveUserNameSF(snapshot.docs[0]['name']);
            await HelperFunctions.saveUserUIdSF(FirebaseAuth.instance.currentUser!.uid);

            setState(() {
              isHomePageAble = true;
            });
          }
      });

    }
    else {

      Future.delayed(Duration(seconds: 0)).then((value) async {
        QuerySnapshot snapshot =
          await databaseService.getUserData(widget.email);
        await HelperFunctions.saveUserLoggedInStatus(true);
        await HelperFunctions.saveUserEmailSF(widget.email);
        await HelperFunctions.saveUserNameSF(snapshot.docs[0]['name']);
        await HelperFunctions.saveUserUIdSF(FirebaseAuth.instance.currentUser!.uid);

        setState(() {
          isHomePageAble = true;
        });
      });
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch(e) {
      showSnackbar(context, Colors.red, AppLocalizations.of(context)!.verificationFailed);
    }
  }

  Future checkEmailVerified() async { 

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      if (this.mounted) {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double verticalPadding = MediaQuery.of(context).size.height * 0.04;
    double borderCircular = MediaQuery.of(context).size.height * 0.035;
    double verifyBtnHeight = MediaQuery.of(context).size.height * 0.04;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red,
                  Colors.lightBlue, 
                ],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: verticalPadding / 3 * 2
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email verification", 
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: verticalPadding / 4 * 5,
                          fontWeight: FontWeight.w800
                        ),),
                        SizedBox(
                          height: verticalPadding / 4,
                        ),
                        Text(
                          "Enter to a beautiful world", 
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: verticalPadding / 1.7,
                          fontWeight: FontWeight.w300
                        ),)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderCircular),
                        topRight: Radius.circular(borderCircular)
                      )
                    ),
                    child: 
                      Column(children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.043,),
                      isHomePageAble? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: verifyBtnHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(borderCircular)
                              )
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.verify,
                              style: TextStyle(color: Colors.white, fontSize: borderCircular / 2),
                            ),
                            onPressed: () {
                              firebaseNotification.addMsgTokenToUser(FirebaseAuth.instance.currentUser!.uid);
                              nextScreenReplace(context, const HomePage(pageIndex: 0,));
                            },
                          )
                        ) : Column(
                        children: [
                          Text.rich(
                        TextSpan(
                          text: AppLocalizations.of(context)!.resend,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.017,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            sendVerificationEmail();
                          }
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.029,),
                      Row(children: <Widget>[
                        Expanded(
                          child: new Container(
                              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                              child: Divider(
                                color: Colors.black,
                                height: MediaQuery.of(context).size.height * 0.033,
                              )),
                        ),
                        Text("OR"),
                        Expanded(
                          child: new Container(
                              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                              child: Divider(
                                color: Colors.black,
                                height: MediaQuery.of(context).size.height * 0.036,
                              )),
                        ),
                      ]),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.023,),
                      Text.rich(
                        TextSpan(
                          text: AppLocalizations.of(context)!.backLogin,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.017,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () async {
                            await HelperFunctions.saveUserEmailSF ("");
                            nextScreenReplace(context, const LoginPage());
                          }
                        ),
                      ),
                        ],
                      )
                    ],),
                      )
                  ),
              ],
            ),
          )
        ),
      ),
    );
    
  }
}