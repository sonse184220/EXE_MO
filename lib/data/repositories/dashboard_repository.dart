import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/dashboard_api_service.dart';
import 'package:inner_child_app/domain/entities/admin_view_dashboard_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';
import 'package:inner_child_app/domain/repositories/i_dashboard_repository.dart';

class DashboardRepository implements IDashboardRepository {
  final DashboardApiService apiService;

  DashboardRepository(this.apiService);

  @override
  Future<Result<TransactionAdminViewModel>> getSearchDashboardInfo(
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await apiService.getSearchDashboardInfo(
        startDate,
        endDate,
      );

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Error fetching dashboard info: $e');
    }
  }

  @override
  Future<Result<List<AdminViewDashboardModel>>> getRevenueStatistics() async {
    try {
      final response = await apiService.getRevenueStatistics();

      if (response.statusCode == 200) {
        final data = response.data as List;
        final items =
            data.map((e) => AdminViewDashboardModel.fromJson(e)).toList();

        return Result.success(items);
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Error fetching revenue statistics: $e');
    }
  }
}
