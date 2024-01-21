import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/main.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {

  final String uId;
  const SettingPage({super.key, required this.uId});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  DatabaseService databaseService = new DatabaseService();

  String? languageTxt;
  bool isLanguageTxtLoading = true;
  bool isEmailVisibilityLoading = false;
  bool? isEmailVisible;

  bool isUserLoading = true;
  bool isErrorOccurred = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {

    try {
      final CollectionReference userCollection = 
          FirebaseFirestore.instance.collection("user");

      final user = userCollection.doc(widget.uId);
      await user.get().then((value) {
        isEmailVisible = value["isEmailVisible"];
        setState(() {
          if (this.mounted) {
            isUserLoading = false;
          }
        });
      });
      HelperFunctions.getUserLanguageFromSF().then((value) {
        setLanguageText(value!);
      });
    } catch(e) {
      setState(() {
        if (this.mounted) {
          isErrorOccurred = true;
        }
      });
    }
  
  }

  void setLanguageText(String language) {
    try {
      if (language != null && language != "") {
        setState(() {
          if (this.mounted) {
            if (language == "en") {
              languageTxt = "English";
            } 
            else if (language == "fr") {
              languageTxt = "French";
            }
            else if (language == "de") {
              languageTxt = "German";
            }
            else if (language == "hi") {
              languageTxt = "Hindi";
            }
            else if (language == "ja") {
              languageTxt = "Japanese";
            }
            else if (language == "ko") {
              languageTxt = "Korean";
            }
            else if (language == "es") {
              languageTxt = "Spanish";
            }
          }
          isLanguageTxtLoading = false;
        });
      }
      else {
        languageTxt = "English";
        isLanguageTxtLoading = false; 
      }
    } 
    catch(e) {
      setState(() {
        if (this.mounted) {
          isErrorOccurred = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                  setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                    isLanguageTxtLoading = true;
                    isEmailVisibilityLoading = false;
                    isUserLoading = true;

                  }
                });
                Future.delayed(Duration.zero,() async {
                  getUser();
                });

              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (isLanguageTxtLoading || isEmailVisibilityLoading || isUserLoading) ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
      appBar: AppBar(
        title: Text("Setting", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.common),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.lang),
                value: Text(languageTxt!),
                onPressed: (context) {
                  _showLanguageOptions(context);
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  isEmailVisible = !isEmailVisible!;
                  _changeEmailVisibility(value);
                },
                initialValue: isEmailVisible,
                leading: Icon(Icons.email),
                title: Text('Show email in profile page'),
              ),
            ],
          ),
        ],
      ),
    );  
  }

  void _showLanguageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  _changeLanguage('en');
                },
              ),
              ListTile(
                title: Text('French'),
                onTap: () {
                  _changeLanguage('fr');
                },
              ),
              ListTile(
                title: Text('German'),
                onTap: () {
                  _changeLanguage('de');
                },
              ),
              ListTile(
                title: Text('Hindi'),
                onTap: () {
                  _changeLanguage('hi');
                },
              ),
              ListTile(
                title: Text('Japanese'),
                onTap: () {
                  _changeLanguage('ja');
                },
              ),
              ListTile(
                title: Text('Korean'),
                onTap: () {
                  _changeLanguage('ko');
                },
              ),
              ListTile(
                title: Text('Spanish'),
                onTap: () {
                  _changeLanguage('es');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(String languageCode) {
    isLanguageTxtLoading = true;
    Future.delayed(Duration(seconds: 0)).then((value) async {
      await HelperFunctions.saveUserLanguageSF(languageCode).then((value) {
        nextScreenReplace(context, MyApp(language: languageCode));
      });
      // setLanguageText(languageCode);
    });
  }

  void _changeEmailVisibility(bool isEmailVisible) {
    isEmailVisibilityLoading = true;
    Future.delayed(Duration(seconds: 0)).then((value) async {
      await databaseService.setUserEmailVisibility(widget.uId, isEmailVisible).then((value) {
        setState(() {
          if (this.mounted) {
            isEmailVisibilityLoading = false;
          }
        });
      });
    });
  }
}