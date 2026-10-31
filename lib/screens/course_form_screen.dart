import 'package:flutter/material.dart';
import '../models/course.dart';
import '../logic/course_logic.dart';
import '../logic/time_helper.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? courseToEdit;
  final String initialDay;

  const CourseFormScreen({
    super.key,
    this.courseToEdit,
    this.initialDay = 'Monday',
  });

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _nameController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  late String _selectedDay;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      final c = widget.courseToEdit!;
      _nameController.text = c.name;
      _selectedDay = c.day;
      _startTimeController.text = c.startTime;
      _endTimeController.text = c.endTime;
    } else {
      _selectedDay = _days.contains(widget.initialDay)
          ? widget.initialDay
          : 'Monday';
      _startTimeController.text = '08:00';
      _endTimeController.text = '10:00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _saveCourse() {
    final name = _nameController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();

    final errorMsg = validateCourseInputs(
      name: name,
      startTime: startTime,
      endTime: endTime,
    );

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final normalizedStart = normalizeTimeString(startTime);
    final normalizedEnd = normalizeTimeString(endTime);

    final resultCourse = Course(
      id: widget.courseToEdit?.id,
      name: name,
      day: _selectedDay,
      startTime: normalizedStart,
      endTime: normalizedEnd,
    );

    Navigator.pop(context, resultCourse);
  }

  void _selectTime(TextEditingController controller) async {
    final initialStr = controller.text.trim();
    final initialMins = timeToMinutes(initialStr) ?? 8 * 60;
    final initialTime = TimeOfDay(
      hour: initialMins ~/ 60,
      minute: initialMins % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hStr = picked.hour.toString().padLeft(2, '0');
      final mStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hStr:$mStr';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.courseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Course' : 'Add New Course',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                hintText: 'e.g. Mathematics, Programming',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Day of the Week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDay,
                  isExpanded: true,
                  icon: const Icon(Icons.calendar_today_rounded,
                      color: Colors.indigo),
                  items: _days.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDay = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Time (HH:MM)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _startTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: '08:00',
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time_filled),
                            onPressed: () => _selectTime(_startTimeController),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Time (HH:MM)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _endTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: '10:00',
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time_filled),
                            onPressed: () => _selectTime(_endTimeController),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  isEditing ? 'Update Course' : 'Add Course',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
