import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Storage {
  final storageBucket = FirebaseStorage.instance;
  late Reference userStorage;

  static Future<void> createStorage(String storageName) async {
    FirebaseStorage.instance.ref().child("/$storageName");
  }

  static Future<void> uploadPhoto(String storageName, String filePath, String fileName) async {
    File file = File(filePath);
    try {
    await FirebaseStorage.instance.ref("/$storageName/$fileName").putFile(file);
    // await storageBucket.ref('/userPhotos/$fileName').putFile(file);
    } on FirebaseException catch(e) {
      print(e);
    }

  }

}