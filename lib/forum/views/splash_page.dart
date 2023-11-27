import 'package:flutter/material.dart';
import '/forum/palette.dart';
import '/forum/services/remote_services.dart';
import '/forum/views/home_page.dart';
import '/forum/views/login_page.dart';
import '/login.dart';

class SplashPage extends StatefulWidget {
  final User currUser;
  const SplashPage({required this.currUser});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  bool _isLoading = false;
  User currUser = User(username:'temp', password: 'temp', name: 'temp');

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
    currUser = widget.currUser;

  }

  Future<void> checkIfLoggedIn() async {
    setState(() {
      _isLoading = true;
    });

    RemoteService remoteService = RemoteService();
    await remoteService.isLoggedIn().then((value) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        ));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  const SizedBox(height: 150),
                  Image.asset(
                    'assets/images/ghse-banner.png',
                    fit: BoxFit.contain,
                    height: 150,
                  ),
                  const SizedBox(height: 200),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(currUser: currUser)),
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
      ),
      backgroundColor: Palette.greentodark[500],
    );
  }
}
