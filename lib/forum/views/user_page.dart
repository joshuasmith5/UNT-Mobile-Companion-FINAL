import 'package:flutter/material.dart';
import '/forum/models/post.dart';
import '/forum/models/user_response.dart';
import '/forum/palette.dart';
import '/forum/services/local_services.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/home_page.dart';
import '/forum/views/post_list_view.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  bool _isLoading = true;
  late String userId;
  UserResponse? user;
  bool isUsersPage = false;

  String bio = '';
  late Image profilePicture = Image.asset('assets/images/def1.png');

  bool _isLoadingPosts = true;
  List<Post>? posts;
  int page = 0;
  bool end = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    RemoteService().getProfilePicture(userId).then((value) {
      setState(() {
        profilePicture = Image.memory(value);
      });
    });
    RemoteService()
        .getUserByUUID(userId)
        .then((value) => setState(() {
              user = value;
              bio = value.bio ?? "";
              _isLoading = false;
            }))
        .then((value) => LocalServices().getUserId().then((value) {
              if (value == userId) {
                setState(() {
                  isUsersPage = true;
                });
              }
            }));

    RemoteService().getPostsOfUser(0, userId).then((value) {
      posts = value;
      setState(() {
        _isLoadingPosts = false;
      });
    });
  }

  addNextPage() {
    page++;
    remoteService.getPostsOfUser(page, userId).then((value) => setState(() {
          posts!.addAll(value);
          if (value.isEmpty) end = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isUsersPage ? buildProfileAppBar(context) : buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Palette.bluetodark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 90,
                        backgroundImage: profilePicture.image,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.userName ?? "",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Visibility(
                          visible: !_isLoadingPosts,
                          replacement: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          child: ListView.builder(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
