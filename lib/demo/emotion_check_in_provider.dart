import 'package:emotion_check_in_app/demo/emotion_check_in.dart';
import 'package:flutter/material.dart';

class EmotionCheckInProvider with ChangeNotifier {
  final List<EmotionCheckIn> _checkInList = [
    EmotionCheckIn(
      userName: "Swam Yi Phyo",
      checkInTime: DateTime(2025, 1, 22, 8, 45),
      emoji: "😊",
      label: "Happy",
      feeling: "Feeling great today!",
      checkInType: CheckInType.onTime,
    ),
    EmotionCheckIn(
      userName: "Swam Yi Phyo",
      checkInTime: DateTime(2025, 1, 24, 10, 15),
      emoji: "😟",
      label: "Stressed",
      feeling: "Feeling overwhelmed.",
      checkInType: CheckInType.late,
    ),
    EmotionCheckIn(
      userName: "Swam Yi Phyo",
      checkInTime: DateTime(2025, 1, 25, 8, 50),
      emoji: "😊",
      label: "Content",
      feeling: "All good.",
      checkInType: CheckInType.onTime,
    ),
    EmotionCheckIn(
      userName: "Swam Yi Phyo",
      checkInTime: DateTime(2025, 1, 26, 11, 0),
      emoji: "😴",
      label: "Tired",
      feeling: "Didn't sleep well.",
      checkInType: CheckInType.late,
    ),
    EmotionCheckIn(
      userName: "Swam Yi Phyo",
      checkInTime: DateTime(2025, 1, 27, 8, 20),
      emoji: "😀",
      label: "Excited",
      feeling: "Looking forward to the day!",
      checkInType: CheckInType.onTime,
    ),
  ];

  List<EmotionCheckIn> get checkInList => _checkInList;

  /// Retrieves today's check-in by searching for a matching date in the check-in list.
  /// Uses firstWhere() to find the first matching check-in.
  /// If no match is found, orElse ensures null is returned instead of throwing an error.
  EmotionCheckIn? get todayCheckIn {
    final today = DateTime.now();
    return _checkInList.cast<EmotionCheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.checkInTime.day == today.day &&
          checkIn.checkInTime.month == today.month &&
          checkIn.checkInTime.year == today.year,
      orElse: () => null,
    );
  }

  /// Add a new check-in data
  void addCheckIn(String userName, DateTime checkInTime, String emoji, String label, String feeling) {
    final checkInType = _determineCheckInType(checkInTime);
    final newCheckIn = EmotionCheckIn(
      userName: userName,
      checkInTime: checkInTime,
      emoji: emoji,
      label: label,
      feeling: feeling,
      checkInType: checkInType,
    );

    _checkInList.add(newCheckIn);
    notifyListeners();
  }

  /// Get a check-in data for a specific date
  EmotionCheckIn? getCheckInByDate(DateTime date) {
    return _checkInList.cast<EmotionCheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.checkInTime.day == date.day &&
          checkIn.checkInTime.month == date.month &&
          checkIn.checkInTime.year == date.year,
      orElse: () => null,
    );
  }

  /// Determine if the check-in is on time or late
  CheckInType _determineCheckInType(DateTime checkInTime) {
    final today = DateTime(checkInTime.year, checkInTime.month, checkInTime.day);
    final onTimeEnd = DateTime(today.year, today.month, today.day, 9, 30);
    return checkInTime.isBefore(onTimeEnd) ? CheckInType.onTime : CheckInType.late;
  }
}