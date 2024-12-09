import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/note/note_bloc.dart';
import 'package:inotes/view/pages/widgets/search_debouncer.dart';
import '../../../core/models/note.dart';
import 'note_editor_view.dart';
import '../../utilities/extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchDebouncer _searchDebouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchDebouncer = SearchDebouncer(
      searchController: _searchController,
      onSearchChanged: (query) => context.read<NoteBloc>().add(NoteEvent.fetchSearchedNotesStart(payload: query)),
    );
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 250, 240),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color.fromARGB(255, 255, 234, 196),
        elevation: 2,
        title: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 234, 196),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(fontSize: 16.0),
            decoration: const InputDecoration(
              hintText: 'Search notes...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state.event == NoteEvents.fetchSearchedNotesStart) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.event == NoteEvents.fetchSearchedNotesSuccess) {
              final notes = state.searchedNotes?.data ?? [];
              if (notes.isEmpty) {
                return const Center(child: Text('No notes found.'));
              }
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteCard(note);
                },
              );
            } else if (state.event == NoteEvents.fetchSearchedNotesFailed) {
              return const Center(child: Text('Failed to fetch search results.'));
            }
            return const Center(child: Text('Start searching for notes.'));
          },
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEditorView(
            existingNote: note,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.createdAt.toFormat(),
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                const Icon(
                  Icons.note_alt_outlined,
                  color: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
