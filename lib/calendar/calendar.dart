import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unt_app/calendar/event.dart';
import 'package:unt_app/calendar/event_item.dart';
import 'package:unt_app/calendar/view_event.dart';
import 'package:unt_app/calendar/add_event.dart';
import 'dart:collection';


class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNT Calendar',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00853E),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Event> > _events; // used provide events to the calendar

  final user = FirebaseAuth.instance.currentUser?.uid;

  int getHashCode(DateTime key) { // get unique hashcode for each date
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    _focusedDay = DateTime.now(); // current day selected when calendar opens
    _firstDay = DateTime.now().subtract(const Duration(days: 1000)); // earliest date the calendar can show
    _lastDay = DateTime.now().add(const Duration(days: 1000)); // latest date the calendar can show
    _selectedDay = DateTime.now();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    _loadFirestoreEvents();
    super.initState();
  }

  // load events from firestore
  _loadFirestoreEvents() async {
    // used to only load events from current month viewed
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    _events = {}; // clear out _events so that duplicates do not load

    final snap = await FirebaseFirestore.instance.collection('events').where('from', isGreaterThanOrEqualTo: firstDay).where('from', isLessThanOrEqualTo: lastDay).where('user_id', isEqualTo: user).withConverter(fromFirestore: Event.fromFirestore, toFirestore: (event, options) => event.toFirestore()).get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day = DateTime.utc(event.from.year, event.from.month, event.from.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
    }
    setState(() {});
  }

  // display event markers
  List _getEventForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UNT Calendar'),
        elevation: 0,
        centerTitle: true,
        leading: CloseButton(
          onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
        ),
      ),
      body: ListView(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: _firstDay,
            lastDay: _lastDay,
            onPageChanged: (focusedDay) { // events change as month page changes
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadFirestoreEvents();
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            // availableCalendarFormats: const {CalendarFormat.month: 'month'},
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              // selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Color(0xFF00853E),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            eventLoader: _getEventForTheDay,
          ),
          ..._getEventForTheDay(_selectedDay).map(
            (event) => EventItem(
              event: event,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewEvent(
                      event: event,
                    ),
                  ),
                );
                if (result == true) {
                  await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
                }
                else if (result == false) {
                  var snapshot = await FirebaseFirestore.instance.collection('events').where('recurrence_id', isEqualTo: event.recurrenceId).get(); //return list of docs matching condition
                  for (var doc in snapshot.docs) { // get each document in list and delete from database
                    await doc.reference.delete();
                  }
                }
                _loadFirestoreEvents();
              },
              onDelete: () async {
                if (event.recurrenceId == '') { // deleting single event. no recurrence
                  final delete = await showDialog(
                    context: context, 
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Event?'),
                      content: const Text('Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Yes'),
                        ),
                      ],
                    ), 
                  );
                  if (delete ?? false) {
                    await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
                    _loadFirestoreEvents();
                  }
                }
                else {
                  final delete = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Recurring Event'),
                      content: const Text('Do you want to delete this event only?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ), 
                          child: const Text('Delete this event only')
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Delete all recurring events'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                  if (delete == true) {
                    await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
                    _loadFirestoreEvents();
                  }
                  else if (delete == false) {
                    var snapshot = await FirebaseFirestore.instance.collection('events').where('recurrence_id', isEqualTo: event.recurrenceId).get(); //return list of docs matching condition
                    for (var doc in snapshot.docs) { // get each document in list and delete from database
                      await doc.reference.delete();
                    }
                    _loadFirestoreEvents();
                  }
                }
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEvent(
                firstDate: _firstDay,
                lastDate: _lastDay,
                selectedDate: _selectedDay,
              ),
            ),
          );
          if (result ?? false) {
            _loadFirestoreEvents();
          }
        },
        backgroundColor: const Color(0xFF00853E),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}