import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/emailVerification.dart';
import 'package:like_app/pages/register_page.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthServie authServie = AuthServie(); 
  HelperFunctions helperFunctions = HelperFunctions();

  bool isErrorOccurred = false;

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.04;
    double borderCircular = MediaQuery.of(context).size.height * 0.035;
    double padding = MediaQuery.of(context).size.height * 0.027;
    double sizedBox = MediaQuery.of(context).size.height * 0.03;
    double signInBtnHeight = MediaQuery.of(context).size.height * 0.04;

    return isErrorOccurred? 
      Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      _isLoading = false;
                      isErrorOccurred = false;
                    }
                  );
                }
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: _isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) :  SingleChildScrollView(
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
                          "Login", 
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
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                labelText: AppLocalizations.of(context)!.email,
                                prefixIcon : Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                              validator: (val) {
                                return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=>^_'{|}~]+@[a-zA-Z]+")
                                    .hasMatch(val!) ? null : AppLocalizations.of(context)!.enterEmail;
                              },
                            ),
                            SizedBox(height: sizedBox),
                            TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                labelText: AppLocalizations.of(context)!.password,
                                prefixIcon : Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              validator: (val) {
                                if (val!.length < 6) {
                                  return AppLocalizations.of(context)!.enterPassword;
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val){
                                setState(() {
                                  password = val;
                                });
                              },
                            ),
                            SizedBox(
                              height: sizedBox * 2.2,
                            ),
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
                                  AppLocalizations.of(context)!.login,
                                  style: TextStyle(color: Colors.white, fontSize: borderCircular / 2),
                                ),
                                onPressed: () {
                                  login();
                                },
                              )
                            ),
                            SizedBox(height: borderCircular / 2 * 1.5),
                            Text.rich(
                              TextSpan(
                                text: AppLocalizations.of(context)!.accountInExist,
                                style: TextStyle(color: Colors.black, fontSize: borderCircular / 8 * 3),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.goToRegisterPage,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline  
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      nextScreen(context, const RegisterPage());
                                    }
                                  ),
                                ]
                              )
                            ),
                            SizedBox(
                              height: sizedBox * 1.2,
                            ),
                            SizedBox(
                              height: sizedBox * 6.5,
                            ),
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
  }

  login() async  {
    try {
      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        await authServie.loginWithUserNameandPassword(email, password)
        .then((value) async {
          if (value == true) {
            await helperFunctions.saveUserEmailSF(email);
            nextScreen(context, EmailVerification(email: email));

          } else {
            setState(() {
              showSnackbar(context, Colors.red, AppLocalizations.of(context)!.loginFailed);
              _isLoading = false; 
            });
          }
        });
      }
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

}