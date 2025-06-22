import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_detail_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_detail_transactions_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/domain/usecases/payment_usecase.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/transaction/transaction_model.dart';

class TransactionManagePage extends ConsumerStatefulWidget {
  const TransactionManagePage({super.key});

  @override
  ConsumerState<TransactionManagePage> createState() =>
      _TransactionManagePageState();
}

class _TransactionManagePageState extends ConsumerState<TransactionManagePage> {
  late final PaymentUsecase _paymentUsecase;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // State management
  List<TransactionAdminViewModel> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _paymentUsecase = ref.read(
      paymentUseCaseProvider,
    ); // Initialize your usecase
    _fetchTransactions();
  }

  // Fetch transactions from PaymentUsecase
  Future<void> _fetchTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedTransactions =
          await _paymentUsecase.getTransactionsForAdmin();
      setState(() {
        transactions = fetchedTransactions.data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Get filtered transactions based on search query
  List<TransactionAdminViewModel> get filteredTransactions {
    if (_searchQuery.isEmpty) {
      return transactions;
    }
    return transactions
        .where(
          (transaction) => _transactionSearchFilter(transaction, _searchQuery),
        )
        .toList();
  }

  // Show transaction detail modal
  void _showTransactionDetail(TransactionAdminViewModel transaction) async {
    showDialog(
      context: context,
      builder:
          (context) => TransactionDetailModal(
            transactionId: transaction.transactionId!,
            paymentUsecase: _paymentUsecase,
          ),
    );
  }

  bool _transactionSearchFilter(
    TransactionAdminViewModel transaction,
    String query,
  ) {
    final searchQuery = query.toLowerCase();
    return (transaction.transactionCode?.toLowerCase().contains(searchQuery) ??
            false) ||
        (transaction.transactionPaymentGateway?.toLowerCase().contains(
              searchQuery,
            ) ??
            false) ||
        (transaction.subscriptionType?.toLowerCase().contains(searchQuery) ??
            false) ||
        (transaction.transactionStatus?.toLowerCase().contains(searchQuery) ??
            false) ||
        (transaction.transactionPaymentStatus?.toLowerCase().contains(
              searchQuery,
            ) ??
            false);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  double get totalAmount {
    return transactions
        .where((t) => t.transactionStatus == 'completed')
        .fold(0.0, (sum, t) => sum + (t.transactionAmount ?? 0) / 100.0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build error state with retry
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Failed to load transactions',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchTransactions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB876),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB876)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading transactions...',
            style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedTransactions = filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Transaction Management',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Section - Only show when not loading
          if (!isLoading && errorMessage == null)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF89B7C2).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${transactions.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total Transactions',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total Revenue',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar - Only show when not loading
          if (!isLoading && errorMessage == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by code, gateway, type, or status...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: _clearSearch,
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF89B7C2),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          if (!isLoading && errorMessage == null) const SizedBox(height: 16),

          // Search Results Info - Only show when not loading
          if (_searchQuery.isNotEmpty && !isLoading && errorMessage == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Found ${displayedTransactions.length} transaction${displayedTransactions.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          if (!isLoading && errorMessage == null) const SizedBox(height: 20),

          // Main Content Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child:
                  isLoading
                      ? _buildLoadingState()
                      : errorMessage != null
                      ? _buildErrorState()
                      : displayedTransactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.account_balance_wallet_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No transactions yet'
                                  : 'No transactions found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Transactions will appear here when available'
                                  : 'Try adjusting your search terms',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: displayedTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = displayedTransactions[index];
                          return TransactionListItem(
                            transaction: transaction,
                            onTap: () => _showTransactionDetail(transaction),
                            searchQuery: _searchQuery,
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final TransactionAdminViewModel transaction;
  final VoidCallback onTap;
  final String searchQuery;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.searchQuery = '',
  });

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
        return const Color(0xFFA8BF8A);
      case 'pending':
      case 'processing':
        return const Color(0xFFFFB876);
      case 'failed':
        return const Color(0xFFE37083);
      default:
        return Colors.grey;
    }
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      );
    }

    final startIndex = lowerText.indexOf(lowerQuery);
    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFB876),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> transactionColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)],
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)],
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)],
      [const Color(0xFF89B7C2), const Color(0xFFE37083)],
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)],
    ];

    // final colorIndex =
    //     int.parse(transaction.transactionId ?? '0') % transactionColors.length;
    final colorIndex = (transaction.transactionId?.hashCode ?? 0).abs() % transactionColors.length;
    final gradientColors = transactionColors[colorIndex];
    final amount = (transaction.transactionAmount ?? 0) / 100.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.receipt_long, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    transaction.transactionCode ?? 'N/A',
                    searchQuery,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.transactionPaymentGateway ?? 'N/A'} • \$${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            transaction.transactionStatus,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.transactionStatus?.toUpperCase() ??
                              'UNKNOWN',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(
                              transaction.transactionStatus,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF89B7C2).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.subscriptionType ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF89B7C2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF89B7C2), size: 24),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailModal extends StatefulWidget {
  final String transactionId;
  final PaymentUsecase paymentUsecase;

  const TransactionDetailModal({
    super.key,
    required this.transactionId,
    required this.paymentUsecase,
  });

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal> {
  TransactionDetailModel? transactionDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetail();
  }

  Future<void> _fetchTransactionDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final detail = await widget.paymentUsecase.getTransactionDetailForAdmin(
        widget.transactionId,
      );
      setState(() {
        transactionDetail = detail.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFFA8BF8A); // MEADOW
      case 'pending':
        return const Color(0xFFFFB876); // PAPAYA
      case 'failed':
      case 'cancelled':
        return const Color(0xFFE37083); // RASPBERRY
      default:
        return const Color(0xFF89B7C2); // SPRING SKY
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              isAmount
                  ? '\$${(int.parse(value) / 100).toStringAsFixed(2)}'
                  : value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionDetailTransactionsModel transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF89B7C2), // SPRING SKY
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  transaction.reference ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'LeagueSpartan',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Amount', transaction.amount?.toString() ?? '0', isAmount: true),
          _buildDetailRow('Account Number', transaction.accountNumber ?? 'N/A'),
          _buildDetailRow('Description', transaction.description ?? 'N/A'),
          _buildDetailRow('Transaction Date', formatDate(transaction.transactionDateTime)),
          if (transaction.counterAccountName != null)
            _buildDetailRow('Counter Account', transaction.counterAccountName!),
          if (transaction.counterAccountNumber != null)
            _buildDetailRow('Counter Account Number', transaction.counterAccountNumber!),
          if (transaction.counterAccountBankName != null)
            _buildDetailRow('Bank Name', transaction.counterAccountBankName!),
          if (transaction.counterAccountBankId != null)
            _buildDetailRow('Bank ID', transaction.counterAccountBankId!),
          if (transaction.virtualAccountName != null)
            _buildDetailRow('Virtual Account Name', transaction.virtualAccountName!),
          if (transaction.virtualAccountNumber != null)
            _buildDetailRow('Virtual Account Number', transaction.virtualAccountNumber!),
        ],
      ),
    );
  }

  String formatDate(DateTime? date, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    if (date == null) return 'N/A';
    return DateFormat(pattern).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                  // SPRING SKY to MEADOW
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'LeagueSpartan',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFB876),
                                    Color(0xFFFFCB7C),
                                  ],
                                  // PAPAYA to SUNSHINE
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Loading transaction details...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7F8C8D),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      )
                      : errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE37083,
                                  ).withOpacity(0.1),
                                  // RASPBERRY
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Color(0xFFE37083), // RASPBERRY
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Failed to load details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                  fontFamily: 'LeagueSpartan',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7F8C8D),
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _fetchTransactionDetail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB876),
                                  // PAPAYA
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'LeagueSpartan',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    transactionDetail?.status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      transactionDetail?.status,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  transactionDetail?.status?.toUpperCase() ??
                                      'UNKNOWN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getStatusColor(
                                      transactionDetail?.status,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'LeagueSpartan',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Transaction Overview
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE9ECEF),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF89B7C2),
                                                Color(0xFFA8BF8A),
                                              ], // SPRING SKY to MEADOW
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Transaction Overview',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C3E50),
                                            fontFamily: 'LeagueSpartan',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDetailRow(
                                      'Transaction ID',
                                      transactionDetail?.id ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      'Order Code',
                                      transactionDetail?.orderCode
                                              ?.toString() ??
                                          'N/A',
                                    ),
                                    _buildDetailRow(
                                      'Amount',
                                      transactionDetail?.amount?.toString() ??
                                          '0',
                                      isAmount: true,
                                    ),
                                    _buildDetailRow(
                                      'Amount Paid',
                                      transactionDetail?.amountPaid
                                              ?.toString() ??
                                          '0',
                                      isAmount: true,
                                    ),
                                    _buildDetailRow(
                                      'Amount Remaining',
                                      transactionDetail?.amountRemaining
                                              ?.toString() ??
                                          '0',
                                      isAmount: true,
                                    ),
                                    // _buildDetailRow('Created At', transactionDetail?.createdAt ?? 'N/A'),
                                    _buildDetailRow(
                                      'Created At',
                                      formatDate(transactionDetail?.createdAt),
                                    ),
                                    if (transactionDetail?.canceledAt != null)
                                      _buildDetailRow(
                                        'Canceled At',
                                        formatDate(
                                          transactionDetail?.canceledAt,
                                        ),
                                      ),
                                    if (transactionDetail?.cancellationReason !=
                                        null)
                                      _buildDetailRow(
                                        'Cancellation Reason',
                                        transactionDetail!.cancellationReason!,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Transaction Items
                              if (transactionDetail?.transactions != null && transactionDetail!.transactions!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFB876), Color(0xFFFFCB7C)], // PAPAYA to SUNSHINE
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Transaction Items (${transactionDetail!.transactions!.length})',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                        fontFamily: 'LeagueSpartan',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...transactionDetail!.transactions!.map((transaction) => _buildTransactionItem(transaction)),
                              ],
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
