class CategoryModel {
  final String id;
  final String title;
  final String description;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? false,
    );
  }
}
