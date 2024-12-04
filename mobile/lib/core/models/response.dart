class PaginatedDataResponse<T> {
  PaginatedDataResponse({
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.path,
    required this.parseMethod,
    required this.loadMethod,
    this.requestBody,
    this.queryParams,
    required this.data,
    this.loading = false,
  });

  int currentPage;
  final int lastPage;
  final String path;
  final int perPage;
  final List<T> data;
  bool loading;
  final T Function(Map<String, dynamic>) parseMethod;
  final Map? requestBody;
  final Map<String, dynamic>? queryParams;
  final int total;
  final String loadMethod;

  factory PaginatedDataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseMethod, {
    Map? reqMap,
    Map<String, dynamic>? queryParams,
    String loadMethod = 'GET',
  }) {
    final meta = json['meta'] as Map<String, dynamic>;
    return PaginatedDataResponse<T>(
      data: List<T>.from(json['data'].map((x) => parseMethod(x))),
      currentPage: meta['current_page'],
      lastPage: meta['last_page'],
      path: meta['path'],
      perPage: meta['per_page'],
      parseMethod: parseMethod,
      requestBody: reqMap,
      total: meta['total'],
      queryParams: queryParams,
      loadMethod: loadMethod,
    );
  }

  bool get hasNext {
    return currentPage < lastPage;
  }

  Future<bool> loadNext() async {
    if (!hasNext || loading) {
      return false;
    }

    loading = true;
    currentPage++;

    String completePath = path;
    if (queryParams != null) {
      bool isFirstQueryParam = true;
      for (var paramKey in queryParams!.keys) {
        completePath += isFirstQueryParam ? '?' : '&';
        completePath += '$paramKey=${queryParams![paramKey]}';
        isFirstQueryParam = false;
      }
    }

    completePath += completePath.contains('?') ? '&' : '?';
    completePath += 'page=$currentPage';

    List? newData;
    try {
      //newData = await ApiService.instance.loadData(completePath, queryParams, method: loadMethod);
      data.addAll(newData!.map((x) => parseMethod(x)));
    } finally {
      loading = false;
    }

    return true;
  }
}
