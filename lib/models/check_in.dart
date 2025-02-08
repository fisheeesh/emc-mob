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

  /// Converts a CheckIn object to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(), // Store in UTC format
    };
  }

  @override
  String toString() {
    return 'CheckIn(Timestamp: $timestamp)';
  }
}