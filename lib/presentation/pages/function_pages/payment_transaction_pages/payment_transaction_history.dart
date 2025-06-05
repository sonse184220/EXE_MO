import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_model.dart';
import 'package:inner_child_app/domain/usecases/payment_usecase.dart';
import 'package:intl/intl.dart';

enum FilterBy { all, thisWeek, thisMonth, earlier }
enum TransactionStatusFilter { all, success, pending, failed }

class PaymentTransactionHistory extends ConsumerStatefulWidget {
  const PaymentTransactionHistory({super.key});

  @override
  ConsumerState<PaymentTransactionHistory> createState() => _PaymentTransactionHistoryState();
}

class _PaymentTransactionHistoryState extends ConsumerState<PaymentTransactionHistory> {
  late PaymentUsecase _paymentUsecase;

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  FilterBy _currentFilter = FilterBy.all;
  TransactionStatusFilter _statusFilter = TransactionStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _paymentUsecase = ref.read(paymentUseCaseProvider);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentUsecase.getPaymentTransactionHistory();
      setState(() {
        _transactions = result.data!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(FilterBy? newFilter) {
    if (newFilter != null) {
      setState(() {
        _currentFilter = newFilter;
      });
    }
  }

  void _onStatusFilterChanged(TransactionStatusFilter? newFilter) {
    if (newFilter != null) {
      setState(() {
        _statusFilter = newFilter;
      });
    }
  }

  String _getFilterDisplayName(FilterBy filter) {
    switch (filter) {
      case FilterBy.all:
        return 'All Time';
      case FilterBy.thisWeek:
        return 'This Week';
      case FilterBy.thisMonth:
        return 'This Month';
      case FilterBy.earlier:
        return 'Earlier';
    }
  }

  String _getStatusFilterDisplayName(TransactionStatusFilter filter) {
    switch (filter) {
      case TransactionStatusFilter.all:
        return 'All Status';
      case TransactionStatusFilter.success:
        return 'Success';
      case TransactionStatusFilter.pending:
        return 'Pending';
      case TransactionStatusFilter.failed:
        return 'Failed';
    }
  }

  String _getTimeCategory(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 7) {
      return 'This week';
    } else if (difference < 30) {
      return 'This month';
    } else {
      return 'Earlier';
    }
  }

  List<MapEntry<String, List<TransactionModel>>> _groupTransactionsByTime() {
    // First apply status filter
    List<TransactionModel> filteredTransactions = _transactions;

    if (_statusFilter != TransactionStatusFilter.all) {
      String targetStatus;
      switch (_statusFilter) {
        case TransactionStatusFilter.success:
          targetStatus = 'success';
          break;
        case TransactionStatusFilter.pending:
          targetStatus = 'pending';
          break;
        case TransactionStatusFilter.failed:
          targetStatus = 'failed';
          break;
        default:
          targetStatus = '';
      }

      filteredTransactions = _transactions.where((transaction) =>
      transaction.transactionStatus?.toLowerCase() == targetStatus ||
          transaction.transactionPaymentStatus?.toLowerCase() == targetStatus
      ).toList();
    }

    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in filteredTransactions) {
      final category = _getTimeCategory(transaction.transactionCreatedAt);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(transaction);
    }

    // Sort groups by time (This week, This month, Earlier)
    final sortedEntries = grouped.entries.toList();
    sortedEntries.sort((a, b) {
      const order = ['This week', 'This month', 'Earlier'];
      return order.indexOf(a.key).compareTo(order.indexOf(b.key));
    });

    return sortedEntries;
  }

  List<MapEntry<String, List<TransactionModel>>> _filterGroups(
      List<MapEntry<String, List<TransactionModel>>> groups,
      ) {
    if (_currentFilter == FilterBy.all) {
      return groups;
    }

    String targetCategory;
    switch (_currentFilter) {
      case FilterBy.thisWeek:
        targetCategory = 'This week';
        break;
      case FilterBy.thisMonth:
        targetCategory = 'This month';
        break;
      case FilterBy.earlier:
        targetCategory = 'Earlier';
        break;
      default:
        return groups;
    }

    return groups.where((group) => group.key == targetCategory).toList();
  }

  void _showTransactionDetail(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailModal(
        transaction: transaction,
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'failed':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline;

    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  String _formatAmount(int? amount, String? currency) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(
      symbol: currency ?? '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Transaction History',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Time filter
                  Row(
                    children: [
                      Text(
                        'Period:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<FilterBy>(
                              value: _currentFilter,
                              onChanged: _onFilterChanged,
                              items: FilterBy.values.map((FilterBy filter) {
                                return DropdownMenuItem<FilterBy>(
                                  value: filter,
                                  child: Text(
                                    _getFilterDisplayName(filter),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status filter
                  Row(
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TransactionStatusFilter>(
                              value: _statusFilter,
                              onChanged: _onStatusFilterChanged,
                              items: TransactionStatusFilter.values.map((filter) {
                                return DropdownMenuItem<TransactionStatusFilter>(
                                  value: filter,
                                  child: Text(
                                    _getStatusFilterDisplayName(filter),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8BC34A)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final groupedTransactions = _groupTransactionsByTime();
    final filteredGroups = _filterGroups(groupedTransactions);

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions found for selected filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8BC34A),
      onRefresh: _fetchTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = filteredGroups[groupIndex];
          final category = group.key;
          final transactions = group.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupIndex > 0) const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF689F38),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...transactions.map((transaction) => _buildTransactionItem(transaction)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final statusColor = _getStatusColor(
        transaction.transactionStatus ?? transaction.transactionPaymentStatus
    );
    final statusIcon = _getStatusIcon(
        transaction.transactionStatus ?? transaction.transactionPaymentStatus
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetail(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.subscriptionType ?? 'Subscription',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.transactionPaymentGateway ?? 'Payment Gateway',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(
                        transaction.transactionAmount,
                        transaction.transactionCurrency,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.transactionCreatedAt != null
                          ? DateFormat('dd MMM yyyy\nHH:mm a').format(
                        transaction.transactionCreatedAt!,
                      )
                          : 'N/A',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailModal extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionDetailModal({
    required this.transaction,
  });

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'failed':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(int? amount, String? currency) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(
      symbol: currency ?? '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(
        transaction.transactionStatus ?? transaction.transactionPaymentStatus
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (transaction.transactionStatus ??
                          transaction.transactionPaymentStatus ?? 'Unknown').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Transaction details
                  _buildDetailRow('Transaction ID', transaction.transactionId ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Amount', _formatAmount(
                    transaction.transactionAmount,
                    transaction.transactionCurrency,
                  )),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment Gateway',
                      transaction.transactionPaymentGateway ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Transaction Code',
                      transaction.transactionCode ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Date',
                      transaction.transactionCreatedAt != null
                          ? DateFormat('dd MMM yyyy HH:mm a').format(
                          transaction.transactionCreatedAt!)
                          : 'N/A'),
                  const SizedBox(height: 20),

                  // Subscription details
                  Text(
                    'Subscription Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Type', transaction.subscriptionType ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Subscription ID',
                      transaction.subscriptionId ?? 'N/A'),
                  const SizedBox(height: 16),

                  if (transaction.subscriptionDescription != null &&
                      transaction.subscriptionDescription!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            transaction.subscriptionDescription!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}