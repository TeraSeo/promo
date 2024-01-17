import 'package:flutter/material.dart';
import 'package:like_app/services/userService.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {

  final String uId;
  final String language;
  const SettingPage({super.key, required this.uId, required this.language});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  DatabaseService databaseService = new DatabaseService();

  String? languageTxt;
  bool isLanguageTxtLoading = true;

  @override
  void initState() {
    super.initState();
    setLanguageText(widget.language);
  }

  void setLanguageText(String language) {
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

  @override
  Widget build(BuildContext context) {
    return isLanguageTxtLoading? Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
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
                  _changeLanguage(context, 'en');
                },
              ),
              ListTile(
                title: Text('French'),
                onTap: () {
                  _changeLanguage(context, 'fr');
                },
              ),
              ListTile(
                title: Text('German'),
                onTap: () {
                  _changeLanguage(context, 'de');
                },
              ),
              ListTile(
                title: Text('Hindi'),
                onTap: () {
                  _changeLanguage(context, 'hi');
                },
              ),
              ListTile(
                title: Text('Japanese'),
                onTap: () {
                  _changeLanguage(context, 'ja');
                },
              ),
              ListTile(
                title: Text('Korean'),
                onTap: () {
                  _changeLanguage(context, 'ko');
                },
              ),
              ListTile(
                title: Text('Spanish'),
                onTap: () {
                  _changeLanguage(context, 'es');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    isLanguageTxtLoading = true;
    Future.delayed(Duration(seconds: 0)).then((value) async {
      await databaseService.setUserLanguage(widget.uId, languageCode).then((value) {
        setState(() {
          if (this.mounted) {
            isLanguageTxtLoading = false;
          }
        });
      });
      setLanguageText(languageCode);
    });
  }
}