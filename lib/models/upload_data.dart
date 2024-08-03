import 'package:cloud_firestore/cloud_firestore.dart';

class UploadData {
  String id;
  String userId;
  List<String> fileUrls;
  DateTime uploadDate;
  String status;

  UploadData({
    required this.id,
    required this.userId,
    required this.fileUrls,
    required this.uploadDate,
    required this.status,
  });

  factory UploadData.fromDocument(DocumentSnapshot doc) {
    return UploadData(
      id: doc.id,
      userId: doc['userId'],
      fileUrls: List<String>.from(doc['fileUrls']),
      uploadDate: (doc['uploadDate'] as Timestamp).toDate(),
      status: doc['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileUrls': fileUrls,
      'uploadDate': uploadDate,
      'status': status,
    };
  }
}