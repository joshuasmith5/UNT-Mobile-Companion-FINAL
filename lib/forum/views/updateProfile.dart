// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '/forum/palette.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/home_page.dart';
import '/forum/views/user_page.dart';

class UpdateProfileWidget extends StatefulWidget {
  const UpdateProfileWidget({super.key});

  @override
  UpdateProfileWidgetState createState() => UpdateProfileWidgetState();
}

class UpdateProfileWidgetState extends State<UpdateProfileWidget> {
  final controller = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Update Profile'),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Bio',
              labelStyle: TextStyle(color: Palette.orangetodark, fontSize: 20),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Palette.orangetodark),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Palette.orangetodark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              remoteService.updateBio(controller.text).then((value) {
                localServices.getUserId().then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserPage(userId: value!)));
                });
              });
            },
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}
