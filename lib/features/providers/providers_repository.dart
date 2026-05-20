import '../../core/network/api_client.dart';
import '../../shared/models/paginated.dart';
import '../../shared/models/provider_details.dart';
import '../../shared/models/provider_summary.dart';

class ProvidersRepository {
  ProvidersRepository([ApiClient? client])
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Paginated<ProviderSummary>> list({
    int page = 1,
    String? categorySlug,
    String? areaType,
    bool featured = false,
    String? keyword,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query['category'] = categorySlug;
    }
    if (areaType != null && areaType.isNotEmpty) {
      query['area_type'] = areaType;
    }
    if (featured) query['featured'] = '1';
    if (keyword != null && keyword.isNotEmpty) query['keyword'] = keyword;

    final json = await _client.get('/providers', query: query);
    return Paginated.fromJson(
      json as Map<String, dynamic>,
      ProviderSummary.fromJson,
    );
  }

  Future<ProviderDetails> details(String slug) async {
    final json = await _client.get('/providers/$slug');
    final data = (json as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ProviderDetails.fromJson(data);
  }

  Future<ProviderSummary?> findById(int id) async {
    // Walk paginated /providers until id is found. Used to resolve favorites.
    int page = 1;
    while (true) {
      final r = await list(page: page);
      for (final p in r.items) {
        if (p.id == id) return p;
      }
      if (!r.hasMore) return null;
      page += 1;
    }
  }
}
