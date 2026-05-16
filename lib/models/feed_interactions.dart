import 'package:ghost_money_world/models/feed_comment.dart';

class FeedInteractions {
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool likedByMe;
  final List<FeedComment> comments;

  const FeedInteractions({
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likedByMe = false,
    this.comments = const [],
  });

  factory FeedInteractions.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    return FeedInteractions(
      likeCount: _asInt(json['likeCount']),
      commentCount: _asInt(json['commentCount']),
      shareCount: _asInt(json['shareCount']),
      likedByMe: json['likedByMe'] == true,
      comments:
          rawComments is List
              ? rawComments
                  .whereType<Map>()
                  .map(
                    (e) => FeedComment.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : const [],
    );
  }

  FeedInteractions copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? likedByMe,
    List<FeedComment>? comments,
  }) {
    return FeedInteractions(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likedByMe: likedByMe ?? this.likedByMe,
      comments: comments ?? this.comments,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
