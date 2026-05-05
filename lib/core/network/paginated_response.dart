class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parser,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((item) => parser(item as Map<String, dynamic>))
        .toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final links = json['links'] as Map<String, dynamic>? ?? const {};

    return PaginatedResponse(
      items: items,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? items.length,
      total: meta['total'] as int? ?? items.length,
      nextPageUrl: links['next'] as String?,
    );
  }
}
