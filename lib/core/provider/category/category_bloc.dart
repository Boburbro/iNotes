import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/models/category.dart';
import 'package:inotes/core/models/response.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/service/remote/category_service.dart';

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
        default:
      }
    });
  }

  Future<void> _onAddCategoryStart(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(
      event: CategoryEvents.addCategoryStart,
    ));

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

      emit(state.copyWith(
        event: CategoryEvents.addCategoryFailure,
      ));
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

      emit(state.copyWith(
        event: CategoryEvents.fetchCategoriesFailure,
      ));
    }
  }

  final _service = CategoryService.instance;
}
