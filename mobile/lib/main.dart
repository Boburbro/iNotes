import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nested/nested.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view/main_view.dart';
import 'core/provider/auth/auth_bloc.dart';
import 'core/provider/category/category_bloc.dart';
import 'core/provider/note/note_bloc.dart';
import 'core/provider/search/search_bloc.dart';
import 'core/provider/theme/theme_cubit.dart';
import 'core/provider/theme/theme_state.dart';
import 'core/provider/user/user_bloc.dart';
import 'core/provider/user/user_event.dart';
import 'core/service/local/cache_service.dart';
import 'view/pages/auth/auth_view.dart';
import 'view/pages/start/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureStorageCacheService.init();
  // (await SharedPreferences.getInstance()).clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _providers,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Note app',
            debugShowCheckedModeBanner: false,
            theme: themeState.theme,
            navigatorKey: navigatorKey,
            localizationsDelegates: _localizationsDelegates,
            supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
            builder: (context, child) => _authenticationListener(child),
            onGenerateRoute: _onRouteGenerator,
          );
        },
      ),
    );
  }

  BlocListener<AuthenticationBloc, AuthenticationState> _authenticationListener(Widget? child) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state.event == AuthenticationEvents.authenticated) {
          await _initializeData(context);

          await navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (state.event == AuthenticationEvents.unauthenticated) {
          await navigatorKey.currentState?.pushNamedAndRemoveUntil('/auth_view', (route) => false);
        }
      },
      child: child,
    );
  }

  List<SingleChildWidget> get _providers {
    return [
      BlocProvider(create: (context) => UserBloc()),
      BlocProvider(create: (context) => NoteBloc()),
      BlocProvider(create: (context) => CategoryBloc()),
      BlocProvider(create: (context) => SearchBloc()),
      BlocProvider(create: (context) => ThemeCubit()..getTheme),
      BlocProvider(
        create: (context) => AuthenticationBloc()..add(AuthenticationEvent.checkAuthentication()),
      ),
    ];
  }

  List<LocalizationsDelegate<dynamic>> get _localizationsDelegates {
    return const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      AppFlowyEditorLocalizations.delegate,
    ];
  }

  Future<void> _initializeData(BuildContext context) async {
    final user = await SecureStorageCacheService.instance.getUser();
    final payload = {'user_id': user!.id, 'is_force_refresh': false};

    if (!context.mounted) return;

    context.read<NoteBloc>().add(NoteEvent.fetchRecentNotesStart(payload: payload));
    context.read<CategoryBloc>().add(CategoryEvent.fetchCategoriesStart(payload: payload));
    context.read<UserBloc>().add(UserEvent.getUserStart(payload: user.id));
  }

  MaterialPageRoute<dynamic> _onRouteGenerator(RouteSettings settings) {
    return switch (settings.name) {
      '/' => MaterialPageRoute(builder: (context) => const Splash()),
      '/auth_view' => MaterialPageRoute(builder: (context) => LoginPage()),
      '/home' => MaterialPageRoute(builder: (context) => const MainView()),
      _ => MaterialPageRoute(builder: (context) => const Scaffold()),
    };
  }
}
