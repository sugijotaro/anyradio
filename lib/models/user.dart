import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String profileImageUrl;
  List<String> likedRadios;

  User({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.likedRadios,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      username: doc['username'],
      profileImageUrl: doc['profileImageUrl'],
      likedRadios: List<String>.from(doc['likedRadios']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
      'likedRadios': likedRadios,
    };
  }
}
