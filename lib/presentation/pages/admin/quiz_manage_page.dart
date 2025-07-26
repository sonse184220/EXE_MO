import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz/create_quiz_logic_score_model.dart';
import 'package:inner_child_app/domain/entities/quiz/create_quiz_model.dart';
import 'package:inner_child_app/domain/entities/quiz/create_quiz_option_model.dart';
import 'package:inner_child_app/domain/entities/quiz/create_quiz_question_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_answer_option_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_question_model.dart';
import 'package:inner_child_app/domain/entities/quiz_category/quiz_category_model.dart';
import 'package:inner_child_app/domain/usecases/quiz_usecase.dart';

class QuizManagePage extends ConsumerStatefulWidget {
  const QuizManagePage({super.key});

  @override
  ConsumerState<QuizManagePage> createState() => _QuizManagePageState();
}

class _QuizManagePageState extends ConsumerState<QuizManagePage> {
  late final QuizUsecase _quizUsecase;

  List<QuizModel> quizzes = [];

  bool isLoadQuiz = false;
  bool isQuizListError = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _fetchQuizzes() async {
    setState(() {
      isLoadQuiz = true;
      isQuizListError = false;
    });

    try {
      final result = await _quizUsecase.getAllQuizzes();

      if (result.isSuccess) {
        setState(() {
          quizzes = result.data!;
          isLoadQuiz = false;
        });
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } catch (_) {
      setState(() {
        isLoadQuiz = false;
        isQuizListError = true;
      });
    }
  }

  void _createQuiz() async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => QuizCreateModal(
            categoryList: [],
            onSave: (newQuiz) async {
              try {
                // final result = await _quizUsecase.createQuiz(newQuiz);
                final result = Result.success('');
                return result.isSuccess;
              } catch (_) {
                return false;
              } finally {
                _fetchQuizzes();
              }
            },
          ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Quiz created successfully');
    } else if (success == false) {
      Notify.showFlushbar('Failed to create Quiz', isError: true);
    }
  }

  // void _editQuiz(QuizModel quiz) async {
  //   final success = await showModalBottomSheet<bool>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder:
  //         (context) => QuizEditModal(
  //           quiz: quiz,
  //           onSave: (updatedQuiz) async {
  //             try {
  //               // final result = await _quizUsecase.updateQuiz(updatedQuiz);
  //               final result = Result.success('');
  //               return result.isSuccess;
  //             } catch (_) {
  //               return false;
  //             } finally {
  //               _fetchQuizzes();
  //             }
  //           },
  //         ),
  //   );
  //
  //   if (success ?? false) {
  //     Notify.showFlushbar('Quiz updated successfully');
  //   } else if (success == false) {
  //     Notify.showFlushbar('Failed to update Quiz', isError: true);
  //   }
  // }


  void _editQuiz(QuizModel quiz) async {
    final detailQuiz = await _quizUsecase.getQuizDetail(quiz.quizId!);
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizEditModal(
        quiz: detailQuiz.data!,
        categoryList: [], // Pass your category list here
        onSave: (updatedQuiz) async {
          try {
            // This callback is kept for compatibility but individual updates are handled within the modal
            _fetchQuizzes(); // Refresh the list after any update
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );

    // The individual update notifications are handled within the modal
    // So we just need to refresh the list when the modal closes
    if (success != null) {
      _fetchQuizzes();
    }
  }

  List<QuizModel> get filteredQuizzes {
    if (_searchQuery.isEmpty) return quizzes;
    return quizzes
        .where(
          (quiz) =>
              quiz.quizTitle?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true ||
              quiz.quizDescription?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true,
        )
        .toList();
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

  void _retryFetch() {
    _fetchQuizzes();
  }

  @override
  void initState() {
    super.initState();
    _quizUsecase = ref.read(quizUseCaseProvider);
    _fetchQuizzes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedQuizzes = filteredQuizzes;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quiz Management',
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
                        '${quizzes.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Quizzes',
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
                  child: const Icon(Icons.quiz, color: Colors.white, size: 24),
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
                hintText: 'Search by title or description',
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

          const SizedBox(height: 16),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Found ${displayedQuizzes.length} quiz${displayedQuizzes.length == 1 ? '' : 'zes'}',
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

          // Add Quiz Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createQuiz,
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
                    'Add New Quiz',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quiz List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildQuizContent(displayedQuizzes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(List<QuizModel> displayedQuizzes) {
    if (isLoadQuiz) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF89B7C2)),
            SizedBox(height: 16),
            Text(
              'Loading quizzes...',
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
            ),
          ],
        ),
      );
    }

    if (isQuizListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load quizzes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _retryFetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89B7C2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (displayedQuizzes.isEmpty) {
      return Center(
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
              _searchQuery.isEmpty ? 'No quizzes yet' : 'No quizzes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Create your first quiz to get started'
                  : 'Try adjusting your search terms',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: displayedQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = displayedQuizzes[index];
        return QuizListItem(
          quiz: quiz,
          onEdit: () => _editQuiz(quiz),
          searchQuery: _searchQuery,
        );
      },
    );
  }
}

class QuizListItem extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onEdit;
  final String searchQuery;

  const QuizListItem({
    super.key,
    required this.quiz,
    required this.onEdit,
    this.searchQuery = '',
  });

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
    final List<List<Color>> quizColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)],
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)],
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)],
      [const Color(0xFF89B7C2), const Color(0xFFE37083)],
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)],
    ];

    final colorIndex = (quiz.quizId?.hashCode.abs() ?? 0) % quizColors.length;
    final gradientColors = quizColors[colorIndex];

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
              child: Icon(Icons.quiz, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  quiz.quizTitle ?? 'Untitled Quiz',
                  searchQuery,
                ),
                const SizedBox(height: 4),
                if (quiz.quizDescription?.isNotEmpty == true) ...[
                  Text(
                    quiz.quizDescription!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8BF8A).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Max Score: ${quiz.quizMaxScore ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA8BF8A),
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
                        '${quiz.questions?.length ?? 0} Questions',
                        style: const TextStyle(
                          fontSize: 12,
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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF89B7C2).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF89B7C2),
                size: 20,
              ),
              onPressed: onEdit,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizCreateModal extends StatefulWidget {
  final List<QuizCategoryModel>
  categoryList; // You should fetch this from API or pass as prop
  final Future<bool> Function(CreateQuizModel) onSave;

  const QuizCreateModal({
    super.key,
    required this.categoryList,
    required this.onSave,
  });

  @override
  State<QuizCreateModal> createState() => _QuizCreateModalState();
}

class _QuizCreateModalState extends State<QuizCreateModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController();

  List<QuizCategoryModel> _categories = [];
  QuizCategoryModel? _selectedCategory;

  List<QuestionData> questions = [];
  bool _isLoading = false;

  List<LogicScoreData> logicScores = [];

  @override
  void initState() {
    super.initState();
    _categories = [
      QuizCategoryModel(quizCategoryId: '1', quizCategoryName: 'Math'),
      QuizCategoryModel(quizCategoryId: '2', quizCategoryName: 'Science'),
    ];
    logicScores.add(LogicScoreData());
  }

  void _addQuestion() => setState(() => questions.add(QuestionData()));

  void _removeQuestion(int index) => setState(() => questions.removeAt(index));

  void _addLogicScore() => setState(() => logicScores.add(LogicScoreData()));

  void _removeLogicScore(int index) =>
      setState(() => logicScores.removeAt(index));

  void _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final model = CreateQuizModel(
      quizTitle: _titleController.text.trim(),
      quizDescription: _descriptionController.text.trim(),
      quizMaxScore: int.tryParse(_maxScoreController.text.trim()) ?? 0,
      quizCategoryId: _selectedCategory?.quizCategoryId ?? '',
      quizzQuestions: questions.map((q) => q.toModel()).toList(),
      quizzLogicScores: logicScores.map((l) => l.toModel()).toList(),
    );

    try {
      final success = await widget.onSave(model);
      if (success && mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();

    for (final q in questions) {
      q.contentController.dispose();
      q.orderController.dispose();
      for (final o in q.options) {
        o.contentController.dispose();
        o.scoreController.dispose();
      }
    }

    for (final l in logicScores) {
      l.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Quiz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      _titleController,
                      'Quiz Title',
                      'Enter quiz title',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _descriptionController,
                      'Description',
                      'Enter quiz description',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(
                                _maxScoreController,
                                'Max Score',
                                'e.g. 100',
                                validator:
                                    (v) => v!.isEmpty ? 'Required' : null,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<QuizCategoryModel>(
                                isExpanded: true,
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  hintText: 'Select category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items:
                                    _categories.map((category) {
                                      return DropdownMenuItem<
                                        QuizCategoryModel
                                      >(
                                        value: category,
                                        child: Text(
                                          category.quizCategoryName ??
                                              'Unknown',
                                        ),
                                      );
                                    }).toList(),
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Please select a category'
                                            : null,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------------- QUESTIONS ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Question'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF89B7C2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ...questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      return QuestionForm(
                        questionData: questions[index],
                        index: index,
                        onRemove: () => _removeQuestion(index),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ---------------- LOGIC SCORES ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Result Logic Scores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addLogicScore,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Logic Score'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB876),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ...logicScores.asMap().entries.map((entry) {
                      final index = entry.key;
                      return LogicScoreForm(
                        logicScoreData: logicScores[index],
                        index: index,
                        onRemove: () => _removeLogicScore(index),
                      );
                    }),

                    const SizedBox(height: 32),

                    // ---------------- BUTTONS ----------------
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB876),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Create Quiz'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// class _QuizCreateModalState extends State<QuizCreateModal> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _maxScoreController = TextEditingController();
//
//   List<QuizCategoryModel> _categories =
//       []; // You should fetch this from API or pass as prop
//   QuizCategoryModel? _selectedCategory;
//
//   List<QuestionData> questions = [];
//   bool _isLoading = false;
//
//   List<LogicScoreData> logicScores = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _categories = [
//       QuizCategoryModel(quizCategoryId: '1', quizCategoryName: 'Math'),
//       QuizCategoryModel(quizCategoryId: '2', quizCategoryName: 'Science'),
//     ];
//
//     logicScores.add(LogicScoreData());
//   }
//
//   void _addQuestion() => setState(() => questions.add(QuestionData()));
//
//   void _removeQuestion(int index) => setState(() => questions.removeAt(index));
//
//   void _addLogicScore() => setState(() => logicScores.add(LogicScoreData()));
//
//   void _removeLogicScore(int index) => setState(() => logicScores.removeAt(index));
//
//   void _saveQuiz() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     final model = CreateQuizModel(
//       quizTitle: _titleController.text.trim(),
//       quizDescription: _descriptionController.text.trim(),
//       quizMaxScore: int.tryParse(_maxScoreController.text.trim()) ?? 0,
//       quizCategoryId: _selectedCategory?.quizCategoryId ?? '',
//       quizzQuestions: questions.map((q) => q.toModel()).toList(),
//       quizzLogicScores: logicScores.map((l) => l.toModel()).toList(),
//     );
//
//     try {
//       final success = await widget.onSave(model);
//       if (success && mounted) Navigator.pop(context, true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _maxScoreController.dispose();
//
//     for (final q in questions) {
//       q.contentController.dispose();
//       q.orderController.dispose();
//       for (final o in q.options) {
//         o.contentController.dispose();
//         o.scoreController.dispose();
//       }
//     }
//
//     for (final l in logicScores) {
//       l.dispose();
//     }
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       margin: const EdgeInsets.only(top: 50),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Create New Quiz',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//
//                     _buildTextField(
//                       _titleController,
//                       'Quiz Title',
//                       'Enter quiz title',
//                       validator: (v) => v!.isEmpty ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 16),
//
//                     _buildTextField(
//                       _descriptionController,
//                       'Description',
//                       'Enter quiz description',
//                     ),
//                     const SizedBox(height: 16),
//
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             children: [
//                               _buildTextField(
//                                 _maxScoreController,
//                                 'Max Score',
//                                'e.g. 100',
//                                 validator: (v) => v!.isEmpty ? 'Required' : null,
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Category',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               DropdownButtonFormField<QuizCategoryModel>(
//                                 isExpanded: true,
//                                 value: _selectedCategory,
//                                 decoration: InputDecoration(
//                                   hintText: 'Select category',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 16,
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.grey.shade50,
//                                 ),
//                                 items: _categories.map((category) {
//                                   return DropdownMenuItem<QuizCategoryModel>(
//                                     value: category,
//                                     child: Text(category.quizCategoryName ?? 'Unknown'),
//                                   );
//                                 }).toList(),
//                                 validator: (value) =>
//                                 value == null ? 'Please select a category' : null,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedCategory = value;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Questions',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: _addQuestion,
//                           icon: const Icon(Icons.add, size: 16),
//                           label: const Text('Add Question'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF89B7C2),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     ...questions.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       return QuestionForm(
//                         questionData: questions[index],
//                         index: index,
//                         onRemove: () => _removeQuestion(index),
//                       );
//                     }),
//
//                     const SizedBox(height: 32),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed:
//                                 _isLoading
//                                     ? null
//                                     : () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _saveQuiz,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFFFB876),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child:
//                                 _isLoading
//                                     ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                     : const Text('Create Quiz'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     String hint, {
//     String? Function(String?)? validator,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           validator: validator,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// Models
class QuestionData {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController orderController = TextEditingController();
  List<OptionData> options = [OptionData()];

  Map<String, dynamic> toJson() {
    return {
      "quizQuestionContent": contentController.text.trim(),
      "quizQuestionOrder": int.tryParse(orderController.text) ?? 0,
      "quizzOptions": options.map((e) => e.toJson()).toList(),
    };
  }

  CreateQuizQuestionModel toModel() => CreateQuizQuestionModel(
    quizQuestionContent: contentController.text.trim(),
    quizQuestionOrder: int.tryParse(orderController.text.trim()) ?? 0,
    quizzOptions: options.map((e) => e.toModel()).toList(),
  );

  void dispose() {
    contentController.dispose();
    orderController.dispose();
  }
}

class OptionData {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      "quizContent": contentController.text.trim(),
      "quizScoreValue": int.tryParse(scoreController.text) ?? 0,
    };
  }

  CreateQuizOptionModel toModel() => CreateQuizOptionModel(
    quizContent: contentController.text.trim(),
    quizScoreValue: int.tryParse(scoreController.text.trim()) ?? 0,
  );

  void dispose() {
    contentController.dispose();
    scoreController.dispose();
  }
}

// Question Form UI
class QuestionForm extends StatelessWidget {
  final QuestionData questionData;
  final int index;
  final VoidCallback onRemove;

  const QuestionForm({
    super.key,
    required this.questionData,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Q${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            TextFormField(
              controller: questionData.contentController,
              decoration: const InputDecoration(labelText: 'Question Content'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: questionData.orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Order'),
            ),
            const SizedBox(height: 12),
            Column(
              children:
                  questionData.options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: option.contentController,
                              decoration: const InputDecoration(
                                labelText: 'Option Text',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: option.scoreController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Score',
                              ),
                            ),
                          ),
                          if (questionData.options.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                questionData.options.removeAt(idx);
                                (context as Element).markNeedsBuild();
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  questionData.options.add(OptionData());
                  (context as Element).markNeedsBuild();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogicScoreData {
  final TextEditingController fromScoreController = TextEditingController();
  final TextEditingController toScoreController = TextEditingController();
  final TextEditingController resultLabelController = TextEditingController();
  final TextEditingController resultDescriptionController =
      TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController resultColorController = TextEditingController();

  CreateQuizLogicScoreModel toModel() => CreateQuizLogicScoreModel(
    fromScore: int.tryParse(fromScoreController.text.trim()) ?? 0,
    toScore: int.tryParse(toScoreController.text.trim()) ?? 0,
    resultLabel: resultLabelController.text.trim(),
    resultDescription: resultDescriptionController.text.trim(),
    priority: int.tryParse(priorityController.text.trim()) ?? 0,
    resultColor: resultColorController.text.trim(),
  );

  void dispose() {
    fromScoreController.dispose();
    toScoreController.dispose();
    resultLabelController.dispose();
    resultDescriptionController.dispose();
    priorityController.dispose();
    resultColorController.dispose();
  }
}

// 4. Add new LogicScoreForm widget:

class LogicScoreForm extends StatelessWidget {
  final LogicScoreData logicScoreData;
  final int index;
  final VoidCallback onRemove;

  const LogicScoreForm({
    super.key,
    required this.logicScoreData,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Result ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: logicScoreData.fromScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'From Score',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: logicScoreData.toScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'To Score',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: logicScoreData.resultLabelController,
              decoration: const InputDecoration(
                labelText: 'Result Label',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: logicScoreData.resultDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Result Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: logicScoreData.priorityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: logicScoreData.resultColorController,
                    decoration: const InputDecoration(
                      labelText: 'Result Color (hex)',
                      border: OutlineInputBorder(),
                      hintText: '#FFFFFF',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizEditModal extends ConsumerStatefulWidget {
  final QuizModel quiz;
  final List<QuizCategoryModel> categoryList;
  final Future<bool> Function(QuizModel) onSave;

  const QuizEditModal({
    super.key,
    required this.quiz,
    required this.categoryList,
    required this.onSave
  });

  @override
  ConsumerState<QuizEditModal> createState() => _QuizEditModalState();
}

class _QuizEditModalState extends ConsumerState<QuizEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _scoreController;
  late QuizUsecase _quizUsecase;

  QuizCategoryModel? _selectedCategory;
  List<QuizCategoryModel> _categories = [];

  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  // Controllers for current question and options
  late TextEditingController _questionController;
  final List<TextEditingController> _optionControllers = [];
  final List<TextEditingController> _scoreControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.quizTitle);
    _descController = TextEditingController(text: widget.quiz.quizDescription);
    _scoreController = TextEditingController(
      text: widget.quiz.quizMaxScore?.toString(),
    );

    _categories = widget.categoryList;
    _selectedCategory = _categories.firstWhere(
          (cat) => cat.quizCategoryId == widget.quiz.quizCategoryId,
      orElse: () => _categories.isNotEmpty ? _categories.first : QuizCategoryModel(quizCategoryId: '', quizCategoryName: ''),
    );

    _quizUsecase = ref.read(quizUseCaseProvider);
    _initializeQuestionControllers();
  }

  void _initializeQuestionControllers() {
    final currentQuestion = widget.quiz.questions?[_currentQuestionIndex];
    _questionController = TextEditingController(
      text: currentQuestion?.quizQuestionContent ?? '',
    );

    _optionControllers.clear();
    _scoreControllers.clear();

    if (currentQuestion?.options != null) {
      for (final option in currentQuestion!.options!) {
        _optionControllers.add(TextEditingController(text: option.quizContent));
        _scoreControllers.add(TextEditingController(text: option.quizScoreValue?.toString()));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _scoreController.dispose();
    _questionController.dispose();

    for (final controller in _optionControllers) {
      controller.dispose();
    }
    for (final controller in _scoreControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _updateQuizField() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // final updateModel = UpdateQuizModel(
      //   quizTitle: _titleController.text.trim(),
      //   quizDescription: _descController.text.trim(),
      //   quizMaxScore: int.tryParse(_scoreController.text.trim()),
      //   quizCategoryId: _selectedCategory?.quizCategoryId,
      // );

      // Call your update API here
      // final result = await _quizUsecase.updateQuiz(widget.quiz.quizId, updateModel);
      final result = Result.success('');

      if (result.isSuccess) {
        Notify.showFlushbar('Quiz updated successfully');
      } else {
        Notify.showFlushbar('Failed to update quiz', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error updating quiz', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuestion() async {
    if (_isLoading) return;

    final currentQuestion = widget.quiz.questions?[_currentQuestionIndex];
    if (currentQuestion == null) return;

    setState(() => _isLoading = true);

    try {
      // final updateModel = UpdateQuizQuestionModel(
      //   quizQuestionContent: _questionController.text.trim(),
      //   quizQuestionOrder: currentQuestion.quizQuestionOrder,
      // );

      // Call your update API here
      // final result = await _quizUsecase.updateQuestion(currentQuestion.quizQuestionId, updateModel);
      final result = Result.success('');

      if (result.isSuccess) {
        Notify.showFlushbar('Question updated successfully');
      } else {
        Notify.showFlushbar('Failed to update question', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error updating question', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOption(int optionIndex) async {
    if (_isLoading) return;

    final currentQuestion = widget.quiz.questions?[_currentQuestionIndex];
    if (currentQuestion?.options == null || optionIndex >= currentQuestion!.options!.length) return;

    final option = currentQuestion.options![optionIndex];

    setState(() => _isLoading = true);

    try {
      // final updateModel = UpdateQuizAnswerOptionModel(
      //   quizContent: _optionControllers[optionIndex].text.trim(),
      //   quizScoreValue: int.tryParse(_scoreControllers[optionIndex].text.trim()) ?? 0,
      // );

      // Call your update API here
      // final result = await _quizUsecase.updateOption(option.quizAnswerOptionId, updateModel);
      final result = Result.success('');

      if (result.isSuccess) {
        Notify.showFlushbar('Option updated successfully');
      } else {
        Notify.showFlushbar('Failed to update option', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error updating option', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
      _initializeQuestionControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions?[_currentQuestionIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Quiz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quiz Details Section
                    _buildTextField(
                      _titleController,
                      'Quiz Title',
                      'Enter quiz title',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _descController,
                      'Description',
                      'Enter quiz description',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _scoreController,
                            'Max Score',
                            'e.g. 100',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<QuizCategoryModel>(
                                isExpanded: true,
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  hintText: 'Select category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem<QuizCategoryModel>(
                                    value: category,
                                    child: Text(
                                      category.quizCategoryName ?? 'Unknown',
                                    ),
                                  );
                                }).toList(),
                                validator: (value) =>
                                value == null ? 'Please select a category' : null,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Update Quiz Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateQuizField,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF89B7C2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Update Quiz Info'),
                      ),
                    ),

                    const Divider(height: 32),

                    // Questions Section
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (widget.quiz.questions != null)
                      Wrap(
                        spacing: 8,
                        children: List.generate(
                          widget.quiz.questions!.length,
                              (index) => ChoiceChip(
                            label: Text('Q${index + 1}'),
                            selected: _currentQuestionIndex == index,
                            onSelected: (_) => _goToQuestion(index),
                            selectedColor: const Color(0xFF89B7C2),
                            labelStyle: TextStyle(
                              color: _currentQuestionIndex == index
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    if (currentQuestion != null) ...[
                      // Question Content
                      _buildTextField(
                        _questionController,
                        'Question Content',
                        'Enter question content',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Update Question Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8BF8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Update Question'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Options Section
                      const Text(
                        'Answer Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (currentQuestion.options != null)
                        ...currentQuestion.options!.asMap().entries.map((entry) {
                          final optionIndex = entry.key;
                          final option = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Option ${optionIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: TextFormField(
                                        controller: _optionControllers[optionIndex],
                                        decoration: InputDecoration(
                                          hintText: 'Answer content',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _scoreControllers[optionIndex],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Score',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () => _updateOption(optionIndex),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFB876),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('Update Option ${optionIndex + 1}'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],

                    const SizedBox(height: 32),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint, {
        String? Function(String?)? validator,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}


// class _QuizEditModalState extends State<QuizEditModal> {
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TextEditingController _scoreController;
//
//   int _currentQuestionIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.quiz.quizTitle);
//     _descController = TextEditingController(text: widget.quiz.quizDescription);
//     _scoreController = TextEditingController(
//       text: widget.quiz.quizMaxScore?.toString(),
//     );
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     _scoreController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateQuizField() async {
//     // call updateQuiz API for title/description/maxScore
//   }
//
//   Future<void> _updateQuestion(QuizQuestionModel question) async {
//     // call updateQuestion API with question.quizQuestionId and its fields
//   }
//
//   Future<void> _updateOption(QuizAnswerOptionModel option) async {
//     // call updateOption API with option.quizAnswerOptionId and its fields
//   }
//
//   void _goToQuestion(int index) {
//     setState(() => _currentQuestionIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final question = widget.quiz.questions?[_currentQuestionIndex];
//
//     return DraggableScrollableSheet(
//       expand: false,
//       builder:
//           (context, scrollController) => Container(
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: ListView(
//               controller: scrollController,
//               children: [
//                 const Text(
//                   'Edit Quiz',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _titleController,
//                   decoration: const InputDecoration(labelText: 'Title'),
//                   onSubmitted: (_) => _updateQuizField(),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _descController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   onSubmitted: (_) => _updateQuizField(),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _scoreController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Max Score'),
//                   onSubmitted: (_) => _updateQuizField(),
//                 ),
//                 const Divider(height: 32),
//                 if (widget.quiz.questions != null)
//                   Wrap(
//                     spacing: 8,
//                     children: List.generate(
//                       widget.quiz.questions!.length,
//                       (index) => ChoiceChip(
//                         label: Text('Q${index + 1}'),
//                         selected: _currentQuestionIndex == index,
//                         onSelected: (_) => _goToQuestion(index),
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 16),
//                 if (question != null) ...[
//                   TextField(
//                     controller: TextEditingController(
//                       text: question.quizQuestionContent,
//                     ),
//                     decoration: const InputDecoration(labelText: 'Question'),
//                     onSubmitted: (_) => _updateQuestion(question),
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     children:
//                         question.options?.map((option) {
//                           final optionContentCtrl = TextEditingController(
//                             text: option.quizContent,
//                           );
//                           final optionScoreCtrl = TextEditingController(
//                             text: option.quizScoreValue?.toString(),
//                           );
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 6.0),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 5,
//                                   child: TextField(
//                                     controller: optionContentCtrl,
//                                     decoration: const InputDecoration(
//                                       labelText: 'Answer',
//                                     ),
//                                     onSubmitted: (_) => _updateOption(option),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   flex: 2,
//                                   child: TextField(
//                                     controller: optionScoreCtrl,
//                                     keyboardType: TextInputType.number,
//                                     decoration: const InputDecoration(
//                                       labelText: 'Score',
//                                     ),
//                                     onSubmitted: (_) => _updateOption(option),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList() ??
//                         [],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//     );
//   }
// }
