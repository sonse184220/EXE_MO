import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_detail_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_list_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_manage_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_progress_page.dart';
import 'package:intl/intl.dart';

// Color Palette
class AppColors {
  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);
}

class GoalHomePage extends ConsumerStatefulWidget {
  const GoalHomePage({super.key});

  @override
  ConsumerState<GoalHomePage> createState() => _GoalHomePageState();
}

class _GoalHomePageState extends ConsumerState<GoalHomePage> {
  late final GoalUsecase _goalUsecase;
  List<GoalModel> _goals = [];
  bool _isLoading = true;
  String? _error;
  final percentageBetterThan = 20; // This would come from backend data
  String? get userName => ref.watch(authNotifierProvider).userInfo?.userId;

  final int completedHabits = 3;
  final int tasksLeft = 2;

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
    super.initState();
    _goalUsecase = ref.read(goalUseCaseProvider);
    _fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    final completedGoals =
        _goals
            .where((goal) => goal.goalStatus?.toLowerCase() == "completed")
            .length;
    final completionPercentage =
        _goals.isEmpty ? 0 : ((completedGoals / _goals.length) * 100).round();

    return SafeArea(
      child: Scaffold(
        // backgroundColor: Color(0xFFFFF9F5), // Very light papaya background
        body:
            _isLoading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState()
                : _buildMainContent(completionPercentage, completedGoals),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9D52)),
            // Medium papaya
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your goals...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFFD4824A), // Muted papaya
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFFF9D52), // Medium papaya
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3D3D), // Dark for readability
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFFD4824A), // Muted papaya
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9D52),
                // Medium papaya
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(int completionPercentage, int completedGoals) {
    return LayoutBuilder(
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
                  color: Color(0xFFFFB876).withAlpha((0.15 * 255).round()),
                  // Papaya-tinted shadow
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(userName ?? 'Unknown'),
                // Progress Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalProgressPage(),
                      ),
                    );
                  },
                  child: _buildProgressCard(
                    completionPercentage,
                    completedGoals,
                    _goals.length,
                  ),
                ),
                // Today Goals Section
                _buildTodayGoalsSection(_goals),
                // Performance Stats
                _buildPerformanceStats(
                  // percentageBetterThan,
                  // tasksLeft,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    final now = DateTime.now();
    final dateFormat = DateFormat('E, d MMMM yyyy');
    final formattedDate = dateFormat.format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFFD4824A), // Muted papaya
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "Goal Sessions"),
                    // TextSpan(
                    //   text: name,
                    //   style: TextStyle(
                    //     color: Color(0xFFFF9D52), // Medium papaya
                    //   ),
                    // ),
                    TextSpan(text: "!"),
                  ],
                ),
              ),
            ],
          ),
          FloatingActionButton(
            backgroundColor: Color(0xFFFF9D52), // Medium papaya
            child: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GoalManagePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int percentage, int completed, int total) {
    return Container(
      width: double.infinity,
      height: 170,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFB876), // Main papaya
            Color(0xFFFFCA94), // Lighter papaya
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withAlpha(
                          (0.3 * 255).round(),
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      "$percentage%",
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                // Text Info
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$completed of $total goals",
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "completed today!",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom-right image
          Positioned(
            bottom: -10,
            right: 0,
            child: Image.asset(
              'assets/images/goal_home_page_calendar.png',
              width: 110,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoalsSection(List<GoalModel> goals) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today Goal",
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoalListPage()),
                  );
                },
                child: Text(
                  "See all",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFFF9D52), // Medium papaya
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return GoalListItem(goal: _goals[index]);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    final stats = _calculatePerformanceStats();
    final percentageBetter = stats['percentageBetter']!;
    final tasksLeft = stats['tasksLeft']!;
    final totalTasks = stats['totalTasks']!;
    final completedTasks = stats['completedTasks']!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        // Light papaya background with very low opacity
        color: Color(0xFFFFB876).withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        // Subtle papaya border
        border: Border.all(color: Color(0xFFFFB876).withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You are doing better than",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    // Darker papaya shade for text
                    color: Color(0xFFE8965A),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "$percentageBetter%",
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    // Rich papaya color for the percentage
                    color: Color(0xFFFF9D52),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              // Papaya-tinted shadow
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB876).withAlpha((0.15 * 255).round()),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
              // Subtle papaya border
              border: Border.all(
                color: Color(0xFFFFB876).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "$tasksLeft/$totalTasks",
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // Medium papaya shade
                    color: Color(0xFFFF9D52),
                  ),
                ),
                Text(
                  "Tasks left",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    // Muted papaya shade
                    color: Color(0xFFD4824A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculatePerformanceStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter goals that are active today
    final todayGoals =
        _goals.where((goal) {
          if (goal.goalStartDate == null) return false;

          final startDate = DateTime(
            goal.goalStartDate!.year,
            goal.goalStartDate!.month,
            goal.goalStartDate!.day,
          );

          final endDate =
              goal.goalEndDate != null
                  ? DateTime(
                    goal.goalEndDate!.year,
                    goal.goalEndDate!.month,
                    goal.goalEndDate!.day,
                  )
                  : today; // If no end date, consider it as today

          // Check if today falls within the goal period
          return (today.isAfter(startDate) ||
                  today.isAtSameMomentAs(startDate)) &&
              (today.isBefore(endDate) || today.isAtSameMomentAs(endDate));
        }).toList();

    final completedTodayGoals =
        todayGoals
            .where((goal) => goal.goalStatus?.toLowerCase() == "completed")
            .length;

    final totalTodayGoals = todayGoals.length;
    final tasksLeft = totalTodayGoals - completedTodayGoals;

    // Calculate percentage better than others (you can modify this logic based on your backend data)
    // For now, using a simple calculation based on completion rate
    final completionRate =
        totalTodayGoals > 0 ? (completedTodayGoals / totalTodayGoals) * 100 : 0;
    final percentageBetter =
        (completionRate * 0.8).round(); // Simple calculation, adjust as needed

    return {
      'percentageBetter': percentageBetter,
      'tasksLeft': tasksLeft,
      'totalTasks': totalTodayGoals,
      'completedTasks': completedTodayGoals,
    };
  }
}

// Reusable GoalListItem Widget
class GoalListItem extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onToggle;
  final VoidCallback? onOptions;

  const GoalListItem({
    super.key,
    required this.goal,
    this.onToggle,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailPage(goalId: goal.goalId!),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          // Light papaya background
          color: Color(0xFFFFB876).withOpacity(0.12),
          // Subtle papaya border
          border: Border.all(
            color: Color(0xFFFFB876).withOpacity(0.25),
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(width: 15),
            Expanded(
              child: Text(
                goal.goalTitle!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  // Darker shade for better readability
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    // Medium papaya for border
                    color: Color(0xFFFF9D52),
                    width: 2,
                  ),
                  color:
                      goal.goalStatus == 'completed'
                          ? Color(
                            0xFFFF9D52,
                          ) // Filled with papaya when completed
                          : Colors.transparent,
                ),
                child:
                    goal.goalStatus == 'completed'
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                // Muted papaya for the options icon
                color: Color(0xFFD4824A),
              ),
              onPressed: onOptions,
            ),
          ],
        ),
      ),
    );
  }
}
