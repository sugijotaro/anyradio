import 'package:cloud_firestore/cloud_firestore.dart';

class UploadData {
  String id;
  String userId;
  String fileUrl;
  DateTime uploadDate;
  String status;

  UploadData({
    required this.id,
    required this.userId,
    required this.fileUrl,
    required this.uploadDate,
    required this.status,
  });

  factory UploadData.fromDocument(DocumentSnapshot doc) {
    return UploadData(
      id: doc.id,
      userId: doc['userId'],
      fileUrl: doc['fileUrl'],
      uploadDate: (doc['uploadDate'] as Timestamp).toDate(),
      status: doc['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate,
      'status': status,
    };
  }
}