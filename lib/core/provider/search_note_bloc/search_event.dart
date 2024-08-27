sealed class SearchEvent {}

class SearchNoteEvent extends SearchEvent {
  final String keyword;

  SearchNoteEvent({required this.keyword});
}

class FetchSearchedNotes extends SearchEvent {}
