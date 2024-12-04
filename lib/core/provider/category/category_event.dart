part of 'category_bloc.dart';

enum CategoryEvents {
  addCategoryStart,
  addCategorySuccess,
  addCategoryFailure,

  fetchCategoriesStart,
  fetchCategoriesSuccess,
  fetchCategoriesFailure,
}

class CategoryEvent {
  CategoryEvents? event;
  dynamic payload;

  CategoryEvent.addCategoryStart({this.payload}) {
    event = CategoryEvents.addCategoryStart;
  }

  CategoryEvent.fetchCategoriesStart({this.payload}) {
    event = CategoryEvents.fetchCategoriesStart;
  }
}
