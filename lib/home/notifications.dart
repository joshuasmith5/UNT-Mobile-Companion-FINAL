import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF00853E),
        elevation: 0,
      ),

      body: const Center(
        child: Text('No new notifications.'),
      ),
    );
  }
}