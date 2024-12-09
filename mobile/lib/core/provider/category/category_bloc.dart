import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/note/note_bloc.dart';
import 'package:inotes/core/utils/note_helper.dart';
import 'package:inotes/main.dart';
import '../../models/category.dart';
import '../../models/response.dart';
import '../../service/local/cache_service.dart';
import '../../service/log_service.dart';
import '../../service/remote/category_service.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryState.initial()) {
    on<CategoryEvent>((event, emit) async {
      switch (event.event) {
        case CategoryEvents.addCategoryStart:
          await _onAddCategoryStart(event, emit);
          break;
        case CategoryEvents.fetchCategoriesStart:
          await _onFetchCategoriesStart(event, emit);
          break;
        case CategoryEvents.incrementNotesCountStart:
          await _onIncrementNotesCount(event, emit);
          break;
        case CategoryEvents.decrementNotesCountStart:
          await _onDecrementNotesCount(event, emit);
          break;
        case CategoryEvents.deleteCategoryStart:
          await _onDeleteCategoryStart(event, emit);
          break;
        default:
      }
    });
  }

  Future<void> _onAddCategoryStart(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(event: CategoryEvents.addCategoryStart));

    try {
      final Category? category = await _service.addCategory(categoryJson: event.payload);

      if (category != null) {
        state.categories!.data.add(category);
        emit(state.copyWith(event: CategoryEvents.addCategorySuccess));

        await CacheService().setCategory(category.toJson());
      }

      emit(state);
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to add note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(event: CategoryEvents.addCategoryFailure));
    }
  }

  Future<void> _onFetchCategoriesStart(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(
      event: CategoryEvents.fetchCategoriesStart,
    ));

    final bool isForceRefresh = event.payload['is_force_refresh'];
    final data = state.categories?.data;
    final isExistData = data != null && data.isNotEmpty;

    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: CategoryEvents.fetchCategoriesSuccess));
      return;
    }

    try {
      final PaginatedDataResponse<Category>? categories = await _service.fetchCategories(userId: event.payload['user_id']);
      emit(state.copyWith(
        categories: categories,
        event: CategoryEvents.fetchCategoriesSuccess,
      ));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to fetch categories',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(event: CategoryEvents.fetchCategoriesFailure));
    }
  }

  Future<void> _onDeleteCategoryStart(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(
      event: CategoryEvents.deleteCategoryStart,
    ));

    try {
      final Category ctr = event.payload['category'];
      final bool? result = await _service.deleteCategory(category: ctr);

      if (result == null) {
        emit(state.copyWith(
          event: CategoryEvents.deleteCategoryFailure,
        ));
        return;
      }

      final categories = state.categories?.data;
      if (categories != null) {
        ListHelper.removeItem(
          categories,
          (category) => category.id == ctr.id,
        );
        emit(state.copyWith(event: CategoryEvents.fetchCategoriesSuccess));
      }

      final event0 = NoteEvent.deleteNotesStart(payload: event.payload);
      navigatorKey.currentContext?.read<NoteBloc>().add(event0);

      await _cacheService.removeCategory(ctr.name);

      emit(state.copyWith(event: CategoryEvents.deleteCategorySuccess));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to delete category',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(event: CategoryEvents.deleteCategoryFailure));
    }
  }

  Future<void> _onIncrementNotesCount(CategoryEvent event, Emitter<CategoryState> emit) async {
    final categories = state.categories?.data;
    if (categories != null) {
      ListHelper.incrementCount(
        categories,
        (category) => category.name == event.payload['category_name'],
        (category) => category.notesCount,
        (category, newCount) => category.copyWith(notesCount: newCount),
      );
    }

    emit(state.copyWith(event: CategoryEvents.fetchCategoriesSuccess));
  }

  Future<void> _onDecrementNotesCount(CategoryEvent event, Emitter<CategoryState> emit) async {
    final categories = state.categories?.data;
    if (categories != null) {
      ListHelper.decrementCount(
        categories,
        (category) => category.name == event.payload['category_name'],
        (category) => category.notesCount,
        (category, newCount) => category.copyWith(notesCount: newCount),
      );
    }

    emit(state.copyWith(event: CategoryEvents.fetchCategoriesSuccess));
  }

  final _service = CategoryService.instance;
  final _cacheService = CacheService();
}
