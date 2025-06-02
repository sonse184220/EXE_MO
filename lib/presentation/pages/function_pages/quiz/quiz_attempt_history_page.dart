import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_detail_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_question_attempt_model.dart';
import 'package:inner_child_app/domain/usecases/quiz_attempt_usecase.dart';
import 'package:inner_child_app/domain/usecases/quiz_usecase.dart';
import 'package:intl/intl.dart';

enum FilterBy { all, thisWeek, thisMonth, earlier }

class QuizAttemptHistoryPage extends ConsumerStatefulWidget {
  const QuizAttemptHistoryPage({super.key});

  @override
  ConsumerState<QuizAttemptHistoryPage> createState() =>
      _QuizAttemptHistoryPageState();
}

class _QuizAttemptHistoryPageState
    extends ConsumerState<QuizAttemptHistoryPage> {
  late final QuizAttemptUsecase _attemptUsecase;

  List<QuizAttemptModel> _quizAttempts = [];
  late QuizAttemptDetailModel? _currentAttemptDetail;
  // Map<String, List<QuizAttemptDetailModel>> _expandedAttempts = {};
  final Set<String> _expandedQuizzes = {};

  bool _isLoading = true;
  bool _isLoadingDetail = false;
  String? _errorMessage;
  FilterBy _currentFilter = FilterBy.all;

  @override
  void initState() {
    super.initState();
    _attemptUsecase = ref.read(quizAttemptUseCaseProvider);
    _fetchQuizAttempts();
  }

  Future<void> _fetchQuizAttempts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _attemptUsecase.getAllQuizAttempts();
      setState(() {
        _quizAttempts = result.data!;
        // _expandedAttempts[quizId] = result.data!.;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQuizAttemptDetail(String quizAttemptId) async {
    setState(() {
      _isLoadingDetail = true;
      _errorMessage = null;
    });

    try {
      final result = await _attemptUsecase.getQuizAttemptDetail(quizAttemptId);
      if(result.isSuccess) {
        setState(() {
          _currentAttemptDetail = result.data!;
          // _expandedAttempts[quizId] = result.data!.;
          _isLoadingDetail = false;
        });
      }else{
        setState(() {
          _currentAttemptDetail = null;
          // _expandedAttempts[quizId] = result.data!.;
          _isLoadingDetail = false;
        });
        Notify.showFlushbar('Fetch attempt detail fail. Please try again!', isError: true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDetail = false;
      });
      Notify.showFlushbar('Error while fetcj attempt detail: $e', isError: true);

    }
  }

  // Future<void> _fetchQuizAttemptDetails(String quizId) async {
  //   if (_expandedAttempts.containsKey(quizId)) {
  //     return; // Already loaded
  //   }
  //
  //   setState(() {
  //     _isLoadingDetails = true;
  //   });
  //
  //   try {
  //     final result = await _attemptUsecase.getQuizAttemptDetail(quizId);
  //     if(result.isSuccess) {
  //       setState(() {
  //         _expandedAttempts[quizId] = result.data!;
  //         _isLoadingDetails = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoadingDetails = false;
  //     });
  //     Notify.showFlushbar('Failed to load attempt details: $e', isError: true);
  //   }
  // }

  void _onFilterChanged(FilterBy? newFilter) {
    if (newFilter != null) {
      setState(() {
        _currentFilter = newFilter;
      });
    }
  }

  String _getFilterDisplayName(FilterBy filter) {
    switch (filter) {
      case FilterBy.all:
        return 'All';
      case FilterBy.thisWeek:
        return 'This Week';
      case FilterBy.thisMonth:
        return 'This Month';
      case FilterBy.earlier:
        return 'Earlier';
    }
  }

  List<MapEntry<String, List<QuizAttemptModel>>> _groupQuizzesByTime() {
    final Map<String, List<QuizAttemptModel>> grouped = {};

    for (var quiz in _quizAttempts) {
      // Use the most recent attempt date for grouping
      DateTime? mostRecentDate;
      // if(quiz.attempts!.isEmpty) {
      //
      //     return;
      //
      // }
      for (var attempt in quiz.attempts!) {
        // Assuming attempt has createdAt field - adjust based on your model
        final attemptDate = attempt.quizUserAnswerCreatedAt ?? DateTime.now();
        if (mostRecentDate == null || attemptDate.isAfter(mostRecentDate)) {
          mostRecentDate = attemptDate;
        }
      }

      final category = _getTimeCategory(mostRecentDate ?? DateTime.now());
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(quiz);
    }

    // Sort groups by time
    final sortedEntries = grouped.entries.toList();
    sortedEntries.sort((a, b) {
      const order = ['This week', 'This month', 'Earlier'];
      return order.indexOf(a.key).compareTo(order.indexOf(b.key));
    });

    return sortedEntries;
  }

  List<MapEntry<String, List<QuizAttemptModel>>> _filterGroups(
      List<MapEntry<String, List<QuizAttemptModel>>> groups,
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

  String _getTimeCategory(DateTime date) {
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

  void _toggleQuizExpansion(String quizId) {
    setState(() {
      if (_expandedQuizzes.contains(quizId)) {
        _expandedQuizzes.remove(quizId);
      } else {
        _expandedQuizzes.add(quizId);
        // _fetchQuizAttemptDetails(quizId);
      }
    });
  }

  void _showAttemptDetail(QuizAttemptDetailModel attempt) async {
    await _fetchQuizAttemptDetail(attempt.quizUserAttemptId!);

    if(_currentAttemptDetail == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuizAttemptDetailModal(attempt: _currentAttemptDetail!),
    );
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
            'Quiz Attempt History',
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
            // Filter dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    'Filter by:',
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
              'Error loading quiz attempts',
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
              onPressed: _fetchQuizAttempts,
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

    if (_quizAttempts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No quiz attempts yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final groupedQuizzes = _groupQuizzesByTime();
    final filteredGroups = _filterGroups(groupedQuizzes);

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No attempts found for ${_getFilterDisplayName(_currentFilter)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8BC34A),
      onRefresh: _fetchQuizAttempts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = filteredGroups[groupIndex];
          final category = group.key;
          final quizzes = group.value;

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
              ...quizzes.map((quiz) => _buildQuizItem(quiz)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuizItem(QuizAttemptModel quiz) {
    // var isExpanded = false;
    final isExpanded = _expandedQuizzes.contains(quiz.quizId);
    // final attemptDetails = _expandedAttempts[quiz.quizId] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quiz header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:  BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(isExpanded ? 0 : 16),
                bottomRight: Radius.circular(isExpanded ? 0 : 16),
              ),
              onTap: () => _toggleQuizExpansion(quiz.quizId!),
              // onTap: () => setState(() {
              //   isExpanded = !isExpanded;
              // }),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BC34A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        color: Color(0xFF689F38),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.quizTitle ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quiz.attempts?.length} attempt${quiz.attempts?.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expanded attempts list
          if (isExpanded) ...[
            const Divider(height: 1, color: Colors.grey),
            // if (_isLoadingDetails)
            //   const Padding(
            //     padding: EdgeInsets.all(16),
            //     child: Center(
            //       child: CircularProgressIndicator(
            //         color: Color(0xFF8BC34A),
            //         strokeWidth: 2,
            //       ),
            //     ),
            //   )
            // else
              if (quiz.attempts!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No attempt details available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: quiz.attempts!.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final attempt = quiz.attempts![index];
                    return _buildAttemptItem(attempt);
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttemptItem(QuizAttemptDetailModel attempt) {
    // final scorePercentage = attempt.quizMaxScore > 0
    //     ? (attempt.quizzFinalScore / attempt.quizMaxScore * 100).round()
    //     : 0;

    final scorePercentage = (attempt.quizMaxScore ?? 0) > 0 && attempt.quizzFinalScore != null
        ? ((attempt.quizzFinalScore! / attempt.quizMaxScore!) * 100).round()
        : 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAttemptDetail(attempt),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getScoreColor(scorePercentage).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assignment_turned_in,
                  color: _getScoreColor(scorePercentage),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attempt Id: ${attempt.quizUserAttemptId}',
                      // 'Score: ${attempt.quizzFinalScore}/${attempt.quizMaxScore}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$scorePercentage%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getScoreColor(scorePercentage),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                attempt.quizUserAnswerCreatedAt != null
                    ? DateFormat('dd MMM\nHH:mm').format(attempt.quizUserAnswerCreatedAt!)
                    : '-',
                // DateFormat('dd MMM\nHH:mm').format(attempt.quizUserAnswerCreatedAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _QuizAttemptDetailModal extends StatelessWidget {
  final QuizAttemptDetailModel attempt;

  const _QuizAttemptDetailModal({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final scorePercentage = (attempt.quizMaxScore ?? 0) > 0 && attempt.quizzFinalScore != null
        ? ((attempt.quizzFinalScore! / attempt.quizMaxScore!) * 100).round()
        : 0;
    // final scorePercentage = attempt.quizMaxScore > 0
    //     ? (attempt.quizzFinalScore / attempt.quizMaxScore * 100).round()
    //     : 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                            'Quiz Attempt Detail',
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

                  // Quiz info
                  _buildDetailRow('Quiz', attempt.quizTitle ?? 'Unknown attempt title'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Description', attempt.quizDescription ?? 'Unknown attempt description'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status', attempt.quizStatus ?? 'Unknown attempt status'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Score',
                    '${attempt.quizzFinalScore}/${attempt.quizMaxScore} ($scorePercentage%)',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Date',
                    // DateFormat('dd MMM yyyy HH:mm a').format(attempt.quizUserAnswerCreatedAt),
                      attempt.quizUserAnswerCreatedAt != null
                          ? DateFormat('dd MMM yyyy HH:mm a').format(attempt.quizUserAnswerCreatedAt!)
                          : '-'
                  ),
                  const SizedBox(height: 20),

                  // Questions section
                  Text(
                    'Questions & Answers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: attempt.questions!.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final question = attempt.questions?[index];
                        return _buildQuestionCard(question!);
                      },
                    ),
                  ),
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
          width: 80,
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

  Widget _buildQuestionCard(QuizQuestionAttemptModel question) {
    final correctOption = question.options?.firstWhere(
          (option) => option.quizScoreValue == 1,
      orElse: () => question.options!.first,
    );
    final userSelectedOption = question.options?.firstWhere(
          (option) => option.quizAnswerOptionId == question.userSelectedOptionId,
      orElse: () => question.options!.first,
    );
    final isCorrect = userSelectedOption?.quizScoreValue == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Question ${question.quizQuestionOrder}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question content
          Text(
            question.quizQuestionContent ?? 'Unknown question content',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // User's answer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Answer:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        question.userSelectedAnswerText ?? 'Unknown answer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Correct answer (if user was wrong)
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Answer:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          correctOption?.quizContent ?? 'Unknown correct content',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}