import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/theme.dart';
import '../../../core/provider/theme/theme_cubit.dart';
import '../../../core/provider/theme/theme_state.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
