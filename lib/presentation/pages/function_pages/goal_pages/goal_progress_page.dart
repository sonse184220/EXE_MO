import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_list_page.dart';

class GoalProgressPage extends ConsumerStatefulWidget {
  const GoalProgressPage({super.key});

  @override
  ConsumerState<GoalProgressPage> createState() => _GoalProgressPageState();
}

class _GoalProgressPageState extends ConsumerState<GoalProgressPage> {
  late final GoalUsecase _goalUsecase;

  List<GoalModel> _goals = [];
  bool _isLoading = true;
  String? _error;

  String selectedMonth = 'This Month'; // Add this as a state variable
  final List<String> months = [
    'This Month',
    'Last Month',
    'January',
    'February',
    'March',
    'April',
  ];

  Future<void> _fetchGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goals = await _goalUsecase.getOwnGoals();
      setState(() {
        _goals = _sortGoalsByTime(goals.data!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<GoalModel> _sortGoalsByTime(List<GoalModel> goals) {
    goals.sort((a, b) {
      // Sort by creation date (most recent first)
      if (a.goalCreatedAt != null && b.goalCreatedAt != null) {
        return b.goalCreatedAt!.compareTo(a.goalCreatedAt!);
      }
      // If creation date is null, put it at the end
      if (a.goalCreatedAt == null && b.goalCreatedAt != null) return 1;
      if (a.goalCreatedAt != null && b.goalCreatedAt == null) return -1;
      return 0;
    });
    return goals;
  }

  List<GoalModel> _getFilteredGoals() {
    final now = DateTime.now();
    DateTime filterDate;

    switch (selectedMonth) {
      case 'This Month':
        filterDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        filterDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'January':
        filterDate = DateTime(now.year, 1, 1);
        break;
      case 'February':
        filterDate = DateTime(now.year, 2, 1);
        break;
      case 'March':
        filterDate = DateTime(now.year, 3, 1);
        break;
      case 'April':
        filterDate = DateTime(now.year, 4, 1);
        break;
      default:
        filterDate = DateTime(now.year, now.month, 1);
    }

    return _goals.where((goal) {
      if (goal.goalCreatedAt == null) return false;

      if (selectedMonth == 'This Month') {
        return goal.goalCreatedAt!.year == now.year &&
            goal.goalCreatedAt!.month == now.month;
      } else if (selectedMonth == 'Last Month') {
        final lastMonth = DateTime(now.year, now.month - 1);
        return goal.goalCreatedAt!.year == lastMonth.year &&
            goal.goalCreatedAt!.month == lastMonth.month;
      } else {
        return goal.goalCreatedAt!.year == filterDate.year &&
            goal.goalCreatedAt!.month == filterDate.month;
      }
    }).toList();
  }

  int _calculateOverallProgress() {
    final filteredGoals = _getFilteredGoals();
    if (filteredGoals.isEmpty) return 0;

    final completedGoals = filteredGoals
        .where((goal) => goal.goalStatus?.toLowerCase() == 'completed')
        .length;

    return ((completedGoals / filteredGoals.length) * 100).round();
  }

  @override
  void initState() {
    super.initState();
    _goalUsecase = ref.read(goalUseCaseProvider);
    _fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Scaffold(
        body:
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB876)))
            : _error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB876),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB876).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button and title
                      _buildHeader(),

                      // Progress report with dropdown
                      _buildProgressHeader(),

                      const SizedBox(height: 24),

                      // Your Goals section with percentage
                      _buildGoalsSection(),

                      const SizedBox(height: 24),

                      // Goal status summary
                      _buildGoalStatusSummary(),

                      const SizedBox(height: 16),

                      // List of habit goals with progress
                      _buildGoalsList(),

                      const SizedBox(height: 16),

                      // Bottom "See All" button
                      _buildSeeAllButton(),
                    ],
                  ),
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
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4935A)),
          onPressed: () {Navigator.pop(context);},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB8743E),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Progress Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB8743E),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB876).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB876).withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMonth,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFFD4935A)),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB8743E),
              ),
              items:
              months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                }
              },
            ),
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[200],
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   child: Row(
        //     children: [
        //       const Text(
        //         'This Month',
        //         style: TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.w500,
        //         ),
        //       ),
        //       const SizedBox(width: 4),
        //       const Icon(Icons.keyboard_arrow_down, size: 18),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    final overallProgress = _calculateOverallProgress();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8743E),
              ),
            ),
            GestureDetector(
              onTap:() {Navigator.push(context, MaterialPageRoute(builder: (context) => GoalListPage()));},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFB876),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ProgressCircle(percentage: overallProgress, size: 150, strokeWidth: 15),
        ),
      ],
    );
  }

  Widget _buildGoalStatusSummary() {
    final filteredGoals = _getFilteredGoals();
    final completedGoals = filteredGoals
        .where((goal) => goal.goalStatus?.toLowerCase() == 'completed')
        .length;
    final inProgressGoals = filteredGoals
        .where((goal) => goal.goalStatus?.toLowerCase() == 'in_progress' ||
        goal.goalStatus?.toLowerCase() == 'active')
        .length;
    final pendingGoals = filteredGoals.length - completedGoals - inProgressGoals;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB876).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB876).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('Completed', completedGoals, const Color(0xFF8FBF47)),
          _buildStatusItem('In Progress', inProgressGoals, const Color(0xFFFFB876)),
          _buildStatusItem('Pending', pendingGoals, const Color(0xFFE0C4A3)),
        ],
      ),
    );
    // return Column(children: []);
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFFB8743E).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    final filteredGoals = _getFilteredGoals();

    if (filteredGoals.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.track_changes, size: 64, color: const Color(0xFFE0C4A3)),
            const SizedBox(height: 16),
            Text(
              'No goals found for $selectedMonth',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFFB8743E).withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredGoals
          .map((goal) => GoalProgressCard(goal: goal))
          .toList(),
    );
  }

  Widget _buildSeeAllButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFB876).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text(
          'See All',
          style: TextStyle(
            color: Color(0xFFFFB876),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ProgressCircle extends StatelessWidget {
  final int percentage;
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;

  const ProgressCircle({
    super.key,
    required this.percentage,
    required this.size,
    this.strokeWidth = 10.0,
    this.activeColor = const Color(0xFFFFB876),
    this.backgroundColor = const Color(0xFFFFF2E8),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: size * 0.2,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB8743E),
          ),
        ),
      ],
    );
  }
}

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;

  const GoalProgressCard({super.key, required this.goal});

  int _calculateGoalProgress() {
    if (goal.goalStatus?.toLowerCase() == 'completed') {
      return 100;
    }

    // Calculate progress based on time elapsed if goal has start and end dates
    if (goal.goalStartDate != null && goal.goalEndDate != null) {
      final now = DateTime.now();
      final totalDuration = goal.goalEndDate!.difference(goal.goalStartDate!).inDays;
      final elapsed = now.difference(goal.goalStartDate!).inDays;

      if (elapsed < 0) return 0; // Goal hasn't started yet
      if (elapsed >= totalDuration) return 100; // Goal period has ended

      return ((elapsed / totalDuration) * 100).round();
    }

    // Default progress calculation based on status
    switch (goal.goalStatus?.toLowerCase()) {
      case 'completed':
        return 100;
      case 'in_progress':
      case 'active':
        return 50; // Assume 50% for active goals without date info
      default:
        return 0;
    }
  }

  String _getGoalStatusText() {
    switch (goal.goalStatus?.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
      case 'active':
        return 'In Progress';
      case 'paused':
        return 'Paused';
      default:
        return 'Completed';
    }
  }

  Color _getStatusColor() {
    switch (goal.goalStatus?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF8FBF47);
      case 'in_progress':
      case 'active':
        return const Color(0xFFFFB876);
      case 'paused':
        return const Color(0xFFE0C4A3);
      default:
        return const Color(0xFFD4935A);
    }
  }

  String _getTimeRemaining() {
    if (goal.goalEndDate == null) return '';

    final now = DateTime.now();
    final difference = goal.goalEndDate!.difference(now).inDays;

    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Due today';
    if (difference == 1) return '1 day left';
    return '$difference days left';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateGoalProgress();
    final statusText = _getGoalStatusText();
    final statusColor = _getStatusColor();
    final timeRemaining = _getTimeRemaining();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB876).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB876).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFFFF2E8),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8743E),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB8743E),
                  ),
                ),
                const SizedBox(height: 4),
                if (goal.goalDescription != null && goal.goalDescription!.isNotEmpty)
                  Text(
                    goal.goalDescription!,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFB8743E).withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                if (timeRemaining.isNotEmpty)
                  Text(
                    timeRemaining,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFD4935A).withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}