import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  late final GoalUsecase _goalUsecase;

  // State management
  GoalModel? _goal;
  int _completedDays = 0;
  bool _isLoading = false;
  String? _error;
  bool _isUpdating = false;

  // Calendar focus
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Sample completed days (can be populated from your data)
  // final Set<DateTime> _completedDays = {
  //   DateTime(2022, 6, 28),
  //   DateTime(2022, 6, 30),
  //   DateTime(2022, 7, 1),
  //   DateTime(2022, 7, 3),
  // };

  @override
  void initState() {
    super.initState();

    _goalUsecase = ref.read(goalUseCaseProvider);

    _fetchGoal();

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Initialize with provided data or defaults
    // habitInfo = widget.habitData ?? {
    //   'name': 'Journaling',
    //   'target': 7,
    //   'daysComplete': 7,
    //   'totalDays': 7,
    //   'daysFailed': 0,
    //   'type': 'Everyday',
    //   'createdOn': DateTime(2022, 6, 4),
    //   'isAchieved': true,
    // };
  }

  bool _isDateInGoalPeriod(DateTime date) {
    if (_goal == null) return false;

    final startDate = _goal!.goalStartDate;
    final endDate = _goal!.goalEndDate;

    if (startDate == null || endDate == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return (dateOnly.isAfter(startOnly) ||
            dateOnly.isAtSameMomentAs(startOnly)) &&
        (dateOnly.isBefore(endOnly) || dateOnly.isAtSameMomentAs(endOnly));
  }

  void _showUpdateProgressDialog() {
    int currentValue = _completedDays;
    final maxValue = _goal?.goalTargetCount ?? 0;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              final TextEditingController controller = TextEditingController(
                text: currentValue.toString(),
              );

              return AlertDialog(
                title: Text('Update Progress'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current progress: $_completedDays / $maxValue days',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        // Decrease button
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed:
                                currentValue > 0
                                    ? () {
                                      setDialogState(() {
                                        currentValue--;
                                        controller.text =
                                            currentValue.toString();
                                      });
                                    }
                                    : null,
                            icon: Icon(Icons.remove),
                            color: currentValue > 0 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Input field
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Completed Days',
                              border: OutlineInputBorder(),
                              suffixText: '/ $maxValue',
                            ),
                            onChanged: (value) {
                              final newValue = int.tryParse(value);
                              if (newValue != null) {
                                setDialogState(() {
                                  currentValue = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        // Increase button
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed:
                                currentValue < maxValue
                                    ? () {
                                      setDialogState(() {
                                        currentValue++;
                                        controller.text =
                                            currentValue.toString();
                                      });
                                    }
                                    : null,
                            icon: Icon(Icons.add),
                            color:
                                currentValue < maxValue
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use +/- buttons or type directly',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final finalValue =
                          int.tryParse(controller.text) ?? currentValue;

                      if (finalValue >= 0 && finalValue <= maxValue) {
                        Navigator.pop(context);
                        _updateProgress(finalValue);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter a value between 0 and $maxValue',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Text('Update'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _fetchGoal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Replace with your actual usecase call
      final goalResponse = await _goalUsecase.getOwnGoalDetail(widget.goalId);

      if (goalResponse.isSuccess) {
        final goal = goalResponse.data;

        setState(() {
          _goal = goal;
          // _completedDays = completedDays;
          _completedDays = goal?.goalPeriodDays ?? 0;
          _isLoading = false;
        });
      }
      // final goal = goalResponse.data;
      // final completedDays = goalResponse.completedDays; // or separate field

      // Mock implementation for demo
      // await Future.delayed(Duration(seconds: 1));
      // final goal = GoalModel(
      //   goalId: widget.goalId,
      //   goalTitle: 'Daily Journaling for Mental Health and Mindfulness Practice',
      //   goalDescription: 'Write in journal every day to improve mindfulness, self-reflection, and mental clarity. This includes writing about daily experiences, gratitude, and personal growth insights.',
      //   goalType: 'Daily',
      //   goalStartDate: DateTime(2025, 5, 1),
      //   goalEndDate: DateTime(2025, 6, 4),
      //   goalTargetCount: 365,
      //   goalPeriodDays: 365,
      //   goalStatus: 'Active',
      //   goalCreatedAt: DateTime(2024, 1, 1),
      //   goalUpdatedAt: DateTime(2024, 1, 30),
      // );
      //
      // // Mock completed days count - this is the only editable field
      // // final completedDays = 45;
      //
      // setState(() {
      //   _goal = goal;
      //   // _completedDays = completedDays;
      //   _isLoading = false;
      // });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProgress(int newCompletedDays) async {
    if (_goal == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Replace with your actual usecase call to update only completed days
      final goalObject = CreateGoalModel(
        goalTitle: _goal!.goalTitle!,
        goalDescription: _goal!.goalDescription!,
        goalType: _goal!.goalType!,
        goalStartDate: _goal!.goalStartDate!,
        goalEndDate: _goal!.goalEndDate!,
        goalTargetCount: _goal!.goalTargetCount!,
        goalPeriodDays: newCompletedDays,
      );

      await _goalUsecase.updateOwnGoals(widget.goalId, goalObject);

      // Mock implementation for demo
      // await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _completedDays = newCompletedDays;
        _isUpdating = false;
      });

      // Show success message
      Notify.showFlushbar('Progress updated: $newCompletedDays days completed');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Progress updated: $newCompletedDays days completed'),
      //     duration: Duration(seconds: 2),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _error = e.toString();
      });

      Notify.showFlushbar('Failed to update progress: $e', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to update progress: $e'),
      //     duration: Duration(seconds: 3),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  // void _showUpdateProgressDialog() {
  //   final TextEditingController controller = TextEditingController(
  //     text: _completedDays.toString(),
  //   );
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Update Progress'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Current progress: $_completedDays / ${_goal?.goalTargetCount ?? 0} days',
  //             style: TextStyle(color: Colors.grey.shade600),
  //           ),
  //           SizedBox(height: 16),
  //           TextField(
  //             controller: controller,
  //             keyboardType: TextInputType.number,
  //             decoration: InputDecoration(
  //               labelText: 'Completed Days',
  //               border: OutlineInputBorder(),
  //               suffixText: '/ ${_goal?.goalTargetCount ?? 0}',
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             final newValue = int.tryParse(controller.text) ?? _completedDays;
  //             final maxValue = _goal?.goalTargetCount ?? 0;
  //
  //             if (newValue >= 0 && newValue <= maxValue) {
  //               Navigator.pop(context);
  //               _updateProgress(newValue);
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text('Please enter a value between 0 and $maxValue'),
  //                   backgroundColor: Colors.orange,
  //                 ),
  //               );
  //             }
  //           },
  //           child: Text('Update'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading goal details...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(onPressed: _fetchGoal, child: Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (_goal == null) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Goal not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
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
                      _buildHeader(_goal!),
                      _buildGoalInfo(_goal!),
                      SizedBox(height: 24),
                      _buildCalendarDisplay(_goal!),
                      SizedBox(height: 24),
                      _buildProgressSection(_goal!),
                      SizedBox(height: 24),
                      _buildDetailSection(_goal!),
                      const SizedBox(height: 20),
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

  Widget _buildHeader(GoalModel goal) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Goal: ${goal.goalTitle ?? 'Unknown Goal'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (_isUpdating)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget _buildHeader() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     child: Row(
  //       children: [
  //         IconButton(
  //           icon: Icon(Icons.arrow_back, size: 24),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             'Goal Details',
  //             style: TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //         if (_isUpdating)
  //           SizedBox(
  //             width: 20,
  //             height: 20,
  //             child: CircularProgressIndicator(strokeWidth: 2),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGoalInfo(GoalModel goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal Title (read-only, with overflow handling)
        // Text(
        //   goal.goalTitle ?? 'Untitled Goal',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.black87,
        //   ),
        //   maxLines: 2,
        //   overflow: TextOverflow.ellipsis,
        // ),
        SizedBox(height: 12),

        // Goal Description (read-only, with overflow handling)
        if (goal.goalDescription != null && goal.goalDescription!.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              goal.goalDescription!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        SizedBox(height: 12),

        // Status Badge (read-only)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(goal.goalStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(goal.goalStatus).withOpacity(0.3),
            ),
          ),
          child: Text(
            goal.goalStatus ?? 'Unknown',
            style: TextStyle(
              color: _getStatusColor(goal.goalStatus),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDisplay(GoalModel goal) {
    final firstDay =
        goal.goalStartDate ?? DateTime.now().subtract(Duration(days: 30));
    final lastDay = goal.goalEndDate ?? DateTime.now().add(Duration(days: 30));

    final adjustedFocusedDay =
        _focusedDay.isAfter(lastDay)
            ? lastDay
            : _focusedDay.isBefore(firstDay)
            ? firstDay
            : _focusedDay;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(firstDay),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'End Date',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(lastDay),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          TableCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: adjustedFocusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: true,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, size: 20),
              rightChevronIcon: Icon(Icons.chevron_right, size: 20),
              titleTextStyle: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade600, width: 2),
              ),
              todayTextStyle: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
              outsideTextStyle: TextStyle(color: Colors.grey.shade400),
            ),
            onDaySelected: null,
            selectedDayPredicate: (_) => false,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay =
                    focusedDay.isAfter(lastDay)
                        ? lastDay
                        : focusedDay.isBefore(firstDay)
                        ? firstDay
                        : focusedDay;
              });
            },
            // onPageChanged: (focusedDay) {
            //   setState(() {
            //     _focusedDay = focusedDay;
            //   });
            // },
            // Enhanced calendar builders for goal period highlighting
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_isDateInGoalPeriod(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
              outsideBuilder: (context, day, focusedDay) {
                if (_isDateInGoalPeriod(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                if (_isDateInGoalPeriod(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade600, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade600, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Legend for calendar colors
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  Colors.green.shade100,
                  Colors.green.shade300,
                  'Goal Period',
                ),
                _buildLegendItem(
                  Colors.blue.shade200,
                  Colors.blue.shade600,
                  'Today',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    Color backgroundColor,
    Color borderColor,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget _buildCalendarDisplay(GoalModel goal) {
  //   final firstDay = goal.goalStartDate ?? DateTime.now().subtract(Duration(days: 30));
  //   final lastDay = goal.goalEndDate ?? DateTime.now().add(Duration(days: 30));
  //
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.blue.shade100),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Column(
  //       children: [
  //         // Date range header
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Start Date',
  //                     style: TextStyle(
  //                       color: Colors.grey.shade600,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   SizedBox(height: 4),
  //                   Text(
  //                     DateFormat('MMM d, yyyy').format(firstDay),
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   Text(
  //                     'End Date',
  //                     style: TextStyle(
  //                       color: Colors.grey.shade600,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   SizedBox(height: 4),
  //                   Text(
  //                     DateFormat('MMM d, yyyy').format(lastDay),
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         Divider(height: 1, color: Colors.grey.shade200),
  //
  //         // Calendar (display only)
  //         TableCalendar(
  //           firstDay: firstDay,
  //           lastDay: lastDay,
  //           focusedDay: _focusedDay,
  //           calendarFormat: CalendarFormat.month,
  //           startingDayOfWeek: StartingDayOfWeek.monday,
  //           headerVisible: true,
  //
  //           headerStyle: HeaderStyle(
  //             formatButtonVisible: false,
  //             titleCentered: true,
  //             leftChevronIcon: Icon(Icons.chevron_left, size: 20),
  //             rightChevronIcon: Icon(Icons.chevron_right, size: 20),
  //             titleTextStyle: TextStyle(
  //               color: Colors.blue.shade700,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             ),
  //           ),
  //
  //           calendarStyle: CalendarStyle(
  //             weekendTextStyle: TextStyle(color: Colors.black),
  //             todayDecoration: BoxDecoration(
  //               color: Colors.blue.shade100,
  //               shape: BoxShape.circle,
  //             ),
  //             todayTextStyle: TextStyle(
  //               color: Colors.blue.shade700,
  //               fontWeight: FontWeight.bold,
  //             ),
  //             outsideTextStyle: TextStyle(color: Colors.grey.shade400),
  //           ),
  //
  //           // Disable interactions - calendar is for display only
  //           onDaySelected: null,
  //           selectedDayPredicate: (_) => false,
  //
  //           onPageChanged: (focusedDay) {
  //             setState(() {
  //               _focusedDay = focusedDay;
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProgressSection(GoalModel goal) {
    final targetCount = goal.goalTargetCount ?? 0;
    final progressPercentage =
        targetCount > 0 ? (_completedDays / targetCount * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isUpdating ? null : _showUpdateProgressDialog,
              icon: Icon(Icons.edit, size: 16),
              label: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Progress display
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_completedDays / $targetCount days',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '${progressPercentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: targetCount > 0 ? _completedDays / targetCount : 0,
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade600,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(GoalModel goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: 16),

        _buildDetailRow('Goal Type', goal.goalType ?? 'N/A'),
        _buildDetailRow('Period', '${goal.goalPeriodDays ?? 0} days'),
        if (goal.goalCreatedAt != null)
          _buildDetailRow(
            'Created',
            DateFormat('MMM d, yyyy').format(goal.goalCreatedAt!),
          ),
        if (goal.goalUpdatedAt != null)
          _buildDetailRow(
            'Last Updated',
            DateFormat('MMM d, yyyy').format(goal.goalUpdatedAt!),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
