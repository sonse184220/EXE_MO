import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class UserManagePage extends ConsumerStatefulWidget {
  const UserManagePage({super.key});
  @override
  ConsumerState<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends ConsumerState<UserManagePage> {
  late final AuthUsecase _authUsecase;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Customer> customers = [
    Customer(
      id: '1',
      name: 'Jane Lopez',
      description: 'Customer since 2021',
      imageUrl: 'https://example.com/jane.jpg',
      email: 'jennifer.lopez@email.com',
      phone: '+1 (555) 123-4567',
      accountNumber: '12345678',
      birthDate: DateTime(1990, 5, 10),
    ),
    Customer(
      id: '2',
      name: 'Kathy Murphy',
      description: 'Customer since 2019',
      imageUrl: 'https://example.com/kathy.jpg',
      email: 'kathy.murphy@email.com',
      phone: '+1 (555) 234-5678',
      accountNumber: '23456789',
      birthDate: DateTime(1985, 3, 15),
    ),
    Customer(
      id: '3',
      name: 'Harry Oldman',
      description: 'Customer since 2022',
      imageUrl: 'https://example.com/harry.jpg',
      email: 'harry.oldman@email.com',
      phone: '+1 (555) 345-6789',
      accountNumber: '34567890',
      birthDate: DateTime(1992, 8, 20),
    ),
    Customer(
      id: '4',
      name: 'Harry Potter',
      description: 'Customer since 2020',
      imageUrl: 'https://example.com/potter.jpg',
      email: 'harry.potter@email.com',
      phone: '+1 (555) 456-7890',
      accountNumber: '45678901',
      birthDate: DateTime(1980, 7, 31),
    ),
    Customer(
      id: '5',
      name: 'John Oldman',
      description: 'Customer since 2018',
      imageUrl: 'https://example.com/john.jpg',
      email: 'kathy.Murphy@email.com',
      phone: '+1 (555) 567-8901',
      accountNumber: '56789012',
      birthDate: DateTime(1975, 12, 5),
    ),
  ];

  // Get filtered customers based on search query
  List<Customer> get filteredCustomers {
    if (_searchQuery.isEmpty) {
      return customers;
    }
    return customers.where((customer) => _customerSearchFilter(customer, _searchQuery)).toList();
  }

  void _createCustomer() async {
    final newCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: CustomerForm(
          onSave: (newCustomer) => Navigator.pop(context, newCustomer),
        ),
      ),
    );
    if (newCustomer != null) {
      setState(() => customers.add(newCustomer));
    }
  }

  void _updateCustomer(Customer customer) async {
    final updatedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: CustomerForm(
          customer: customer,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );
    if (updatedCustomer != null) {
      setState(() {
        final index = customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          customers[index] = updatedCustomer;
        }
      });
    }
  }

  void _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
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
        customers.removeWhere((c) => c.id == customer.id);
      });
    }
  }

  bool _customerSearchFilter(Customer customer, String query) {
    final searchQuery = query.toLowerCase();
    return customer.name.toLowerCase().contains(searchQuery) ||
        customer.email.toLowerCase().contains(searchQuery) ||
        customer.phone.toLowerCase().contains(searchQuery) ||
        customer.accountNumber.toLowerCase().contains(searchQuery);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCustomers = filteredCustomers;

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
          'Customer Management',
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
                        '${customers.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Customers',
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
                    Icons.people_outline,
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
                hintText: 'Search by name, email, phone, or account number...',
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
                    'Found ${displayedCustomers.length} customer${displayedCustomers.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    Text(
                      ' for "$_searchQuery"',
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

          // Add Customer Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createCustomer,
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
                    'Add New Customer',
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

          // Customer List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: displayedCustomers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No customers yet'
                          : 'No customers found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Add your first customer to get started'
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
                itemCount: displayedCustomers.length,
                itemBuilder: (context, index) {
                  final customer = displayedCustomers[index];
                  return CustomerListItem(
                    customer: customer,
                    onEdit: () => _updateCustomer(customer),
                    onDelete: () => _deleteCustomer(customer),
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

class Customer {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String email;
  final String phone;
  final String accountNumber;
  final DateTime birthDate;

  Customer({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.email,
    required this.phone,
    required this.accountNumber,
    required this.birthDate,
  });
}

class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String searchQuery;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  // Helper method to highlight search terms
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
    // Generate a harmonious color for each customer
    final List<List<Color>> customerColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)], // Raspberry to Ice Cream
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)], // Papaya to Sunshine
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)], // Meadow to Spring Sky
      [const Color(0xFF89B7C2), const Color(0xFFE37083)], // Spring Sky to Raspberry
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)], // Ice Cream to Meadow
    ];

    final colorIndex = int.parse(customer.id) % customerColors.length;
    final gradientColors = customerColors[colorIndex];

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
            child: Center(
              child: Text(
                customer.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(customer.name, searchQuery),
                const SizedBox(height: 4),
                Text(
                  customer.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8BF8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA8BF8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSave;

  const CustomerForm({
    super.key,
    this.customer,
    required this.onSave,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _accountNumberController;
  DateTime _birthDate = DateTime(1990, 1, 1);

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      final nameParts = customer.name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      _firstNameController = TextEditingController(text: firstName);
      _lastNameController = TextEditingController(text: lastName);
      _emailController = TextEditingController(text: customer.email);
      _phoneController = TextEditingController(text: customer.phone);
      _accountNumberController = TextEditingController(text: customer.accountNumber);
      _birthDate = customer.birthDate;
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _accountNumberController = TextEditingController();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final name = '${_firstNameController.text} ${_lastNameController.text}';
      final customer = Customer(
        id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: 'Customer since ${DateTime.now().year}',
        imageUrl: widget.customer?.imageUrl ?? '',
        email: _emailController.text,
        phone: _phoneController.text,
        accountNumber: _accountNumberController.text,
        birthDate: _birthDate,
      );
      widget.onSave(customer);
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    bool isRequired = true,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF89B7C2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: validator,
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer == null ? 'Add New Customer' : 'Edit Customer',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'First Name',
                controller: _firstNameController,
                hint: 'Enter first name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Enter last name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: '+1 (555) 000-0000',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Of Birth*',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _birthDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _birthDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFAFA),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today_outlined, color: const Color(0xFF7F8C8D), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Bank Account Number',
                controller: _accountNumberController,
                hint: 'Enter account number',
                helpText: 'Valid Bank Account Number Required',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Email',
                controller: _emailController,
                hint: 'name@email.com',
                helpText: 'Valid Email Address Required',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFBDC3C7)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: const Color(0xFFFFB876).withOpacity(0.4),
                      ),
                      child: Text(
                        widget.customer == null ? 'Save' : 'Update',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}