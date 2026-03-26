class VideoModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String thumbnail;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    required this.thumbnail,
  });

  factory VideoModel.fromMap(Map<String, dynamic> data) {
    return VideoModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      videoUrl: data['video'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
    );
  }
}
