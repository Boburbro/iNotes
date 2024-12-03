enum SearchEvents {
  fetchSearchResults,
  successSearchResult,
  failedSearchResults,
}

class SearchEvent {
  SearchEvents? type;
  dynamic query;

  SearchEvent.fetchSearchResults({required this.query}) {
    type = SearchEvents.fetchSearchResults;
  }
}
