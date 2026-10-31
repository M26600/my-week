import 'package:flutter_test/flutter_test.dart';
import 'package:my_week/models/course.dart';
import 'package:my_week/logic/time_helper.dart';
import 'package:my_week/logic/course_logic.dart';

void main() {
  group('Time Helper Tests', () {
    test('timeToMinutes converts valid HH:MM correctly', () {
      expect(timeToMinutes('08:00'), 480);
      expect(timeToMinutes('08:30'), 510);
      expect(timeToMinutes('00:00'), 0);
      expect(timeToMinutes('23:59'), 1439);
    });

    test('timeToMinutes returns null for invalid formats', () {
      expect(timeToMinutes('8h'), isNull);
      expect(timeToMinutes('25:00'), isNull);
      expect(timeToMinutes('10:75'), isNull);
      expect(timeToMinutes(''), isNull);
      expect(timeToMinutes('abc'), isNull);
    });

    test('validateTimeFormat reports correct errors', () {
      expect(validateTimeFormat(''), 'Time cannot be empty');
      expect(validateTimeFormat('8h'), 'Use HH:MM format (e.g. 08:30)');
      expect(validateTimeFormat('25:00'), 'Hours must be between 00 and 23');
      expect(validateTimeFormat('10:75'), 'Minutes must be between 00 and 59');
      expect(validateTimeFormat('08:30'), isNull);
    });

    test('minutesToFormattedHours formats durations properly', () {
      expect(minutesToFormattedHours(210), '3h 30m');
      expect(minutesToFormattedHours(120), '2h');
      expect(minutesToFormattedHours(45), '45m');
      expect(minutesToFormattedHours(0), '0m');
    });
  });

  group('Course Logic Tests', () {
    test('Clash condition - overlapping courses clash', () {
      final c1 = Course(
        id: '1',
        name: 'Mathematics',
        day: 'Monday',
        startTime: '08:00',
        endTime: '10:00',
      );
      final c2 = Course(
        id: '2',
        name: 'Physics',
        day: 'Monday',
        startTime: '09:00',
        endTime: '11:00',
      );

      expect(doCoursesClash(c1, c2), isTrue);
    });

    test('Clash condition - back-to-back courses do NOT clash', () {
      final c1 = Course(
        id: '1',
        name: 'Mathematics',
        day: 'Monday',
        startTime: '08:00',
        endTime: '10:00',
      );
      final c2 = Course(
        id: '2',
        name: 'Physics',
        day: 'Monday',
        startTime: '10:00',
        endTime: '11:30',
      );

      expect(doCoursesClash(c1, c2), isFalse);
    });

    test('Clash condition - courses on different days do NOT clash', () {
      final c1 = Course(
        id: '1',
        name: 'Mathematics',
        day: 'Monday',
        startTime: '08:00',
        endTime: '10:00',
      );
      final c2 = Course(
        id: '2',
        name: 'Physics',
        day: 'Tuesday',
        startTime: '08:00',
        endTime: '10:00',
      );

      expect(doCoursesClash(c1, c2), isFalse);
    });

    test('getCoursesForDay sorts courses chronologically by start time', () {
      final courses = [
        Course(
          id: '1',
          name: 'Programming',
          day: 'Monday',
          startTime: '11:00',
          endTime: '13:00',
        ),
        Course(
          id: '2',
          name: 'Mathematics',
          day: 'Monday',
          startTime: '08:00',
          endTime: '10:00',
        ),
        Course(
          id: '3',
          name: 'Physics',
          day: 'Monday',
          startTime: '09:00',
          endTime: '11:00',
        ),
      ];

      final sorted = getCoursesForDay(courses, 'Monday');
      expect(sorted.map((c) => c.name).toList(), [
        'Mathematics',
        'Physics',
        'Programming',
      ]);
    });

    test('calculateTotalMinutesForDay calculates duration sum', () {
      final dayCourses = [
        Course(
          id: '1',
          name: 'Mathematics',
          day: 'Monday',
          startTime: '08:00',
          endTime: '10:00',
        ), // 2h = 120m
        Course(
          id: '2',
          name: 'Physics',
          day: 'Monday',
          startTime: '10:00',
          endTime: '11:30',
        ), // 1.5h = 90m
      ];

      expect(calculateTotalMinutesForDay(dayCourses), 210); // 3h 30m
    });

    test('validateCourseInputs checks required rules', () {
      // Empty name
      expect(
        validateCourseInputs(
          name: '',
          startTime: '08:00',
          endTime: '10:00',
        ),
        'Course name cannot be empty',
      );

      // End time before start time
      expect(
        validateCourseInputs(
          name: 'Math',
          startTime: '10:00',
          endTime: '08:00',
        ),
        'End time must be after start time',
      );

      // Same start and end time
      expect(
        validateCourseInputs(
          name: 'Math',
          startTime: '10:00',
          endTime: '10:00',
        ),
        'End time must be after start time',
      );

      // Valid
      expect(
        validateCourseInputs(
          name: 'Math',
          startTime: '08:00',
          endTime: '10:00',
        ),
        isNull,
      );
    });
  });
}
