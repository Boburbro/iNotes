import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/config/theme.dart';
import 'package:note_app/core/provider/theme/theme_state.dart';
import 'package:note_app/core/service/cache_service.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : _cacheService = CacheServiceImpl(),
        super(ThemeState.initial());

  final themes = {
    'light': AppTheme.light,
    'black': AppTheme.black,
  };

  void changeTheme(String newtheme) async {
    await _cacheService.changeTheme(newtheme);
    final theme = themes[newtheme];
    emit(state.copyWith(theme: theme));
  }

  void get getTheme async {
    final theme = await _cacheService.getTheme() ?? 'light';

    emit(state.copyWith(theme: themes[theme]));
  }

  late final CacheServiceImpl _cacheService;
}
