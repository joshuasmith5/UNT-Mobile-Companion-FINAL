import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String userId;
  final String title;
  final DateTime from;
  final DateTime to;
  final String? description;
  final String? course;
  final String? section;
  final String? professor;
  final List<dynamic>? meetingDays;
  final String? recurrenceId;
  final DateTime until;
  final String? roomNumber;

  Event({
    required this.id,
    required this.userId,
    required this. title,
    required this.from,
    required this.to,
    this.description,
    this.course,
    this.section,
    this.professor,
    this.meetingDays,
    this.recurrenceId,
    required this.until,
    this.roomNumber
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      id: snapshot.id,
      userId: data['user_id'],
      title: data['title'],
      from: data['from'].toDate(),
      to: data['to'].toDate(),
      description: data['description'],
      course: data['course'],
      section: data['section'],
      professor: data['professor'],
      meetingDays: data['meeting_days'], // Firebase to List
      recurrenceId: data['recurrence_id'],
      until: data['until'].toDate(),
      roomNumber: data['room_number']
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "user_id": userId,
      "title": title,
      "from": Timestamp.fromDate(from),
      "to": Timestamp.fromDate(to),
      "description": description,
      "course": course,
      "section": section,
      "professor": professor,
      "meeting_days": meetingDays, // List to Firebase array
      "recurrence_id": recurrenceId,
      "until": Timestamp.fromDate(until),
      "room_number": roomNumber
    };
  }
}