import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_detail_page.dart';

class GoalListPage extends ConsumerStatefulWidget {
  const GoalListPage({super.key});

  @override
  ConsumerState<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends ConsumerState<GoalListPage> {
  late final GoalUsecase _goalUsecase;

  List<GoalModel> _goals = [];

  bool _isLoading = false;
  String? _error;

  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Achieved', 'Unachieved'];

  Future<void> _fetchGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goals = await _goalUsecase.getOwnGoals();
      setState(() {
        _goals = goals.data!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _goalUsecase = ref.read(goalUseCaseProvider);

    _fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Scaffold(
        backgroundColor: Color(0xFFFFF8F3), // Light papaya background
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFB876).withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with back button and title
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // List of goals with progress
                    Expanded(
                      child: _buildContent(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFFE89A4D)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCC7A2B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFFFF0E6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFFFE1CC), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFFE89A4D)),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCC7A2B),
              ),
              items:
              filters.map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedFilter = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Handle loading state
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFFB876),
              backgroundColor: Color(0xFFFFE1CC),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your goals...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFCC7A2B),
              ),
            ),
          ],
        ),
      );
    }

    // Handle error state
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFFFB876).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load goals',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFCC7A2B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFE89A4D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB876),
                foregroundColor: Colors.white,
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

    // Handle empty state
    if (_goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Color(0xFFFFB876).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFCC7A2B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFE89A4D),
              ),
            ),
          ],
        ),
      );
    }

    // Show goals list
    return RefreshIndicator(
      onRefresh: _fetchGoals,
      color: Color(0xFFFFB876),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildGoalsList(),
      ),
    );
  }

  Widget _buildGoalsList() {
    // Filter goals based on selected filter and goalCompletedAt
    List<GoalModel> filteredGoals;
    switch (selectedFilter) {
      case 'Achieved':
        filteredGoals = _goals.where((goal) => goal.goalCompletedAt != null).toList();
        break;
      case 'Unachieved':
        filteredGoals = _goals.where((goal) => goal.goalCompletedAt == null).toList();
        break;
      default:
        filteredGoals = _goals;
    }

    if (filteredGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No ${selectedFilter.toLowerCase()} goals found',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFCC7A2B),
            ),
          ),
        ),
      );
    }

    return Column(
      children: filteredGoals
          .map((goal) => GoalProgressCard(
        goal: goal,
        tapped: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailPage(goalId: goal.goalId!),
            ),
          );
        },
      ))
          .toList(),
    );
  }
}

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? tapped;

  const GoalProgressCard({super.key, required this.goal, this.tapped});

  @override
  Widget build(BuildContext context) {
    // Determine if goal is achieved based on goalCompletedAt
    final isAchieved = goal.goalCompletedAt != null;

    // Calculate progress based on goal dates
    final progress = _calculateProgress();
    final progressPercentage = (progress * 100).round();

    return GestureDetector(
      onTap: tapped,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAchieved ? Color(0xFFD4B86A) : Color(0xFFFFE1CC),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFB876).withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress circle
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Color(0xFFFFF0E6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAchieved ? Color(0xFFD4B86A) : Color(0xFFFFB876),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '$progressPercentage%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAchieved ? Color(0xFFD4B86A) : Color(0xFFCC7A2B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),
            // Goal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.goalTitle ?? 'Untitled Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitleText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCC7A2B),
                    ),
                  ),
                ],
              ),
            ),
            // Achievement status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAchieved
                    ? Color(0xFFD4B86A).withOpacity(0.15)
                    : Color(0xFFFFB876).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAchieved ? Color(0xFFD4B86A) : Color(0xFFFFB876),
                  width: 1,
                ),
              ),
              child: Text(
                isAchieved ? 'Achieved' : 'In Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: isAchieved ? Color(0xFFB8941A) : Color(0xFFCC7A2B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  double _calculateProgress() {
    // If goal is completed, show 100%
    if (goal.goalCompletedAt != null) return 1.0;

    final startDate = goal.goalStartDate;
    final endDate = goal.goalEndDate;
    final now = DateTime.now();

    // If no dates are set, calculate based on target count and period
    if (startDate == null || endDate == null) {
      if (goal.goalTargetCount != null && goal.goalPeriodDays != null) {
        // This is a rough estimate - you might want to track actual progress elsewhere
        final createdAt = goal.goalCreatedAt ?? now;
        final daysSinceCreated = now.difference(createdAt).inDays;
        final periodProgress = (daysSinceCreated / goal.goalPeriodDays!).clamp(0.0, 1.0);
        return periodProgress;
      }
      return 0.0;
    }

    // Calculate progress based on date range
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final totalDuration = endDate.difference(startDate).inDays;
    final elapsed = now.difference(startDate).inDays;

    if (totalDuration <= 0) return 0.0;

    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  String _buildSubtitleText() {
    final startDate = goal.goalStartDate;
    final endDate = goal.goalEndDate;
    final targetCount = goal.goalTargetCount;
    final periodDays = goal.goalPeriodDays;

    // Show target count and period if available
    if (targetCount != null && periodDays != null) {
      return '$targetCount times in $periodDays days';
    }

    // Show date range if available
    if (startDate != null && endDate != null) {
      final startFormatted = _formatDate(startDate);
      final endFormatted = _formatDate(endDate);
      return '$startFormatted - $endFormatted';
    }

    // Show goal type if available
    if (goal.goalType != null && goal.goalType!.isNotEmpty) {
      return 'Type: ${goal.goalType}';
    }

    // Fallback to description or status
    return goal.goalDescription ?? goal.goalStatus ?? 'No description';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}