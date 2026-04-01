class VideoModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String thumbnail;
  final String playbackId;
  final String muxAssetId;
  final String status;
  final String duration;
  final String source;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    required this.thumbnail,
    required this.playbackId,
    required this.muxAssetId,
    required this.status,
    required this.duration,
    required this.source,
  });

  String get resolvedVideoUrl {
    if (playbackId.isNotEmpty) return "https://stream.mux.com/$playbackId.m3u8";
    return '';
  }

  String get resolvedThumbnail {
    if (playbackId.isNotEmpty) {
      return "https://image.mux.com/$playbackId/thumbnail.jpg?width=640&height=360";
    }
    return '';
  }

  bool get isMuxReady {
    if (playbackId.isEmpty) return false;
    if (status.isEmpty) return true;
    return status.toLowerCase() == 'ready';
  }

  factory VideoModel.fromMap(Map<String, dynamic> data, {String? docId}) {
    return VideoModel(
      id: (data['id'] ?? docId ?? '').toString(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      videoUrl: (data['video'] ?? data['videoUrl'] ?? '').toString(),
      thumbnail: data['thumbnail'] ?? '',
      playbackId: (data['playbackId'] ?? '').toString(),
      muxAssetId: (data['muxAssetId'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      duration: (data['duration'] ?? '').toString(),
      source: (data['source'] ?? '').toString(),
    );
  }
}
