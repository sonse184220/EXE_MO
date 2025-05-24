import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/widgets/reusable_crud_base_page/entity_list_screen.dart';

class UserManagePage extends StatefulWidget {


  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  // final Customer customer = null;
  // final VoidCallback onEdit;
  // final VoidCallback onDelete;
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

  //Customer customer

  void _createCustomer() async {
    final newCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => Dialog(
        child: CustomerForm(
          onSave: (newCustomer) => Navigator.pop(context, newCustomer),
        ),
      ),
    );

    if (newCustomer != null) {
      // Replace with real API call
      setState(() => customers.add(newCustomer));
    }
    // setState(() {
    //   customers.add(customer);
    // });
  }

  void _updateCustomer(Customer customer) async {
    final updatedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => Dialog(
        child: CustomerForm(
          customer: customer,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );

    if (updatedCustomer != null) {
      // Replace this with actual API call to update
      _updateCustomer(updatedCustomer);
    }
    // setState(() {
    //   final index = customers.indexWhere((c) => c.id == customer.id);
    //   if (index != -1) {
    //     customers[index] = customer;
    //   }
    // });
  }

  void _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Replace this with actual API call to delete
      setState(() {
        customers.removeWhere((c) => c.id == customer.id);
      });
    }
    // setState(() {
    //   customers.removeWhere((c) => c.id == customer.id);
    // });
  }

  // Custom search function for Customer entity
  bool _customerSearchFilter(Customer customer, String query) {
    return customer.name.toLowerCase().contains(query) ||
        customer.email.toLowerCase().contains(query) ||
        customer.phone.toLowerCase().contains(query) ||
        customer.accountNumber.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return EntityListScreen<Customer>(
      title: 'Customer List',
      entities: customers,
      onCreateEntity: (customer) => _createCustomer(),
      onUpdateEntity: (customer) => _updateCustomer(customer),
      onDeleteEntity: (customer) => _deleteCustomer(customer),
      searchFilter: _customerSearchFilter, // Now required parameter
      itemBuilder: (context, customer, onEdit, onDelete) {
        return CustomerListItem(
          customer: customer,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
      formBuilder: (context, customer, onSave) {
        return CustomerForm(
          customer: customer,
          onSave: onSave,
        );
      },
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

// Example usage - Customer Item Widget
class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: customer.imageUrl.isNotEmpty
                ? NetworkImage(customer.imageUrl) as ImageProvider
                : const AssetImage('assets/default_avatar.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[600]),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// Customer Form Widget
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'First Name*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'Enter first name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Last Name*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Enter last name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Phone Number*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '+1 (555) 000-0000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Text('US'),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 18),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Date Of Birth*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
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
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _birthDate.month.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _birthDate.day.toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _birthDate.year.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Bank Account Number*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                hintText: 'Enter account number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an account number';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Valid Bank Account Number Required',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Email*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'name@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Valid Email Address Required',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(widget.customer == null ? 'Save' : 'Update'),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}
