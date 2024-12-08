import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inotes/core/types.dart';

typedef SearchCallback = void Function(Json query);

class SearchDebouncer {
  final TextEditingController searchController;
  final Duration debounceDuration;
  final SearchCallback onSearchChanged;
  Timer? _debounce;
  String? category;

  SearchDebouncer({
    required this.searchController,
    required this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.category,
  }) {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      final Json query = {};
      query['query'] = searchController.text.trim();

      if (category != null) {
        query['category'] = category;
      }

      print('QUERY: $query');
      onSearchChanged(query);
    });
  }

  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
  }
}
