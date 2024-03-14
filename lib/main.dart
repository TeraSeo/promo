import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:like_app/helper/firebaseNotification.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/shared/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'dart:ui';

void main() async {
  bool result = await InternetConnectionChecker().hasConnection;
  if(result == true) {
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) {
      await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: Constants.apiKey,
        appId: Constants.appId, 
        messagingSenderId: Constants.messagingSenderId, 
        projectId: Constants.projectId));
    }
    else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await MobileAds.instance.initialize();
    FirebaseNotification.instance.initNotificaiton();
    
    runApp(const MyApp(language: ""));
  } else {
    runApp(const NoInternetConnectionApp());
  } 
}

class MyApp extends StatefulWidget {
  final String language;
  const MyApp({super.key, required this.language});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  String? language;
  bool isLanguageLoading = true;

  HelperFunctions helperFunctions = HelperFunctions();

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
    if (widget.language == "") {
      getUserLanguageSF();
    }
    else {
      language = widget.language;
      setState(() {
        if (this.mounted) {
          isLanguageLoading = false;
        }
      });
    }
  }

  getUserLoggedInStatus() async {
    await helperFunctions.getUserLoggedInStatus().then((value) {
      if (value!=null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  getUserLanguageSF() async {
    try {
      await helperFunctions.getUserLanguageFromSF().then((value) {
        if (value!=null) {
          setState(() {
            language = value;
            isLanguageLoading = false;
          });
        }
        else {
          getLocalLanguageCode();
          helperFunctions.saveUserLanguageSF(language!);
        }
      });
    } catch(e) {
      print(e);
    }
  }

  getLocalLanguageCode() {
    if (window.locale.languageCode == "en") {
      language = "en";
    } 
    else if (window.locale.languageCode == "de") {
      language = "de";
    }
    else if (window.locale.languageCode == "es") {
      language = "es";
    }
    else if (window.locale.languageCode == "fr") {
      language = "fr";
    }
    else if (window.locale.languageCode == "hi") {
      language = "hi";
    }
    else if (window.locale.languageCode == "ja") {
      language = "ja";
    }
    else if (window.locale.languageCode == "ko") {
      language = "ko";
    }
    else {
      language = "en";
    }
    setState(() {
      if (this.mounted) {
        isLanguageLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLanguageLoading?
      Center(child: CircularProgressIndicator(color: Colors.white,),) :
      MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(language!),
      supportedLocales: [
        Locale('en'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('hi'),
        Locale('ja'),
        Locale('ko'),
      ],
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? const HomePage(pageIndex: 0) : const LoginPage(),
    );
  }
} 


class NoInternetConnectionApp extends StatelessWidget {
  const NoInternetConnectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('Please check your network connection and try again.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  HelperFunctions().restartApp();
                },
                child: Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}