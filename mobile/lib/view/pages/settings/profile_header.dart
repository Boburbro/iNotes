import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/provider/auth/auth_bloc.dart';
import '../../../core/provider/user/user_bloc.dart';
import '../../../core/provider/user/user_event.dart';
import '../../../core/provider/user/user_state.dart';
import '../../../core/service/local/cache_service.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  Uint8List? _avatarPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      _avatarPath = await imageFile.readAsBytes();

      final userId = await getUserId();

      final userJson = {
        'user_id': userId,
        'avatar': _avatarPath,
      };
      if (!mounted) return;
      context.read<UserBloc>().add(UserEvent.updateProfileStart(payload: userJson));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state.event == UserEvents.updateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final user = state.user;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.username}',
                  style: const TextStyle(color: Colors.black),
                ),
                const Text(
                  'My Notes',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Modal açılıyor
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return _buildBottomSheet(context);
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: user?.avatar != null ? NetworkImage(user!.avatar!) : const AssetImage('assets/placeholder_avatar.png'),
                  ),
                ),
                height: 40,
                width: 40,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Change Profile Picture"),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthenticationBloc>().add(AuthenticationEvent.logoutStart());
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete account", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final userId = await getUserId();
              final payload = {'user_id': userId};

              if (!context.mounted) return;

              final event = AuthenticationEvent.deleteAccountStart(payload: payload);
              context.read<AuthenticationBloc>().add(event);
            },
          ),
        ],
      ),
    );
  }
}

Future<int> getUserId() async {
  SecureStorageCacheService secureStorage = SecureStorageCacheService.instance;
  final user = await secureStorage.getUser();
  return user!.id;
}
