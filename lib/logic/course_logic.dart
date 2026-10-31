import '../models/course.dart';
import 'time_helper.dart';

bool doCoursesClash(Course c1, Course c2) {
  if (c1.day != c2.day) return false;
  if (c1.id == c2.id) return false;

  final start1 = timeToMinutes(c1.startTime);
  final end1 = timeToMinutes(c1.endTime);
  final start2 = timeToMinutes(c2.startTime);
  final end2 = timeToMinutes(c2.endTime);

  if (start1 == null || end1 == null || start2 == null || end2 == null) {
    return false;
  }

  // Clash condition: two courses on the same day clash if each starts before the other ends
  return start1 < end2 && start2 < end1;
}

List<Course> getClashingCourses(Course target, List<Course> allCourses) {
  return allCourses.where((c) => doCoursesClash(target, c)).toList();
}

List<String> getClashNames(Course target, List<Course> allCourses) {
  return getClashingCourses(target, allCourses).map((c) => c.name).toList();
}

List<Course> getCoursesForDay(List<Course> allCourses, String day) {
  final dayCourses = allCourses.where((c) => c.day == day).toList();
  dayCourses.sort((a, b) {
    final startA = timeToMinutes(a.startTime) ?? 0;
    final startB = timeToMinutes(b.startTime) ?? 0;
    if (startA != startB) {
      return startA.compareTo(startB);
    }
    final endA = timeToMinutes(a.endTime) ?? 0;
    final endB = timeToMinutes(b.endTime) ?? 0;
    return endA.compareTo(endB);
  });
  return dayCourses;
}

int calculateTotalMinutesForDay(List<Course> dayCourses) {
  int total = 0;
  for (final course in dayCourses) {
    final start = timeToMinutes(course.startTime);
    final end = timeToMinutes(course.endTime);
    if (start != null && end != null && end > start) {
      total += (end - start);
    }
  }
  return total;
}

int calculateTotalMinutesForWeek(List<Course> allCourses) {
  int total = 0;
  for (final course in allCourses) {
    final start = timeToMinutes(course.startTime);
    final end = timeToMinutes(course.endTime);
    if (start != null && end != null && end > start) {
      total += (end - start);
    }
  }
  return total;
}

int getTotalClashesInWeek(List<Course> allCourses) {
  final clashingIds = <String>{};
  for (int i = 0; i < allCourses.length; i++) {
    for (int j = i + 1; j < allCourses.length; j++) {
      if (doCoursesClash(allCourses[i], allCourses[j])) {
        clashingIds.add(allCourses[i].id);
        clashingIds.add(allCourses[j].id);
      }
    }
  }
  return clashingIds.length;
}

class FreeTimeSlot {
  final String startTime;
  final String endTime;
  final int durationMinutes;

  FreeTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });
}

List<FreeTimeSlot> findFreeTimeSlots(List<Course> sortedDayCourses) {
  final slots = <FreeTimeSlot>[];
  if (sortedDayCourses.length < 2) return slots;

  for (int i = 0; i < sortedDayCourses.length - 1; i++) {
    final currentEnd = timeToMinutes(sortedDayCourses[i].endTime);
    final nextStart = timeToMinutes(sortedDayCourses[i + 1].startTime);

    if (currentEnd != null && nextStart != null && nextStart > currentEnd) {
      slots.add(FreeTimeSlot(
        startTime: normalizeTimeString(sortedDayCourses[i].endTime),
        endTime: normalizeTimeString(sortedDayCourses[i + 1].startTime),
        durationMinutes: nextStart - currentEnd,
      ));
    }
  }
  return slots;
}

String? validateCourseInputs({
  required String name,
  required String startTime,
  required String endTime,
}) {
  if (name.trim().isEmpty) {
    return 'Course name cannot be empty';
  }

  final startErr = validateTimeFormat(startTime);
  if (startErr != null) {
    return 'Start time: $startErr';
  }

  final endErr = validateTimeFormat(endTime);
  if (endErr != null) {
    return 'End time: $endErr';
  }

  final startMins = timeToMinutes(startTime)!;
  final endMins = timeToMinutes(endTime)!;

  if (endMins <= startMins) {
    return 'End time must be after start time';
  }

  return null;
}
