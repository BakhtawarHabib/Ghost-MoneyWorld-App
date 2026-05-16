class FeedComment {
  final String id;
  final String uid;
  final String displayName;
  final String text;
  final DateTime? createdAt;

  const FeedComment({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.text,
    this.createdAt,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) {
    return FeedComment(
      id: json['id']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'User',
      text: json['text']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
