/// Provider as returned by list endpoints (cards, search, related).
class ProviderSummary {
  ProviderSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.areaType,
    required this.isFeatured,
    this.shortDescription,
    this.phone,
    this.whatsapp,
    this.address,
    this.workingHours,
    this.coverImageUrl,
    this.logoUrl,
    this.categoryName,
    this.categorySlug,
  });

  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? workingHours;
  final String? coverImageUrl;
  final String? logoUrl;
  final String areaType;
  final bool isFeatured;
  final String? categoryName;
  final String? categorySlug;

  bool get isInsideCompound => areaType == 'inside_compound';

  factory ProviderSummary.fromJson(Map<String, dynamic> j) {
    final cat = j['category'] as Map<String, dynamic>?;
    return ProviderSummary(
      id: j['id'] as int,
      name: j['name'] as String,
      slug: j['slug'] as String,
      shortDescription: j['short_description'] as String?,
      phone: j['phone'] as String?,
      whatsapp: j['whatsapp'] as String?,
      address: j['address'] as String?,
      workingHours: j['working_hours'] as String?,
      coverImageUrl: j['cover_image_url'] as String?,
      logoUrl: j['logo_url'] as String?,
      areaType: (j['area_type'] as String?) ?? 'inside_compound',
      isFeatured: (j['is_featured'] as bool?) ?? false,
      categoryName: cat?['name'] as String?,
      categorySlug: cat?['slug'] as String?,
    );
  }
}
