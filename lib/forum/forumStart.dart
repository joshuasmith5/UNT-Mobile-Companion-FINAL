import 'package:flutter/material.dart';
import '../forum/palette.dart';
import '../forum/views/splash_page.dart';
import '/login.dart';


class ForumStart extends StatelessWidget {
  //const MyApp({super.key});
  final User currUser;

  const ForumStart({required this.currUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Companion Forum',
      theme: ThemeData(
        primarySwatch: Palette.greentodark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Palette.orangetodark,
          selectionColor: Palette.orangetodark,
          selectionHandleColor: Palette.orangetodark,
        ),
      ),
      home: SplashPage(currUser: currUser),
    );
  }
}