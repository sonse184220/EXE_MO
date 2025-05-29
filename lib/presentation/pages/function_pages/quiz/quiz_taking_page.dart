import 'package:flutter/material.dart';

// Models
class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  Quiz({required this.id, required this.title, required this.questions});
}

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  // final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    // required this.correctAnswerIndex,
    required this.explanation,
  });
}

class UserAnswer {
  final String questionId;
  final int selectedIndex;
  // final bool isCorrect;

  UserAnswer({
    required this.questionId,
    required this.selectedIndex,
    // required this.isCorrect,
  });
}

// Main Quiz Taking Page
class QuizTakingPage extends StatefulWidget {
  final String quizId;

  const QuizTakingPage({super.key, required this.quizId});

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  Quiz? quiz;
  PageController pageController = PageController();
  int currentQuestionIndex = 0;
  List<UserAnswer> userAnswers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  // Simulate API call to fetch quiz data
  Future<void> _fetchQuizData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Fake data with longer options to test view more functionality
    final fakeQuiz = Quiz(
      id: widget.quizId,
      title: "Math Quiz",
      questions: [
        Question(
          id: "1",
          questionText: "If David's age is 27 years old in 2011. What was his age in 2003?",
          options: [
            "19 years - This is the correct answer because we need to subtract 8 years from his current age",
            "37 years - This would be his age if we added 8 years instead of subtracting",
            "20 years - This is close but not quite right, off by one year",
            "17 years - This would be if we subtracted 10 years instead of 8 years"
          ],
          // correctAnswerIndex: 0,
          explanation: "David was 27 in 2011. To find his age in 2003, we subtract 8 years (2011 - 2003 = 8). So 27 - 8 = 19 years old.",
        ),
        Question(
          id: "2",
          questionText: "What is the result of 25 × 4?",
          options: [
            "90 - This would be the result if we calculated 25 × 3.6 approximately",
            "100 - This is the correct answer: 25 × 4 = 100",
            "110 - This is too high, perhaps from miscalculating 25 × 4.4",
            "120 - This would be closer to 25 × 5 but still not accurate"
          ],
          // correctAnswerIndex: 1,
          explanation: "25 × 4 = 100. You can think of it as 25 × 4 = (20 + 5) × 4 = 80 + 20 = 100.",
        ),
        Question(
          id: "3",
          questionText: "If a rectangle has length 12 cm and width 8 cm, what is its perimeter?",
          options: ["40 cm", "48 cm", "96 cm", "20 cm"],
          // correctAnswerIndex: 0,
          explanation: "Perimeter = 2(length + width) = 2(12 + 8) = 2(20) = 40 cm.",
        ),
        Question(
          id: "4",
          questionText: "What is 15% of 200?",
          options: ["25", "30", "35", "40"],
          // correctAnswerIndex: 1,
          explanation: "15% of 200 = (15/100) × 200 = 0.15 × 200 = 30.",
        ),
        Question(
          id: "5",
          questionText: "What is the square root of 144?",
          options: ["11", "12", "13", "14"],
          // correctAnswerIndex: 1,
          explanation: "√144 = 12, because 12 × 12 = 144.",
        ),
      ],
    );

    setState(() {
      quiz = fakeQuiz;
      isLoading = false;
    });
  }

  void _selectAnswer(int selectedIndex) {
    if (quiz == null) return;

    final currentQuestion = quiz!.questions[currentQuestionIndex];
    final questionId = currentQuestion.id;

    // Check if user already answered this question
    final existingIndex = userAnswers.indexWhere((a) => a.questionId == questionId);

    if (existingIndex != -1) {
      // Replace existing answer
      userAnswers[existingIndex] = UserAnswer(
        questionId: questionId,
        selectedIndex: selectedIndex,
      );
    } else {
      // Add new answer
      userAnswers.add(UserAnswer(
        questionId: questionId,
        selectedIndex: selectedIndex,
      ));
    }

    setState(() {});
  }

  UserAnswer? _getUserAnswer(String questionId) {
    try {
      return userAnswers.firstWhere((answer) => answer.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quiz!.questions.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToQuestion(int questionIndex) {
    pageController.animateToPage(
      questionIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showQuestionNavigationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionNavigationModal(
        questions: quiz!.questions,
        userAnswers: userAnswers,
        currentQuestionIndex: currentQuestionIndex,
        onQuestionSelected: (index) {
          Navigator.pop(context);
          _goToQuestion(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5E6D3),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    if (quiz == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5E6D3),
        body: const Center(
          child: Text("Failed to load quiz"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Progress Bar
            _buildProgressBar(),
            // Quiz Content
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentQuestionIndex = index;
                  });
                },
                itemCount: quiz!.questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(quiz!.questions[index]);
                },
              ),
            ),
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF8B4513),
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              quiz!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: _showQuestionNavigationModal,
            child: const Text(
              "Questions",
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${currentQuestionIndex + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              Text(
                "/${quiz!.questions.length}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / quiz!.questions.length,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question) {
    final userAnswer = _getUserAnswer(question.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Question Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = userAnswer?.selectedIndex == index;
            // final isCorrect = index == question.correctAnswerIndex;
            final showResult = userAnswer != null;
            final hasAnswer = userAnswer != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ExpandableOptionButton(
                text: option,
                isSelected: isSelected,
                // isCorrect: isCorrect,
                // showResult: showResult,
                // isDisabled: false, // Disable if already answered
                onTap: () => _selectAnswer(index),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Explanation (if answer is selected)
          if (userAnswer != null)
            _buildExplanation(question.explanation),
        ],
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return ExpandableExplanation(explanation: explanation);
  }

  Widget _buildNavigationButtons() {
    final hasAnswer = _getUserAnswer(quiz!.questions[currentQuestionIndex].id) != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (currentQuestionIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  foregroundColor: const Color(0xFF8B4513),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Previous",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (currentQuestionIndex > 0) const SizedBox(width: 12),
          if (currentQuestionIndex < quiz!.questions.length - 1 && hasAnswer)
            Expanded(
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (currentQuestionIndex == quiz!.questions.length - 1 && hasAnswer)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle quiz completion
                  _showQuizResults();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Finish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showQuizResults() {
    final correctAnswers = userAnswers.length;
    final totalQuestions = quiz!.questions.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Text(
          "You answered $correctAnswers out of $totalQuestions questions correctly.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

// Expandable Option Button Widget
class ExpandableOptionButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  // final bool isCorrect;
  // final bool showResult;
  // final bool isDisabled;
  final VoidCallback onTap;

  const ExpandableOptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    // required this.isCorrect,
    // required this.showResult,
    // required this.isDisabled,
    required this.onTap,
  });

  @override
  State<ExpandableOptionButton> createState() => _ExpandableOptionButtonState();
}

class _ExpandableOptionButtonState extends State<ExpandableOptionButton> {
  bool isExpanded = false;
  bool needsExpansion = false;

  @override
  void initState() {
    super.initState();
    // Check if text is long enough to need expansion
    needsExpansion = widget.text.length > 80; // Adjust threshold as needed
  }

  @override
  Widget build(BuildContext context) {
    // Color backgroundColor;
    // Color textColor;
    // Widget? trailingIcon;

    final backgroundColor = widget.isSelected ? const Color(0xFF4CAF50) : const Color(0xFFFFB74D);
    final textColor = widget.isSelected ? Colors.white : const Color(0xFF8B4513);

    // if (widget.showResult) {
    //   if (widget.isSelected && widget.isCorrect) {
    //     backgroundColor = const Color(0xFF4CAF50);
    //     textColor = Colors.white;
    //     trailingIcon = const Icon(Icons.check, color: Colors.white, size: 20);
    //   } else if (widget.isSelected && !widget.isCorrect) {
    //     backgroundColor = const Color(0xFFFF5722);
    //     textColor = Colors.white;
    //     trailingIcon = const Icon(Icons.close, color: Colors.white, size: 20);
    //   } else if (widget.isCorrect) {
    //     backgroundColor = const Color(0xFF4CAF50);
    //     textColor = Colors.white;
    //     trailingIcon = const Icon(Icons.check, color: Colors.white, size: 20);
    //   } else {
    //     backgroundColor = const Color(0xFFFFB74D);
    //     textColor = const Color(0xFF8B4513);
    //   }
    // } else {
    //   backgroundColor = const Color(0xFFFFB74D);
    //   textColor = const Color(0xFF8B4513);
    // }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    needsExpansion && !isExpanded
                        ? "${widget.text.substring(0, 80)}..."
                        : widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (needsExpansion)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textColor.withOpacity(0.8),
                    size: 16,
                  ),
                // if (trailingIcon != null) trailingIcon,
                // if (!widget.showResult && !needsExpansion)
                //   Icon(
                //     Icons.arrow_forward_ios,
                //     color: textColor,
                //     size: 16,
                //   ),
              ],
            ),
            if (needsExpansion)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? "View less" : "View more",
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: textColor.withOpacity(0.8),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Expandable Explanation Widget
class ExpandableExplanation extends StatefulWidget {
  final String explanation;

  const ExpandableExplanation({super.key, required this.explanation});

  @override
  State<ExpandableExplanation> createState() => _ExpandableExplanationState();
}

class _ExpandableExplanationState extends State<ExpandableExplanation> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Explanation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? "View less" : "View more",
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Text(
              widget.explanation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Question Navigation Modal
class QuestionNavigationModal extends StatelessWidget {
  final List<Question> questions;
  final List<UserAnswer> userAnswers;
  final int currentQuestionIndex;
  final Function(int) onQuestionSelected;

  const QuestionNavigationModal({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.currentQuestionIndex,
    required this.onQuestionSelected,
  });

  UserAnswer? _getUserAnswer(String questionId) {
    try {
      return userAnswers.firstWhere((answer) => answer.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  "Go to Question",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF8B4513)),
                ),
              ],
            ),
          ),
          // Question Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final userAnswer = _getUserAnswer(question.id);
                  final isAnswered = userAnswer != null;
                  // final isCorrect = userAnswer?.isCorrect ?? false;
                  final isCurrent = index == currentQuestionIndex;

                  Color backgroundColor;
                  Color textColor;
                  Widget? icon;

                  if (isCurrent) {
                    backgroundColor = const Color(0xFF8B4513);
                    textColor = Colors.white;
                  } else if (isAnswered) {
                    // if (isCorrect) {
                    //   backgroundColor = const Color(0xFF4CAF50);
                    //   textColor = Colors.white;
                    //   icon = const Icon(Icons.check, color: Colors.white, size: 16);
                    // } else {
                      backgroundColor = const Color(0xFFFF5722);
                      textColor = Colors.white;
                      icon = const Icon(Icons.close, color: Colors.white, size: 16);
                    // }
                  } else {
                    backgroundColor = const Color(0xFFFFB74D);
                    textColor = const Color(0xFF8B4513);
                  }

                  return GestureDetector(
                    onTap: () => onQuestionSelected(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (icon != null)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: icon,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Usage Example (how to navigate to the quiz page)
class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Quizzes"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Math Quiz"),
            subtitle: const Text("5 questions"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizTakingPage(quizId: "math_quiz_1"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}