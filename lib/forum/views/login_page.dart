import 'package:flutter/material.dart';
import '/forum/palette.dart';
import '/forum/views/home_page.dart';
import '/login.dart';

class LoginPage extends StatefulWidget {
  final User currUser;
  const LoginPage({required this.currUser});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset(
              'assets/images/ghse_logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            const Text(
              '  GHSE Forum',
              style: TextStyle(color: Palette.orangetolight),
            ),
          ],
        ),
      ),
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
                    'Login',
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
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: userController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
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
                      obscureText: _obscureText,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                            color: Palette.orangetodark, fontSize: 20),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.orangetodark),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Palette.orangetodark,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: () async {
                          if (userController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            return;
                          } else {
                            await remoteService
                                .getToken(userController.text,
                                    passwordController.text)
                                .then((value) => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage())));
                          }
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Login')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
