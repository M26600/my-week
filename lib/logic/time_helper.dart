int? timeToMinutes(String timeStr) {
  final trimmed = timeStr.trim();
  final regExp = RegExp(r'^(\d{1,2}):(\d{2})$');
  final match = regExp.firstMatch(trimmed);

  if (match == null) return null;

  final hours = int.tryParse(match.group(1)!);
  final minutes = int.tryParse(match.group(2)!);

  if (hours == null || minutes == null) return null;
  if (hours < 0 || hours > 23) return null;
  if (minutes < 0 || minutes > 59) return null;

  return hours * 60 + minutes;
}

String? validateTimeFormat(String timeStr) {
  final trimmed = timeStr.trim();
  if (trimmed.isEmpty) {
    return 'Time cannot be empty';
  }

  final regExp = RegExp(r'^(\d{1,2}):(\d{2})$');
  final match = regExp.firstMatch(trimmed);

  if (match == null) {
    return 'Use HH:MM format (e.g. 08:30)';
  }

  final hours = int.tryParse(match.group(1)!);
  final minutes = int.tryParse(match.group(2)!);

  if (hours == null || hours < 0 || hours > 23) {
    return 'Hours must be between 00 and 23';
  }

  if (minutes == null || minutes < 0 || minutes > 59) {
    return 'Minutes must be between 00 and 59';
  }

  return null;
}

String normalizeTimeString(String timeStr) {
  final trimmed = timeStr.trim();
  final regExp = RegExp(r'^(\d{1,2}):(\d{2})$');
  final match = regExp.firstMatch(trimmed);
  if (match == null) return timeStr;

  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);

  final hStr = hours.toString().padLeft(2, '0');
  final mStr = minutes.toString().padLeft(2, '0');
  return '$hStr:$mStr';
}

String minutesToFormattedHours(int totalMinutes) {
  if (totalMinutes <= 0) return '0m';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours > 0 && minutes > 0) {
    return '${hours}h ${minutes}m';
  } else if (hours > 0) {
    return '${hours}h';
  } else {
    return '${minutes}m';
  }
}

String formatMinutesToTime(int totalMinutes) {
  final hours = (totalMinutes ~/ 60) % 24;
  final minutes = totalMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}
