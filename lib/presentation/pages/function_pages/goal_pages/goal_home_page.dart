import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_manage_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_progress_page.dart';
import 'package:intl/intl.dart';

class GoalHomePage extends StatefulWidget {
  // final String userName;
  // final List<HabitItem> habits;
  // final int completedHabits;
  // final int tasksLeft;

  const GoalHomePage({
    super.key,
    // required this.userName,
    // required this.habits,
    // required this.completedHabits,
    // required this.tasksLeft,
  });

  @override
  State<GoalHomePage> createState() => _GoalHomePageState();
}

class _GoalHomePageState extends State<GoalHomePage> {
  final percentageBetterThan = 20; // This would come from backend data

  final String userName = "Nhi";

  // final List<HabitItem> habits;
  final int completedHabits = 3;
  final int tasksLeft = 2;

  final List<HabitItem> habits = [
    HabitItem(title: "Meditating", isCompleted: true, color: Colors.green),
    HabitItem(title: "Read Philosophy", isCompleted: true, color: Colors.green),
    HabitItem(title: "Journaling", isCompleted: false, color: Colors.green),
    HabitItem(title: "Exercise", isCompleted: false, color: Colors.blue),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
    HabitItem(title: "Drink Water", isCompleted: true, color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate completion percentage
    final completionPercentage =
    habits.isEmpty
        ? 0
        : (completedHabits / habits.length * 100).round();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(userName),

                    // Progress Card
                    GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => GoalProgressPage()));}, child: _buildProgressCard(
                      completionPercentage,
                      completedHabits,
                      habits.length,
                    ),),

                    // Today Goals Section
                    _buildTodayGoalsSection(habits),

                    // Performance Stats
                    _buildPerformanceStats(
                      percentageBetterThan,
                      tasksLeft,
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "Hello, "),
                    TextSpan(
                      text: name,
                      style: TextStyle(
                        color: Color(0xFFFF7F27),
                      ), // matching orange
                    ),
                    TextSpan(text: "!"),
                  ],
                ),
              ),
            ],
          ),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(Icons.add, color: Colors.white),
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
          colors: [Color(0xFFFF7F27), Color(0xFFFFA733)],
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
                          "$completed of $total habits",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "completed today!",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🎯 Bottom-right image
          Positioned(
            bottom: -10,
            right: 0,
            child: Image.asset(
              'assets/images/goal_home_page_calendar.png',
              // make sure this path is correct
              width: 110,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoalsSection(List<HabitItem> habits) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today Goal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // View all goals functionality
                },
                child: Text("See all", style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return HabitListItem(habit: habits[index]);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(int percentageBetter, int tasksLeft) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "$percentageBetter%",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "$tasksLeft/4",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  "Tasks left",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HabitItem {
  final String title;
  final bool isCompleted;
  final Color color;

  HabitItem({
    required this.title,
    required this.isCompleted,
    this.color = Colors.green,
  });
}

// Reusable HabitListItem Widget
class HabitListItem extends StatelessWidget {
  final HabitItem habit;
  final VoidCallback? onToggle;
  final VoidCallback? onOptions;

  const HabitListItem({
    super.key,
    required this.habit,
    this.onToggle,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Color(0xFFEDFFF4),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 15),
          Expanded(
            child: Text(
              habit.title,
              style: TextStyle(fontSize: 16, color: Colors.black87),
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
                  // color: Color(0xFF5FE394),
                  color: Color(0xFF37C871),
                  width: 2,
                ),
                color:
                habit.isCompleted ? Color(0xFF5FE394) : Colors.transparent,
              ),
              child:
              habit.isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onPressed: onOptions,
          ),
        ],
      ),
    );
  }
}
