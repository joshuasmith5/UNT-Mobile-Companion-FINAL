import 'package:flutter/material.dart';
import '/forum/models/post.dart';
import '/forum/palette.dart';
import '/forum/services/local_services.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/editPostPage.dart';
import '/forum/views/login_page.dart';
import '/forum/views/search_page.dart';
import '/forum/views/updateProfile.dart';
import '/forum/views/user_page.dart';
import '/login.dart';
User currUser = User(username:'temp', password: 'temp', name: 'temp');


AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      color: Colors.white,
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    titleSpacing: 0,
    elevation: 0,
    title: Row(
      children: <Widget>[
        Image.asset(
          'assets/images/ghse_logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        const Text(
          ' Forum',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

AppBar buildMainAppBar(BuildContext context) {
  return AppBar(
    title: Row(
      children: <Widget>[
        Image.asset(
          'assets/images/ghse_logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        const Text(
          ' Forum',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
    actions: [
      IconButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SearchPage())),
          icon: const Icon(Icons.search),
          color: Colors.white),
      IconButton(
        onPressed: () {
          localServices.getUserId().then((value) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserPage(userId: currUser.name)));
          });
        },
        icon: const Icon(Icons.person),
        color: Colors.white,
      ),
    ],
    elevation: 0,
  );
}

AppBar buildProfileAppBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      color: Palette.orangetolight,
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    titleSpacing: 0,
    title: Row(
      children: <Widget>[
        Image.asset(
          'assets/images/ghse_logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        const Text(
          ' Forum',
          style: TextStyle(color: Palette.orangetolight),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        color: Palette.bluetolight[400],
        onPressed: () {
          LocalServices().deleteUserData();
          Navigator.pop(context);
         // Navigator.pushReplacement(
            //context,
            //MaterialPageRoute(builder: (context) => const LoginPage()),
          //);
        },
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        color: Palette.bluetolight[400],
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UpdateProfileWidget()),
          );
        },
      ),
    ],
  );
}

AppBar buildEditAppBar(BuildContext context, Post post) {
  return AppBar(
    leading: IconButton(
      color: Palette.orangetolight,
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    titleSpacing: 0,
    title: Row(
      children: <Widget>[
        Image.asset(
          'assets/images/ghse_logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        const Text(
          ' Forum',
          style: TextStyle(color: Palette.orangetolight),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.edit),
        color: Palette.bluetolight[400],
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
          );
        },
      ),
      IconButton(
          icon: const Icon(Icons.delete),
          color: Palette.bluetolight[400],
          onPressed: () {
            //Show popup
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Post"),
                  content:
                      const Text("Are you sure you want to delete this post?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        RemoteService().deletePost(post.id);
                      },
                    ),
                  ],
                );
              },
            );
          })
    ],
  );
}
