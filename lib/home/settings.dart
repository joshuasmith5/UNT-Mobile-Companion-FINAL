import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF00853E),
        elevation: 0,
      ),

      body: const Center(
        child: Text('This is the settings page'),
      ),
    );
  }
}