class ProviderMedia {
  ProviderMedia({
    required this.id,
    required this.type,
    required this.imageUrl,
    this.title,
    this.sortOrder = 0,
  });

  final int id;

  /// One of: gallery, menu, product, cover, banner.
  final String type;
  final String? title;
  final String imageUrl;
  final int sortOrder;

  factory ProviderMedia.fromJson(Map<String, dynamic> j) => ProviderMedia(
        id: j['id'] as int,
        type: (j['type'] as String?) ?? 'gallery',
        title: j['title'] as String?,
        imageUrl: (j['image_url'] as String?) ?? '',
        sortOrder: (j['sort_order'] as int?) ?? 0,
      );
}
