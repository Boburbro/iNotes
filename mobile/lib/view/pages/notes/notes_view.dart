import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/view/pages/widgets/search_debouncer.dart';
import 'package:inotes/view/utilities/utils.dart';
import '../../../core/models/category.dart';
import '../../../core/models/note.dart';
import '../../../core/provider/note/note_bloc.dart';
import 'note_editor_view.dart';
import '../../utilities/colors.dart';
import '../../utilities/extensions.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key, required this.category});

  final Category category;

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late SearchDebouncer _searchDebouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchDebouncer = SearchDebouncer(
      category: widget.category.name,
      searchController: _searchController,
      onSearchChanged: (payload) {
        context.read<NoteBloc>().add(NoteEvent.fetchSearchedNotesByCategoryStart(payload: payload));
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchDebouncer.initialize();
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = EdgeInsets.only(top: MediaQuery.of(context).padding.top);
    const left = EdgeInsets.only(left: 24.0);
    const right = EdgeInsets.only(right: 24.0);
    const bottom = EdgeInsets.only(bottom: 24.0);

    return ColoredBox(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: AppColors.primaryGrey.withOpacity(0.1),
        body: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                color: Color(widget.category.color),
                padding: left + right + top + bottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(widget.category.avatar),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Search notes...',
                        hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.search, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notes Grid Section
            BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state.event == NoteEvents.fetchSearchedNotesByCategoryStart) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.event == NoteEvents.fetchSearchedNotesByCategorySuccess) {
                  final notes = state.searchedNotes?.data;

                  if (notes == null || notes.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "No notes found in this category.",
                            style: TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final note = notes[index];
                        return _buildNoteCard(note);
                      },
                      childCount: notes.length,
                    ),
                  );
                }

                if (state.event == NoteEvents.fetchSearchedNotesByCategoryFailed) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "Something went wrong. Please try again.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(
                  child: Center(child: Text('Start searching for notes.')),
                );
              },
            ),
          ],
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
            category: widget.category,
            existingNote: note,
          ),
        ),
      ),
      onLongPress: () => ViewUtils.showDeleteConfirmationBottomSheet(
        context: context,
        title: "Delete Note?",
        description: "Are you sure you want to permanently delete this note? This action cannot be undone.",
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        onDelete: () {
          final payload = {
            'note_id': note.id,
            'category': note.category,
          };
          context.read<NoteBloc>().add(NoteEvent.deleteNoteStart(payload: payload));
        },
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
