import 'dart:convert';

import 'package:like_app/datas/users.dart';
import 'package:http/http.dart' as http;
import 'package:like_app/helper/logger.dart';
import 'package:like_app/services/storage.dart';

class RestApi
{
  Logging logging = new Logging();
  Storage storage = new Storage();

  Future<dynamic> getUser(String uId) async {
    var client = http.Client();

    var uri = Uri.parse('http://localhost:8080/likeApp/getUser');
    var _headers = {
      'uId' : uId
    };
    var response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return LikeUser.fromJson(jsonDecode(response.body));
    }
    else {
      return new LikeUser();
    }
  }

  Future<void> setUserProfile(String uId, String path, String fileName, String email) async {
    var client = http.Client();

    var uri = Uri.parse('http://localhost:8080/likeApp/updateUserProfile');
    Map _body = {
      'uId' : uId,
      'path' : fileName
    };
    var response = await client.put(uri, body: _body).then((value) => {
      if (value.statusCode == 200) {
        storage.uploadProfileImage(path, fileName, email),
        logging.message_info(email+" profile path setting completed " + value.body)
      }
      else {
        logging.message_error(email+" profile path setting failed")
      }
    });
  }

  Future<void> setUserBackground(String uId, String path, String fileName, String email) async {
    var client = http.Client();

    var uri = Uri.parse('http://localhost:8080/likeApp/updateUserBackground');
    Map _body = {
      'uId' : uId,
      'path' : fileName
    };
    var response = await client.put(uri, body: _body).then((value) => {
      if (value.statusCode == 200) {
        storage.uploadProfileBackground(path, fileName, email),
        logging.message_info(email+"'s background path setting completed " + value.body)
      }
      else {
        logging.message_error(email+"'s background path setting failed")
      }
    });
  }

  Future<void> setUserInfo(String uId, String username, String intro) async {
    var client = http.Client();

    var uri = Uri.parse('http://localhost:8080/likeApp/updateUserInformation');
    Map _body = {
      'uId' : uId,
      'name' : username,
      'intro' : intro
    };
    var response = await client.put(uri, body: _body).then((value) => {
      if (value.statusCode == 200) {
        logging.message_info(username+"'s profile information update completed " + value.body)
      }
      else {
        logging.message_error(username+"'s profile information update failed")
      }
    });
  }
}