import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class DashboardApiService {
  final DioClient _client;

  DashboardApiService(this._client);

  Future<Response> getSearchDashboardInfo(
    String startDate,
    String endDate,
  ) async {
    return await _client.get(
      'innerchild/dashboard/search-dashboard-info?startDate=$startDate&endDate=$endDate',
    );
  }

  Future<Response> getRevenueStatistics() async {
    return await _client.get('innerchild/dashboard/revenue-statistics');
  }
}
