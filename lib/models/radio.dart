import 'package:cloud_firestore/cloud_firestore.dart';

enum RadioGenre {
  comedy,
  news,
  education,
  parenting,
  mentalHealth,
  romance,
  mystery,
  business,
  entertainment,
  history,
  health,
  science,
  sports,
  fiction,
  religion,
}

class Radio {
  String id;
  String title;
  String description;
  String script;
  String audioUrl;
  String thumbnail;
  String uploaderId;
  DateTime uploadDate;
  List<Comment> comments;
  int likes;
  RadioGenre genre;
  int playCount;
  String language;
  DateTime? lastPlayed;
  String privacyLevel;

  Radio({
    required this.id,
    required this.title,
    required this.description,
    required this.script,
    required this.audioUrl,
    required this.thumbnail,
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
      script: doc['script'],
      audioUrl: doc['audioUrl'],
      thumbnail: doc['thumbnail'],
      uploaderId: doc['uploaderId'],
      uploadDate: (doc['uploadDate'] as Timestamp).toDate(),
      comments:
          (doc['comments'] as List).map((c) => Comment.fromMap(c)).toList(),
      likes: doc['likes'],
      genre: RadioGenre.values.byName(doc['genre']),
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
      'script': script,
      'audioUrl': audioUrl,
      'thumbnail': thumbnail,
      'uploaderId': uploaderId,
      'uploadDate': uploadDate,
      'comments': comments.map((c) => c.toMap()).toList(),
      'likes': likes,
      'genre': genre.name,
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
