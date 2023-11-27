import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unt_app/calendar/event.dart';
import 'package:day_picker/day_picker.dart';
import 'package:uuid/uuid.dart';

class EditEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final Event event;
  final String? recurrenceId;

  const EditEvent({super.key, required this.firstDate, required this.lastDate, required this.event, this.recurrenceId});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late String _recurrenceId;

  late List<dynamic> _meetingDays;
  late List<DayInWeek> _days;

  late TextEditingController _titleController;
  late TextEditingController _fromDateController;
  late TextEditingController _fromTimeController;
  late TextEditingController _toDateController;
  late TextEditingController _toTimeController;
  late TextEditingController _descriptionController;
  late TextEditingController _courseController;
  late TextEditingController _sectionController;
  late TextEditingController _professorController;
  late TextEditingController _roomNumberController;

  bool _validateTitle = false;
  bool _validateFromDate = false;
  bool _validateFromTime = false;
  bool _validateToDate = false;
  bool _validateToTime = false;
  
  @override
  void initState() {
    super.initState();
    // _selectedDay = widget.event.from;
    _titleController = TextEditingController(text: widget.event.title);
    _fromDateController = TextEditingController(text: DateFormat("MM-dd-yyyy").format(widget.event.from));
    _fromTimeController = TextEditingController(text: DateFormat.jm().format(widget.event.from));
    _toDateController = TextEditingController(text: DateFormat("MM-dd-yyyy").format(widget.event.to));
    _toTimeController = TextEditingController(text: DateFormat.jm().format(widget.event.to));
    _descriptionController = TextEditingController(text: widget.event.description);
    _courseController = TextEditingController(text: widget.event.course);
    _sectionController = TextEditingController(text: widget.event.section);
    _professorController = TextEditingController(text: widget.event.professor);
    _roomNumberController = TextEditingController(text: widget.event.roomNumber);

    // if event is a single event not a recurring event
    if (widget.event.recurrenceId == '') {
      _fromDate = widget.event.from;
      _toDate = widget.event.to;
    } else { // if event is a recurring event
      _fromDate = widget.event.from;
      _toDate = widget.event.until;
    }

    // if parameter recurrenceId is null, then we are editing a single event
    // else if it is not null, then we are editing a whole set of recurring events
    _recurrenceId = widget.recurrenceId ?? '';

    // initalize _days for day picker
    _days = [
      DayInWeek('Sun'),
      DayInWeek('Mon'),
      DayInWeek('Tue'),
      DayInWeek('Wed'),
      DayInWeek('Thu'),
      DayInWeek('Fri'),
      DayInWeek('Sat'),
    ];

    // store previous meetings days from event
    _meetingDays = widget.event.meetingDays ?? [];
    // print('{initial _meetingsDays: $_meetingDays}');
    // if _meeting days contains a day of the week, toggle that day in day picker
    for (String meeting in _meetingDays) {
      if (meeting == 'Sun') {
        _days[0].isSelected = true;
      } else if (meeting == 'Mon') {
        _days[1].isSelected = true;
      } else if (meeting == 'Tue') {
        _days[2].isSelected = true;
      } else if (meeting == 'Wed') {
        _days[3].isSelected = true;
      } else if (meeting == 'Thu') {
        _days[4].isSelected = true;
      } else if (meeting == 'Fri') {
        _days[5].isSelected = true;
      } else if (meeting == 'Sat') {
        _days[6].isSelected = true;
      }
    }
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
        title: const Text('Edit Event'),
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
              _updateEvent();
            },
            icon: const Icon(Icons.done),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                      labelText: 'Enter starting date of event',
                      errorText: _validateFromDate ? 'start date cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedFromDate = await showDatePicker(
                        context: context,
                        initialDate: _fromDate,
                        firstDate: DateTime(1995),
                        lastDate: DateTime(2100)
                      );
                      if (pickedFromDate != null) {
                        _fromDate = DateTime(pickedFromDate.year, pickedFromDate.month, pickedFromDate.day, _fromDate.hour, _fromDate.minute); // keep time the same, even if date changes
                        if (_fromDate.isAfter(_toDate)) {
                          _toDate = _fromDate;
                          _toDateController.text = _fromDateController.text;
                        }
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
                      labelText: 'Enter starting time of event',
                      errorText: _validateFromTime ? 'start time cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedFromTime = await showTimePicker( // save time selected
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(widget.event.from)
                      );
                      if(pickedFromTime != null) {
                        // update fromDate with new time picked
                        final oldFromDate = _fromDate;
                        final newFromDate = DateTime(oldFromDate.year, oldFromDate.month, oldFromDate.day, pickedFromTime.hour, pickedFromTime.minute); 

                        // convert TimeOfDay to string
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
                      labelText: 'Enter ending date of event',
                      errorText: _validateToDate ? 'end date cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedToDate = await showDatePicker(
                        context: context,
                        initialDate: _toDate,
                        firstDate: _fromDate,
                        lastDate: DateTime(2100)
                      );
                      if (pickedToDate != null) {
                        _toDate = DateTime(pickedToDate.year, pickedToDate.month, pickedToDate.day, _toDate.hour, _toDate.minute); // keep time the same, even if date changes
                        String formattedFromDate = DateFormat("MM-dd-yyyy").format(pickedToDate);
                        _toDateController.text = formattedFromDate.toString();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _toTimeController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.access_time),
                      labelText: 'Enter ending time of event',
                      errorText: _validateToTime ? 'end time cannot be empty!' : null,
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedToTime = await showTimePicker( // save time selected
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(widget.event.to)
                      );
                      if(pickedToTime != null) {
                        // take previous _toDate and add new picked time
                        final oldToDate = _toDate;
                        final newToDate = DateTime(oldToDate.year, oldToDate.month, oldToDate.day, pickedToTime.hour, pickedToTime.minute);

                        // convert TimeOfDay to string
                        final time = DateFormat.jm().format(newToDate);
                        _toTimeController.text = time.toString();

                        // update _toDate with new time
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

  void _updateEvent() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final course = _courseController.text;
    final section = _sectionController.text;
    final professor = _professorController.text;
    final meetingDays = _meetingDays;
    final roomNumber = _roomNumberController.text;
    final until = _toDate;

    if (title.isEmpty) {
      print('title cannot be empty');
      return;
    }

    final days =_numOfDaysBetweenDates(_fromDate, _toDate);
    
    if(days == 0) {
      if (widget.event.recurrenceId == '') { // single event edit
        await FirebaseFirestore.instance.collection('events').doc(widget.event.id).update({
          "title": title,
          "description": description,
          "course": course,
          "section": section,
          "professor": professor,
          "meeting_days": meetingDays,
          "recurrence_id": _recurrenceId,
          "until": Timestamp.fromDate(until),
          "room_number": roomNumber,
          "from": Timestamp.fromDate(_fromDate),
          "to": Timestamp.fromDate(_toDate)
        });
        if (mounted) {
          Navigator.pop<bool>(context, true);
        }
      }
      else if (widget.event.recurrenceId != '' && _recurrenceId == '') { // single event that is part of recurrence event
        await FirebaseFirestore.instance.collection('events').doc(widget.event.id).update({
          "title": title,
          "description": description,
          "course": course,
          "section": section,
          "professor": professor,
          "meeting_days": meetingDays,
          "recurrence_id": _recurrenceId,
          "until": Timestamp.fromDate(until),
          "room_number": roomNumber,
          "from": Timestamp.fromDate(_fromDate),
          "to": Timestamp.fromDate(_toDate)
        });
        if (mounted) {
          Navigator.pop<bool>(context, true);
        }
      }
      else if (widget.event.recurrenceId != '' && _recurrenceId != '') { // range based event edited to single event
        // obtain all events from recurrence and delete
        var snapshot = await FirebaseFirestore.instance.collection('events').where('recurrence_id', isEqualTo: _recurrenceId).get(); //return list of docs matching recurrence_id
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        await FirebaseFirestore.instance.collection('events').add({
          "title": title,
          "description": description,
          "course": course,
          "section": section,
          "professor": professor,
          "meeting_days": _meetingDays,
          "recurrence_id": '', // range based event edited to single event, recurrence id no longer needed
          "until": Timestamp.fromDate(until),
          "room_number": roomNumber,
          "from": Timestamp.fromDate(_fromDate),
          "to": Timestamp.fromDate(_toDate)
        });
        if (mounted) {
          Navigator.pop<bool>(context, true);
        }
      }
    }
    else { // days > 0 = range based event
      if(widget.event.recurrenceId == '') { // single event edited to range based event
        // create unique id for occurences of the same type
        var uuid = const Uuid();
        var v4 = uuid.v4();
        _recurrenceId = v4;

        if (_meetingDays.isEmpty){ // if consecutive order
          // delete single event so it is not duplicated by range events
          await FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete();
          for(int i = 0; i < days + 1; i++) {
            await FirebaseFirestore.instance.collection('events').add({
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
              "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
            });
            _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
          }
          if (mounted) {
            Navigator.pop<bool>(context, true);
          }
        }
        else { // if meeting days are set
          // delete single event so it is not duplicated
          await FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete();
          for(int i = 0; i < days + 1; i++) {
            // if current date day matches any meeting day
            if (_meetingDays.any((meetingDay) => meetingDay == DateFormat('EEE').format(_fromDate))) {
              await FirebaseFirestore.instance.collection('events').add({
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
                "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
              });
              _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
            }
            // no match found
            else {
              _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
            }
          }
          if (mounted) {
            Navigator.pop<bool>(context, true);
          }
        }
      }
      else if (widget.event.recurrenceId != '' && _recurrenceId == '') { // edit single event from recurring events
        await FirebaseFirestore.instance.collection('events').doc(widget.event.id).update({
          "title": title,
          "description": description,
          "course": course,
          "section": section,
          "professor": professor,
          "meeting_days": meetingDays,
          "recurrence_id": widget.event.recurrenceId,
          "until": Timestamp.fromDate(until),
          "room_number": roomNumber,
          "from": Timestamp.fromDate(_fromDate),
          "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
        });
        if (mounted) {
          Navigator.pop<bool>(context, true);
        }
      }
      else if (widget.event.recurrenceId != '' && _recurrenceId != '') { // edit every event from a recurrence
        // obtain all events from recurrence and delete
        var snapshot = await FirebaseFirestore.instance.collection('events').where('recurrence_id', isEqualTo: _recurrenceId).get(); //return list of docs matching recurrence_id
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        
        // replace events with updated events
        
        // must generate new recurrence id 
        var uuid = const Uuid();
        var v4 = uuid.v4();
        _recurrenceId = v4;

        if (_meetingDays.isEmpty){ // if consecutive order
          // delete single event so it is not duplicated by range events
          await FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete();
          for(int i = 0; i < days + 1; i++) {
            await FirebaseFirestore.instance.collection('events').add({
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
              "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
            });
            _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
          }
          if (mounted) {
            Navigator.pop<bool>(context, true);
          }
        }
        else { // if meeting days are set
          // delete single event so it is not duplicated
          await FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete();
          for(int i = 0; i < days + 1; i++) {
            // if current date day matches any meeting day
            if (_meetingDays.any((meetingDay) => meetingDay == DateFormat('EEE').format(_fromDate))) {
              await FirebaseFirestore.instance.collection('events').add({
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
                "to": Timestamp.fromDate(DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _toDate.hour, _toDate.minute))
              });
              _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
            }
            // no match found
            else {
              _fromDate = DateTime(_fromDate.year, _fromDate.month, _fromDate.day + 1, _fromDate.hour, _fromDate.minute);
            }
          }
          if (mounted) {
            Navigator.pop<bool>(context, true);
          }
        }
      }
    }
  }

  // used for ranged dates
  int _numOfDaysBetweenDates(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}