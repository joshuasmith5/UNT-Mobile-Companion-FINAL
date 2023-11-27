import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '/forum/models/auth.dart';
import '/forum/models/auth_response.dart';
import '/forum/models/comment.dart';
import '/forum/models/post.dart';
import '/forum/models/user_response.dart';
import '/forum/services/local_services.dart';
import 'package:http/http.dart' as http;

final LocalServices localServices = LocalServices();

class RemoteService {
  final apiUrl = 'http://68.219.219.183:8080/api/v1/';

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Post>?> getPostsPage(int page) async {
    var url = Uri.parse('${apiUrl}post/page/$page');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = response.body;
      return postFromJson(json);
    }
    return null;
  }

  Future<void> register(String userName, String password) async {
    var url = Uri.parse('${apiUrl}auth/register');
    final body =
        jsonEncode(Auth(userName: userName, password: password).toJson());

    final response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      AuthResponse authResponse = authResponseFromJson(response.body);
      var token = authResponse.token;
      var date = DateTime.now().add(const Duration(hours: 24));
      await localServices.writeUserData(
          userName, authResponse.userId, token, date.toString());
    }
  }

  Future<AuthResponse> getToken(String userName, String password) async {
    var url = Uri.parse('${apiUrl}auth/authenticate');
    final body =
        jsonEncode(Auth(userName: userName, password: password).toJson());
    headers.remove('Authorization');

    final response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      AuthResponse authResponse = authResponseFromJson(response.body);
      var token = authResponse.token;
      var date = DateTime.now().add(const Duration(hours: 24));
      await localServices.writeUserData(
          userName, authResponse.userId, token, date.toString());
      return authResponseFromJson(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<void> addPost({required String title, required String content}) async {
    var url = Uri.parse('${apiUrl}post/add');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});

    final body = jsonEncode({"title": title, "content": content});

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 201) {
    } else {}
  }

  Future<void> addPostToFirestore({required String title, required String content}) async {
    await FirebaseFirestore.instance.collection('posts').add({
      'id': '0003',
      'title': title,
      'content': content,
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'user_name': 'test_student',
      'date': Timestamp.fromDate(DateTime.now())
    });
  }

  Future<List<Post>?> search(String text, int page) async {
    var url = Uri.parse('${apiUrl}post/search/$text/$page');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = response.body;
      return postFromJson(json);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    var expiration = await localServices.getExpiration();
    if (expiration != null) {
      var date = DateTime.parse(expiration);
      if (date.isBefore(DateTime.now())) {
        await logout();
        return false;
      }
    }
    var token = await localServices.getToken();
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  logout() async {
    await localServices.deleteUserData();
  }

  Future<List<Comment>> getComments(int page, String postId) async {
    var url = Uri.parse('${apiUrl}comment/get/$postId/$page');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = response.body;
      return commentFromJson(json);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<bool> addComment(String id, String text) async {
    var url = Uri.parse('${apiUrl}comment/add/');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.post(url,
        headers: headers, body: jsonEncode({"content": text, "post_id": id}));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addCommentToFireStore(String id, String text) async {
    await FirebaseFirestore.instance.collection('comments').add({
      'post_id': id,
      'content': text,
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'user_name': 'test_student',
      'date': Timestamp.fromDate(DateTime.now())
    });
  }

  Future<List<Post>> getPostsOfUser(int page, String userId) async {
    var url = Uri.parse('${apiUrl}post/user/$userId/$page');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = response.body;
      return postFromJson(json);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<UserResponse> getUserByUUID(String userId) async {
    var url = Uri.parse('${apiUrl}user/$userId');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = response.body;
      return userResponseFromJson(json);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<void> updatePost(String postId, Post post) async {
    var url = Uri.parse('${apiUrl}post/$postId');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response =
        await http.put(url, headers: headers, body: jsonEncode(post.toJson()));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(String id) async {
    var url = Uri.parse('${apiUrl}post/del/$id');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to delete post');
    }
  }

  Future<Uint8List> getProfilePicture(String id) async {
    var url = Uri.parse('${apiUrl}file/profile/$id');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200 &&
        response.headers['content-type']!.contains('image')) {
      var bytes = response.bodyBytes;
      return bytes;
    } else {
      throw Exception('Failed to load Picture');
    }
  }

  Future<void> updateBio(String bio) async {
    var url = Uri.parse('${apiUrl}user/update/$bio');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    var response = await http.put(url, headers: headers);

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to update bio');
    }
  }

  Future<void> updateProfilePicture(Image image) async {
    //var url = Uri.parse('${apiUrl}file/profile');
    var token = await localServices.getToken();
    headers.addAll({'Authorization': 'Bearer $token'});
    //var byteData = await image.toByteData();

    //var response = await http.put(url,headers: headers,);
  }
}
