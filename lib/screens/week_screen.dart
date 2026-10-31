import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../logic/course_logic.dart';
import '../logic/time_helper.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';
import 'course_form_screen.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  String _selectedDay = 'Monday';

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  final Map<String, String> _dayShortNames = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
  };

  void _showMessage(String message, {Color? background}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
  }

  void _showError(String action, Object error) {
    _showMessage(
      'Could not $action.\n$error',
      background: Colors.red.shade700,
    );
  }

  Future<void> _addCourse(List<Course> currentCourses) async {
    final result = await Navigator.push<Course>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseFormScreen(initialDay: _selectedDay),
      ),
    );
    if (result == null || !mounted) return;

    final collection = myCourses();
    if (collection == null) {
      _showError('add ${result.name}', 'You are not signed in.');
      return;
    }

    try {
      await collection.add({
        ...result.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;

      final clashing = getClashNames(result, currentCourses);
      if (clashing.isNotEmpty) {
        _showMessage(
          'Added ${result.name}, but it clashes with ${clashing.join(', ')}!',
          background: Colors.orange.shade800,
        );
      } else {
        _showMessage('${result.name} added successfully.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('add ${result.name}', e);
    }
  }

  Future<void> _editCourse(Course course) async {
    final result = await Navigator.push<Course>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseFormScreen(courseToEdit: course),
      ),
    );
    if (result == null || !mounted) return;

    final collection = myCourses();
    if (collection == null) {
      _showError('update ${course.name}', 'You are not signed in.');
      return;
    }

    try {
      await collection.doc(course.id).update(result.toMap());
      if (!mounted) return;
      _showMessage('${result.name} updated successfully.');
    } catch (e) {
      if (!mounted) return;
      _showError('update ${course.name}', e);
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final collection = myCourses();
    if (collection == null) {
      _showError('delete ${course.name}', 'You are not signed in.');
      return;
    }

    try {
      await collection.doc(course.id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${course.name} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.amber,
            onPressed: () async {
              try {
                await collection.doc(course.id).set({
                  ...course.toMap(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                _showMessage('${course.name} restored.');
              } catch (e) {
                if (!mounted) return;
                _showError('restore ${course.name}', e);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('delete ${course.name}', e);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildContent(List<Course> allCourses) {
    final dayCourses = getCoursesForDay(allCourses, _selectedDay);
    final dayMinutes = calculateTotalMinutesForDay(dayCourses);
    final dayHoursText = minutesToFormattedHours(dayMinutes);

    final weekMinutes = calculateTotalMinutesForWeek(allCourses);
    final weekHoursText = minutesToFormattedHours(weekMinutes);
    final totalClashes = getTotalClashesInWeek(allCourses);

    final freeSlots = findFreeTimeSlots(dayCourses);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'My Week',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekly Summary Banner
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Total Class Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weekHoursText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${allCourses.length} courses total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (totalClashes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$totalClashes clash${totalClashes > 1 ? 'es' : ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'No clashes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Day Chips Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _days.map((day) {
                final isSelected = day == _selectedDay;
                final dayCourseList = getCoursesForDay(allCourses, day);
                final hasDayClash = dayCourseList
                    .any((c) => getClashNames(c, allCourses).isNotEmpty);

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dayShortNames[day] ?? day,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (hasDayClash
                                  ? Colors.red.shade700
                                  : Colors.black87),
                        ),
                      ),
                      if (dayCourseList.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : (hasDayClash
                                    ? Colors.red.shade100
                                    : Colors.indigo.shade50),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${dayCourseList.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (hasDayClash
                                      ? Colors.red.shade900
                                      : Colors.indigo.shade800),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: Colors.indigo,
                  backgroundColor: hasDayClash
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.indigo
                        : (hasDayClash
                            ? Colors.red.shade300
                            : Colors.grey.shade300),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDay = day;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),

          // Selected Day Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                Text(
                  'Total class time: $dayHoursText',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),

          // Free time banner if free slots exist
          if (freeSlots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: freeSlots.map((slot) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '🌱 Free: ${slot.startTime}–${slot.endTime} (${minutesToFormattedHours(slot.durationMinutes)})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // List of courses or Empty State
          Expanded(
            child: dayCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 72,
                          color: Colors.indigo.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No classes on $_selectedDay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + below to add a class to $_selectedDay',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: dayCourses.length,
                    itemBuilder: (context, index) {
                      final course = dayCourses[index];
                      return CourseCard(
                        course: course,
                        allCourses: allCourses,
                        onTap: () => _editCourse(course),
                        onDelete: () => _deleteCourse(course),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCourse(allCourses),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.indigo,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'My Week',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = myCourses();
    if (collection == null) {
      return _buildStatus(
        icon: Icons.lock_outline_rounded,
        title: 'You are signed out',
        subtitle: 'Log in again to see your week.',
        color: Colors.orange.shade700,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatus(
            icon: Icons.hourglass_empty_rounded,
            title: 'Loading your week...',
            subtitle: 'Fetching your courses from Firestore.',
          );
        }

        if (snapshot.hasError) {
          return _buildStatus(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load your courses',
            subtitle: '${snapshot.error}',
            color: Colors.red.shade700,
          );
        }

        final allCourses =
            (snapshot.data?.docs ?? []).map((doc) => Course.fromDoc(doc)).toList();

        return _buildContent(allCourses);
      },
    );
  }
}
