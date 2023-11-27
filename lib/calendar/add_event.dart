import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:day_picker/day_picker.dart';
import 'package:uuid/uuid.dart';

class AddEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  
  const AddEvent({
      Key? key,
      required this.firstDate,
      required this.lastDate,
      this.selectedDate
  }) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late DateTime _selectedDay;
  late DateTime _fromDate;
  late DateTime _toDate;

  // used for day picker
  List<dynamic> _meetingDays = [];
  final List<DayInWeek> _days = [
    DayInWeek('Sun'),
    DayInWeek('Mon'),
    DayInWeek('Tue'),
    DayInWeek('Wed'),
    DayInWeek('Thu'),
    DayInWeek('Fri'),
    DayInWeek('Sat'),
  ];

  // used for generating unique recurrence id
  String _recurrenceId = '';

  final _titleController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _fromTimeController = TextEditingController();
  final _toTimeController = TextEditingController();
  final _toDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  final _sectionController = TextEditingController();
  final _professorController = TextEditingController();
  final _roomNumberController = TextEditingController();

  bool _validateTitle = false;
  bool _validateFromDate = false;
  bool _validateFromTime = false;
  bool _validateToDate = false;
  bool _validateToTime = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate ?? DateTime.now();
    _fromDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, _selectedDay.hour, _selectedDay.minute);
    _toDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, _selectedDay.hour, _selectedDay.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fromDateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _toDateController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    _sectionController.dispose();
    _professorController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        elevation: 0,
        leading: const CloseButton(),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
            ),
            onPressed: () {
              setState(() {
                _titleController.text.isEmpty ? _validateTitle = true : _validateTitle = false;
                _fromDateController.text.isEmpty ? _validateFromDate = true : _validateFromDate = false;
                _fromTimeController.text.isEmpty ? _validateFromTime = true : _validateFromTime = false;
                _toDateController.text.isEmpty ? _validateToDate = true : _validateToDate = false;
                _toTimeController.text.isEmpty ? _validateToTime = true : _validateToTime = false;
              });
              _addEvent();
            },
            icon: const Icon(Icons.done),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'title',
                errorText: _validateTitle ? 'title cannot be empty!' : null,
              ),
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _fromDateController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      labelText: 'start date',
                      errorText: _validateFromDate ? 'start date cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedFromDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay,
                        firstDate: DateTime(1995),
                        lastDate: DateTime(2100)
                      );
                      if (pickedFromDate != null) {
                        _fromDate = pickedFromDate;
                        String formattedFromDate = DateFormat("MM-dd-yyyy").format(pickedFromDate);
                        
                        _fromDateController.text = formattedFromDate.toString();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _fromTimeController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.access_time),
                      labelText: 'start time',
                      errorText: _validateFromTime ? 'start time cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedFromTime = await showTimePicker( // save time selected
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDay)
                      );
                      if(pickedFromTime != null) {
                        // update fromDate with pickedFromTime
                        final oldFromDate = _fromDate;
                        final newFromDate = DateTime(oldFromDate.year, oldFromDate.month, oldFromDate.day, pickedFromTime.hour, pickedFromTime.minute);
                        final time = DateFormat.jm().format(newFromDate);
                        _fromTimeController.text = time.toString();
                        _fromDate = newFromDate;
                      }
                    },
                  ),  
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _toDateController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      labelText: 'end date',
                      errorText: _validateToDate ? 'end date cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedToDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay,
                        firstDate: _fromDate, // anything before from date cannot be picked
                        lastDate: DateTime(2100)
                      );
                      if (pickedToDate != null) {
                        _toDate = pickedToDate;
                        String formattedFromDate = DateFormat("MM-dd-yyyy").format(pickedToDate);
                        _toDateController.text = formattedFromDate.toString();
                      }
                    },
                  ),
                ),
                Expanded(
                  child:  TextField(
                    controller: _toTimeController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.access_time),
                      labelText: 'end time',
                      errorText: _validateToTime ? 'end time cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedToTime = await showTimePicker( // save time selected
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDay)
                      );
                      if(pickedToTime != null) {
                        // update toDate to include time picked
                        final oldToDate = _toDate;
                        final newToDate = DateTime(oldToDate.year, oldToDate.month, oldToDate.day, pickedToTime.hour, pickedToTime.minute);

                        // convert TimeOfDay to string
                        final time = DateFormat.jm().format(newToDate);
                        _toTimeController.text = time.toString();

                        _toDate = newToDate;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            SelectWeekDays(
              boxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFFEEEEEE),
              ),
              fontSize: 14,
              // fontWeight: FontWeight.w500,
              days: _days,
              border: false,
              daysFillColor: const Color(0xFF00853E),
              selectedDayTextColor: Colors.white,
              unSelectedDayTextColor: Colors.black,
              onSelect: (values) {
                _meetingDays = values;
                // print(values);
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _courseController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'course'),
            ),
            TextField(
              controller: _sectionController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'section'),
            ),
            TextField(
              controller: _professorController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'professor'),
            ),
            TextField(
              controller: _roomNumberController,
              maxLines: 1,
              decoration: const InputDecoration(labelText: 'room number'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'description'),
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final title = _titleController.text;
    final description = _descriptionController.text;
    final course = _courseController.text;
    final section = _sectionController.text;
    final professor = _professorController.text;
    final roomNumber = _roomNumberController.text;
    final until = _toDate;
    
    if (title.isEmpty || _fromDateController.text.isEmpty || _fromTimeController.text.isEmpty || _toDateController.text.isEmpty || _toTimeController.text.isEmpty) {
      print('fields cannot be empty');
      return;
    }

    final days =_numOfDaysBetweenDates(_fromDate, _toDate);

    if (days == 0) { // if single date event
      await FirebaseFirestore.instance.collection('events').add({
        "user_id": userId,
        "title": title,
        "description": description,
        "course": course,
        "section": section,
        "professor": professor,
        "meeting_days": _meetingDays,
        "recurrence_id": _recurrenceId,
        "until": Timestamp.fromDate(until),
        "room_number": roomNumber,
        "from": Timestamp.fromDate(_fromDate),
        "to": Timestamp.fromDate(_toDate)
      });
    } 
    else { // if range based event
      // create unique id for occurences of the same type
      var uuid = const Uuid();
      var v4 = uuid.v4();
      _recurrenceId = v4;
      // print(_recurrenceId);

      if (_meetingDays.isEmpty){ // if consecutive order
        for(int i = 0; i < days + 1; i++) {
          await FirebaseFirestore.instance.collection('events').add({
            "user_id": userId,
            "title": title,
            "description": description,
            "course": course,
            "section": section,
            "professor": professor,
            "meeting_days": _meetingDays,
            "recurrence_id": _recurrenceId,
            "until": Timestamp.fromDate(until),
            "room_number": roomNumber,
            "from": Timestamp.fromDate(_fromDate),
            // since event is a recurring event, 'until' holds end date and 'to' holds the end time of event
            "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
            // "to": Timestamp.fromDate(_toDate)
          });
          _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
        }
      }
      else { // if meeting days are set
        for(int i = 0; i < days + 1; i++) {
          // if current date day matches any meeting day
          if (_meetingDays.any((meetingDay) => meetingDay == DateFormat('EEE').format(_fromDate))) {
            await FirebaseFirestore.instance.collection('events').add({
              "user_id": userId,
              "title": title,
              "description": description,
              "course": course,
              "section": section,
              "professor": professor,
              "meeting_days": _meetingDays,
              "recurrence_id": _recurrenceId,
              "until": Timestamp.fromDate(until),
              "room_number": roomNumber,
              "from": Timestamp.fromDate(_fromDate),
              // since event is a recurring event, 'until' holds end date and 'to' holds the end time of event
              "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
              // "to": Timestamp.fromDate(_toDate)
            });
            _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
          }
          // no match found
          else {
            _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
          }
        }
      }
    }
    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }

  // used for ranged dates
  int _numOfDaysBetweenDates(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

}