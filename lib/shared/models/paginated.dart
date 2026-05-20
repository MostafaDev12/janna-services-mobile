/// Generic pagination envelope from Laravel API resources.
class Paginated<T> {
  Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final dataList = (j['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList();

    final meta = j['meta'] as Map<String, dynamic>?;

    return Paginated<T>(
      items: dataList,
      currentPage: (meta?['current_page'] as int?) ?? 1,
      lastPage: (meta?['last_page'] as int?) ?? 1,
      total: (meta?['total'] as int?) ?? dataList.length,
    );
  }
}
