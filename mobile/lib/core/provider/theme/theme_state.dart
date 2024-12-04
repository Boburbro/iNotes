import 'package:flutter/material.dart';

class ThemeState {
  final bool isloading;
  final ThemeData? theme;

  ThemeState({
    required this.isloading,
    required this.theme,
  });

  ThemeState copyWith({
    bool? isloading,
    ThemeData? theme,
  }) {
    return ThemeState(
      isloading: isloading ?? this.isloading,
      theme: theme ?? this.theme,
    );
  }

  factory ThemeState.initial() {
    return ThemeState(isloading: false, theme: ThemeData.light());
  }
}
