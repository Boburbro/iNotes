import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:inotes/core/models/category.dart';
import 'package:inotes/core/models/note.dart';
import 'package:inotes/core/provider/note/note_bloc.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/view/utilities/colors.dart';

class NoteEditorView extends StatefulWidget {
  const NoteEditorView({super.key, this.existingNote, this.category});
  final Note? existingNote;
  final Category? category;

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late QuillController _controller;
  late TextEditingController _titleController;

  late FocusNode _focusNode;
  bool _isKeyboardVisible = false;
  bool _isToolbarExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _focusNode = FocusNode();
    _titleController = TextEditingController();

    _focusNode.addListener(() {
      setState(() => _isKeyboardVisible = _focusNode.hasFocus);
    });

    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      // Convert existing content to Delta and set it to the controller
      final delta = Delta.fromJson(jsonDecode(widget.existingNote!.delta!));
      _controller = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() async {
    // Quill Delta'sını JSON'a çevir
    final delta = _controller.document.toDelta();
    final deltaJson = jsonEncode(delta.toJson());

    final secureStorageCacheService = SecureStorageCacheService.instance;
    final user = await secureStorageCacheService.getUser();

    // Yeni not oluştur
    final note = NewNote(
      userId: user!.id,
      categoryId: widget.category!.id,
      title: _titleController.text.trim(),
      category: widget.category!.name,
      updatedAt: null,
      content: _controller.document.toPlainText(),
      delta: deltaJson,
      color: getRandomColor().value,
    );

    if (!mounted) return;
    context.read<NoteBloc>().add(NoteEvent.addNoteStart(noteJson: note.toJson()));
  }

  void _updateNote() async {
    // Quill Delta'sını JSON'a çevir
    final delta = _controller.document.toDelta();
    final deltaJson = jsonEncode(delta.toJson());

    final secureStorageCacheService = SecureStorageCacheService.instance;
    final user = await secureStorageCacheService.getUser();

    // Güncellenmiş notu oluştur
    final updatedNote = Note(
      id: widget.existingNote!.id,
      userId: user!.id,
      categoryId: widget.existingNote!.categoryId,
      title: _titleController.text.trim(),
      category: widget.existingNote!.category,
      updatedAt: DateTime.now(),
      content: _controller.document.toPlainText(),
      delta: deltaJson,
      color: widget.existingNote!.color,
    );

    if (!mounted) return;
    context.read<NoteBloc>().add(NoteEvent.updateNoteStart(payload: updatedNote.toJson()));
  }

  Color getRandomColor() {
    final randomIndex = Random().nextInt(AppColors.colors.length);
    return AppColors.colors[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.existingNote?.color ?? AppColors.primaryYellow.value),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(widget.existingNote?.color ?? AppColors.primaryYellow.value),
        elevation: 0,
        actions: [
          BlocConsumer<NoteBloc, NoteState>(
            listener: (context, state) {
              if (state.event == NoteEvents.addNoteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
              if (state.event == NoteEvents.updateNoteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              if (state.event == NoteEvents.addNoteStart || state.event == NoteEvents.updateNoteStart) {
                return const Center(child: CircularProgressIndicator());
              }
              return TextButton(
                onPressed: (widget.existingNote != null) ? _updateNote : _saveNote,
                child: Text(
                  (widget.existingNote != null) ? 'Update' : 'Done',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'title...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                focusNode: _focusNode,
                configurations: const QuillEditorConfigurations(
                  showCursor: true,
                  placeholder: 'description...',
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      TextStyle(color: Colors.black, fontSize: 18),
                      HorizontalSpacing(0, 0),
                      VerticalSpacing(0, 0),
                      VerticalSpacing(0, 0),
                      BoxDecoration(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Alt Araç Çubuğu
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isToolbarExpanded ? 300 : 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_isToolbarExpanded ? 20 : 0),
              ),
            ),
            child: Column(
              children: [
                // Genişletme/Daraltma Düğmesi
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isToolbarExpanded = !_isToolbarExpanded;
                    });
                  },
                  child: Container(
                    height: 30,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        _isToolbarExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      ),
                    ),
                  ),
                ),

                // Hızlı Eylem Butonları
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.text_format,
                        onPressed: () => _applyStyle(FontWeight.bold),
                        tooltip: 'Kalın',
                      ),
                      _buildQuickActionButton(
                        icon: Icons.format_italic,
                        onPressed: () => _applyStyle(FontStyle.italic),
                        tooltip: 'İtalik',
                      ),
                      _buildQuickActionButton(
                        icon: Icons.format_underlined,
                        onPressed: () => _applyUnderline(),
                        tooltip: 'Altı Çizili',
                      ),
                      _buildQuickActionButton(
                        icon: Icons.emoji_emotions,
                        onPressed: _showEmojiPicker,
                        tooltip: 'Emoji Ekle',
                      ),
                      _buildQuickActionButton(
                        icon: Icons.add_link,
                        onPressed: _insertLink,
                        tooltip: 'Bağlantı Ekle',
                      ),
                    ],
                  ),
                ),

                // Detaylı Toolbar (Genişletildiğinde)
                if (_isToolbarExpanded)
                  Expanded(
                    child: QuillToolbar.simple(
                      controller: _controller,
                      configurations: const QuillSimpleToolbarConfigurations(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Diğer metodlar önceki örnekle aynı (applyStyle, showEmojiPicker, vb.)
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  void _applyStyle(dynamic style) {
    if (style is FontWeight) {
      _controller.formatSelection(
        Attribute('bold', AttributeScope.inline, style == FontWeight.bold),
      );
    } else if (style is FontStyle) {
      _controller.formatSelection(
        Attribute('italic', AttributeScope.inline, style == FontStyle.italic),
      );
    }
  }

  void _applyUnderline() {
    _controller.formatSelection(
      const UnderlineAttribute(),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemCount: _emojiList.length,
            itemBuilder: (context, index) {
              return TextButton(
                child: Text(
                  _emojiList[index],
                  style: const TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  _controller.document.insert(_controller.selection.baseOffset, _emojiList[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController linkController = TextEditingController();
        return AlertDialog(
          title: const Text('Bağlantı Ekle'),
          content: TextField(
            controller: linkController,
            decoration: const InputDecoration(
              hintText: 'URL\'yi girin',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Ekle'),
              onPressed: () {
                final link = linkController.text;
                if (link.isNotEmpty) {
                  _controller.formatSelection(
                    LinkAttribute(link),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final List<String> _emojiList = ['😀', '😍', '🎉', '👍', '❤️', '🌟', '🚀', '🍕', '🎈', '🌈'];
}
