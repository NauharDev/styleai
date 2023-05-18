import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class Storage {
  final storageBucket = FirebaseStorage.instance;

  Future<void> uploadPhoto(String filePath, String fileName) async {
    File file = File(filePath);
    try {
    await storageBucket.ref('/userPhotos/$fileName').putFile(file);
    } on FirebaseException catch(e) {
      print(e);
    }

  }

}