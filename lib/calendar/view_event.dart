// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unt_app/calendar/event.dart';
import 'package:unt_app/calendar/edit_event.dart';
import 'package:intl/intl.dart';

class ViewEvent extends StatelessWidget {
  final Event event;
  const ViewEvent({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (event.recurrenceId == '') { // editing single event
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEvent(
                      firstDate: DateTime.now().subtract(const Duration(days: 1000)),
                      lastDate: DateTime.now().add(const Duration(days: 1000)),
                      event: event
                    )
                  )
                );
                if (result ?? false) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
              else if (event.recurrenceId != '') { // editing recurring event(s)
                final result = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Recurring Event'),
                    content: const Text('Do you want to edit this event only?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Edit this event only'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Edit all recurring events'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                );
                print('RESULT: ${result}');
                if (result == true)  { // editing single event from a recurring set of events
                  if (context.mounted) {
                    final edit = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEvent(
                          firstDate: DateTime.now().subtract(const Duration(days: 1000)),
                          lastDate: DateTime.now().add(const Duration(days: 1000)),
                          event: event
                        )
                      )
                    );
                    if (edit ?? false) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                }
                else if (result == false) { // editing all recurring events
                  if (context.mounted) {
                    final edit = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEvent(
                          firstDate: DateTime.now().subtract(const Duration(days: 1000)),
                          lastDate: DateTime.now().add(const Duration(days: 1000)),
                          event: event,
                          recurrenceId: event.recurrenceId,
                        )
                      )
                    );
                    if (edit ?? false) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                }
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (event.recurrenceId == '') { // deleting single event
                final delete = await showDialog(
                  context: context, 
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Event?'),
                    content: const Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
                if (delete ?? false) {
                  if(context.mounted){
                    Navigator.pop(context, true);
                  }
                }
              }
              else { // deleting recurring event
                final delete = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Recurring Event'),
                    content: const Text('Do you want to delete this event only?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Delete this event only'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Delete all recurring events'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
                if (delete != null) {
                  if(context.mounted) {
                    Navigator.pop(context, delete);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: <Widget>[
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24,),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'From',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${DateFormat.yMMMEd().format(event.from)} ${DateFormat.jm().format(event.from)}',
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'To',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${DateFormat.yMMMEd().format(event.to)} ${DateFormat.jm().format(event.to)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              event.recurrenceId != "" ? Container( // if recurring event display 'until' date otherwise display nothing
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Every',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${event.meetingDays}',
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ) : const SizedBox(height: 1,),
              event.recurrenceId != "" ? Container( // if recurring event display 'until' date otherwise display nothing
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Until',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${DateFormat.yMMMEd().format(event.until)} ${DateFormat.jm().format(event.until)}',
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ) : const SizedBox(height: 1,),
              event.description != '' ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      SizedBox(height: 35,),
                      Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    ],
                  ),
                  Text(event.description!, style: const TextStyle(fontSize: 18,),)
                ],
              ) : const SizedBox(height: 1,),
            ],
          ),
          event.course != '' ? Column( // if course field is completed display class info
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16,),
              const Text(
                'Class Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Expanded(child: Text('Course:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
                  Text(event.course!, style: const TextStyle(fontSize: 18,))
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Section:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
                  Text(event.section!, style: const TextStyle(fontSize: 18,))
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Professor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
                  Text(event.professor!, style: const TextStyle(fontSize: 18,))
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Room number:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
                  Text(event.roomNumber!, style: const TextStyle(fontSize: 18,))
                ],
              ),
            ],
          ) : const SizedBox(height: 1,),
        ],
      ),
    );
  }
}