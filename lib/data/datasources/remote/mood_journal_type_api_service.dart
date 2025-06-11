import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class MoodJournalTypeApiService {
  final DioClient _client;

  MoodJournalTypeApiService(this._client);

  Future<Response> getAllTypes() {
    return _client.get('innerchild/moodjournal/all-types');
  }

  Future<Response> createType(String typeName) {
    final dataObject = {"moodJournalTypeName": typeName};
    return _client.post('innerchild/moodjournal/create-type', data: dataObject);
  }

  Future<Response> updateType(String id, String typeName) {
    final dataObject = {"moodJournalTypeName": typeName};
    return _client.put(
      'innerchild/moodjournal/update-type/$id',
      data: dataObject,
    );
  }
}
