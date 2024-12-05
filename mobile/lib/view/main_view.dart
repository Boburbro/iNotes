import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/provider/category/category_bloc.dart';
import '../core/provider/note/note_bloc.dart';
import '../core/service/local/cache_service.dart';
import 'pages/notes/note_editor_view.dart';
import 'pages/settings/profile_header.dart';
import 'pages/notes/search_view.dart';
import 'pages/widgets/add_category_bottom_sheet.dart';
import 'pages/notes/notes_view.dart';
import 'pages/widgets/category_selection_sheet.dart';
import 'utilities/colors.dart';
import 'utilities/utils.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color.fromARGB(255, 255, 234, 196),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: AppColors.primaryGrey,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: const Color.fromARGB(255, 255, 234, 196),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const ProfileHeader(),
                      const SizedBox(height: 16),
                      TextField(
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search your notes',
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 248, 237),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: IconButton(
                              icon: const Icon(Icons.search, color: Colors.black),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Notes Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Notes',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Notes List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: BlocBuilder<NoteBloc, NoteState>(
                    builder: (context, state) {
                      if (state.event == NoteEvents.fetchRecentNotesStart) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final recentNotes = state.recentNotes?.data;
                      //final categories = state.categories?.data;

                      if (recentNotes == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (recentNotes.isEmpty) {
                        return const Center(child: Text('No recent notes'));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentNotes.length,
                        itemBuilder: (context, index) {
                          final recentNote = recentNotes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return NoteEditorView(existingNote: recentNote);
                                  },
                                ),
                              );
                            },
                            onLongPress: () => ViewUtils.showDeleteConfirmationBottomSheet(
                              context: context,
                              title: "Delete Note?",
                              description: "Are you sure you want to permanently delete this note? This action cannot be undone.",
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.red,
                              onDelete: () {
                                final payload = {
                                  'user_id': recentNote.userId,
                                  'note_id': recentNote.id,
                                  'category_id': recentNote.categoryId,
                                  'category': recentNote.category,
                                };
                                context.read<NoteBloc>().add(NoteEvent.deleteNoteStart(payload: payload));
                              },
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(16.0),
                              padding: const EdgeInsets.all(16.0),
                              width: 200,
                              decoration: BoxDecoration(
                                color: Color(recentNote.color),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recentNote.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    recentNote.content,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Folder Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Folder',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) {
                              return const AddCategoryBottomSheet();
                            },
                          );
                        },
                        icon: const Icon(Icons.add_box_outlined),
                      ),
                    ],
                  ),
                ),
              ),

              // Folder List
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state.event == CategoryEvents.fetchCategoriesStart) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }

                  final categories = state.categories?.data;

                  if (categories == null) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }

                  if (categories.isEmpty) {
                    return const SliverToBoxAdapter(child: Center(child: Text('No categories')));
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotesView(category: category),
                              ),
                            );
                          },
                          onLongPress: () {
                            ViewUtils.showDeleteConfirmationBottomSheet(
                              context: context,
                              title: "Delete Category?",
                              description:
                                  "Are you sure you want to permanently delete this category? All related notes will also be deleted.",
                              icon: Icons.delete_forever,
                              iconColor: Colors.orange,
                              onDelete: () {
                                final payload = {'category_id': category.id, 'user_id': category.userId};
                                context.read<CategoryBloc>().add(CategoryEvent.deleteCategoryStart(payload: payload));
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                            padding: const EdgeInsets.all(16.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(category.color),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(category.avatar),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${category.notesCount} Notes',
                                      style: const TextStyle(fontSize: 20),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final existCategories = await CacheService().getCategories();
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (context) => CategorySelectionSheet(categories: existCategories),
                );
              }
            },
            backgroundColor: AppColors.primaryOrange,
            child: const Icon(Icons.add),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(height: 80, color: AppColors.primaryGrey),
        ),
      ),
    );
  }
}
