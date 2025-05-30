import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class GoalDetailPage extends StatefulWidget {
  final Map<String, dynamic>? habitData;

  const GoalDetailPage({super.key, this.habitData});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  // Calendar focus
  DateTime _focusedDay = DateTime(2022, 6, 4);
  DateTime _selectedDay = DateTime(2022, 6, 4);

  // Sample habit data if none provided
  late Map<String, dynamic> habitInfo;

  // Sample completed days (can be populated from your data)
  final Set<DateTime> _completedDays = {
    DateTime(2022, 6, 28),
    DateTime(2022, 6, 30),
    DateTime(2022, 7, 1),
    DateTime(2022, 7, 3),
  };

  @override
  void initState() {
    super.initState();

    // Initialize with provided data or defaults
    habitInfo = widget.habitData ?? {
      'name': 'Journaling',
      'target': 7,
      'daysComplete': 7,
      'totalDays': 7,
      'daysFailed': 0,
      'type': 'Everyday',
      'createdOn': DateTime(2022, 6, 4),
      'isAchieved': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Scaffold(
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
                      // Header
                      _buildHeader(),

                      // Calendar
                      _buildCalendarWidget(),

                      // Habit Status
                      _buildHabitStatusWidget(),

                      // Habit Detail Info
                      _buildHabitDetailInfoWidget(),

                      // Spacer
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

  Widget _buildHeader() {
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
                'Goal: ${habitInfo['name']} everyday',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCalendarWidget() {
    final firstDay = DateTime(2022, 6, 1);
    final lastDay = DateTime(2022, 7, 31);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Date range header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start date',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'End date',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Date values
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM d yyyy').format(firstDay),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMMM d yyyy').format(
                      DateTime(firstDay.year, firstDay.month + 1, firstDay.day - 1)),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Calendar
          TableCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: true,

            // Custom header
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, size: 20),
              rightChevronIcon: Icon(Icons.chevron_right, size: 20),
              titleTextStyle: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Calendar styling
            calendarStyle: CalendarStyle(
              // Weekend days
              weekendTextStyle: TextStyle(color: Colors.black),

              // Today styling
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
              ),
              todayTextStyle: TextStyle(color: Colors.black),

              // Selected day styling
              // selectedDecoration: BoxDecoration(
              //   color: Colors.blue.shade100,
              //   shape: BoxShape.circle,
              // ),

              // Outside days (from other months)
              outsideTextStyle: TextStyle(color: Colors.grey.shade400),

              // Markers for completed days
              markersMaxCount: 1,
              canMarkersOverflow: false,
            ),

            // Calendar events/markers for completed days
            eventLoader: (day) {
              // Check if this day is marked as completed
              return _isCompletedDay(day) ? [day] : [];
            },

            // Cell builder for custom styling
            calendarBuilders: CalendarBuilders(
              // Custom day cell builder to show green background for completed days
              defaultBuilder: (context, day, focusedDay) {
                if (_isCompletedDay(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return null; // Use default cell
              },
            ),

            // Calendar selection handling
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }

  bool _isCompletedDay(DateTime day) {
    return _completedDays.any((completedDay) =>
        isSameDay(completedDay, day));
  }

  Widget _buildHabitStatusWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habitInfo['name'] + ' ' + habitInfo['type'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              habitInfo['isAchieved'] ? 'Achieved' : 'In Progress',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitDetailInfoWidget() {
    // Create a reusable widget for the habit details
    return Column(
      children: [
        _buildDetailRow('Habit Name:', habitInfo['name']),
        _buildDetailRow('Target:', '${habitInfo['daysComplete']} from ${habitInfo['totalDays']} Days'),
        _buildDetailRow('Days complete:', '${habitInfo['daysComplete']} from ${habitInfo['totalDays']} Days'),
        _buildDetailRow('Days failed:', '${habitInfo['daysFailed']} Day'),
        _buildDetailRow('Habit type:', habitInfo['type']),
        _buildDetailRow('Created on', DateFormat('MMMM d yyyy').format(habitInfo['createdOn'])),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
