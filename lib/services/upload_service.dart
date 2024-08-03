import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class UploadService {
  Future<String> uploadFile(File file) async {
    String fileName = Uuid().v4();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('uploads/$fileName')
        .putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> saveUploadData(List<String> downloadUrls) async {
    String uploadId = Uuid().v4();
    await FirebaseFirestore.instance.collection('uploads').doc(uploadId).set({
      'id': uploadId,
      'userId': 'dummyUserId',
      'fileUrls': downloadUrls,
      'uploadDate': Timestamp.now(),
      'status': 'processing',
    });
  }
}