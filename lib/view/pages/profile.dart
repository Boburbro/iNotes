import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/config/theme.dart';
import 'package:note_app/core/provider/theme/theme_cubit.dart';
import 'package:note_app/core/provider/theme/theme_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Change theme'),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  return Switch.adaptive(
                    value: state.theme == AppTheme.black,
                    onChanged: (_) {
                      context.read<ThemeCubit>().changeTheme(state.theme == AppTheme.black ? 'light' : 'black');
                    },
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
