import 'package:flutter/material.dart';
import '/forum/palette.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/home_page.dart';

class AddPostWidget extends StatefulWidget {
  const AddPostWidget({Key? key}) : super(key: key);

  @override
  AddPostWidgetState createState() => AddPostWidgetState();
}

class AddPostWidgetState extends State<AddPostWidget> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: Palette.greentodark,
        child: Column(
          children: [
            Container(
              color: Palette.greentodark,
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              child: Row(
                children: const [
                  Text(
                    'Create a new post',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                            color: Colors.white, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
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
                            color: Colors.white, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
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
                          remoteService.addPostToFirestore(
                            title: titel,
                            content: content,
                          );
                          //return to home page
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Post')),
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
