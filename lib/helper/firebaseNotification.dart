import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:like_app/services/userService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirebaseNotification {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final FirebaseNotification _instance = FirebaseNotification._internal();

  FirebaseNotification._internal();

  static FirebaseNotification get instance => _instance;

  Future handleBackgroundMessage(RemoteMessage message) async {
    print(message.notification?.title);
  }  

  Future initNotificaiton() async {
    _firebaseMessaging.requestPermission();
  }

  Future addMsgTokenToUser(String uId) async {
    try {
      DatabaseService databaseService = DatabaseService.instance;

      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await _firebaseMessaging.getToken();
        databaseService.updateMessagingToken(fcmToken.toString(), uId);
      }

    } catch(e) {
      print(e);
    }
  }

  void sendPushMessage(String username, String token, BuildContext context) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA3VXtIw8:APA91bGhNfy0YZbTtzBvUrH5CNi-Ci7Bf2wn77kJCdFCkhJM0IHedEr4UvuK9jLiHgemwzYIjt4vSbxX4DBaQZZ5CaELh-Ekz8d1mmAcSKnucX-HYw2p6j07MN7H3ntk8lhqpcr4hCcj',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': username + AppLocalizations.of(context)!.likedPost,
              'title': AppLocalizations.of(context)!.likeNotification,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

}