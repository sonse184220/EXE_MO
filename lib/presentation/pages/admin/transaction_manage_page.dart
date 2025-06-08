import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class TransactionManagePage extends ConsumerStatefulWidget {
  const TransactionManagePage({super.key});
  @override
  ConsumerState<TransactionManagePage> createState() => _TransactionManagePageState();
}

class _TransactionManagePageState extends ConsumerState<TransactionManagePage> {
  late final AuthUsecase _authUsecase;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<TransactionModel> transactions = [
    TransactionModel(
      transactionId: '1',
      transactionPaymentGateway: 'Stripe',
      transactionAmount: 2999,
      transactionCurrency: 'USD',
      transactionStatus: 'completed',
      transactionPaymentStatus: 'paid',
      transactionCode: 'TXN_001',
      transactionCreatedAt: DateTime(2024, 1, 15),
      subscriptionType: 'Premium',
      subscriptionDescription: 'Premium subscription with all features',
      subscriptionId: 'SUB_PREMIUM_001',
    ),
    TransactionModel(
      transactionId: '2',
      transactionPaymentGateway: 'PayPal',
      transactionAmount: 1999,
      transactionCurrency: 'USD',
      transactionStatus: 'pending',
      transactionPaymentStatus: 'processing',
      transactionCode: 'TXN_002',
      transactionCreatedAt: DateTime(2024, 2, 10),
      subscriptionType: 'Basic',
      subscriptionDescription: 'Basic subscription with core features',
      subscriptionId: 'SUB_BASIC_002',
    ),
    TransactionModel(
      transactionId: '3',
      transactionPaymentGateway: 'Square',
      transactionAmount: 4999,
      transactionCurrency: 'USD',
      transactionStatus: 'completed',
      transactionPaymentStatus: 'paid',
      transactionCode: 'TXN_003',
      transactionCreatedAt: DateTime(2024, 3, 5),
      subscriptionType: 'Enterprise',
      subscriptionDescription: 'Enterprise subscription with advanced features',
      subscriptionId: 'SUB_ENTERPRISE_003',
    ),
    TransactionModel(
      transactionId: '4',
      transactionPaymentGateway: 'Stripe',
      transactionAmount: 2999,
      transactionCurrency: 'USD',
      transactionStatus: 'failed',
      transactionPaymentStatus: 'failed',
      transactionCode: 'TXN_004',
      transactionCreatedAt: DateTime(2024, 3, 20),
      subscriptionType: 'Premium',
      subscriptionDescription: 'Premium subscription with all features',
      subscriptionId: 'SUB_PREMIUM_004',
    ),
    TransactionModel(
      transactionId: '5',
      transactionPaymentGateway: 'PayPal',
      transactionAmount: 1999,
      transactionCurrency: 'USD',
      transactionStatus: 'completed',
      transactionPaymentStatus: 'paid',
      transactionCode: 'TXN_005',
      transactionCreatedAt: DateTime(2024, 4, 12),
      subscriptionType: 'Basic',
      subscriptionDescription: 'Basic subscription with core features',
      subscriptionId: 'SUB_BASIC_005',
    ),
  ];

  // Get filtered transactions based on search query
  List<TransactionModel> get filteredTransactions {
    if (_searchQuery.isEmpty) {
      return transactions;
    }
    return transactions.where((transaction) => _transactionSearchFilter(transaction, _searchQuery)).toList();
  }

  void _createTransaction() async {
    final newTransaction = await showDialog<TransactionModel>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: TransactionForm(
          onSave: (newTransaction) => Navigator.pop(context, newTransaction),
        ),
      ),
    );
    if (newTransaction != null) {
      setState(() => transactions.add(newTransaction));
    }
  }

  void _updateTransaction(TransactionModel transaction) async {
    final updatedTransaction = await showDialog<TransactionModel>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: TransactionForm(
          transaction: transaction,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );
    if (updatedTransaction != null) {
      setState(() {
        final index = transactions.indexWhere((t) => t.transactionId == transaction.transactionId);
        if (index != -1) {
          transactions[index] = updatedTransaction;
        }
      });
    }
  }

  void _deleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete transaction ${transaction.transactionCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF49AA2).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE37083))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        transactions.removeWhere((t) => t.transactionId == transaction.transactionId);
      });
    }
  }

  bool _transactionSearchFilter(TransactionModel transaction, String query) {
    final searchQuery = query.toLowerCase();
    return (transaction.transactionCode?.toLowerCase().contains(searchQuery) ?? false) ||
        (transaction.transactionPaymentGateway?.toLowerCase().contains(searchQuery) ?? false) ||
        (transaction.subscriptionType?.toLowerCase().contains(searchQuery) ?? false) ||
        (transaction.transactionStatus?.toLowerCase().contains(searchQuery) ?? false) ||
        (transaction.transactionPaymentStatus?.toLowerCase().contains(searchQuery) ?? false);
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

  @override
  Widget build(BuildContext context) {
    final displayedTransactions = filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Management',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats Section
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
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

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by code, gateway, type, or status...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
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
                  borderSide: const BorderSide(color: Color(0xFF89B7C2), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
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
                  if (_searchQuery.isNotEmpty) ...[
                    Text(
                      ' for "${_searchQuery}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Add Transaction Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB876),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFFB876).withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add New Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Transaction List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: displayedTransactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.account_balance_wallet_outlined : Icons.search_off,
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
                          ? 'Add your first transaction to get started'
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
                    onEdit: () => _updateTransaction(transaction),
                    onDelete: () => _deleteTransaction(transaction),
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

class TransactionModel {
  final String? transactionId;
  final String? transactionPaymentGateway;
  final int? transactionAmount;
  final String? transactionCurrency;
  final String? transactionStatus;
  final String? transactionPaymentStatus;
  final String? transactionCode;
  final DateTime? transactionCreatedAt;
  final String? subscriptionType;
  final String? subscriptionDescription;
  final String? subscriptionId;

  TransactionModel({
    this.transactionId,
    this.transactionPaymentGateway,
    this.transactionAmount,
    this.transactionCurrency,
    this.transactionStatus,
    this.transactionPaymentStatus,
    this.transactionCode,
    this.transactionCreatedAt,
    this.subscriptionType,
    this.subscriptionDescription,
    this.subscriptionId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] as String?,
      transactionPaymentGateway: json['transactionPaymentGateway'] as String?,
      transactionAmount: json['transactionAmount'] as int?,
      transactionCurrency: json['transactionCurrency'] as String?,
      transactionStatus: json['transactionStatus'] as String?,
      transactionPaymentStatus: json['transactionPaymentStatus'] as String?,
      transactionCode: json['transactionCode'] as String?,
      transactionCreatedAt: json['transactionCreatedAt'] != null
          ? DateTime.tryParse(json['transactionCreatedAt'])
          : null,
      subscriptionType: json['subscriptionType'] as String?,
      subscriptionDescription: json['subscriptionDescription'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionPaymentGateway': transactionPaymentGateway,
      'transactionAmount': transactionAmount,
      'transactionCurrency': transactionCurrency,
      'transactionStatus': transactionStatus,
      'transactionPaymentStatus': transactionPaymentStatus,
      'transactionCode': transactionCode,
      'transactionCreatedAt': transactionCreatedAt?.toIso8601String(),
      'subscriptionType': subscriptionType,
      'subscriptionDescription': subscriptionDescription,
      'subscriptionId': subscriptionId,
    };
  }
}

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String searchQuery;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
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

    final colorIndex = int.parse(transaction.transactionId ?? '0') % transactionColors.length;
    final gradientColors = transactionColors[colorIndex];
    final amount = (transaction.transactionAmount ?? 0) / 100.0;

    return Container(
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
              child: Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(transaction.transactionCode ?? 'N/A', searchQuery),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.transactionStatus).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.transactionStatus?.toUpperCase() ?? 'UNKNOWN',
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(transaction.transactionStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF89B7C2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF89B7C2), size: 20),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE37083).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE37083), size: 20),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;
  final Function(TransactionModel) onSave;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.onSave,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _transactionCodeController;
  late final TextEditingController _amountController;
  late final TextEditingController _subscriptionIdController;
  late final TextEditingController _subscriptionDescriptionController;

  String _selectedPaymentGateway = 'Stripe';
  String _selectedCurrency = 'USD';
  String _selectedStatus = 'pending';
  String _selectedPaymentStatus = 'processing';
  String _selectedSubscriptionType = 'Basic';
  DateTime _transactionDate = DateTime.now();

  final List<String> _paymentGateways = ['Stripe', 'PayPal', 'Square', 'Razorpay'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY'];
  final List<String> _statuses = ['pending', 'completed', 'failed', 'cancelled'];
  final List<String> _paymentStatuses = ['processing', 'paid', 'failed', 'refunded'];
  final List<String> _subscriptionTypes = ['Basic', 'Premium', 'Enterprise'];

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _transactionCodeController = TextEditingController(text: transaction.transactionCode);
      _amountController = TextEditingController(
        text: transaction.transactionAmount != null
            ? (transaction.transactionAmount! / 100.0).toStringAsFixed(2)
            : '',
      );
      _subscriptionIdController = TextEditingController(text: transaction.subscriptionId);
      _subscriptionDescriptionController = TextEditingController(text: transaction.subscriptionDescription);
      _selectedPaymentGateway = transaction.transactionPaymentGateway ?? 'Stripe';
      _selectedCurrency = transaction.transactionCurrency ?? 'USD';
      _selectedStatus = transaction.transactionStatus ?? 'pending';
      _selectedPaymentStatus = transaction.transactionPaymentStatus ?? 'processing';
      _selectedSubscriptionType = transaction.subscriptionType ?? 'Basic';
      _transactionDate = transaction.transactionCreatedAt ?? DateTime.now();
    } else {
      _transactionCodeController = TextEditingController();
      _amountController = TextEditingController();
      _subscriptionIdController = TextEditingController();
      _subscriptionDescriptionController = TextEditingController();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final transaction = TransactionModel(
        transactionId: widget.transaction?.transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        transactionCode: _transactionCodeController.text.trim(),
        transactionPaymentGateway: _selectedPaymentGateway,
        transactionAmount: (amount * 100).round(),
        transactionCurrency: _selectedCurrency,
        transactionStatus: _selectedStatus,
        transactionPaymentStatus: _selectedPaymentStatus,
        transactionCreatedAt: _transactionDate,
        subscriptionType: _selectedSubscriptionType,
        subscriptionDescription: _subscriptionDescriptionController.text.trim(),
        subscriptionId: _subscriptionIdController.text.trim(),
      );
      widget.onSave(transaction);
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildFormField(
              label: 'Transaction Code',
              controller: _transactionCodeController,
              hint: 'Enter transaction code',
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
            _buildFormField(
              label: 'Amount (e.g. 9.99)',
              controller: _amountController,
              hint: 'Enter amount',
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
            _buildDropdown(
              label: 'Payment Gateway',
              value: _selectedPaymentGateway,
              items: _paymentGateways,
              onChanged: (val) => setState(() => _selectedPaymentGateway = val!),
            ),
            _buildDropdown(
              label: 'Currency',
              value: _selectedCurrency,
              items: _currencies,
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),
            _buildDropdown(
              label: 'Transaction Status',
              value: _selectedStatus,
              items: _statuses,
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            _buildDropdown(
              label: 'Payment Status',
              value: _selectedPaymentStatus,
              items: _paymentStatuses,
              onChanged: (val) => setState(() => _selectedPaymentStatus = val!),
            ),
            _buildDropdown(
              label: 'Subscription Type',
              value: _selectedSubscriptionType,
              items: _subscriptionTypes,
              onChanged: (val) => setState(() => _selectedSubscriptionType = val!),
            ),
            _buildFormField(
              label: 'Subscription ID',
              controller: _subscriptionIdController,
              hint: 'Enter subscription ID',
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
            _buildFormField(
              label: 'Subscription Description',
              controller: _subscriptionDescriptionController,
              hint: 'Enter description',
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB876),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.transaction == null ? 'Save' : 'Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transactionCodeController.dispose();
    _amountController.dispose();
    _subscriptionIdController.dispose();
    _subscriptionDescriptionController.dispose();
    super.dispose();
  }
}
