import '../../core/network/api_client.dart';
import '../../shared/models/important_number.dart';

class ImportantNumbersRepository {
  ImportantNumbersRepository([ApiClient? client])
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<ImportantNumber>> all() async {
    final json = await _client.get('/important-numbers');
    final list = (json as Map<String, dynamic>?)?['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ImportantNumber.fromJson)
        .toList();
  }
}
