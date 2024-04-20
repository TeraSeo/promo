import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/userService.dart';

class FirebaseNotification {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final FirebaseNotification _instance = FirebaseNotification._internal();

  FirebaseNotification._internal();

  static FirebaseNotification get instance => _instance;

  Logging logger = Logging();

  Future handleBackgroundMessage(RemoteMessage message) async {
    print(message.notification?.title);
  }  

  Future initNotificaiton() async {
    _firebaseMessaging.requestPermission();
  }

  Future addMsgTokenToUser(String uId) async {
    try {
      DatabaseService databaseService = DatabaseService.instance;
      HelperFunctions helperFunctions = HelperFunctions();

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
        helperFunctions.saveUserFCMTokenSF(fcmToken.toString());
        databaseService.updateMessagingToken(fcmToken.toString(), uId);
      }

      logger.message_info("succeeded to add fcm token to user");

    } catch(e) {
      logger.message_warning("failed to add fcm token to user\n" + e.toString());
    }
  }

  void sendPushMessage(String username, String token, BuildContext context, String language) async {
    try {

      logger.message_info(token);

      String? body;
      String? title;

      switch (language) {
        case "en":
          title = "Like Notification";
          body = username + " liked your post";
          break;
        case "fr":
          title = "Rien n'est sélectionné";
          body = username + " a aimé ton message";
          break;
        case "de":
          title = "Like-Benachrichtigung";
          body = username + " hat deinen Beitrag gefallen";
          break;
        case "hi":
          title = "अधिसूचना की तरह";
          body = username + " को आपकी पोस्ट पसंद आयी";
          break;
        case "ja":
          title = "いいねお知らせ";
          body = username + " ンさんが投稿を愛しています";
          break;
        case "ko":
          title = "좋아요 알림";
          body = username + "님이 게시물을 좋아합니다";
          break;
        case "es":
          title = "Notificación Me gusta";
          body = username + " le gustó tu publicación.";
          break;
        default: 
          title = "Like Notification";
          body = username + " liked your post";
          break;
      }

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
              'body': body,
              'title': title
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

      logger.message_info("succeeded to send notification");

    } catch (e) {
      logger.message_warning("failed to send notification\n" + e.toString());
    }
  }

}
