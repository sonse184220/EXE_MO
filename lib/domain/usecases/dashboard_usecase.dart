import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/admin_view_dashboard_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';
import 'package:inner_child_app/domain/repositories/i_dashboard_repository.dart';

class DashboardUsecase {
  final IDashboardRepository iDashboardRepository;

  DashboardUsecase(this.iDashboardRepository);

  Future<Result<TransactionAdminViewModel>> getSearchDashboardInfo(String startDate, String endDate) {
    return iDashboardRepository.getSearchDashboardInfo(startDate, endDate);
  }

  Future<Result<List<AdminViewDashboardModel>>> getRevenueStatistics() {
    return iDashboardRepository.getRevenueStatistics();
  }
}
