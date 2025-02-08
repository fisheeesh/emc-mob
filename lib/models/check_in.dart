class CheckIn {
  final DateTime timestamp;

  CheckIn({required this.timestamp});

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    try {
      String timestampStr = json['timestamp'] ?? '';
      DateTime dateTime = DateTime.parse(timestampStr).toLocal();

      return CheckIn(timestamp: dateTime);
    } catch (e) {
      throw FormatException("Invalid timestamp format: ${json['timestamp']}");
    }
  }

  @override
  String toString() {
    return 'CheckIn(Timestamp: $timestamp)';
  }
}