import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/pages/showBookmarked.dart';
import 'package:like_app/pages/showLiked.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {

  final String uId;
  final List<dynamic> postsLiked;
  final List<dynamic> postsBookmarked;

  const SettingPage({super.key, required this.uId, required this.postsLiked, required this.postsBookmarked});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  DatabaseService databaseService = DatabaseService.instance;
  HelperFunctions helperFunctions = HelperFunctions();

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
        if (this.mounted) {
          setState(() {
            isUserLoading = false;
          });
        }
      });
      helperFunctions.getUserLanguageFromSF().then((value) {
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
      if (language != "") {
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
              SettingsTile.navigation(
                leading: Icon(Icons.format_paint),
                title: Text(AppLocalizations.of(context)!.liked),
                onPressed: (context) {
                  nextScreen(context, ShowLikedPosts(likedPosts: widget.postsLiked, uId: widget.uId, preferredLanguage: languageTxt!,));
                },
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.format_paint),
                title: Text(AppLocalizations.of(context)!.bookmarked),
                onPressed: (context) {
                  nextScreen(context, ShowBookmarkedPosts(bookmarkedPosts: widget.postsBookmarked, uId: widget.uId, preferredLanguage: languageTxt!,));
                },
              )
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
                  showYesNoBox(context, 'en');
                },
              ),
              ListTile(
                title: Text('French'),
                onTap: () {
                  showYesNoBox(context, 'fr');
                },
              ),
              ListTile(
                title: Text('German'),
                onTap: () {
                  showYesNoBox(context, 'de');
                },
              ),
              ListTile(
                title: Text('Hindi'),
                onTap: () {
                  showYesNoBox(context, 'hi');
                },
              ),
              ListTile(
                title: Text('Japanese'),
                onTap: () {
                  showYesNoBox(context, 'ja');
                },
              ),
              ListTile(
                title: Text('Korean'),
                onTap: () {
                  showYesNoBox(context, 'ko');
                },
              ),
              ListTile(
                title: Text('Spanish'),
                onTap: () {
                  showYesNoBox(context, 'es');
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
      await helperFunctions.saveUserLanguageSF(languageCode);
      await databaseService.setUserLanguage(widget.uId, languageCode).then((value) {
        if (this.mounted) {
          setState(() {
              isLanguageTxtLoading = false;
          });
        }
        HelperFunctions().restartApp();
      });
    });
  }

  void showYesNoBox(BuildContext context, String languageCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.languageChange),
          content: Text(AppLocalizations.of(context)!.clickYes),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _changeLanguage(languageCode);
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.no),
            ),
          ],
        );
      },
    );
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