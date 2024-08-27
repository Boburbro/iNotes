import 'package:note_app/core/models/note/note.dart';

class SearchState {
  final bool isloading;
  final List<Note> searchedNotes;

  SearchState({
    required this.isloading,
    required this.searchedNotes,
  });

  SearchState copyWith({
    bool? isloading,
    List<Note>? searchedNotes,
  }) {
    return SearchState(
      isloading: isloading ?? this.isloading,
      searchedNotes: searchedNotes ?? this.searchedNotes,
    );
  }

  factory SearchState.initial() {
    return SearchState(isloading: false, searchedNotes: []);
  }
}
