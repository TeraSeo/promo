import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/pages/otp.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/services/database_service.dart';
import 'package:like_app/widgets/widgets.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String name = "";
  String email = "";
  String password = "";
  String passwordCheck = "";
  AuthServie authServie = AuthServie();
  bool exist = true;

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.04;
    double borderCircular = MediaQuery.of(context).size.height * 0.035;
    double padding = MediaQuery.of(context).size.height * 0.027;
    double sizedBox = MediaQuery.of(context).size.height * 0.03;
    double signInBtnHeight = MediaQuery.of(context).size.height * 0.04;

    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) : Padding(
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
                          "Register", 
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
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              maxLength: 20,
                              decoration: textInputDecoration.copyWith(
                                labelText: "Account name",
                                prefixIcon : Icon(
                                  Icons.account_box,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              validator: (val) {
                                if (val!.isNotEmpty && val.length < 16) {
                                  return null;
                                } else {
                                  return "name can not be empty";
                                }
                              },
                              onChanged: (val){
                                setState(() {
                                  name = val;
                                });
                              },
                            ),
                            SizedBox(height: sizedBox),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                labelText: "Email",
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
                                    .hasMatch(val!) ? null : "Please enter a valid email";
                              },
                            ),
                            SizedBox(height: sizedBox),
                            TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon : Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              validator: (val) {
                                if (val!.length < 6) {
                                  return "Password must be at least 6 characters";
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
                              height: sizedBox,
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                labelText: "Check Password",
                                prefixIcon : Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              validator: (val) {
                                if (password != passwordCheck) {
                                  return "passwords should be same";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val){
                                setState(() {
                                  passwordCheck = val;
                                });
                              },
                            ),
                            SizedBox(
                              height: sizedBox * 2,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: signInBtnHeight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(borderCircular)
                                  )
                                ),
                                child: Text(
                                  "Register",
                                  style: TextStyle(color: Colors.white, fontSize: borderCircular / 2),
                                ),
                                onPressed: () {
                                  register();
                                },
                              )
                            ),
                            SizedBox(height: sizedBox / 2),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(color: Colors.black, fontSize: borderCircular / 8  * 3),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Back to Login page",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline  
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      nextScreen(context, const LoginPage());
                                    }
                                  ),
                                ]
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ),
      ),
      
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      existing(name).then((value) async {
        if (value == true) {
          await authServie.registerUserWithEmailandPassword(name, email, password)
            .then((value) async {
            if (value == true) {
              // saving the shared preference state
              await HelperFunctions.saveUserEmailSF(email);
              nextScreenReplace(context, const OtpScreen());

            } else {
              setState(() {
                showSnackbar(context, Colors.red, value);
                _isLoading = false; 
              });
            }
          });
        }
        else {
          showAlertDialog(context);
        }
      });
      
    }
  }

  Future<bool> existing(String accountName) async {
    return await DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid).checkExist(accountName);
  }  

  showAlertDialog(BuildContext context) {

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        nextScreenReplace(context, const RegisterPage());
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Existing!"),
      content: Text("The name is already existing"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
