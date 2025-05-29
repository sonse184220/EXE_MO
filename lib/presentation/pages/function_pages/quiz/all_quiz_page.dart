import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/usecases/quiz_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/quiz/quiz_taking_page.dart';

class AllQuizPage extends ConsumerStatefulWidget {
  const AllQuizPage({super.key});

  @override
  ConsumerState<AllQuizPage> createState() => _AllQuizPageState();
}

class _AllQuizPageState extends ConsumerState<AllQuizPage> {
  // late final QuizCategoryUsecase _quizCategoryUsecase;
  // late final QuizSubcategoryUsecase _quizSubcategoryUsecase;
  late final QuizUsecase _quizUseCase;

  List<QuizModel> allQuizList = [];
  List<QuizModel> filteredQuizList = [];
  List<QuizCategory> categories = [];
  List<SubQuizCategoryModel> allSubCategories = [];

  bool isLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize use cases
    // _quizCategoryUsecase = ref.read(quizCategoryUseCaseProvider);
    // _quizSubcategoryUsecase = ref.read(quizSubcategoryUseCaseProvider);
    _quizUseCase = ref.read(quizUseCaseProvider);

    // Load data after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // final quizResult = await _quizUseCase.getAllQuizzes();
      final loadedCategories = await _loadCategories();
      final loadedSubCategories = await _loadSubCategories();

      throw Error();

      // setState(() {
      //   allQuizList = quizResult.data!;
      //   filteredQuizList = List.from(allQuizList);
      //   isLoading = false;
      // });
    } catch (e) {
      final mockQuizList = [
        QuizModel(
          quizId: 'q1',
          quizTitle: 'General Anxiety Test',
          quizDescription: 'Measure your general level of anxiety.',
          subQuizCategoryId: '1',
          questionCount: 10,
          estimatedDuration: 5,
          quizDifficulty: 'Easy',
          quizIsPremium: false,
        ),
        QuizModel(
          quizId: 'q2',
          quizTitle: 'Social Anxiety Assessment',
          quizDescription: 'Understand your level of social anxiety.',
          subQuizCategoryId: '1',
          questionCount: 8,
          estimatedDuration: 4,
          quizDifficulty: 'Medium',
          quizIsPremium: false,
        ),
        QuizModel(
          quizId: 'q3',
          quizTitle: 'Depression Self-Check',
          quizDescription: 'Quick screening for depressive symptoms.',
          subQuizCategoryId: '2',
          questionCount: 12,
          estimatedDuration: 6,
          quizDifficulty: 'Medium',
          quizIsPremium: false,
        ),
        QuizModel(
          quizId: 'q4',
          quizTitle: 'Major Depression Inventory',
          quizDescription: 'Detailed depression scale assessment.',
          subQuizCategoryId: '2',
          questionCount: 15,
          estimatedDuration: 8,
          quizDifficulty: 'Hard',
          quizIsPremium: true,
        ),
        QuizModel(
          quizId: 'q5',
          quizTitle: 'Big Five Personality Traits',
          quizDescription: 'Find out where you stand in the Big Five.',
          subQuizCategoryId: '3',
          questionCount: 25,
          estimatedDuration: 12,
          quizDifficulty: 'Medium',
          quizIsPremium: false,
        ),
        QuizModel(
          quizId: 'q6',
          quizTitle: 'Mindfulness Awareness Test',
          quizDescription: 'Measure your present-moment awareness.',
          subQuizCategoryId: '4',
          questionCount: 10,
          estimatedDuration: 5,
          quizDifficulty: 'Easy',
          quizIsPremium: false,
        ),
        QuizModel(
          quizId: 'q7',
          quizTitle: 'Emotional Intimacy Scale',
          quizDescription: 'Gauge emotional closeness in relationships.',
          subQuizCategoryId: '5',
          questionCount: 12,
          estimatedDuration: 6,
          quizDifficulty: 'Medium',
          quizIsPremium: true,
        ),
      ];

      setState(() {
        allQuizList = mockQuizList;
        filteredQuizList = List.from(mockQuizList);
        isLoading = false;
      });
      debugPrint('Error loading data: $e');
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  Future<List<QuizCategory>> _loadCategories() async {
    try {
      throw Error();
      // final result = await _quizCategoryUsecase.getAllQuizCategories();
      // final loadedCategories = result.data!;

      // setState(() {
      //   categories = loadedCategories;
      // });
      //
      // return loadedCategories;
    } catch (e) {
      debugPrint('Error loading categories: $e');

      final mockCategories = [
        QuizCategory(
          quizCategoryId: '1',
          quizCategoryName: 'Self-Assessment',
          subQuizCategories: [],
        ),
        QuizCategory(
          quizCategoryId: '2',
          quizCategoryName: 'Personality',
          subQuizCategories: [],
        ),
        QuizCategory(
          quizCategoryId: '3',
          quizCategoryName: 'Mental Health',
          subQuizCategories: [],
        ),
        QuizCategory(
          quizCategoryId: '4',
          quizCategoryName: 'Mindfulness',
          subQuizCategories: [],
        ),
        QuizCategory(
          quizCategoryId: '5',
          quizCategoryName: 'Relationships',
          subQuizCategories: [],
        ),
      ];

      setState(() {
        categories = mockCategories;
      });

      return mockCategories;
    }
  }

  Future<List<SubQuizCategoryModel>> _loadSubCategories() async {
    try {
      throw Error();
      // final result = await _quizSubcategoryUsecase.getAllSubQuizCategories();
      // final loadedSubCategories = result.data!;
      //
      // setState(() {
      //   allSubCategories = loadedSubCategories;
      // });
      //
      // return loadedSubCategories;
    } catch (e) {
      debugPrint('Error loading subcategories: $e');

      final mockSubCategories = [
        SubQuizCategoryModel(
          subQuizCategoryId: '1',
          subQuizCategoryName: 'Anxiety Assessment',
          quizCategoryId: '1',
          quizCategoryName: 'Self-Assessment',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '2',
          subQuizCategoryName: 'Depression Scale',
          quizCategoryId: '1',
          quizCategoryName: 'Self-Assessment',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '3',
          subQuizCategoryName: 'Big Five Traits',
          quizCategoryId: '2',
          quizCategoryName: 'Personality',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '4',
          subQuizCategoryName: 'Myers-Briggs Type',
          quizCategoryId: '2',
          quizCategoryName: 'Personality',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '5',
          subQuizCategoryName: 'Stress Level',
          quizCategoryId: '3',
          quizCategoryName: 'Mental Health',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '6',
          subQuizCategoryName: 'Emotional Intelligence',
          quizCategoryId: '3',
          quizCategoryName: 'Mental Health',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '7',
          subQuizCategoryName: 'Awareness Practice',
          quizCategoryId: '4',
          quizCategoryName: 'Mindfulness',
        ),
        SubQuizCategoryModel(
          subQuizCategoryId: '8',
          subQuizCategoryName: 'Love Languages',
          quizCategoryId: '5',
          quizCategoryName: 'Relationships',
        ),
      ];

      setState(() {
        allSubCategories = mockSubCategories;
      });

      return mockSubCategories;
    }
  }

  void _filterQuizzesBySubCategory() {
    setState(() {
      if (selectedSubCategoryId == null) {
        filteredQuizList = allQuizList.where((quiz) {
          return searchQuery.isEmpty ||
              (quiz.quizTitle?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false) ||
              (quiz.quizDescription?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false);
        }).toList();
      } else {
        filteredQuizList = allQuizList.where((quiz) {
          bool matchesSearch = searchQuery.isEmpty ||
              (quiz.quizTitle?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false) ||
              (quiz.quizDescription?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false);

          bool matchesSubCategory =
              quiz.subQuizCategoryId == selectedSubCategoryId;

          return matchesSearch && matchesSubCategory;
        }).toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterQuizzesBySubCategory();
  }

  void _clearFilters() {
    setState(() {
      selectedCategoryId = null;
      selectedSubCategoryId = null;
      searchQuery = '';
      _searchController.clear();
      filteredQuizList = List.from(allQuizList);
    });
  }

  List<SubQuizCategoryModel> _getSubCategoriesForCategory(String categoryId) {
    return allSubCategories
        .where((sub) => sub.quizCategoryId == categoryId)
        .toList();
  }

  String _formatQuizInfo(QuizModel quiz) {
    final questionCount = quiz.questionCount ?? 0;
    final duration = quiz.estimatedDuration ?? 10;
    return '$questionCount questions • ${duration}min';
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                color: const Color(0xFF4B3621),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: (screenHeight * 1 / 2) * 0.6,
                      child: Image.asset(
                        'assets/images/quiz_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header Section
                          _buildHeader(),

                          const SizedBox(height: 20),

                          // Search and Filter Row
                          _buildSearchAndFilterRow(),

                          const SizedBox(height: 16),

                          // Active Filters Display
                          if (selectedSubCategoryId != null || searchQuery.isNotEmpty)
                            _buildActiveFilters(),

                          const SizedBox(height: 16),

                          // Quiz List
                          Expanded(
                            child: isLoading ? _buildLoadingState() : _buildQuizList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Quiz Library',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (selectedSubCategoryId != null || searchQuery.isNotEmpty)
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search quizzes...',
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha((0.7 * 255).round()),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Button
        GestureDetector(
          onTap: _showFilterModal,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 20,
                ),
                if (selectedSubCategoryId != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (selectedSubCategoryId != null) ...[
            _buildFilterChip(
              _getSubCategoryName(selectedSubCategoryId!),
                  () {
                setState(() {
                  selectedSubCategoryId = null;
                  selectedCategoryId = null;
                });
                _filterQuizzesBySubCategory();
              },
            ),
            const SizedBox(width: 8),
          ],
          if (searchQuery.isNotEmpty) ...[
            _buildFilterChip(
              'Search: "$searchQuery"',
                  () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Filter Quizzes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Dropdown
                      _buildCategoryDropdown(setModalState),

                      const SizedBox(height: 24),

                      // Subcategory Section
                      if (selectedCategoryId != null) ...[
                        const Text(
                          'Subcategory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSubcategoryList(setModalState),
                      ],
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _filterQuizzesBySubCategory();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          hint: const Text('Select Category'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.quizCategoryId,
                child: Text(category.quizCategoryName),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setModalState(() {
              selectedCategoryId = value;
              selectedSubCategoryId = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(StateSetter setModalState) {
    final subCategories = _getSubCategoriesForCategory(selectedCategoryId!);

    if (subCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No subcategories available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: subCategories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          final isSelected = selectedSubCategoryId == subCategory.subQuizCategoryId;

          return GestureDetector(
            onTap: () {
              setModalState(() {
                if (selectedSubCategoryId == subCategory.subQuizCategoryId) {
                  selectedSubCategoryId = null;
                } else {
                  selectedSubCategoryId = subCategory.subQuizCategoryId;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subCategory.subQuizCategoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.orange.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSubCategoryName(String subCategoryId) {
    try {
      final subCategory = allSubCategories.firstWhere(
            (sub) => sub.subQuizCategoryId == subCategoryId,
      );
      return subCategory.subQuizCategoryName;
    } catch (e) {
      return 'Selected Subcategory';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildQuizList() {
    if (filteredQuizList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.white.withAlpha((0.6 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'No quizzes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha((0.8 * 255).round()),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha((0.6 * 255).round()),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredQuizList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final quiz = filteredQuizList[index];
        return _buildQuizCard(quiz: quiz);
      },
    );
  }

  Widget _buildQuizCard({required QuizModel quiz}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quiz Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.quiz,
              color: Colors.orange,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Quiz Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizTitle ?? 'Untitled Quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (quiz.quizDescription != null)
                  Text(
                    quiz.quizDescription!,
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  _formatQuizInfo(quiz),
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (quiz.quizDifficulty != null)
                      _buildTag(quiz.quizDifficulty!, _getDifficultyColor(quiz.quizDifficulty!)),
                    if (quiz.quizIsPremium == true)
                      _buildTag('Premium', Colors.amber),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Start Quiz Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizTakingPage(quizId: "1",),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class QuizModel {
  final String? quizId;
  final String? quizTitle;
  final String? quizDescription;
  final String? subQuizCategoryId;
  final int? questionCount;
  final int? estimatedDuration;
  final String? quizDifficulty;
  final bool? quizIsPremium;

  QuizModel({
    this.quizId,
    this.quizTitle,
    this.quizDescription,
    this.subQuizCategoryId,
    this.questionCount,
    this.estimatedDuration,
    this.quizDifficulty,
    this.quizIsPremium,
  });
}

class QuizCategory {
  final String quizCategoryId;
  final String quizCategoryName;
  final List<SubQuizCategoryModel> subQuizCategories;

  QuizCategory({
    required this.quizCategoryId,
    required this.quizCategoryName,
    required this.subQuizCategories,
  });
}

class SubQuizCategoryModel {
  final String subQuizCategoryId;
  final String subQuizCategoryName;
  final String quizCategoryId;
  final String quizCategoryName;

  SubQuizCategoryModel({
    required this.subQuizCategoryId,
    required this.subQuizCategoryName,
    required this.quizCategoryId,
    required this.quizCategoryName,
  });
}
