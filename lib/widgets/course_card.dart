import 'package:flutter/material.dart';
import '../models/course.dart';
import '../logic/course_logic.dart';
import '../logic/time_helper.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final List<Course> allCourses;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.allCourses,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final clashingNames = getClashNames(course, allCourses);
    final hasClash = clashingNames.isNotEmpty;

    final startMins = timeToMinutes(course.startTime) ?? 0;
    final endMins = timeToMinutes(course.endTime) ?? 0;
    final durationMins = endMins > startMins ? endMins - startMins : 0;
    final durationText = minutesToFormattedHours(durationMins);

    final cardColor = hasClash ? const Color(0xFFFFF2F2) : Colors.white;
    final borderColor = hasClash ? Colors.red.shade400 : Colors.indigo.shade100;
    final accentColor = hasClash ? Colors.red.shade700 : Colors.indigo.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: hasClash ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasClash
                            ? Colors.red.shade100
                            : Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasClash ? Icons.warning_rounded : Icons.book_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hasClash
                                  ? Colors.red.shade900
                                  : const Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: hasClash
                                    ? Colors.red.shade700
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${normalizeTimeString(course.startTime)} – ${normalizeTimeString(course.endTime)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: hasClash
                                      ? Colors.red.shade800
                                      : Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasClash
                                      ? Colors.red.shade200
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  durationText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: hasClash
                                        ? Colors.red.shade900
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: hasClash ? Colors.red : Colors.grey.shade600,
                      tooltip: 'Delete course',
                      onPressed: onDelete,
                    ),
                  ],
                ),
                if (hasClash) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Clashes with ${clashingNames.join(', ')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
