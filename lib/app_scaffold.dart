import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/note_bloc/note_bloc.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/editor_page.dart';
import 'package:inotes/profile_header.dart';
import 'package:inotes/view/pages/add_category_page.dart';
import 'package:inotes/view/pages/category_selector_sheet.dart';
import 'package:inotes/view/pages/notes_view.dart';
import 'package:inotes/view/utilities/colors.dart';
import 'package:inotes/view/utilities/utils.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: AppColors.primaryGrey,
          body: CustomScrollView(
            slivers: [
              // Top Section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const ProfileHeader(),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search your notes',
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: AppColors.primaryOrange,
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
                      final categories = state.categories?.data;

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
                              final category = categories!.firstWhere((category) {
                                return category.name == recentNote.category;
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdvancedRichTextEditor(
                                    category: category,
                                    existingNote: recentNote,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () => ViewUtils.showAdvancedDeleteNoteBottomSheet(
                              context,
                              noteId: recentNote.id,
                              categoryId: recentNote.categoryId,
                              categoryName: recentNote.category,
                              userId: recentNote.userId,
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
              BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  if (state.event == NoteEvents.fetchCategoriesStart) {
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
