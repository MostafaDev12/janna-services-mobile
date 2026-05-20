import '../../core/network/api_client.dart';
import '../../shared/models/banner.dart';
import '../../shared/models/category.dart';
import '../../shared/models/important_number.dart';
import '../../shared/models/provider_summary.dart';

class HomeData {
  HomeData({
    required this.banners,
    required this.categories,
    required this.featured,
    required this.importantNumbers,
  });

  final List<HomeBanner> banners;
  final List<Category> categories;
  final List<ProviderSummary> featured;
  final List<ImportantNumber> importantNumbers;
}

class HomeRepository {
  HomeRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<HomeData> loadAll() async {
    final results = await Future.wait([
      _client.get('/banners'),
      _client.get('/categories'),
      _client.get('/providers', query: {'featured': '1'}),
      _client.get('/important-numbers'),
    ]);

    List<T> parseList<T>(dynamic json, T Function(Map<String, dynamic>) f) {
      final data = (json as Map<String, dynamic>?)?['data'];
      if (data is! List) return const [];
      return data.whereType<Map<String, dynamic>>().map(f).toList();
    }

    return HomeData(
      banners: parseList(results[0], HomeBanner.fromJson),
      categories: parseList(results[1], Category.fromJson),
      featured: parseList(results[2], ProviderSummary.fromJson),
      importantNumbers: parseList(results[3], ImportantNumber.fromJson),
    );
  }
}
