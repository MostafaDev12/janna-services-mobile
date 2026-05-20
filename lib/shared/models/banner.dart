class HomeBanner {
  HomeBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.linkUrl,
    this.providerSlug,
    this.providerName,
    this.sortOrder = 0,
  });

  final int id;
  final String? title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final String? providerSlug;
  final String? providerName;
  final int sortOrder;

  factory HomeBanner.fromJson(Map<String, dynamic> j) {
    final p = j['provider'] as Map<String, dynamic>?;
    return HomeBanner(
      id: j['id'] as int,
      title: j['title'] as String?,
      subtitle: j['subtitle'] as String?,
      imageUrl: (j['image_url'] as String?) ?? '',
      linkUrl: j['link_url'] as String?,
      providerSlug: p?['slug'] as String?,
      providerName: p?['name'] as String?,
      sortOrder: (j['sort_order'] as int?) ?? 0,
    );
  }
}
