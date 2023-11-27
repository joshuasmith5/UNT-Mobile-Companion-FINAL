import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home/home.dart';
import 'signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String username;
  String password;
  String name;

  User({required this.username, required this.password, required this.name});

  bool isValid() {
    // checking if the username and password are not empty
    return username.isNotEmpty && password.isNotEmpty && name.isNotEmpty;
  }

  bool authenticate() {
    // perform authentication logic here, such as checking if the username and password match a stored user
    return username == "valid_username" && password == "valid_password";
  }

// static List<User> userList = [
//   User(username: "admin", password: "password", name: "developer"),
//   User(username: "student", password: "password", name: "Test Student"),
// ];
}

//runs log in screen
void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'UNT App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00853E),
        // primaryColor: const Color(0xFF00853e),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Color(0xFF00853e)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00853e)),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00853e),
        ),
      ),
      home: const Scaffold(
        // appBar: AppBar(
        //    title: const Text(_title),
        //    backgroundColor: const Color(0xFF00853e)),
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late TextEditingController nameController;
  late TextEditingController passwordController;

  List<User> userList = [];
  String loginError = '';
  User adminUser = User(username: "admin", password: "password", name: "developer");
  User studentUser = User(username: "student", password: "password", name: "Test Student");



  @override
  void initState() {
    nameController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
    // add the adminUser and studentUser to the userList
    userList.add(adminUser);
    userList.add(studentUser);
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> errorDialog(BuildContext context, String text,) {
    return showDialog( // returns dialog box
      context: context,
      builder: (context) {
        return AlertDialog( // returns actual alert message
          title: const Text('An error occurred'),
          content: Text(text), // error text
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // dismisses dialog box
              },
              child: const Text('OK')
            )
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset('assets/images/unt-1890-banner.svg')
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'EUID',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _launchForgotPasswordURL();
              },
              child: const Text(
                'Forgot Password',
                style: TextStyle(color: Color(0xFF00853e)),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00853e),
                ),
                child: const Text('Login'),
                onPressed: () async {
                  final email = nameController.text;
                  final password = passwordController.text;

                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password
                    );

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(currUser: User(username: 'Test', password: password, name: 'Test User'))
                        )
                      );
                    }
                    
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      await errorDialog(context, 'User not found');
                    }
                    else if (e.code == 'wrong-password'){
                      await errorDialog(context, 'Wrong credentials');
                    }
                    else {
                      await errorDialog(context, 'Error: ${e.code}');
                    }
                  } catch (e) {
                    await errorDialog(context, e.toString());
                  }


                  // User enteredUser = User(username: nameController.text, password: passwordController.text, name: 'First Last');
                  // bool isAuthenticated = false;
                  // String nameOfUser = '';
                  // for(User user in userList){
                  //   if(enteredUser.username == user.username && enteredUser.password == user.password){
                  //     isAuthenticated = true;
                  //     enteredUser.name = user.name;
                  //     nameOfUser = user.name;
                  //     break;
                  //   }
                  // }
                  // if(isAuthenticated)
                  // {
                  //   //String username = enteredUser.name;
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => HomeScreen(currUser: enteredUser)),
                  //   );
                  // }
                  // else {
                  //   setState(() {
                  //     loginError = 'Incorrect username or password';
                  //   });
                  // }
                },
              ),
            ),
            // if (loginError.isNotEmpty) // check if loginError is not empty
            //   Container(
            //     padding: const EdgeInsets.all(10),
            //     child: Text(
            //       loginError,
            //       style: const TextStyle(
            //         color: Colors.red,
            //       ),
            //     ),
            //   ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Don\'t have an account?'),
                TextButton(
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 20, color: Color(0xFF00853e)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                )
              ],
            ),
          ],
        )
    );
  }
}

Future <void> _launchForgotPasswordURL() async {
  Uri url = Uri.parse('https://ams.untsystem.edu/what_is_my_password/');
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}
