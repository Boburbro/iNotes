part of 'category_bloc.dart';

enum CategoryEvents {
  addCategoryStart,
  addCategorySuccess,
  addCategoryFailure,

  fetchCategoriesStart,
  fetchCategoriesSuccess,
  fetchCategoriesFailure,

  deleteCategoryStart,
  deleteCategorySuccess,
  deleteCategoryFailure,

  incrementNotesCountStart,
  decrementNotesCountStart
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

  CategoryEvent.deleteCategoryStart({this.payload}) {
    event = CategoryEvents.deleteCategoryStart;
  }

  CategoryEvent.incrementNotesCountStart({this.payload}) {
    event = CategoryEvents.incrementNotesCountStart;
  }

  CategoryEvent.decrementNotesCountStart({this.payload}) {
    event = CategoryEvents.decrementNotesCountStart;
  }
}
