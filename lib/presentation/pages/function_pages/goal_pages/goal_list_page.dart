import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_detail_page.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({super.key});

  @override
  State<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Achieved', 'Unachieved'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                      child: SingleChildScrollView(child: _buildGoalsList()),
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

  Widget _buildGoalsList() {
    // Sample goal data - in a real app, this would come from a data source
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
      HabitData(title: 'Meditate', progress: 7, target: 7, isAchieved: true),
      HabitData(
        title: 'Learn Arabic',
        progress: 5,
        target: 7,
        isAchieved: false,
      ),
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
      HabitData(title: 'Meditate', progress: 7, target: 7, isAchieved: true),
      HabitData(
        title: 'Learn Arabic',
        progress: 5,
        target: 7,
        isAchieved: false,
      ),
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
      HabitData(title: 'Meditate', progress: 7, target: 7, isAchieved: true),
      HabitData(
        title: 'Learn Arabic',
        progress: 5,
        target: 7,
        isAchieved: false,
      ),
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
      HabitData(title: 'Meditate', progress: 7, target: 7, isAchieved: true),
      HabitData(
        title: 'Learn Arabic',
        progress: 5,
        target: 7,
        isAchieved: false,
      ),
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
      HabitData(title: 'Meditate', progress: 7, target: 7, isAchieved: true),
      HabitData(
        title: 'Learn Arabic',
        progress: 5,
        target: 7,
        isAchieved: false,
      ),
    ];

    // Filter goals if needed
    List<HabitData> filteredGoals;
    if (selectedFilter == 'Achieved') {
      filteredGoals = habits.where((goal) => goal.isAchieved).toList();
    } else if (selectedFilter == 'Unachieved') {
      filteredGoals = habits.where((habit) => !habit.isAchieved).toList();
    } else {
      filteredGoals = habits;
    }

    return Column(
      children:
          filteredGoals
              .map((habit) => HabitProgressCard(habit: habit, tapped: () {Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailPage()));},))
              .toList(),
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
  final VoidCallback? tapped;

  const HabitProgressCard({super.key, required this.habit, this.tapped});

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
