class Category {
  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.providersCount,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final int? providersCount;

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'] as int,
        name: j['name'] as String,
        slug: j['slug'] as String,
        description: j['description'] as String?,
        iconUrl: j['icon_url'] as String?,
        imageUrl: j['image_url'] as String?,
        sortOrder: (j['sort_order'] as int?) ?? 0,
        isActive: (j['is_active'] as bool?) ?? true,
        providersCount: j['providers_count'] as int?,
      );
}
