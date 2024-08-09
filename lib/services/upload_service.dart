import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class UploadService {
  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, "${Uuid().v4()}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 1080,
      minHeight: 1080,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }

  Future<List<String>> uploadFiles(
      List<File> files, String userId, String language) async {
    List<String> downloadUrls = [];
    String uploadId = Uuid().v4();

    for (var file in files) {
      File compressedFile = await compressImage(file);
      String fileName = Uuid().v4();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('uploads/$uploadId/$fileName')
          .putFile(compressedFile);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    await saveUploadData(uploadId, downloadUrls, userId, language);
    return downloadUrls;
  }

  Future<void> saveUploadData(String uploadId, List<String> downloadUrls,
      String userId, String language) async {
    await FirebaseFirestore.instance.collection('uploads').doc(uploadId).set({
      'id': uploadId,
      'userId': userId,
      'fileUrls': downloadUrls,
      'uploadDate': Timestamp.now(),
      'status': 'processing',
      'language': language,
    });
  }
}
