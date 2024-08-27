import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/models/note/note.dart';
import 'package:note_app/core/provider/note_bloc/note_bloc.dart';
import 'package:note_app/core/provider/note_bloc/note_event.dart';
import 'package:note_app/view/pages/favorite.dart';
import 'package:note_app/view/pages/home.dart';
import 'package:note_app/view/pages/profile.dart';
import 'package:note_app/view/pages/search.dart';
import 'package:note_app/view/utilities/extensions.dart';
import 'package:uuid/uuid.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;
  final _pages = const <StatefulWidget>[HomePage(), FavoritePage(), ProfilePage()];
  final appBarTitles = {
    0: 'Home',
    1: 'Favorite',
    2: 'Profile',
  };

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showCreateNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) return;

                final note = Note(
                  id: const Uuid().v4(),
                  isfavorite: false,
                  createdAt: DateTime.now().toFormat(),
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
                context.read<NoteBloc>().add(AddNoteEvent(note: note));
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_currentIndex] ?? ''),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchPage(),
                      )),
                  icon: const Icon(Icons.search),
                )
              ]
            : null,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (currentIndex) => setState(() => _currentIndex = currentIndex),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
