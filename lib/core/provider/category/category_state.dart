part of 'category_bloc.dart';

class CategoryState {
  final PaginatedDataResponse<Category>? categories;
  final CategoryEvents? event;

  CategoryState({this.categories, this.event});

  CategoryState copyWith({
    PaginatedDataResponse<Category>? categories,
    CategoryEvents? event,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      event: event ?? this.event,
    );
  }

  factory CategoryState.initial() {
    return CategoryState(
      categories: null,
      event: null,
    );
  }
}
