import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/admin_view_dashboard_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';

abstract class IDashboardRepository {
  Future<Result<TransactionAdminViewModel>> getSearchDashboardInfo(String startDate, String endDate);
  Future<Result<List<AdminViewDashboardModel>>> getRevenueStatistics();
}
