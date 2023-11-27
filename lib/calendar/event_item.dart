import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unt_app/calendar/event.dart';

class EventItem extends StatelessWidget {
  final Event event;
  final Function() onDelete;
  final Function()? onTap;
  const EventItem({super.key, required this.event, required this.onDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title,),
      subtitle: Text("${DateFormat.jm().format(event.from)}  -  ${DateFormat.jm().format(event.to)}"),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}