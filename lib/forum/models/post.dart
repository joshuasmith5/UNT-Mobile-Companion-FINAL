// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Post> postFromJson(String str) =>
    List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userName,
    required this.date,
  });

  String id;
  String title;
  String content;
  String userId;
  String userName;
  DateTime date;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        userId: json["user_id"],
        userName: json["user_name"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "user_id": userId,
        "user_name": userName,
        "date": date.toIso8601String(),
      };

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data();
    return Post(
      id: snapshot.id,
      userId: data!['user_id'],
      title: data['title'],
      content: data['content'],
      userName: data['user_name'],
      date: data['date'].toDate(),
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "user_id": userId,
      "user_name": userName,
      "date": Timestamp.fromDate(DateTime.now()),
    };  
  }
}
