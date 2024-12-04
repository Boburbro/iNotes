import 'package:dio/dio.dart';
import '../../models/note.dart';
import '../../models/response.dart';
import '../../utils/api_client.dart';
import '../../utils/dio_helper.dart';
import '../log_service.dart';
import '../../../view/utilities/utils.dart';

class NoteService {
  static NoteService? _instance;
  static NoteService get instance => _instance ?? NoteService._();
  late final Dio _dio;

  NoteService._() : _dio = ApiClient.instance.dio;

  Future<Note?> addNote({required Map<String, dynamic> noteJson}) async {
    final formData = FormData.fromMap({
      'user_id': noteJson['user_id'],
      'category_id': noteJson['category_id'],
      'title': noteJson['title'],
      'content': noteJson['content'],
      'category': noteJson['category'],
      'delta': noteJson['delta'],
      'color': ViewUtils.colorToHex(noteJson['color']),
    });

    try {
      final response = await _dio.post('/note', data: formData);
      if (response.statusCode == 201) {
        return Note.fromJson(response.data);
      }
      throw 'Failed to add note';
    } on DioException catch (exception) {
      final message = DioErrorHelper.handle(exception);
      AppLog.instance.debug('Add Note Error Message: $message');
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      throw 'Failed to add note';
    }
  }

  Future<PaginatedDataResponse<Note>?> fetchNotes({required int userId}) async {
    final queryParameters = {'user_id': userId};
    try {
      final response = await _dio.get('/notes', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final notes = PaginatedDataResponse<Note>.fromJson(response.data, Note.fromJson);
        return notes;
      }
      throw 'Failed to load notes';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Notes Error Message: $e');
      throw 'Failed to load notes';
    }
  }

  Future<PaginatedDataResponse<Note>?> fetchNotesByCategory({required int userId, required int categoryId}) async {
    final queryParameters = {'user_id': userId, 'category_id': categoryId};
    try {
      final response = await _dio.get('/notes-by-category', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final notes = PaginatedDataResponse<Note>.fromJson(response.data, Note.fromJson);
        return notes;
      }
      throw 'Failed to load notes';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Notes Error Message: $e');
      throw 'Failed to load notes';
    }
  }

  Future<PaginatedDataResponse<Note>?> fetchRecentNotes({required int userId}) async {
    final queryParameters = {'user_id': userId};
    try {
      final response = await _dio.get('/recent-notes', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final recentNotes = PaginatedDataResponse<Note>.fromJson(response.data, Note.fromJson);
        return recentNotes;
      }
      throw 'Failed to load recent notes';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Recent Notes Error Message: $e');
      throw 'Failed to load recent notes';
    }
  }

  Future<bool> deleteNote({
    required int userId,
    required int categoryId,
    required int noteId,
  }) async {
    final queryParameters = {'user_id': userId, 'category_id': categoryId, 'note_id': noteId};
    try {
      final response = await _dio.delete('/note', queryParameters: queryParameters);
      return response.statusCode == 204;
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Recent Notes Error Message: $e');
      throw 'Failed to load recent notes';
    }
  }

  Future<Note?> updateNote({
    required int userId,
    required int noteId,
    required String title,
    required String content,
    required String delta,
  }) async {
    final data = {
      "user_id": userId,
      "note_id": noteId,
      "title": title,
      "content": content,
      "delta": delta,
    };
    try {
      final response = await _dio.put('/note', data: data);
      if (response.statusCode == 200) {
        return Note.fromJson(response.data);
      }
      throw 'Failed to update note';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Update Note Error Message: $e');
      throw 'Failed to update note';
    }
  }

  Future<PaginatedDataResponse<Note>?> searchforNotes({required String query}) async {
    try {
      final response = await _dio.post('/notes/$query');
      if (response.statusCode == 200) {
        final notes = PaginatedDataResponse<Note>.fromJson(response.data, Note.fromJson);
        return notes;
      }
      throw 'Failed to load notes';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Notes Error Message: $e');
      throw 'Failed to load notes';
    }
  }
}
