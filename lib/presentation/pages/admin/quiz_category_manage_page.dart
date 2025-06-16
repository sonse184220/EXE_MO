import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/domain/entities/quiz_category/quiz_category_model.dart';

class QuizCategoryManagePage extends ConsumerStatefulWidget {
  const QuizCategoryManagePage({super.key});

  @override
  ConsumerState<QuizCategoryManagePage> createState() => _QuizCategoryManagePageState();
}

class _QuizCategoryManagePageState extends ConsumerState<QuizCategoryManagePage> {
  List<QuizCategoryModel> quizCategories = [];
  bool isLoadCategory = false;
  bool isCategoryListError = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _fetchQuizCategories() async {
    setState(() {
      isLoadCategory = true;
      isCategoryListError = false;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      final mockCategories = [
        QuizCategoryModel(
          quizCategoryId: '1',
          quizCategoryName: 'General Knowledge',
          quizCategoryDescription: 'Questions about various topics and general information',
        ),
        QuizCategoryModel(
          quizCategoryId: '2',
          quizCategoryName: 'Science',
          quizCategoryDescription: 'Physics, Chemistry, Biology and Earth Sciences',
        ),
        QuizCategoryModel(
          quizCategoryId: '3',
          quizCategoryName: 'History',
          quizCategoryDescription: 'World history, ancient civilizations, and historical events',
        ),
      ];

      setState(() {
        quizCategories = mockCategories;
        isLoadCategory = false;
      });
    } catch (_) {
      setState(() {
        isLoadCategory = false;
        isCategoryListError = true;
      });
    }
  }

  void _createQuizCategory() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: QuizCategoryForm(
            onSave: (newCategory) async {
              try {
                // Simulate API call
                await Future.delayed(const Duration(seconds: 1));

                // Mock success - replace with actual API call
                setState(() {
                  quizCategories.add(QuizCategoryModel(
                    quizCategoryId: DateTime.now().millisecondsSinceEpoch.toString(),
                    quizCategoryName: newCategory.quizCategoryName,
                    quizCategoryDescription: newCategory.quizCategoryDescription,
                  ));
                });

                return true;
              } catch (_) {
                return false;
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz Category created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create Quiz Category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateQuizCategory(QuizCategoryModel category) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: QuizCategoryForm(
            quizCategory: category,
            onSave: (updated) async {
              try {
                // Simulate API call
                await Future.delayed(const Duration(seconds: 1));

                // Mock success - replace with actual API call
                setState(() {
                  final index = quizCategories.indexWhere((c) => c.quizCategoryId == updated.quizCategoryId);
                  if (index != -1) {
                    quizCategories[index] = updated;
                  }
                });

                return true;
              } catch (_) {
                return false;
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<QuizCategoryModel> get filteredQuizCategories {
    if (_searchQuery.isEmpty) return quizCategories;
    return quizCategories.where((category) =>
    category.quizCategoryName!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (category.quizCategoryDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
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
  void initState() {
    super.initState();
    _fetchQuizCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCategories = filteredQuizCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quiz Category Management',
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
                        '${quizCategories.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Quiz Categories',
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
                    Icons.quiz,
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
                hintText: 'Search by category name or description',
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
                    'Found ${displayedCategories.length} categor${displayedCategories.length == 1 ? 'y' : 'ies'}',
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

          // Add Quiz Category Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createQuizCategory,
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
                    'Add New Quiz Category',
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

          // Loading, Error, or Categories List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoadCategory
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF89B7C2),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading quiz categories...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              )
                  : isCategoryListError
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchQuizCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF89B7C2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : displayedCategories.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.quiz_outlined : Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No quiz categories yet'
                          : 'No quiz categories found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Add your first quiz category to get started'
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
                itemCount: displayedCategories.length,
                itemBuilder: (context, index) {
                  final category = displayedCategories[index];
                  return QuizCategoryListItem(
                    quizCategory: category,
                    onEdit: () => _updateQuizCategory(category),
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

class QuizCategoryListItem extends StatelessWidget {
  final QuizCategoryModel quizCategory;
  final VoidCallback onEdit;
  final String searchQuery;

  const QuizCategoryListItem({
    super.key,
    required this.quizCategory,
    required this.onEdit,
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
    // Generate a harmonious color for each quiz category
    final List<List<Color>> categoryColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)], // Raspberry to Ice Cream
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)], // Papaya to Sunshine
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)], // Meadow to Spring Sky
      [const Color(0xFF89B7C2), const Color(0xFFE37083)], // Spring Sky to Raspberry
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)], // Ice Cream to Meadow
    ];

    final colorIndex = (quizCategory.quizCategoryId?.hashCode.abs() ?? 0) % categoryColors.length;
    final gradientColors = categoryColors[colorIndex];

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
                Icons.quiz,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(quizCategory.quizCategoryName ?? '', searchQuery),
                const SizedBox(height: 4),
                if (quizCategory.quizCategoryDescription != null && quizCategory.quizCategoryDescription!.isNotEmpty) ...[
                  Text(
                    quizCategory.quizCategoryDescription!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F8C8D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'ID: ${quizCategory.quizCategoryId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95A5A6),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8BF8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Quiz Category',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA8BF8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        ],
      ),
    );
  }
}

class QuizCategoryForm extends StatefulWidget {
  final QuizCategoryModel? quizCategory;
  final Future<bool> Function(QuizCategoryModel) onSave;

  const QuizCategoryForm({
    super.key,
    this.quizCategory,
    required this.onSave,
  });

  @override
  State<QuizCategoryForm> createState() => _QuizCategoryFormState();
}

class _QuizCategoryFormState extends State<QuizCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoryNameController;
  late final TextEditingController _categoryDescriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final category = widget.quizCategory;
    _categoryNameController = TextEditingController(text: category?.quizCategoryName ?? '');
    _categoryDescriptionController = TextEditingController(text: category?.quizCategoryDescription ?? '');
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final category = QuizCategoryModel(
        quizCategoryId: widget.quizCategory?.quizCategoryId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        quizCategoryName: _categoryNameController.text.trim(),
        quizCategoryDescription: _categoryDescriptionController.text.trim().isEmpty
            ? null
            : _categoryDescriptionController.text.trim(),
      );

      try {
        final success = await widget.onSave(category);
        if (success && mounted) {
          Navigator.pop(context, true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
      constraints: const BoxConstraints(maxHeight: 500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.quizCategory == null ? 'Add New Quiz Category' : 'Edit Quiz Category',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Category Name',
                controller: _categoryNameController,
                hint: 'Enter quiz category name',
                prefixIcon: const Icon(Icons.quiz, color: Color(0xFF89B7C2)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  if (value.length < 2) {
                    return 'Category name must be at least 2 characters';
                  }
                  return null;
                },
                helpText: 'Choose a clear, descriptive name for your quiz category',
              ),
              const SizedBox(height: 20),
              _buildFormField(
                label: 'Description',
                controller: _categoryDescriptionController,
                hint: 'Enter category description (optional)',
                prefixIcon: const Icon(Icons.description, color: Color(0xFF89B7C2)),
                isRequired: false,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 10) {
                    return 'Description must be at least 10 characters if provided';
                  }
                  return null;
                },
                helpText: 'Provide details about what this category covers',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                      onPressed: _isLoading ? null : _saveForm,
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
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        widget.quizCategory == null ? 'Save' : 'Update',
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
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }
}