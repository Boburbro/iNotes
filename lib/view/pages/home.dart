import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:note_app/core/models/note/note.dart';

import 'package:note_app/core/provider/note_bloc/note_event.dart';
import 'package:note_app/core/provider/note_bloc/note_state.dart';
import 'package:note_app/view/utilities/extensions.dart';

import '../../core/provider/note_bloc/note_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(FetchNotesEvent());
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state.isloading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final notes = state.notes;
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Slidable(
              key: ValueKey(note.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text('Do you really want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<NoteBloc>().add(DeleteNoteEvent(note: note));
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Edit note'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: const InputDecoration(hintText: "Title"),
                              ),
                              TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(hintText: "Description"),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) return;
                                final newNote = Note(
                                  id: note.id,
                                  isfavorite: note.isfavorite,
                                  title: _titleController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  createdAt: DateTime.now().toFormat(),
                                );

                                context.read<NoteBloc>().add(UpdateNoteEvent(note: newNote));
                                Navigator.of(context).pop();
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(note.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.description),
                    Text(note.createdAt, style: const TextStyle(fontSize: 10)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite),
                  color: switch (note.isfavorite) {
                    true => Colors.red,
                    _ => null,
                  },
                  onPressed: () {
                    if (!note.isfavorite) {
                      final favoriteNote = Note(
                        id: note.id,
                        isfavorite: true,
                        title: note.title,
                        description: note.description,
                        createdAt: note.createdAt,
                      );
                      context.read<NoteBloc>().add(AddNoteToFavoriteEvent(note: favoriteNote));
                    } else {
                      final unfavoriteNote = Note(
                        id: note.id,
                        isfavorite: false,
                        title: note.title,
                        description: note.description,
                        createdAt: note.createdAt,
                      );
                      context.read<NoteBloc>().add(RemoveNoteFromFavoriteEvent(note: unfavoriteNote));
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
