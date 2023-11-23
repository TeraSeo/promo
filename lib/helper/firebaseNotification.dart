import 'package:firebase_messaging/firebase_messaging.dart';

class FireStoreNotification {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future initNotification() async {

    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();

  }
}