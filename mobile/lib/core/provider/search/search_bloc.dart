// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:inotes/core/provider/note/note_bloc.dart';
// import 'package:inotes/main.dart';
// import 'search_event.dart';
// import 'search_state.dart';
// import '../../service/log_service.dart';
// import '../../service/remote/note_service.dart';

// class SearchBloc extends Bloc<SearchEvent, SearchState> {
//   SearchBloc() : super(SearchState.initial()) {
//     on<SearchEvent>((event, emit) async {
//       switch (event.type) {
//         case SearchEvents.fetchSearchResult:
//           await _onfetchSearchResult(event, emit);
//           break;
//         case SearchEvents.fetchSearchResultByCategory:
//           await _onfetchSearchResultByCategory(event, emit);
//           break;
//         default:
//       }
//     });
//   }

//   Future<void> _onfetchSearchResult(SearchEvent event, Emitter<SearchState> emit) async {
//     emit(state.copyWith(event: SearchEvents.fetchSearchResult));
//     try {
//       if (event.payload['query'].isEmpty) {
//         state.notes?.data.clear();
//         emit(state.copyWith(event: SearchEvents.successSearchResult));
//         return;
//       }
//       final notes = await _noteService.searchforNotes(query: event.payload['query']);
//       if (notes == null) return;

//       emit(state.copyWith(notes: notes, event: SearchEvents.successSearchResult));
//     } catch (error, stackTrace) {
//       AppLog.instance.error(
//         'Failed to fetch search results',
//         error: error,
//         stackTrace: stackTrace,
//       );

//       emit(state.copyWith(
//         event: SearchEvents.failedSearchResult,
//       ));
//     }
//   }

//   Future<void> _onfetchSearchResultByCategory(SearchEvent event, Emitter<SearchState> emit) async {
//     emit(state.copyWith(event: SearchEvents.fetchSearchResultByCategory));
//     try {
//       if (event.payload['query'].isEmpty) {
//         navigatorKey.currentContext
//             ?.read<NoteBloc>()
//             .add(NoteEvent.fetchNotesByCategoryStart(payload: {'query': '', 'category': event.payload['category']}));
//         state.notes?.data.clear();
//         emit(state.copyWith(event: SearchEvents.successSearchResultByCategory));
//         return;
//       }
//       final notes =
//           await _noteService.searchforNotesByCategory(query: event.payload['query'], category: event.payload['category']);
//       if (notes == null) return;

//       emit(state.copyWith(notes: notes, event: SearchEvents.successSearchResultByCategory));
//     } catch (error, stackTrace) {
//       AppLog.instance.error(
//         'Failed to fetch search results',
//         error: error,
//         stackTrace: stackTrace,
//       );

//       emit(state.copyWith(
//         event: SearchEvents.failedSearchResultByCategory,
//       ));
//     }
//   }

//   final _noteService = NoteService.instance;
// }
