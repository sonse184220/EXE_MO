import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_list_page.dart';

class GoalProgressPage extends StatefulWidget {
  const GoalProgressPage({super.key});

  @override
  State<GoalProgressPage> createState() => _GoalProgressPageState();
}

class _GoalProgressPageState extends State<GoalProgressPage> {
  String selectedMonth = 'This Month'; // Add this as a state variable
  final List<String> months = [
    'This Month',
    'Last Month',
    'January',
    'February',
    'March',
    'April',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                      _buildHabitsList(),

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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Progress',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMonth,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(onTap:() {Navigator.push(context, MaterialPageRoute(builder: (context) => GoalListPage()));},child: Text(
              'See all',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),)
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ProgressCircle(percentage: 60, size: 150, strokeWidth: 15),
        ),
      ],
    );
  }

  Widget _buildGoalStatusSummary() {
    return Column(children: []);
  }

  Widget _buildHabitsList() {
    // Sample habit data - in a real app, this would come from a data source
    final List<HabitData> habits = [
      HabitData(
        title: 'Journaling everyday',
        progress: 7,
        target: 7,
        isAchieved: true,
      ),
      HabitData(
        title: 'Cooking Practice',
        progress: 7,
        target: 7,
        isAchieved: true,
      ),
      HabitData(title: 'Vitamin', progress: 5, target: 7, isAchieved: false),
    ];

    return Column(
      children: habits.map((habit) => HabitProgressCard(habit: habit)).toList(),
    );
  }

  Widget _buildSeeAllButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'See All',
          style: TextStyle(
            color: Colors.orange,
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
    this.activeColor = Colors.orange,
    this.backgroundColor = const Color(0xFFEEEEEE),
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
            color: activeColor,
          ),
        ),
      ],
    );
  }
}

// Data model for habit items
class HabitData {
  final String title;
  final int progress;
  final int target;
  final bool isAchieved;

  HabitData({
    required this.title,
    required this.progress,
    required this.target,
    required this.isAchieved,
  });

  // Calculate percentage progress
  int get progressPercentage => ((progress / target) * 100).round();
}

// Reusable widget for habit progress cards
class HabitProgressCard extends StatelessWidget {
  final HabitData habit;

  const HabitProgressCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  value: habit.progress / habit.target,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    habit.isAchieved ? Colors.green : Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '${habit.progressPercentage}%',
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
          // Habit details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${habit.progress} from ${habit.target} days target',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Achievement status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  habit.isAchieved
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              habit.isAchieved ? 'Achieved' : 'Unachieved',
              style: TextStyle(
                fontSize: 12,
                color: habit.isAchieved ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
