import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_detail_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_list_page.dart';

class GoalManagePage extends ConsumerStatefulWidget {
  const GoalManagePage({super.key});

  @override
  ConsumerState<GoalManagePage> createState() => _GoalManagePageState();
}

class _GoalManagePageState extends ConsumerState<GoalManagePage>
    with TickerProviderStateMixin {
  bool _isFormVisible = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _targetCountController = TextEditingController();
  final _periodDaysController = TextEditingController();

  // Form state
  GoalModel? _editingGoal;

  bool get _isEditing => _editingGoal != null;

  late final GoalUsecase _goalUsecase;
  List<GoalModel> _goals = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
        _error = 'Error while fetch all goals';
        _isLoading = false;
      });
    }
  }

  void _toggleForm({GoalModel? goalToEdit}) {
    setState(() {
      if (goalToEdit != null) {
        // Edit mode
        _editingGoal = goalToEdit;
        _titleController.text = goalToEdit.goalTitle ?? '';
        _descriptionController.text = goalToEdit.goalDescription ?? '';
        _typeController.text = goalToEdit.goalType ?? '';
        _targetCountController.text =
            goalToEdit.goalTargetCount?.toString() ?? '';
        _periodDaysController.text =
            goalToEdit.goalPeriodDays?.toString() ?? '';
        _selectedStartDate = goalToEdit.goalStartDate;
        _selectedEndDate = goalToEdit.goalEndDate;
        _isFormVisible = true;
        _slideController.forward();
      } else if (_isFormVisible) {
        // Close form
        _isFormVisible = false;
        _slideController.reverse();
        _clearForm();
      } else {
        // Open form for new goal
        _clearForm();
        _editingGoal = null;
        _clearForm();
        _isFormVisible = true;
        _slideController.forward();
      }
    });
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _typeController.clear();
    _targetCountController.clear();
    _periodDaysController.clear();
    _selectedStartDate = null;
    _selectedEndDate = null;
    _editingGoal = null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? _selectedStartDate ?? DateTime.now()
              : _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _submitGoal() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _typeController.text.trim().isEmpty ||
        _targetCountController.text.trim().isEmpty ||
        _periodDaysController.text.trim().isEmpty ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Please fill in all the required fields')),
      // );
      Notify.showFlushbar('Please fill in all the required fields');
      return;
    }

    final targetCount = int.tryParse(_targetCountController.text.trim());
    final periodDays = int.tryParse(_periodDaysController.text.trim());

    if (targetCount == null || periodDays == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Please enter valid numbers for target and period')),
      // );
      Notify.showFlushbar('Please enter valid numbers for target and period');
      return;
    }

    if (_selectedStartDate!.isAfter(_selectedEndDate!)) {
      Notify.showFlushbar('Start date must be before or equal to end date');
      return;
    }
    // if (_titleController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please enter a goal title')),
    //   );
    //   return;
    // }

    setState(() {
      _isSubmitting = true;
    });
    final goalObject = CreateGoalModel(
      goalTitle: _titleController.text.trim(),
      goalDescription: _descriptionController.text.trim(),
      goalType: _typeController.text.trim(),
      goalStartDate: _selectedStartDate!,
      goalEndDate: _selectedEndDate!,
      goalTargetCount: int.tryParse(_targetCountController.text.trim())!,
      goalPeriodDays: int.tryParse(_periodDaysController.text.trim())!,
    );

    try {
      if (_isEditing) {
        // Update existing goal
        final result = await _goalUsecase.updateOwnGoals(
          _editingGoal!.goalId!,
          goalObject,
          // title: _titleController.text.trim(),
          // description: _descriptionController.text.trim(),
          // type: _typeController.text.trim(),
          // targetCount: int.tryParse(_targetCountController.text.trim()),
          // periodDays: int.tryParse(_periodDaysController.text.trim()),
          // startDate: _selectedStartDate,
          // endDate: _selectedEndDate,
        );

        if (result.isSuccess) {
          Notify.showFlushbar('Goal updated successfully!');
        } else {
          throw Exception('Fail to update goal. Please try again');
        }
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Goal updated successfully!')),
        // );
      } else {
        // Create new goal
        final result = await _goalUsecase.createOwnGoals(
          goalObject,
          // title: _titleController.text.trim(),
          // description: _descriptionController.text.trim(),
          // type: _typeController.text.trim(),
          // targetCount: int.tryParse(_targetCountController.text.trim()),
          // periodDays: int.tryParse(_periodDaysController.text.trim()),
          // startDate: _selectedStartDate,
          // endDate: _selectedEndDate,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Goal created successfully!')),
        // );
        if (result.isSuccess) {
          Notify.showFlushbar('Goal created successfully!');
        } else {
          throw Exception('Fail to create goal. Please try again');
        }
      }

      // Refresh goals list
      await _fetchGoals();

      _clearForm();
      // Close form
      _toggleForm();
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: ${e.toString()}')),
      // );

      Notify.showFlushbar('Error while add new goal', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
        _isFormVisible = false;
      });
    }
  }

  Future<void> _deleteGoal(GoalModel goal) async {
    bool isDeleting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) => AlertDialog(
                title: Text('Delete Goal'),
                content:
                    isDeleting
                        ? Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Deleting...'),
                          ],
                        )
                        : Text(
                          'Are you sure you want to delete "${goal.goalTitle}"?',
                        ),
                actions:
                    isDeleting
                        ? []
                        : [
                          TextButton(
                            onPressed:
                                () => Navigator.pop(dialogContext, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              setDialogState(() => isDeleting = true);

                              try {
                                final result = await _goalUsecase
                                    .deleteOwnGoals(goal.goalId!);

                                if (result.isSuccess) {
                                  // Close dialog first
                                  Navigator.of(dialogContext).pop(true);

                                  // Then show success message and refresh
                                  Notify.showFlushbar(
                                    'Goal deleted successfully!',
                                  );
                                  await _fetchGoals();
                                } else {
                                  setDialogState(() => isDeleting = false);
                                  Notify.showFlushbar(
                                    'Failed to delete goal',
                                    isError: true,
                                  );
                                }
                              } catch (e) {
                                setDialogState(() => isDeleting = false);
                                Notify.showFlushbar(
                                  'Error deleting goal',
                                  isError: true,
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text('Delete'),
                          ),
                        ],
              ),
        );
      },
    );
  }

  Future<void> _toggleGoalCompletion(GoalModel goal) async {
    try {
      final newStatus = goal.goalStatus == 'completed' ? 'active' : 'completed';
      // await _goalUsecase.toggleGoalCompletion(goal.goalId!, newStatus);
      await _fetchGoals();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating goal')));
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _targetCountController.dispose();
    _periodDaysController.dispose();
    super.dispose();
  }

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

    _goalUsecase = ref.read(goalUseCaseProvider);
    _fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Add this
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title (fixed at top)
                    _buildHeader(),

                    // Scrollable content area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Form for adding new habits
                            SizeTransition(
                              sizeFactor: _slideController,
                              axisAlignment: -1.0,
                              child: _buildGoalForm(),
                            ),

                            // Today's goals section with constrained height
                            _buildTodayGoalsSection(),
                          ],
                        ),
                      ),
                    ),

                    // Spacing at the bottom
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
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       resizeToAvoidBottomInset: true,
  //       body: LayoutBuilder(
  //         builder: (context, constraints) {
  //           return ConstrainedBox(
  //             constraints: BoxConstraints(minHeight: constraints.maxHeight),
  //             child: Container(
  //               width: double.infinity,
  //               padding: const EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Color(0xFFFFB876).withOpacity(0.1),
  //                     blurRadius: 10,
  //                     offset: Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Back button and title
  //                   _buildHeader(),
  //
  //                   // Form for adding new habits
  //                   SizeTransition(
  //                     sizeFactor: _slideController,
  //                     axisAlignment: -1.0,
  //                     child: _buildGoalForm(),
  //                   ),
  //
  //                   // Today's goals section
  //                   _buildTodayGoalsSection(),
  //
  //                   // Spacing at the bottom
  //                   SizedBox(height: 40),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

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
                color: Color(0xFFFFB876),
              ),
              label: Text(
                _isFormVisible ? 'Hide Add Goal Form' : 'Add New Goal',
                style: TextStyle(color: Color(0xFFFFB876)),
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
                  'Manage your goals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep a track of your goals',
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

  Widget _buildGoalForm() {
    if (!_isEditing) {
      _periodDaysController.text = '0';
    }

    return Column(
      children: [
        // Form title
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Edit Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6A065),
              ),
            ),
          ),

        // Title input
        _buildFormTextField(
          controller: _titleController,
          hintText: 'Goal Title',
        ),
        SizedBox(height: 12),

        // Description input
        _buildFormTextField(
          controller: _descriptionController,
          hintText: 'Description',
          maxLines: 3,
        ),
        SizedBox(height: 12),

        // Type input
        _buildFormTextField(
          controller: _typeController,
          hintText: 'Goal Type (e.g., fitness, study, etc.)',
        ),
        SizedBox(height: 12),

        // Target count and period days in a row
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(
                controller: _targetCountController,
                hintText: 'Target Days Count',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFormTextField(
                controller: _periodDaysController,
                hintText: 'Day(s) Completed/Target',
                keyboardType: TextInputType.number,
                enabled: _isEditing,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Date selection buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFFFD8B3), width: 1),
                  ),
                  child: Text(
                    _selectedStartDate != null
                        ? 'Start: ${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                        : 'Select Start Date',
                    style: TextStyle(
                      color:
                      _selectedStartDate != null
                          ? Color(0xFFCC9054)
                          : Color(0xFFB38760),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFFFD8B3), width: 1),
                  ),
                  child: Text(
                    _selectedEndDate != null
                        ? 'End: ${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                        : 'Select End Date',
                    style: TextStyle(
                      color:
                      _selectedEndDate != null
                          ? Color(0xFFCC9054)
                          : Color(0xFFB38760),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFB876),
              disabledBackgroundColor: Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            _isSubmitting
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  _isEditing ? 'Updating...' : 'Creating...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
                : Text(
              _isEditing ? 'Update Goal' : 'Add Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Cancel button for edit mode
        if (_isEditing) ...[
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => _toggleForm(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFFFD8B3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC9054),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 12 : 0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFE5CC), width: 1),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFFB38760)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTodayGoalsSection() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: isKeyboardVisible && _isFormVisible
            ? 250  // Smaller height when form is visible and keyboard is up
            : 400, // Normal height
      ),
      child: Column(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoalListPage()),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(fontSize: 14, color: Color(0xFFB38760)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Expanded(
            child: _buildGoalsList(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget _buildTodayGoalsSection() {
  //   return Expanded(
  //     child: SingleChildScrollView( // Wrap the entire section with SingleChildScrollView
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Today Goal',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => GoalListPage()),
  //                   );
  //                 },
  //                 child: Text(
  //                   'See all',
  //                   style: TextStyle(fontSize: 14, color: Color(0xFFB38760)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12),
  //
  //           // Use Container with minimum height instead of Expanded
  //           Container(
  //             constraints: BoxConstraints(
  //               minHeight: 300, // Minimum height to show some content
  //               maxHeight: MediaQuery.of(context).size.height * 0.6, // Maximum height
  //             ),
  //             child: _buildGoalsList(),
  //           ),
  //           SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTodayGoalsSection() {
  //   return Expanded(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Today Goal',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => GoalListPage()),
  //                 );
  //               },
  //               child: Text(
  //                 'See all',
  //                 style: TextStyle(fontSize: 14, color: Color(0xFFB38760)),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 12),
  //
  //         Expanded(
  //           child: _buildGoalsList(),
  //           // ListView.builder(
  //           //   itemCount: _goals.length,
  //           //   itemBuilder: (context, index) {
  //           //     return HabitListItem(habit: _goals[index]);
  //           //   },
  //           // ),
  //         ),
  //         SizedBox(height: 20),
  //
  //         // Goal items
  //         // ..._goals.map((goal) => _buildGoalItem(goal)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGoalsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB876)),
        ),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Color(0xFFFF9B76)),
            SizedBox(height: 16),
            Text(
              'Error loading goals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB876),
              ),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),);
    }

    if (_goals.isEmpty) {
      return SingleChildScrollView(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 48, color: Color(0xFFFFD8B3)),
            SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first goal to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),);
    }

    return RefreshIndicator(
      onRefresh: _fetchGoals,
      child: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          return GestureDetector(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailPage(goalId: _goals[index].goalId!)));}, child: GoalListItem(
            goal: _goals[index],
            // onToggle: () => _toggleGoalCompletion(_goals[index]),
            onToggle: () => null,
            onEdit: () => _toggleForm(goalToEdit: _goals[index]),
            onDelete: () => _deleteGoal(_goals[index]),
          ),);
        },
      ),
    );
  }
}

class GoalListItem extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalListItem({
    super.key,
    required this.goal,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.goalStatus == 'completed';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Color(0xFFFFF9F4),
        border: Border.all(color: Color(0xFFFFE5CC), width: 1),
      ),
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goalTitle ?? 'Untitled Goal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (goal.goalDescription != null &&
                    goal.goalDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      goal.goalDescription!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                if (goal.goalType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Type: ${goal.goalType}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE6A065),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (goal.goalTargetCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Target: ${goal.goalTargetCount} times',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xFFFFB876), width: 2),
                color: isCompleted ? Color(0xFFFFB876) : Colors.transparent,
              ),
              child:
              isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Color(0xFFB38760)),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder:
                (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Color(0xFFFFB876)),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Color(0xFFFF9B76)),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
