import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _LoginPageState();

}

class _LoginPageState extends State<OtpScreen> {

  String email = "";

  @override
  void initState() {
    super.initState();
    verify();
  }

  bool isVerifying = true;

  
  getData() async{
    try {
      await HelperFunctions.getUserEmailFromSF().then((value) => {
        setState(() {
          email = value!;
          print(value);
        })
      });
    } catch(e) {
      print(e);
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

  final formKey = GlobalKey<FormState>();

  List<String> codes = ["","","",""];

  bool isErrorOccurred = false;

  EmailOTP myauth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.04;
    double borderCircular = MediaQuery.of(context).size.height * 0.035;
    double padding = MediaQuery.of(context).size.height * 0.027;
    double signInBtnHeight = MediaQuery.of(context).size.height * 0.04;

    try {

      return isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isVerifying = true;
                    }
                  );
                }
                Future.delayed(Duration.zero,() async {
                  verify();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :  Scaffold(
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
                          AppLocalizations.of(context)!.oTPVerification, 
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
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding:  EdgeInsets.all(padding),  
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Verification",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height * 0.024,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.012,),
                            Text(
                              AppLocalizations.of(context)!.threeMinutes,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height * 0.015,
                                color: Colors.black38
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(borderCircular)
                              ),
                              child: Column(
                                children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _textFieldOtp(first: true, last: false, code: 0),
                                    _textFieldOtp(first: true, last: false, code: 1),
                                    _textFieldOtp(first: true, last: false, code: 2),
                                    _textFieldOtp(first: false, last: true, code: 3)

                                  ],
                                ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.033,),
                              SizedBox(
                              width: double.infinity,
                              height: signInBtnHeight,
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
                                  checkOTP();
                                },
                              )
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.043,),
                            Text(
                              AppLocalizations.of(context)!.codeLate,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height * 0.0147,
                                color: Colors.black38
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.017,),
                            Text.rich(
                              TextSpan(
                                text: AppLocalizations.of(context)!.resend,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.017,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  verify();
                                }
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.029,)
                            ,Row(children: <Widget>[
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
                            SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                            
                            ]),
                              
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );

    } catch(e) {
        return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isVerifying = true;
                    }
                  );
                }
                Future.delayed(Duration.zero,() async {
                  verify();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
    
  }

  _textFieldOtp({required bool first, last, required int code}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.height * 0.0008,
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            codes[code] = value.toString();
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 1 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.028),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: MediaQuery.of(context).size.height * 0.003, color: Colors.black12),
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.013)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: MediaQuery.of(context).size.height * 0.003, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.013)
            )
          ),
        ),
      ),
    );
  }

  verified() async  {
          
      QuerySnapshot snapshot =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
      
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveUserEmailSF(email);
      await HelperFunctions.saveUserNameSF(snapshot.docs[0]['name']);
      await HelperFunctions.saveUserUIdSF(FirebaseAuth.instance.currentUser!.uid);

      nextScreenReplace(context, const HomePage(pageIndex: 0,));
    
  }

  checkOTP() async {
    try {
       String otpCode = codes[0] + codes[1] + codes[2] + codes[3];
      if (myauth.verifyOTP(otp: otpCode) == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.otpVerified)));
        verified();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidOtp)));
      }
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
   
  }

  verify() async {
    try {
      await getData();
      myauth.setConfig(
            appEmail: "t6858101@gmail.com",
            appName: "Email OTP",
            userEmail: email,
            otpLength: 4,
            otpType: OTPType.mixed
          );
      if (await myauth.sendOTP() == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.otpSent),));

          if (this.mounted) {
            setState(() {
              isVerifying = false;
            });
          }
      
      } else {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.otpFailed)));

          if (this.mounted) {
            setState(() {
              isVerifying = false;
            });
          }

      } 
    } catch(e) {
      print(e);
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }
}