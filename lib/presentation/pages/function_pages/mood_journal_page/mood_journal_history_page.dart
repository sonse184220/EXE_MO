import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';
import 'package:inner_child_app/domain/entities/mood_journal/mood_journal_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal_type/mood_journal_type_model.dart';
import 'package:inner_child_app/domain/usecases/mood_journal_type_usecase.dart';
import 'package:inner_child_app/domain/usecases/mood_journal_usecase.dart';
import 'package:intl/intl.dart';

enum FilterBy { all, thisWeek, thisMonth, earlier }

enum Mood { happy, neutral, sad }

class MoodJournalHistoryPage extends ConsumerStatefulWidget {
  const MoodJournalHistoryPage({super.key});

  @override
  ConsumerState<MoodJournalHistoryPage> createState() =>
      _MoodJournalHistoryPageState();
}

class _MoodJournalHistoryPageState
    extends ConsumerState<MoodJournalHistoryPage> {
  late MoodJournalUsecase _moodJournalUsecase;
  late MoodJournalTypeUsecase _moodJournalTypeUsecase;

  List<MoodJournalModel> _moodJournals = [];
  List<MoodJournalTypeModel> journalTypes = [];

  bool _isLoading = true;
  bool _isLoadingTypes = false;

  String? _errorMessage;
  FilterBy _currentFilter = FilterBy.all;

  Future<void> _loadJournalTypes() async {
    setState(() {
      _isLoadingTypes = true;
    });

    try {
      final types = await _moodJournalTypeUsecase.getAllTypes();
      setState(() {
        journalTypes = types.data!;
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTypes = false;
      });
      // Handle error - show snackbar or dialog
      Notify.showFlushbar('Failed to load journal types', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load journal types: $e')),
      // );
    }
  }

  Future<void> _fetchMoodJournals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _moodJournalUsecase.getMoodJournalHistory();
      setState(() {
        _moodJournals = result.data!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(FilterBy? newFilter) {
    if (newFilter != null) {
      setState(() {
        _currentFilter = newFilter;
      });
    }
  }

  String _getMoodString(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return 'Happy';
      case Mood.neutral:
        return 'Neutral';
      case Mood.sad:
        return 'Sad';
    }
  }

  Mood? _getMoodFromString(String moodString) {
    switch (moodString.toLowerCase()) {
      case 'happy':
        return Mood.happy;
      case 'neutral':
        return Mood.neutral;
      case 'sad':
        return Mood.sad;
      default:
        return null;
    }
  }

  String _getFilterDisplayName(FilterBy filter) {
    switch (filter) {
      case FilterBy.all:
        return 'All';
      case FilterBy.thisWeek:
        return 'This Week';
      case FilterBy.thisMonth:
        return 'This Month';
      case FilterBy.earlier:
        return 'Earlier';
    }
  }

  List<MapEntry<String, List<MoodJournalModel>>> _groupJournalsByTime() {
    final Map<String, List<MoodJournalModel>> grouped = {};

    for (var journal in _moodJournals) {
      final category = _getTimeCategory(journal.moodJournalCreatedAt);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(journal);
    }

    // Sort groups by time (This week, This month, Earlier)
    final sortedEntries = grouped.entries.toList();
    sortedEntries.sort((a, b) {
      const order = ['This week', 'This month', 'Earlier'];
      return order.indexOf(a.key).compareTo(order.indexOf(b.key));
    });

    return sortedEntries;
  }

  List<MapEntry<String, List<MoodJournalModel>>> _filterGroups(
    List<MapEntry<String, List<MoodJournalModel>>> groups,
  ) {
    if (_currentFilter == FilterBy.all) {
      return groups;
    }

    String targetCategory;
    switch (_currentFilter) {
      case FilterBy.thisWeek:
        targetCategory = 'This week';
        break;
      case FilterBy.thisMonth:
        targetCategory = 'This month';
        break;
      case FilterBy.earlier:
        targetCategory = 'Earlier';
        break;
      default:
        return groups;
    }

    return groups.where((group) => group.key == targetCategory).toList();
  }

  void _showMoodJournalDetail(MoodJournalModel journal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _EditableMoodJournalModal(
            journal: journal,
            moodJournalUsecase: _moodJournalUsecase,
            journalTypes: journalTypes,
            onUpdated: () {
              _fetchMoodJournals();
            },
          ),
    );
  }

  // void _showMoodJournalDetail(MoodJournalModel journal) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _buildDetailModal(journal),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _moodJournalUsecase = ref.read(moodJournalUseCaseProvider);
    _moodJournalTypeUsecase = ref.read(moodJournalTypeUseCaseProvider);
    _fetchMoodJournals();
    _loadJournalTypes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Journal History',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Filter by:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FilterBy>(
                        value: _currentFilter,
                        onChanged: _onFilterChanged,
                        items:
                        FilterBy.values.map((FilterBy filter) {
                          return DropdownMenuItem<FilterBy>(
                            value: filter,
                            child: Text(
                              _getFilterDisplayName(filter),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    ));
  }

  Widget _buildDetailModal(MoodJournalModel journal) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 56, // or any height that fits your design
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered title
                        Center(
                          child: Text(
                            'Mood Journal Detail',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Right-aligned close button
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     Align(alignment: Alignment.center, child: Text(
                  //       'Mood Journal Detail',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.grey[800],
                  //       ),
                  //     ),),
                  //     Align(alignment: Alignment.centerRight, child: IconButton(
                  //       onPressed: () => Navigator.pop(context),
                  //       icon: Icon(Icons.close, color: Colors.grey[600]),
                  //     ),)
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Title', journal.moodJournalTitle),
                  const SizedBox(height: 16),
                  _buildDetailRow('Emotion', journal.moodJournalEmotion),
                  const SizedBox(height: 16),
                  _buildDetailRow('Type', journal.moodJournalTypeName),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Date',
                    DateFormat(
                      'dd MMM yyyy HH:mm a',
                    ).format(journal.moodJournalCreatedAt),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          journal.moodJournalDescription,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  String _getTimeCategory(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 7) {
      return 'This week';
    } else if (difference < 30) {
      return 'This month';
    } else {
      return 'Earlier';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8BC34A)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading mood journals',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMoodJournals,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_moodJournals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mood, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No mood journals yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final groupedJournals = _groupJournalsByTime();
    final filteredGroups = _filterGroups(groupedJournals);

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No journals found for ${_getFilterDisplayName(_currentFilter)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8BC34A),
      onRefresh: _fetchMoodJournals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = filteredGroups[groupIndex];
          final category = group.key;
          final journals = group.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupIndex > 0) const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF689F38),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...journals.map((journal) => _buildJournalItem(journal)).toList(),
            ],
          );
        },
      ),
    );
  }

  // Widget _buildBody() {
  //   if (_isLoading) {
  //     return const Center(
  //       child: CircularProgressIndicator(
  //         color: Color(0xFF8BC34A),
  //       ),
  //     );
  //   }
  //
  //   if (_errorMessage != null) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.error_outline,
  //             size: 64,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'Error loading mood journals',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             _errorMessage!,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey[500],
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: _fetchMoodJournals,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF8BC34A),
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Retry'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   if (_moodJournals.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.mood,
  //             size: 64,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'No mood journals yet',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   final groupedJournals = _groupJournalsByTime();
  //
  //   return RefreshIndicator(
  //     color: const Color(0xFF8BC34A),
  //     onRefresh: _fetchMoodJournals,
  //     child: ListView.builder(
  //       padding: const EdgeInsets.all(16),
  //       itemCount: groupedJournals.length,
  //       itemBuilder: (context, groupIndex) {
  //         final group = groupedJournals[groupIndex];
  //         final category = group.key;
  //         final journals = group.value;
  //
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             if (groupIndex > 0) const SizedBox(height: 24),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF8BC34A).withOpacity(0.2),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 category,
  //                 style: const TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF689F38),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             ...journals.map((journal) => _buildJournalItem(journal)).toList(),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildJournalItem(MoodJournalModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMoodJournalDetail(journal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC34A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFF689F38),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journal.moodJournalTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        journal.moodJournalTypeName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      journal.moodJournalEmotion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'dd MMM yyyy\nHH:mm a',
                      ).format(journal.moodJournalCreatedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableMoodJournalModal extends StatefulWidget {
  final MoodJournalModel journal;
  final MoodJournalUsecase moodJournalUsecase;
  final List<MoodJournalTypeModel> journalTypes;
  final VoidCallback onUpdated;

  const _EditableMoodJournalModal({
    required this.journal,
    required this.moodJournalUsecase,
    required this.onUpdated,
    required this.journalTypes,
  });

  @override
  State<_EditableMoodJournalModal> createState() =>
      _EditableMoodJournalModalState();
}

class _EditableMoodJournalModalState extends State<_EditableMoodJournalModal> {
  bool _isEditMode = false;
  bool _isSaving = false;
  late TextEditingController _titleController;

  // late TextEditingController _emotionController;
  late TextEditingController _descriptionController;

  // late TextEditingController _typeIdController;

  Mood? _selectedMood;
  MoodJournalTypeModel? _selectedJournalType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.journal.moodJournalTitle,
    );
    _descriptionController = TextEditingController(
      text: widget.journal.moodJournalDescription,
    );

    // Initialize selected mood
    _selectedMood = _getMoodFromString(widget.journal.moodJournalEmotion);

    // Initialize selected journal type
    _selectedJournalType = widget.journalTypes.firstWhere(
      (type) => type.moodJournalTypeId == widget.journal.moodJournalTypeId,
      orElse:
          () =>
              widget.journalTypes.isNotEmpty
                  ? widget.journalTypes.first
                  : null!,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getMoodString(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return 'Happy';
      case Mood.neutral:
        return 'Neutral';
      case Mood.sad:
        return 'Sad';
    }
  }

  Mood? _getMoodFromString(String moodString) {
    switch (moodString.toLowerCase()) {
      case 'happy':
        return Mood.happy;
      case 'neutral':
        return Mood.neutral;
      case 'sad':
        return Mood.sad;
      default:
        return null;
    }
  }

  Future<void> _saveChanges() async {
    // Validation
    if (_selectedMood == null) {
      Notify.showFlushbar('Please select a mood', isError: true);
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
      return;
    }

    if (_selectedJournalType == null) {
      Notify.showFlushbar('Please select a journal type', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please select a journal type')),
      // );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      Notify.showFlushbar('Please enter a journal title', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please enter a journal title')),
      // );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      Notify.showFlushbar('Please write your journal content', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please write your journal content')),
      // );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updateData = LogMoodJournalRequest(
        moodJournalTitle: _titleController.text.trim(),
        moodJournalEmotion: _getMoodString(_selectedMood!),
        moodJournalDescription: _descriptionController.text.trim(),
        moodJournalTypeId: _selectedJournalType!.moodJournalTypeId,
      );

      // Call your update method from usecase
      final result = await widget.moodJournalUsecase.updateMoodJournal(
        widget.journal.moodJournalId,
        updateData,
      );

      widget.onUpdated();
      Navigator.pop(context);

      Notify.showFlushbar('Mood journal updated successfully');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Mood journal updated successfully'),
      //     backgroundColor: Color(0xFF8BC34A),
      //   ),
      // );
    } catch (e) {
      Notify.showFlushbar('Error updating mood journal: $e', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error updating mood journal: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _isEditMode = false;
      // Reset controllers to original values
      _titleController.text = widget.journal.moodJournalTitle;
      _descriptionController.text = widget.journal.moodJournalDescription;
      _selectedMood = _getMoodFromString(widget.journal.moodJournalEmotion);
      _selectedJournalType = widget.journalTypes.firstWhere(
        (type) => type.moodJournalTypeId == widget.journal.moodJournalTypeId,
        orElse:
            () =>
                widget.journalTypes.isNotEmpty
                    ? widget.journalTypes.first
                    : null!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered title
                        Center(
                          child: Text(
                            _isEditMode
                                ? 'Edit Mood Journal'
                                : 'Mood Journal Detail',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Right-aligned buttons
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isEditMode) ...[
                                if (_isSaving)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF8BC34A),
                                      ),
                                    ),
                                  )
                                else ...[
                                  IconButton(
                                    onPressed: _saveChanges,
                                    icon: const Icon(
                                      Icons.check,
                                      color: Color(0xFF8BC34A),
                                    ),
                                    tooltip: 'Save',
                                  ),
                                  IconButton(
                                    onPressed: _resetForm,
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                    ),
                                    tooltip: 'Cancel',
                                  ),
                                ],
                              ] else ...[
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditMode = true;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.grey[600],
                                  ),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[600],
                                  ),
                                  tooltip: 'Close',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isEditMode) ...[
                    _buildEditField('Title', _titleController),
                    const SizedBox(height: 16),
                    _buildMoodSelector(),
                    const SizedBox(height: 16),
                    _buildJournalTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Date',
                      DateFormat(
                        'dd MMM yyyy HH:mm a',
                      ).format(widget.journal.moodJournalCreatedAt),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter description...',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildDetailRow('Title', widget.journal.moodJournalTitle),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Emotion',
                      widget.journal.moodJournalEmotion,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Type', widget.journal.moodJournalTypeName),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Date',
                      DateFormat(
                        'dd MMM yyyy HH:mm a',
                      ).format(widget.journal.moodJournalCreatedAt),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.journal.moodJournalDescription,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8BC34A)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              Mood.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF8BC34A)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF8BC34A)
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          _getMoodString(mood),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildJournalTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journal Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MoodJournalTypeModel>(
              value: _selectedJournalType,
              isExpanded: true,
              onChanged: (MoodJournalTypeModel? newValue) {
                setState(() {
                  _selectedJournalType = newValue;
                });
              },
              items:
                  widget.journalTypes.map<
                    DropdownMenuItem<MoodJournalTypeModel>
                  >((MoodJournalTypeModel type) {
                    return DropdownMenuItem<MoodJournalTypeModel>(
                      value: type,
                      child: Text(
                        type.moodJournalTypeName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
