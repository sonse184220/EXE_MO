import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';

class MoodJournalApiService {
  final DioClient _client;

  MoodJournalApiService(this._client);

  Future<Response> logMood(LogMoodJournalRequest request) {
    final dataObject = request.toJson();
    return _client.post('innerchild/moodjournal/add-log', data: dataObject);
  }
}