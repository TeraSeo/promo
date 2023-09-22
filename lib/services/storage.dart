import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter_native_image/flutter_native_image.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage = 
    firebase_storage.FirebaseStorage.instance;

  Future<void> uploadProfileImage(String filePath, String fileName, String email) async {
    File file = File(filePath);

    try {
      await deleteProfileImage(email);
      await storage.ref(email + '/profile/$fileName').putFile(file);
      
    } on firebase_core.FirebaseException catch(e) {
      print(e);
    }
  }

  Future<String> loadProfileFile(String email, String fileName) async {
    final ref = await storage.ref().child(email+'/profile/$fileName');
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> deleteProfileImage(String email) async {
      final storages = storage.ref().child(email + '/profile');
      final results = await storages.listAll();
      for (var result in results.items) {
        await storage.ref().child(result.fullPath).delete();
      }
  }

  Future<File> compressImage(File file) async {
    File compressFile = await FlutterNativeImage.compressImage(file.path, quality: 50);
    return compressFile;
  }


  Future<void> uploadProfileBackground(String filePath, String fileName, String email) async {
    File file = File(filePath);

    try {
      await deleteProfileBackground(email);
      await storage.ref(email + '/background/$fileName').putFile(file);

    } on firebase_core.FirebaseException catch(e) {
      print(e);
    }
  }

  Future<String> loadProfileBackground(String email, String fileName) async {
    final ref = await storage.ref().child(email+'/background/$fileName');
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> deleteProfileBackground(String email) async {
      final storages = storage.ref().child(email + '/background');
      final results = await storages.listAll();
      for (var result in results.items) {
        await storage.ref().child(result.fullPath).delete();
      }
  }

  Future<File> compressBackground(File file) async {
    File compressFile = await FlutterNativeImage.compressImage(file.path, quality: 50);
    return compressFile;
  }


  Future<void> uploadPostImage(String filePath, String fileName, String email, String postID) async {
    File file = File(filePath);

    try {
      await storage.ref(email + '/posts/' + postID + '/$fileName').putFile(file);

    } on firebase_core.FirebaseException catch(e) {
      print(e);
    }

  }

  Future<void> deletePostImages(String email, String postID) async {
      final storages = storage.ref().child(email + '/posts/' + postID);
      final results = await storages.listAll();
      for (var result in results.items) {
        await storage.ref().child(result.fullPath).delete();
      }
  }

  Future<List<String>> loadPostImages(String email, String postId, List<dynamic> fileName) async {
    List<String> urls = [];
    try {
      for (int i = 0; i < fileName.length; i++) {
        final ref = await storage.ref().child(email+'/posts/$postId/' + fileName[i].toString());
        final url = await ref.getDownloadURL();
      
        urls.add(url);
      }
      return urls;

    } catch (e) {
      return [];
    }
  }

}