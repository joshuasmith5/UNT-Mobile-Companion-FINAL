// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '/forum/models/post.dart';
import '/forum/palette.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/post_page.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  editPostPageState createState() => editPostPageState();
}

// ignore: camel_case_types
class editPostPageState extends State<EditPostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.post.title;
    contentController.text = widget.post.content;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: Palette.bluetodark,
        child: Column(
          children: [
            Container(
              color: Palette.bluetolight,
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              child: Row(
                children: const [
                  Text(
                    'Update your post',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Palette.orangetodark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                            color: Palette.orangetodark, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        labelStyle: TextStyle(
                            color: Palette.orangetodark, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: () async {
                          var titel = titleController.text;
                          var content = contentController.text;
                          if (titel.isEmpty | content.isEmpty) {
                            //show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please fill in all fields')));
                            return;
                          }
                          widget.post.title = titel;
                          widget.post.content = content;
                          RemoteService()
                              .updatePost(widget.post.id, widget.post);
                          //return to home page
                          Navigator.of(context).pop();
                          //reload post page with new post
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenPostWidget(
                                        post: widget.post,
                                      )));
                        },
                        icon: const Icon(Icons.post_add),
                        label: const Text('Update Post')),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
