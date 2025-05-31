import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class MoodJournalTypeApiService {
  final DioClient _client;

  MoodJournalTypeApiService(this._client);

  Future<Response> getAllTypes() {
    return _client.get('innerchild/moodjournal/all-types');
  }
}