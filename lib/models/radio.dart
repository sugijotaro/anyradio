import 'package:cloud_firestore/cloud_firestore.dart';

class Radio {
  String id;
  String title;
  String description;
  String audioUrl;
  String imageUrl;
  String uploaderId;
  DateTime uploadDate;
  List<Comment> comments;
  int likes;
  String genre;
  int playCount;
  String language;
  DateTime? lastPlayed;
  String privacyLevel;

  Radio({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.uploaderId,
    required this.uploadDate,
    required this.comments,
    required this.likes,
    required this.genre,
    required this.playCount,
    required this.language,
    this.lastPlayed,
    required this.privacyLevel,
  });

  factory Radio.fromDocument(DocumentSnapshot doc) {
    return Radio(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      audioUrl: doc['audioUrl'],
      imageUrl: doc['imageUrl'],
      uploaderId: doc['uploaderId'],
      uploadDate: (doc['uploadDate'] as Timestamp).toDate(),
      comments: (doc['comments'] as List).map((c) => Comment.fromMap(c)).toList(),
      likes: doc['likes'],
      genre: doc['genre'],
      playCount: doc['playCount'],
      language: doc['language'],
      lastPlayed: (doc['lastPlayed'] as Timestamp?)?.toDate(),
      privacyLevel: doc['privacyLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'uploaderId': uploaderId,
      'uploadDate': uploadDate,
      'comments': comments.map((c) => c.toMap()).toList(),
      'likes': likes,
      'genre': genre,
      'playCount': playCount,
      'language': language,
      'lastPlayed': lastPlayed,
      'privacyLevel': privacyLevel,
    };
  }
}

class Comment {
  String id;
  String userId;
  String content;
  DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}