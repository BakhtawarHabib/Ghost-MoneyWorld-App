class CategoryModel {
  final String id;
  final String legacyId;
  final String title;
  final String description;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.legacyId,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, {String? docId}) {
    final firestoreDocId = (docId ?? '').toString();
    final resolvedTitle =
        (data['title'] ?? data['name'] ?? '').toString().trim();
    return CategoryModel(
      // Enforce Firestore document id as the primary category id.
      id: firestoreDocId,
      // Keep optional legacy/custom id from payload for backward visibility.
      legacyId: (data['id'] ?? '').toString(),
      // Support both "title" and "name" keys from Firestore payloads.
      title: resolvedTitle,
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? false,
    );
  }
}
