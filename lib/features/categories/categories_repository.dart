import '../../core/network/api_client.dart';
import '../../shared/models/category.dart';
import '../../shared/models/paginated.dart';
import '../../shared/models/provider_summary.dart';

class CategoriesRepository {
  CategoriesRepository([ApiClient? client])
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<Category>> all() async {
    final json = await _client.get('/categories');
    final list = (json as Map<String, dynamic>?)?['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  Future<Paginated<ProviderSummary>> providersOf(String slug,
      {int page = 1}) async {
    final json = await _client
        .get('/categories/$slug/providers', query: {'page': page});
    return Paginated.fromJson(
      json as Map<String, dynamic>,
      ProviderSummary.fromJson,
    );
  }
}
