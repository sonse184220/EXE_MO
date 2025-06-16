import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';
import 'package:inner_child_app/domain/usecases/audio_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_subcategory_usecase.dart';

class AudioCategoryManagePage extends ConsumerStatefulWidget {
  const AudioCategoryManagePage({super.key});

  @override
  ConsumerState<AudioCategoryManagePage> createState() =>
      _AudioCategoryManagePageState();
}

class _AudioCategoryManagePageState
    extends ConsumerState<AudioCategoryManagePage>
    with SingleTickerProviderStateMixin {
  late final AudioCategoryUsecase _audioCategoryUsecase;
  late final AudioSubcategoryUsecase _audioSubcategoryUsecase;

  late TabController _tabController;

  bool isLoadCategory = false;
  bool isLoadSubCategory = false;

  bool isCategoryListError = false;
  bool isSubCategoryListError = false;

  List<AudioCategory> audioCategories = [];
  List<SubAudioCategoryModel> audioSubCategories = [];

  final TextEditingController _categorySearchController =
      TextEditingController();
  String _categorySearchQuery = '';

  final TextEditingController _subCategorySearchController =
      TextEditingController();
  String _subCategorySearchQuery = '';

  @override
  void initState() {
    super.initState();

    _audioCategoryUsecase = ref.read(audioCategoryUseCaseProvider);
    _audioSubcategoryUsecase = ref.read(audioSubcategoryUseCaseProvider);

    _tabController = TabController(length: 2, vsync: this);

    _fetchCategories();
    _fetchSubCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoadCategory = true;
      isCategoryListError = false;
    });

    try {
      final result = await _audioCategoryUsecase.getAllAudioCategories();
      if (result.isSuccess) {
        setState(() {
          audioCategories = result.data!;
          isLoadCategory = false;
        });
      } else {
        throw Exception('Fetch audio categories fail');
      }
    } catch (e) {
      setState(() {
        isLoadCategory = false;
        isCategoryListError = true;
      });
    }
  }

  Future<void> _fetchSubCategories() async {
    setState(() {
      isLoadSubCategory = true;
      isSubCategoryListError = false;
    });

    try {
      final result = await _audioSubcategoryUsecase.getAllSubAudioCategories();
      if (result.isSuccess) {
        setState(() {
          audioSubCategories = result.data!;
          isLoadSubCategory = false;
        });
      } else {
        throw Exception('Fetch audio subcatgories fail');
      }
    } catch (e) {
      setState(() {
        isLoadSubCategory = false;
        isSubCategoryListError = true;
      });
    }
  }

  // AudioCategory CRUD methods
  void _createAudioCategory() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AudioCategoryForm(
            onSave: (newAudioCategory) async {
              try {
                final result = await _audioCategoryUsecase.createAudioCategory(
                  newAudioCategory.audioCategoryName,
                );
                Navigator.pop(context, result.isSuccess);
              } catch (_) {
                Navigator.pop(context, false);
              } finally {
                _fetchCategories();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Audio Category created successfully');
    } else {
      Notify.showFlushbar('Fail to create Audio Category', isError: true);
    }
  }

  void _updateAudioCategory(AudioCategory category) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AudioCategoryForm(
            audioCategory: category,
            onSave: (updated) async {
              try {
                final result = await _audioCategoryUsecase.updateAudioCategory(
                  updated.audioCategoryId,
                  updated.audioCategoryName,
                );
                Navigator.pop(context, result.isSuccess);
              } catch (_) {
                Navigator.pop(context, false);
              } finally {
                _fetchCategories();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Audio Category updated successfully');
    } else {
      Notify.showFlushbar('Failed to update Audio Category', isError: true);
    }
  }



  void _deleteAudioCategory(AudioCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete "${category.audioCategoryName}"?\n\nThis will also delete all associated subcategories.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF49AA2).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFE37083)),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        audioCategories.removeWhere(
          (c) => c.audioCategoryId == category.audioCategoryId,
        );
        audioSubCategories.removeWhere(
          (s) => s.audioCategoryId == category.audioCategoryId,
        );
      });
    }
  }

  // // SubAudioCategory CRUD methods
  void _createSubAudioCategory() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SubAudioCategoryForm(
            audioCategories: audioCategories,
            onSave: (sub) async {
              try {
                final result = await _audioSubcategoryUsecase.createAudioSubCategory(
                  sub.audioCategoryId,
                  sub.subAudioCategoryName,
                );
                Navigator.pop(context, result.isSuccess);
              } catch (_) {
                Navigator.pop(context, false);
              } finally {
                _fetchSubCategories();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Sub Category created successfully');
    } else {
      Notify.showFlushbar('Failed to create Sub Category', isError: true);
    }
  }

  void _updateSubAudioCategory(SubAudioCategoryModel subCategory) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SubAudioCategoryForm(
            subAudioCategory: subCategory,
            audioCategories: audioCategories,
            onSave: (updated) async {
              try {
                final result = await _audioSubcategoryUsecase.updateAudioSubCategory(
                  updated.subAudioCategoryId,
                  updated.audioCategoryId,
                  updated.subAudioCategoryName,
                );
                Navigator.pop(context, result.isSuccess);
              } catch (_) {
                Navigator.pop(context, false);
              } finally {
                _fetchSubCategories();
              }
            },
          ),
        ),
      ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Sub Category updated successfully');
    } else {
      Notify.showFlushbar('Failed to update Sub Category', isError: true);
    }
  }



  void _deleteSubAudioCategory(SubAudioCategoryModel subCategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete "${subCategory.subAudioCategoryName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF49AA2).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFE37083)),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        audioSubCategories.removeWhere(
          (s) => s.subAudioCategoryId == subCategory.subAudioCategoryId,
        );
      });
    }
  }

  // Search filters
  List<AudioCategory> get filteredCategories {
    if (_categorySearchQuery.isEmpty) return audioCategories;
    return audioCategories
        .where((cat) => _categorySearchFilter(cat, _categorySearchQuery))
        .toList();
  }

  List<SubAudioCategoryModel> get filteredSubCategories {
    if (_subCategorySearchQuery.isEmpty) return audioSubCategories;
    return audioSubCategories
        .where((sub) => _subCategorySearchFilter(sub, _subCategorySearchQuery))
        .toList();
  }

  bool _categorySearchFilter(AudioCategory category, String query) {
    final q = query.toLowerCase();
    return category.audioCategoryName.toLowerCase().contains(q);
  }

  bool _subCategorySearchFilter(
    SubAudioCategoryModel subCategory,
    String query,
  ) {
    final q = query.toLowerCase();
    return subCategory.subAudioCategoryName.toLowerCase().contains(q);
  }

  void _onCategorySearchChanged(String query) {
    setState(() {
      _categorySearchQuery = query;
    });
  }

  void _clearCategorySearch() {
    setState(() {
      _categorySearchQuery = '';
      _categorySearchController.clear();
    });
  }

  void _onSubCategorySearchChanged(String query) {
    setState(() {
      _subCategorySearchQuery = query;
    });
  }

  void _clearSubCategorySearch() {
    setState(() {
      _subCategorySearchQuery = '';
      _subCategorySearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBF9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: const Text(
            'Audio Category Management',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: const Color(0xFF89B7C2),
            labelColor: const Color(0xFF2C3E50),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.category), text: 'Categories'),
              Tab(
                icon: Icon(Icons.subdirectory_arrow_right),
                text: 'Subcategories',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Categories Tab
            _buildCategoryTab(),

            // Subcategories Tab
            _buildSubCategoryTab(),
          ],
        ),
      ),
    );
  }

  // These should be separate Widget-returning methods or widgets:
  Widget _buildCategoryTab() {
    return Column(
      children: [
        _buildStatsBox(
          '${filteredCategories.length}',
          'Total Categories',
          Icons.category,
        ),
        _buildSearchBar(
          controller: _categorySearchController,
          onChanged: _onCategorySearchChanged,
          query: _categorySearchQuery,
          onClear: _clearCategorySearch,
          hintText: 'Search categories by name...',
        ),
        _buildCreateButton('Add Category', _createAudioCategory),
        _buildCategoryList(),
      ],
    );
  }

  Widget _buildSubCategoryTab() {
    return Column(
      children: [
        _buildStatsBox(
          '${filteredSubCategories.length}',
          'Total Subcategories',
          Icons.subdirectory_arrow_right,
        ),
        _buildSearchBar(
          controller: _subCategorySearchController,
          onChanged: _onSubCategorySearchChanged,
          query: _subCategorySearchQuery,
          onClear: _clearSubCategorySearch,
          hintText: 'Search subcategories by name...',
        ),
        _buildCreateButton('Add Subcategory', _createSubAudioCategory),
        _buildSubCategoryList(),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Expanded(
      child:
          isLoadCategory
              ? const Center(child: CircularProgressIndicator())
              : isCategoryListError
              ? _buildRetryBox('Failed to load categories.', _fetchCategories)
              : filteredCategories.isEmpty
              ? _buildEmptyBox(
                _categorySearchQuery,
                emptyMessage: 'No categories yet',
                searchMessage: 'No categories found',
                hintMessage: 'Add your first category to get started',
                searchHint: 'Try adjusting your search terms',
              )
              : ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AudioCategoryListItem(
                      audioCategory: category,
                      onEdit: () => _updateAudioCategory(category),
                      onDelete:
                          () => _deleteAudioCategory(
                            category,
                          ), // Uncomment if needed
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildSubCategoryList() {
    return Expanded(
      child:
          isLoadSubCategory
              ? const Center(child: CircularProgressIndicator())
              : isSubCategoryListError
              ? _buildRetryBox(
                'Failed to load subcategories.',
                _fetchSubCategories,
              )
              : filteredSubCategories.isEmpty
              ? _buildEmptyBox(
                _subCategorySearchQuery,
                emptyMessage: 'No subcategories yet',
                searchMessage: 'No subcategories found',
                hintMessage: 'Add your first subcategory to get started',
                searchHint: 'Try adjusting your search terms',
              )
              : ListView.builder(
                itemCount: filteredSubCategories.length,
                itemBuilder: (context, index) {
                  final sub = filteredSubCategories[index];

                  // Find the parent category for display
                  final category = audioCategories.firstWhere(
                    (cat) => cat.audioCategoryId == sub.audioCategoryId,
                    orElse:
                        () => AudioCategory(
                          audioCategoryId: '',
                          audioCategoryName: 'Unknown',
                          // subAudioCategories: [],
                        ),
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SubAudioCategoryListItem(
                      subAudioCategory: SubAudioCategoryModel(
                        subAudioCategoryId: sub.subAudioCategoryId,
                        subAudioCategoryName: sub.subAudioCategoryName,
                        audioCategoryId: sub.audioCategoryId,
                        audioCategoryName: category.audioCategoryName,
                      ),
                      onEdit: () => _updateSubAudioCategory(sub),
                      onDelete: () => _deleteSubAudioCategory(sub),
                      searchQuery: _subCategorySearchQuery,
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildStatsBox(String count, String label, IconData icon) {
    return Container(
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
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
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
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String query,
    required VoidCallback onClear,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon:
              query.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                    onPressed: onClear,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryBox(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(
    String query, {
    required String emptyMessage,
    required String searchMessage,
    required String hintMessage,
    required String searchHint,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.folder_open : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? emptyMessage : searchMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty ? hintMessage : searchHint,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AudioCategoryListItem extends StatelessWidget {
  final AudioCategory audioCategory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String searchQuery;

  const AudioCategoryListItem({
    super.key,
    required this.audioCategory,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
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
    final colorIndex = audioCategory.audioCategoryName.length % 5;
    final List<List<Color>> colors = [
      [Color(0xFFE37083), Color(0xFFF49AA2)],
      [Color(0xFFFFB876), Color(0xFFFFCB7C)],
      [Color(0xFFA8BF8A), Color(0xFF89B7C2)],
      [Color(0xFF89B7C2), Color(0xFFE37083)],
      [Color(0xFFF49AA2), Color(0xFFA8BF8A)],
    ];

    final gradient = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.1),
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
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.category, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildHighlightedText(
              audioCategory.audioCategoryName,
              searchQuery,
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
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF89B7C2),
                    size: 20,
                  ),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
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
              //     onPressed: onDelete,
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

class AudioCategoryForm extends StatefulWidget {
  final AudioCategory? audioCategory;
  final Future<void> Function(AudioCategory newCategory) onSave;

  const AudioCategoryForm({
    super.key,
    this.audioCategory,
    required this.onSave,
  });

  @override
  State<AudioCategoryForm> createState() => _AudioCategoryFormState();
}

class _AudioCategoryFormState extends State<AudioCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.audioCategory?.audioCategoryName ?? '',
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final newCategory = AudioCategory(
      audioCategoryId: widget.audioCategory?.audioCategoryId ?? '',
      audioCategoryName: _nameController.text.trim(),
      // subAudioCategories: [],
    );
    try {
      await widget.onSave(newCategory);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
            children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF89B7C2), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.audioCategory == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 24),
            _buildFormField(
              label: 'Category Name',
              controller: _nameController,
              hint: 'Enter category name',
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFBDC3C7)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB876),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.audioCategory == null ? 'Save' : 'Update', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}


// SubAudioCategory List Item Widget
class SubAudioCategoryListItem extends StatelessWidget {
  final SubAudioCategoryModel subAudioCategory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String searchQuery;

  const SubAudioCategoryListItem({
    super.key,
    required this.subAudioCategory,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
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
    final List<Color> gradient = [Color(0xFFFFB876), Color(0xFFFFCB7C)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.1),
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
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  subAudioCategory.subAudioCategoryName,
                  searchQuery,
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${subAudioCategory.audioCategoryName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                Text(
                  'ID: ${subAudioCategory.subAudioCategoryId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBDC3C7),
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
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF89B7C2),
                    size: 20,
                  ),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Container(
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFE37083).withOpacity(0.15),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.delete_outline,
              //       color: Color(0xFFE37083),
              //       size: 20,
              //     ),
              //     onPressed: onDelete,
              //     constraints: const BoxConstraints(
              //       minWidth: 36,
              //       minHeight: 36,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

// SubAudioCategory Form Widget
class SubAudioCategoryForm extends StatefulWidget {
  final SubAudioCategoryModel? subAudioCategory;
  final List<AudioCategory> audioCategories;
  final Future<void> Function(SubAudioCategoryModel) onSave;

  const SubAudioCategoryForm({
    super.key,
    this.subAudioCategory,
    required this.audioCategories,
    required this.onSave,
  });

  @override
  State<SubAudioCategoryForm> createState() => _SubAudioCategoryFormState();
}

class _SubAudioCategoryFormState extends State<SubAudioCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subCategoryNameController;
  String? _selectedAudioCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final sub = widget.subAudioCategory;
    _subCategoryNameController = TextEditingController(
      text: sub?.subAudioCategoryName ?? '',
    );
    _selectedAudioCategoryId = sub?.audioCategoryId ??
        (widget.audioCategories.isNotEmpty ? widget.audioCategories.first.audioCategoryId : null);
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategory = widget.audioCategories.firstWhere(
          (c) => c.audioCategoryId == _selectedAudioCategoryId,
    );

    final sub = SubAudioCategoryModel(
      subAudioCategoryId: widget.subAudioCategory?.subAudioCategoryId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      subAudioCategoryName: _subCategoryNameController.text.trim(),
      audioCategoryId: selectedCategory.audioCategoryId,
      audioCategoryName: selectedCategory.audioCategoryName,
    );

    setState(() => _isLoading = true);
    try {
      await widget.onSave(sub);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subAudioCategory == null ? 'Add Sub Category' : 'Edit Sub Category',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 24),

              // Sub Category Name
              _buildFormField(
                label: 'Sub Category Name',
                field: TextFormField(
                  controller: _subCategoryNameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Enter sub category name',
                    prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF89B7C2), width: 2)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter a sub category name';
                    if (value.trim().length < 2) return 'Must be at least 2 characters';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Parent Category Dropdown
              _buildFormField(
                label: 'Parent Category',
                field: DropdownButtonFormField<String>(
                  value: _selectedAudioCategoryId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF89B7C2), width: 2)),
                  ),
                  items: widget.audioCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.audioCategoryId,
                      child: Text(cat.audioCategoryName, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _selectedAudioCategoryId = value),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please select a parent category' : null,
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CircularProgressIndicator()),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFBDC3C7)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.subAudioCategory == null ? 'Create' : 'Update', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: SingleChildScrollView(
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Text(
  //               widget.subAudioCategory == null ? 'Add Sub Category' : 'Edit Sub Category',
  //               style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Sub Category Name
  //             TextFormField(
  //               controller: _subCategoryNameController,
  //               enabled: !_isLoading,
  //               decoration: const InputDecoration(
  //                 labelText: 'Sub Category Name',
  //                 prefixIcon: Icon(Icons.subdirectory_arrow_right),
  //                 border: OutlineInputBorder(),
  //               ),
  //               validator: (value) {
  //                 if (value == null || value.trim().isEmpty) return 'Please enter a sub category name';
  //                 if (value.trim().length < 2) return 'Must be at least 2 characters';
  //                 return null;
  //               },
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Parent Category Dropdown
  //             DropdownButtonFormField<String>(
  //               value: _selectedAudioCategoryId,
  //               isExpanded: true,
  //               decoration: const InputDecoration(
  //                 labelText: 'Parent Category',
  //                 prefixIcon: Icon(Icons.category),
  //                 border: OutlineInputBorder(),
  //               ),
  //               items: widget.audioCategories.map((cat) {
  //                 return DropdownMenuItem(
  //                   value: cat.audioCategoryId,
  //                   child: Text(cat.audioCategoryName, overflow: TextOverflow.ellipsis),
  //                 );
  //               }).toList(),
  //               onChanged: _isLoading
  //                   ? null
  //                   : (value) => setState(() => _selectedAudioCategoryId = value),
  //               validator: (value) =>
  //               (value == null || value.isEmpty) ? 'Please select a parent category' : null,
  //             ),
  //             const SizedBox(height: 16),
  //
  //             if (_isLoading)
  //               const Padding(
  //                 padding: EdgeInsets.only(bottom: 20),
  //                 child: Center(child: CircularProgressIndicator()),
  //               ),
  //
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: _isLoading ? null : _saveForm,
  //                   child: Text(widget.subAudioCategory == null ? 'Create' : 'Update'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFormField({
    required String label,
    required Widget field,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
            children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  void dispose() {
    _subCategoryNameController.dispose();
    super.dispose();
  }
}
