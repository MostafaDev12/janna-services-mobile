class ImportantNumber {
  ImportantNumber({
    required this.id,
    required this.title,
    required this.phone,
    this.whatsapp,
    this.description,
    this.sortOrder = 0,
  });

  final int id;
  final String title;
  final String phone;
  final String? whatsapp;
  final String? description;
  final int sortOrder;

  factory ImportantNumber.fromJson(Map<String, dynamic> j) => ImportantNumber(
        id: j['id'] as int,
        title: j['title'] as String,
        phone: j['phone'] as String,
        whatsapp: j['whatsapp'] as String?,
        description: j['description'] as String?,
        sortOrder: (j['sort_order'] as int?) ?? 0,
      );
}
