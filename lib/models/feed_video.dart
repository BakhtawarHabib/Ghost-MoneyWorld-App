class FeedVideo {
  final String id;
  final String title;
  final String description;
  final String playbackId;
  final String thumbnail;
  final String aspectRatio;
  final DateTime? createdAt;

  const FeedVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.playbackId,
    required this.thumbnail,
    this.aspectRatio = '9:16',
    this.createdAt,
  });

  String get streamUrl => 'https://stream.mux.com/$playbackId.m3u8';

  factory FeedVideo.fromJson(Map<String, dynamic> json) {
    final playbackId = json['playbackId']?.toString() ?? '';
    final thumb = json['thumbnail']?.toString() ?? '';
    return FeedVideo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      playbackId: playbackId,
      thumbnail:
          thumb.isNotEmpty
              ? thumb
              : (playbackId.isNotEmpty
                  ? 'https://image.mux.com/$playbackId/thumbnail.png?width=540&height=960&fit_mode=preserve'
                  : ''),
      aspectRatio: json['aspectRatio']?.toString() ?? '9:16',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
