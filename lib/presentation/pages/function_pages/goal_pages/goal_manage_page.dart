import 'package:flutter/material.dart';

class GoalManagePage extends StatefulWidget {
  const GoalManagePage({super.key});

  @override
  State<GoalManagePage> createState() => _GoalManagePageState();
}

class _GoalManagePageState extends State<GoalManagePage>
    with TickerProviderStateMixin {
  bool _isFormVisible = false;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  final List<HabitItem> _goals = [
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
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  void _toggleForm() {
    setState(() {
      _isFormVisible = !_isFormVisible;
      if (_isFormVisible) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      _buildHeader(),

                      // Form for adding new habits
                      SizeTransition(
                        sizeFactor: _slideController,
                        axisAlignment: -1.0,
                        child: _buildHabitForm(),
                      ),

                      // Today's goals section
                      _buildTodayGoalsSection(),

                      // Spacing at the bottom
                      SizedBox(height: 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton.icon(
              onPressed: _toggleForm,
              icon: Icon(
                _isFormVisible ? Icons.expand_less : Icons.add,
                color: Colors.deepOrange,
              ),
              label: Text(
                _isFormVisible ? 'Hide Add Habit Form' : 'Add New Habit',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Habit tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep a track of your habits',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitForm() {
    return Column(
      children: [
        // Title input
        _buildFormTextField(hintText: 'Title'),
        SizedBox(height: 12),

        // Description input
        _buildFormTextField(hintText: 'Description', maxLines: 3),
        SizedBox(height: 12),

        // Note input
        _buildFormTextField(hintText: 'Note'),
        SizedBox(height: 20),

        // Add button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Add task functionality would go here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add this task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFormTextField({required String hintText, int maxLines = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 12 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTodayGoalsSection() {
    return Expanded(child:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // "See all" functionality would go here
              },
              child: Text(
                'See all',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        Expanded(
          child:
          ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              return HabitListItem(habit: _goals[index]);
            },
          ),
        ),
        SizedBox(height: 20),

        // Goal items
        // ..._goals.map((goal) => _buildGoalItem(goal)),
      ],
    ));
  }

  // Widget _buildGoalItem(GoalItem goal) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(6),
  //       color: Color(0xFFEDFFF4),
  //     ),
  //     margin: EdgeInsets.only(bottom: 10),
  //     child: Row(
  //       children: [
  //         SizedBox(width: 15),
  //         Expanded(
  //           child: Text(
  //             habit.title,
  //             style: TextStyle(fontSize: 16, color: Colors.black87),
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: onToggle,
  //           child: Container(
  //             width: 24,
  //             height: 24,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(6),
  //               border: Border.all(
  //                 // color: Color(0xFF5FE394),
  //                 color: Color(0xFF37C871),
  //                 width: 2,
  //               ),
  //               color:
  //               habit.isCompleted ? Color(0xFF5FE394) : Colors.transparent,
  //             ),
  //             child:
  //             habit.isCompleted
  //                 ? Icon(Icons.check, size: 16, color: Colors.white)
  //                 : null,
  //           ),
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.more_vert, color: Colors.grey),
  //           onPressed: onOptions,
  //         ),
  //       ],
  //     ),
  //   );
  //   // return Container(
  //   //   margin: EdgeInsets.only(bottom: 12),
  //   //   child: Row(
  //   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //   //     children: [
  //   //       Text(
  //   //         goal.title,
  //   //         style: TextStyle(
  //   //           fontSize: 14,
  //   //           fontWeight: FontWeight.w500,
  //   //           color: goal.isCompleted ? Colors.green : Colors.black,
  //   //         ),
  //   //       ),
  //   //       Row(
  //   //         children: [
  //   //           // Checkbox
  //   //           GestureDetector(
  //   //             onTap: () {
  //   //               setState(() {
  //   //                 goal.isCompleted = !goal.isCompleted;
  //   //               });
  //   //             },
  //   //             child: Container(
  //   //               width: 24,
  //   //               height: 24,
  //   //               decoration: BoxDecoration(
  //   //                 borderRadius: BorderRadius.circular(4),
  //   //                 border: goal.isCompleted ? null : Border.all(color: Colors.grey[400]!),
  //   //                 color: goal.isCompleted ? Colors.green : Colors.transparent,
  //   //               ),
  //   //               child: goal.isCompleted
  //   //                   ? Icon(Icons.check, size: 16, color: Colors.white)
  //   //                   : null,
  //   //             ),
  //   //           ),
  //   //           SizedBox(width: 8),
  //   //
  //   //           // Options button
  //   //           IconButton(
  //   //             icon: Icon(Icons.more_vert, color: Colors.grey),
  //   //             onPressed: () {
  //   //               // Options functionality would go here
  //   //             },
  //   //           ),
  //   //         ],
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );
  // }
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

// class GoalItem {
//   final String title;
//   bool isCompleted;
//
//   GoalItem({
//     required this.title,
//     required this.isCompleted,
//   });
// }
