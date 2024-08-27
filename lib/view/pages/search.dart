import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/provider/search_note_bloc/search_bloc.dart';
import 'package:note_app/core/provider/search_note_bloc/search_event.dart';
import 'package:note_app/core/provider/search_note_bloc/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _focusNode,
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'search..',
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
          onChanged: (value) {
            context.read<SearchBloc>().add(SearchNoteEvent(keyword: _searchController.text.trim()));
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.isloading) return const CircularProgressIndicator();

          final searchedNotes = state.searchedNotes;
          return ListView.builder(
            itemCount: searchedNotes.length,
            itemBuilder: (context, index) {
              final searchedNote = searchedNotes[index];
              return ListTile(
                title: Text(searchedNote.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(searchedNote.description),
                    Text(searchedNote.createdAt, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
