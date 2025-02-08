enum CheckInType {
  onTime,
  late,
}

class EmotionCheckIn {
  final String userName;
  final DateTime checkInTime;
  final String emoji;
  final String label;
  final String feeling;
  final CheckInType checkInType;

  EmotionCheckIn({
    required this.userName,
    required this.checkInTime,
    required this.emoji,
    required this.label,
    required this.feeling,
    required this.checkInType,
  });
}