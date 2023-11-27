import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/forum/models/comment.dart';
import '/forum/models/post.dart';
import '/forum/palette.dart';
import '/forum/services/local_services.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/comment_list_view.dart';
import '/forum/views/home_page.dart';
import '/forum/views/user_page.dart';

class FullScreenPostWidget extends StatefulWidget {
  final Post post;

  const FullScreenPostWidget({Key? key, required this.post}) : super(key: key);

  @override
  FullScreenPostWidgetState createState() => FullScreenPostWidgetState();
}

class FullScreenPostWidgetState extends State<FullScreenPostWidget> {
  late List<Comment> comments = [];
  late Post post;
  int page = 0;
  bool end = false;
  bool isLoaded = false;
  TextEditingController commentController = TextEditingController();
  bool isOwnPost = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadFireStoreComments();
    super.initState();
    post = widget.post;
    // getData();
  }

  _loadFireStoreComments() async {
    comments = [];
    final snap = await FirebaseFirestore.instance.collection('comments').where('post_id', isEqualTo: widget.post.id).orderBy('date', descending: false).withConverter(fromFirestore: Comment.fromFirestore, toFirestore: (comment, options) => comment.toFirestore()).get();
    for (var doc in snap.docs) {
      final comment = doc.data();
      comments.add(comment);
    }
    setState(() {});
  }

  // getData() async {
  //   comments = await remoteService.getComments(0, post.id);
  //   setState(() {
  //     isLoaded = true;
  //   });
  //   LocalServices().getUserId().then((value) {
  //     if (value == post.userId) {
  //       setState(() {
  //         isOwnPost = true;
  //       });
  //     }
  //   });
  // }

  addNextPage() {
    page++;
    remoteService.getComments(page, post.id).then((value) => setState(() {
          comments.addAll(value);
          if (value.isEmpty) end = true;
        }));
    //reload the page
  }

  //Page to display a post in full screen including the post Content and Comments
  @override
  Widget build(BuildContext context) {
    String date = LocalServices().getFormatedDate(post.date);

    return Scaffold(
      appBar: isOwnPost ? buildEditAppBar(context, post) : buildAppBar(context),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 224, 224),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 15,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPage(
                                userId: post.userId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          post.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 15,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              child: Row(
                children: const [
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 116, 5),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 0, bottom: 16, left: 16, right: 16),
              child: TextField(
                cursorColor: Colors.black,
                controller: commentController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        String text = commentController.text;
                        if (commentController.text.isNotEmpty) {
                          remoteService.addCommentToFireStore(post.id, text);
                              // .addComment(post.id, text)
                              // .then((value) => {
                              //       if (value == true)
                              //         {
                              //           setState(() {
                              //             comments.insert(
                              //                 0,
                              //                 Comment(
                              //                     userId: '0',
                              //                     content: text,
                              //                     date: DateTime.now(),
                              //                     userName: 'Me',
                              //                     id: '0'));
                              //           })
                              //         }
                              //     });
                          commentController.clear();
                          _loadFireStoreComments();
                        }
                      },
                      icon: const Icon(Icons.send)),
                  fillColor: Color.fromARGB(255, 202, 201, 201),
                  filled: true,
                  hintText: 'Write a comment',
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Expanded(child: ListView.builder(itemBuilder: (context, index) {
              int? postLength = comments.length;

              if (index == postLength && !end) {
                addNextPage();
                // return Container(
                //   padding: const EdgeInsets.all(16),
                //   child: const Center(
                //     child: CircularProgressIndicator(),
                //   ),
                // );
              } else if (index < postLength) {
                final comment = comments[index];
                return CommentWidget(comment: comment);
              }
              return null;
            })),
          ],
        ),
      ),
    );
  }
}
