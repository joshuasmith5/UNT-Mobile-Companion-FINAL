import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unt_app/login.dart';
import 'package:unt_app/map/map.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(SignUp());
}

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
            centerTitle: true,
            backgroundColor: const Color(0xFF00853e),
            leading: IconButton(
            icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Navigate back to the previous screen
          Navigator.pop(context);
        },
      ),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  late TextEditingController uNameController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController ;

  @override
  void initState() {
    uNameController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    uNameController.dispose();
    nameController.dispose();
    emailController.dispose();
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

  void _submit() async {
    final String uName = uNameController.text;
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    print('Username: $uName');
    print('Name: $name');
    print('Email: $email');
    print('Password: $password');

    //send info to database
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      final user = FirebaseAuth.instance.currentUser;
      user?.updateDisplayName(name);
      print(user?.displayName);
      //return user to log in screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyApp(),
          )
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await errorDialog(context, 'Weak password');
      }
      else if (e.code == 'email-already-in-use'){
        await errorDialog(context, 'Email is already in use');
      }
      else if (e.code == 'invalid-email'){
        await errorDialog(context, 'Invalid email address');
      }
      else {
        await errorDialog(context, 'Error: ${e.code}');
      }
    } catch (e) {
      await errorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset('assets/images/unt-1890-banner.svg')
        ),
        TextField(
          controller: uNameController,
          decoration: const InputDecoration(
            labelText: 'Username',
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
        ),
        const SizedBox(height: 32.0),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF00853e), // Change this to the desired color
          ),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
