import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class UploadService {
  Future<List<String>> uploadFiles(List<File> files) async {
    List<String> downloadUrls = [];
    String uploadId = Uuid().v4();

    for (var file in files) {
      String fileName = Uuid().v4();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('uploads/$uploadId/$fileName')
          .putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    
    await saveUploadData(uploadId, downloadUrls);
    return downloadUrls;
  }

  Future<void> saveUploadData(String uploadId, List<String> downloadUrls) async {
    await FirebaseFirestore.instance.collection('uploads').doc(uploadId).set({
      'id': uploadId,
      'userId': 'dummyUserId',
      'fileUrls': downloadUrls,
      'uploadDate': Timestamp.now(),
      'status': 'processing',
    });
  }
}