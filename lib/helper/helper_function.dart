import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {

  static String usersLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userUidKey = "USERUIDKEY";
  static String languageKey = "LANGUAGE";

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(usersLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserUIdSF(String uid) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userUidKey, uid);
  }

  static Future<bool> saveUserLanguageSF(String language) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(languageKey, language);
  }

  static Future<String?> getUserNameFromSF() async {
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

  static Future<String?> getUserEmailFromSF() async {
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

  static Future<String?> getUserUIdFromSF() async {
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

  static Future<bool?> getUserLoggedInStatus() async {
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

  static Future<String?> getUserLanguageFromSF() async {
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

}