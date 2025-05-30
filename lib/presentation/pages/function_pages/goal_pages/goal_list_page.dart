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
                      color: Colors.black12,
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Your Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your goals...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load goals',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchGoals,
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Show goals list
    return RefreshIndicator(
      onRefresh: _fetchGoals,
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
              color: Colors.grey[600],
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => GoalDetailPage(goalId: goal.goalId),
          //   ),
          // );
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
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAchieved ? Colors.green : Colors.blue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '$progressPercentage%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitleText(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Achievement status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAchieved
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isAchieved ? 'Achieved' : 'In Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: isAchieved ? Colors.green : Colors.blue,
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