import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/config/theme.dart';
import 'package:inotes/core/provider/theme/theme_state.dart';
import 'package:inotes/core/service/local/cache_service.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : _cacheService = CacheService(),
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

  late final CacheService _cacheService;
}
