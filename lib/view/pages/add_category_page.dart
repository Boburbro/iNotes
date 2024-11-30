import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inotes/core/provider/note_bloc/note_bloc.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({super.key});

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController nameController = TextEditingController();

  Uint8List? _avatarPath;
  Color? _selectedColor;

  final List<Color> _colors = [
    Colors.redAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.orangeAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.tealAccent.shade100,
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      _avatarPath = await imageFile.readAsBytes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category Name',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Enter category name',
              prefixIcon: const Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category Avatar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                image: DecorationImage(
                  image: _avatarPath != null
                      ? MemoryImage(_avatarPath!)
                      : const AssetImage('assets/placeholder_avatar.png') as ImageProvider,
                ),
              ),
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category Color',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 24,
                      child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          BlocConsumer<NoteBloc, NoteState>(
            listener: (context, state) {
              if (state.event == NoteEvents.addCategorySuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              if (state.event == NoteEvents.addCategoryStart) {
                return const Center(child: CircularProgressIndicator());
              }
              return ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a category name')),
                    );
                    return;
                  }
                  if (_avatarPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a category avatar')),
                    );
                    return;
                  }
                  if (_selectedColor == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a category color')),
                    );
                    return;
                  }

                  final categoryJson = {
                    'name': nameController.text,
                    'avatar': _avatarPath!,
                    'color': _selectedColor!.value,
                  };

                  context.read<NoteBloc>().add(NoteEvent.addCategoryStart(categoryJson: categoryJson));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
