import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/sample_courses.dart';

class Course {
  String id;
  String name;
  String day;
  String startTime;
  String endTime;
  DateTime? createdAt;

  Course({
    String? id,
    required this.name,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.createdAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Course copyWith({
    String? id,
    String? name,
    String? day,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Course(
      id: doc.id,
      name: data['name'] as String? ?? '',
      day: data['day'] as String? ?? 'Monday',
      startTime: data['startTime'] as String? ?? '08:00',
      endTime: data['endTime'] as String? ?? '10:00',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// Safely returns the signed-in user's courses collection: users/{uid}/courses
CollectionReference<Map<String, dynamic>>? myCourses() {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('courses');
  } catch (e) {
    debugPrint('myCourses exception: $e');
    return null;
  }
}

// Writes sample courses for a newly created account
Future<void> addSampleCourses() async {
  final collection = myCourses();
  if (collection == null) return;

  final samples = List<Course>.from(sampleCourses);
  final batch = FirebaseFirestore.instance.batch();

  for (final course in samples) {
    batch.set(collection.doc(), {
      ...course.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
}
