import 'provider_media.dart';

/// Full provider returned by `/providers/{slug}`.
class ProviderDetails {
  ProviderDetails({
    required this.id,
    required this.name,
    required this.slug,
    required this.areaType,
    required this.isFeatured,
    this.description,
    this.shortDescription,
    this.phone,
    this.whatsapp,
    this.address,
    this.locationUrl,
    this.workingHours,
    this.coverImageUrl,
    this.logoUrl,
    this.categoryName,
    this.categorySlug,
    this.gallery = const [],
    this.menu = const [],
    this.products = const [],
    this.banners = const [],
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? locationUrl;
  final String? workingHours;
  final String? coverImageUrl;
  final String? logoUrl;
  final String areaType;
  final bool isFeatured;
  final String? categoryName;
  final String? categorySlug;
  final List<ProviderMedia> gallery;
  final List<ProviderMedia> menu;
  final List<ProviderMedia> products;
  final List<ProviderMedia> banners;

  bool get isInsideCompound => areaType == 'inside_compound';
  bool get hasGallery => gallery.isNotEmpty;
  bool get hasMenu => menu.isNotEmpty;
  bool get hasProducts => products.isNotEmpty;

  factory ProviderDetails.fromJson(Map<String, dynamic> j) {
    final cat = j['category'] as Map<String, dynamic>?;
    List<ProviderMedia> mediaList(String key) {
      final list = j[key] as List?;
      if (list == null) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ProviderMedia.fromJson)
          .toList();
    }

    return ProviderDetails(
      id: j['id'] as int,
      name: j['name'] as String,
      slug: j['slug'] as String,
      description: j['description'] as String?,
      shortDescription: j['short_description'] as String?,
      phone: j['phone'] as String?,
      whatsapp: j['whatsapp'] as String?,
      address: j['address'] as String?,
      locationUrl: j['location_url'] as String?,
      workingHours: j['working_hours'] as String?,
      coverImageUrl: j['cover_image_url'] as String?,
      logoUrl: j['logo_url'] as String?,
      areaType: (j['area_type'] as String?) ?? 'inside_compound',
      isFeatured: (j['is_featured'] as bool?) ?? false,
      categoryName: cat?['name'] as String?,
      categorySlug: cat?['slug'] as String?,
      gallery: mediaList('gallery'),
      menu: mediaList('menu'),
      products: mediaList('products'),
      banners: mediaList('banners'),
    );
  }
}
