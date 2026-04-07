/// Firestore `liveStreams` document (Mux live).
class LiveStreamModel {
  final String id;
  final String title;
  final String description;
  final String playbackId;
  final String muxLiveStreamId;
  final String status;
  final String streamKey;
  final String createdBy;
  /// Optional custom poster (e.g. Firebase Storage URL from Firestore).
  final String thumbnail;

  LiveStreamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.playbackId,
    required this.muxLiveStreamId,
    required this.status,
    required this.streamKey,
    required this.createdBy,
    required this.thumbnail,
  });

  /// Mux HLS playback URL (same pattern as on-demand).
  String get hlsUrl {
    if (playbackId.isEmpty) return '';
    return 'https://stream.mux.com/$playbackId.m3u8';
  }

  String get thumbnailUrl {
    final custom = thumbnail.trim();
    if (custom.isNotEmpty) return custom;
    if (playbackId.isEmpty) return '';
    return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=640&height=360';
  }

  bool get canPlay => playbackId.isNotEmpty;

  /// Treat as actively broadcasting when Mux reports live.
  bool get isLiveNow {
    final s = status.toLowerCase();
    return s == 'active' || s == 'live' || s == 'broadcasting';
  }

  /// Firestore status values where there is no live feed to play yet (skip ExoPlayer).
  static bool statusMeansNoBroadcast(String raw) {
    final t = raw.toLowerCase().trim();
    if (t.isEmpty) return false;
    const off = {
      'idle',
      'disconnected',
      'disabled',
      'offline',
      'ended',
      'waiting',
    };
    return off.contains(t);
  }

  factory LiveStreamModel.fromMap(Map<String, dynamic> data, {String? docId}) {
    return LiveStreamModel(
      id: docId ?? (data['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      playbackId: (data['playbackId'] ?? '').toString(),
      muxLiveStreamId: (data['muxLiveStreamId'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      streamKey: (data['streamKey'] ?? '').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
      thumbnail: (data['thumbnail'] ?? '').toString(),
    );
  }
}
