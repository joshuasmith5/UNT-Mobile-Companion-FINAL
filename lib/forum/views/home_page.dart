import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '/forum/models/post.dart';
import '/forum/palette.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/create_post.dart';
import '/forum/views/post_list_view.dart';

RemoteService remoteService = RemoteService();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Post>? posts;
  var isLoaded = false;
  int page = 0;
  bool end = false;

  final user = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    _loadFirestorePosts();
    super.initState();
    // getData();
  }

  _loadFirestorePosts() async {
    posts = [];

    // get all posts
    final snap = await FirebaseFirestore.instance.collection('posts').orderBy('date', descending: false).withConverter(fromFirestore: Post.fromFirestore, toFirestore: (post, options) => post.toFirestore()).get();
    for (var doc in snap.docs) {
      final post = doc.data();
      posts?.add(post);
    }
    setState(() {});
  }

  // getData() async {
  //   posts = await remoteService.getPostsPage(0);
  //   if (posts != null) {
  //     setState(() {
  //       isLoaded = true;
  //     });
  //   }
  // }

  addNextPage() {
    page++;
    remoteService.getPostsPage(page).then((value) => setState(() {
          posts!.addAll(value!);
          if (value.isEmpty) end = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMainAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddPostWidget(),
          )).then((value) => _loadFirestorePosts());
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add),
      ),
      // body: RefreshIndicator(
      //   color: Palette.orangetodark,
      //   backgroundColor: Palette.greentodark[50],
      //   onRefresh: () async {
      //     page = 0;
      //     end = false;
      //     await remoteService.getPostsPage(0).then((value) => setState(() {
      //           posts = value;
      //         }));
      //   },
      //   child: Visibility(
      //     visible: isLoaded,
      //     replacement: const Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //     child: ListView.builder(
      //       itemBuilder: (context, index) {
      //         int? postLength = posts?.length;

      //         if (index == postLength && !end) {
      //           addNextPage();
      //           return Container(
      //             padding: const EdgeInsets.all(16),
      //             child: const Center(
      //               child: CircularProgressIndicator(),
      //             ),
      //           );
      //         } else if (index < postLength!) {
      //           final post = posts![index];
      //           return PostWidget(post: post);
      //         }
      //         return null;
      //       },
      //     ),
      //   ),
      // ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          int? postLength = posts?.length;

          if (index == postLength && !end) {
            addNextPage();
            return Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (index < postLength!) {
            final post = posts![index];
            return PostWidget(post: post);
          }
          return null;
        },
      ),
      backgroundColor: const Color.fromARGB(255, 202, 201, 201),
    );
  }
}
