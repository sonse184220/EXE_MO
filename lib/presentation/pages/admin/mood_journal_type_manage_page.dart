import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/mood_journal_type/mood_journal_type_model.dart';
import 'package:inner_child_app/domain/usecases/mood_journal_type_usecase.dart';

class MoodJournalTypeManagePage extends ConsumerStatefulWidget {
  const MoodJournalTypeManagePage({super.key});
  @override
  ConsumerState<MoodJournalTypeManagePage> createState() => _MoodJournalTypeManagePageState();
}

class _MoodJournalTypeManagePageState extends ConsumerState<MoodJournalTypeManagePage> {
  late final MoodJournalTypeUsecase _moodJournalTypeUsecase;

  List<MoodJournalTypeModel> moodJournalTypes = [];

  bool isLoadType = false;
  bool isTypeListError = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _fetchMoodJournalTypes() async {
    setState(() {
      isLoadType = true;
      isTypeListError = false;
    });

    try {
      final result = await _moodJournalTypeUsecase.getAllTypes();
      if (result.isSuccess) {
        setState(() {
          moodJournalTypes = result.data!;
          isLoadType = false;
        });
      } else {
        throw Exception('Fail to fetch types');
      }
    } catch (_) {
      setState(() {
        isLoadType = false;
        isTypeListError = true;
      });
    }
  }

  void _createMoodJournalType() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: MoodJournalTypeForm(
            onSave: (newType) async {
              try {
                final result = await _moodJournalTypeUsecase.createType(newType.moodJournalTypeName);
                return result.isSuccess;
                // Navigator.pop(context, result.isSuccess);
              } catch (_) {
                // Navigator.pop(context, false);
                return false;
              } finally {
                _fetchMoodJournalTypes();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Mood Type created successfully');
    } else {
      Notify.showFlushbar('Failed to create Mood Type', isError: true);
    }
  }

  void _updateMoodJournalType(MoodJournalTypeModel type) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: MoodJournalTypeForm(
            moodJournalType: type,
            onSave: (updated) async {
              try {
                final result = await _moodJournalTypeUsecase.updateType(
                  updated.moodJournalTypeId,
                  updated.moodJournalTypeName,
                );
                return result.isSuccess;
              } catch (_) {
                return false;
              } finally {
                _fetchMoodJournalTypes();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Type updated successfully');
    } else {
      Notify.showFlushbar('Failed to update type', isError: true);
    }
  }

  List<MoodJournalTypeModel> get filteredMoodJournalTypes {
    if (_searchQuery.isEmpty) return moodJournalTypes;
    return moodJournalTypes.where((type) => type.moodJournalTypeName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _moodJournalTypeUsecase = ref.read(moodJournalTypeUseCaseProvider);

    _fetchMoodJournalTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTypes = filteredMoodJournalTypes;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Mood Journal Type Management',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats Section
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF89B7C2).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${moodJournalTypes.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Journal Types',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mood,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by type name',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF89B7C2), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Found ${displayedTypes.length} type${displayedTypes.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    Text(
                      ' for "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Add Journal Type Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createMoodJournalType,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB876),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFFB876).withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add New Journal Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Journal Types List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: displayedTypes.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.mood_outlined : Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No journal types yet'
                          : 'No journal types found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Add your first journal type to get started'
                          : 'Try adjusting your search terms',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: displayedTypes.length,
                itemBuilder: (context, index) {
                  final type = displayedTypes[index];
                  return MoodJournalTypeListItem(
                    moodJournalType: type,
                    onEdit: () => _updateMoodJournalType(type),
                    // onDelete: () => _deleteMoodJournalType(type),
                    searchQuery: _searchQuery,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoodJournalTypeListItem extends StatelessWidget {
  final MoodJournalTypeModel moodJournalType;
  final VoidCallback onEdit;
  // final VoidCallback onDelete;
  final String searchQuery;

  const MoodJournalTypeListItem({
    super.key,
    required this.moodJournalType,
    required this.onEdit,
    // required this.onDelete,
    this.searchQuery = '',
  });

  // Helper method to highlight search terms
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      );
    }

    final startIndex = lowerText.indexOf(lowerQuery);
    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFB876),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate a harmonious color for each journal type
    final List<List<Color>> typeColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)], // Raspberry to Ice Cream
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)], // Papaya to Sunshine
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)], // Meadow to Spring Sky
      [const Color(0xFF89B7C2), const Color(0xFFE37083)], // Spring Sky to Raspberry
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)], // Ice Cream to Meadow
    ];

    final colorIndex = moodJournalType.moodJournalTypeId.hashCode.abs() % typeColors.length;
    final gradientColors = typeColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.mood,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(moodJournalType.moodJournalTypeName, searchQuery),
                const SizedBox(height: 4),
                Text(
                  'ID: ${moodJournalType.moodJournalTypeId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8BF8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Journal Type',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA8BF8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF89B7C2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF89B7C2), size: 20),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
              const SizedBox(width: 8),
              // Container(
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFE37083).withOpacity(0.15),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: IconButton(
              //     icon: const Icon(Icons.delete_outline, color: Color(0xFFE37083), size: 20),
              //     // onPressed: onDelete,
              //     constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

  class MoodJournalTypeForm extends StatefulWidget {
    final MoodJournalTypeModel? moodJournalType;
    final Future<bool> Function(MoodJournalTypeModel) onSave;

    const MoodJournalTypeForm({
      super.key,
      this.moodJournalType,
      required this.onSave,
    });

    @override
    State<MoodJournalTypeForm> createState() => _MoodJournalTypeFormState();
  }

  class _MoodJournalTypeFormState extends State<MoodJournalTypeForm> {
    final _formKey = GlobalKey<FormState>();
    late final TextEditingController _typeNameController;

    bool _isLoading = false;

    @override
    void initState() {
      super.initState();
      final type = widget.moodJournalType;
      _typeNameController = TextEditingController(text: type?.moodJournalTypeName ?? '');
    }

    void _saveForm() async {
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);

        final type = MoodJournalTypeModel(
          moodJournalTypeId: widget.moodJournalType?.moodJournalTypeId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          moodJournalTypeName: _typeNameController.text.trim(),
        );

        try {
          final success = await widget.onSave(type);
          if (success && mounted) {
            Navigator.pop(context, true);
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }

    Widget _buildFormField({
      required String label,
      required TextEditingController controller,
      required String hint,
      String? Function(String?)? validator,
      Widget? prefixIcon,
      bool isRequired = true,
      String? helpText,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF89B7C2), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: validator,
          ),
          if (helpText != null) ...[
            const SizedBox(height: 4),
            Text(
              helpText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      );
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.moodJournalType == null ? 'Add New Journal Type' : 'Edit Journal Type',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  label: 'Journal Type Name',
                  controller: _typeNameController,
                  hint: 'Enter journal type name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a journal type name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFBDC3C7)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB876),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: const Color(0xFFFFB876).withOpacity(0.4),
                        ),
                        child:  _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          widget.moodJournalType == null ? 'Save' : 'Update',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    @override
    void dispose() {
      _typeNameController.dispose();
      super.dispose();
    }
  }