import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HelperFunctions {

  static final HelperFunctions _instance = HelperFunctions._internal();

  factory HelperFunctions() {
    return _instance;
  }

  HelperFunctions._internal();

  String usersLoggedInKey = "LOGGEDINKEY";
  String userNameKey = "USERNAMEKEY";
  String userEmailKey = "USEREMAILKEY";
  String userUidKey = "USERUIDKEY";
  String languageKey = "LANGUAGE";

  Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(usersLoggedInKey, isUserLoggedIn);
  }

  Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  Future<bool> saveUserUIdSF(String uid) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userUidKey, uid);
  }

  Future<bool> saveUserLanguageSF(String language) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(languageKey, language);
  }

  Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    dynamic value = sf.get(userNameKey);
    if (value == null) {
      return null;
    }
    else if (value is String) {
      return value;
    } else {
      throw Exception('Invalid value type for key $userNameKey');
    }
  }

  Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    dynamic value = sf.get(userEmailKey);
    if (value == null) {
      return null;
    } 
    else if (value is String) {
      return value;
    } else {
      throw Exception('Invalid value type for key $userEmailKey');
    }
  }

  Future<String?> getUserUIdFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    dynamic value = sf.get(userUidKey);
    if (value == null) {
      return null;
    } 
    else if (value is String) {
      return value;
    } else {
      throw Exception('Invalid value type for key $userEmailKey');
    }
  }

  Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    dynamic value = sf.get(usersLoggedInKey);
    if (value == null) {
      return null;
    } else if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    } else {
      throw Exception('Invalid value type for key $usersLoggedInKey');
    }
  }

  Future<String?> getUserLanguageFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    dynamic value = sf.get(languageKey);
    if (value == null) {
      return null;
    } 
    else if (value is String) {
      return value;
    } else {
      throw Exception('Invalid value type for key $userEmailKey');
    }
  }
  
  void restartApp() {
    if (Platform.isAndroid) {
      // For Android
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // For iOS
      exit(0);
    }
  }
  
  bool isVideoFile(File file) {
    String extension = file.path.split('.').last.toLowerCase();

    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];

    return videoExtensions.contains(extension);
  }

  bool isVideoFileWString(String fileName) {

    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];

    for (int i = 0; i < videoExtensions.length; i++) {
      if (fileName.contains(videoExtensions[i])) {
         return true;
      }
    }
    return false;
  }

  Future sendEmailVerification() async {

    Logger logger = new Logger();

    final _auth = FirebaseAuth.instance;
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch(e) {
      logger.log(Level.error, e.toString());
    }
  }

  String changeCategoryToEnglish(String category) {

    if (category == "Nachricht" || category == "News" || category == "Noticias" || category == "Nouvelles" || category == "समाचार" || category == "ニュース" || category == "뉴스") {
      return "News";
    }
    else if (category == "Unterhaltung" || category == "Entertainment" || category == "Entretenimiento" || category == "Divertissement" || category == "मनोरंजन" || category == "エンターテインメント" || category == "연예") {
      return "Entertainment";
    }
    else if (category == "Sports" || category == "Deportes" || category == "Des sports" || category == "スポーツ" || category == "스포츠") {
      return "Sports";
    } 
    else if (category == "Essen" || category == "Food" || category == "Alimento" || category == "Nourriture" || category == "खाना" || category == "食べ物" || category == "음식") {
      return "Food";
    }
    else if (category == "Wirtschaft" || category == "Economy" || category == "Economía" || category == "Économie" || category == "अर्थव्यवस्था" || category == "経済" || category == "경제") {
      return "Economy";
    }
    else if (category == "Aktie" || category == "Stock" || category == "Existencias" || category == "株式" || category == "주식") {
      return "Stock";
    }
    else if (category == "Einkaufen" || category == "Shopping" || category == "Compras" || category == "ショッピング" || category == "쇼핑") {
      return "Shopping";
    }
    else if (category == "Wissenschaft" || category == "Science" || category == "Ciencia" || category == "विज्ञान" || category == "科学" || category == "과학") {
      return "Science";
    }
    else if (category == "Etc." || category == "その他" || category == "기타") {
      return "Etc.";
    }
    else {
      return "";
    }

  }

  Future<bool> reportPost(String postId) async {
    try {

      final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("report");

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);

      String reportId = Uuid().v4();

      await userCollection.doc(reportId).set({
        "reportId": reportId,
        "postId" : postId,
        "reported" : tsdate
      });

      return true;

    } catch (e) {
      Logger logger = new Logger();
      logger.log(Level.error, "failed to report\n" + e.toString());
      return false;
    }
  } 


  Future<bool> reportComment(String commentId) async {
    try {

      final CollectionReference userCollection = 
        FirebaseFirestore.instance.collection("report");

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);

      String reportId = Uuid().v4();

      await userCollection.doc(reportId).set({
        "reportId": reportId,
        "commentId" : commentId,
        "reported" : tsdate
      });

      return true;

    } catch (e) {
      Logger logger = new Logger();
      logger.log(Level.error, "failed to report\n" + e.toString());
      return false;
    }
  } 

  showInterstitialAd() async {

    final String androidTestUnitId = "ca-app-pub-3940256099942544/1033173712";
    final String iosTestUnitId = "ca-app-pub-3940256099942544/4411468910";

    InterstitialAd.load(
      adUnitId: Platform.isIOS? iosTestUnitId : androidTestUnitId, 
      request: AdRequest(), 
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      )
    );

  }

}