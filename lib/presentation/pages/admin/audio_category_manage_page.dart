import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/presentation/widgets/reusable_crud_base_page/entity_list_screen.dart';

class AudioCategoryManagePage extends ConsumerStatefulWidget {
  const AudioCategoryManagePage({super.key});

  @override
  ConsumerState<AudioCategoryManagePage> createState() => _AudioCategoryManagePageState();
}

class _AudioCategoryManagePageState extends ConsumerState<AudioCategoryManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - replace with actual data from your API
  List<AudioCategory> audioCategories = [
    AudioCategory(
      audioCategoryId: '1',
      audioCategoryName: 'Meditation & Mindfulness',
      subAudioCategories: [],
    ),
    AudioCategory(
      audioCategoryId: '2',
      audioCategoryName: 'Sleep Stories',
      subAudioCategories: [],
    ),
    AudioCategory(
      audioCategoryId: '3',
      audioCategoryName: 'Anxiety Relief',
      subAudioCategories: [],
    ),
    AudioCategory(
      audioCategoryId: '4',
      audioCategoryName: 'Focus & Concentration',
      subAudioCategories: [],
    ),
    AudioCategory(
      audioCategoryId: '5',
      audioCategoryName: 'Emotional Healing',
      subAudioCategories: [],
    ),
  ];

  List<SubAudioCategoryModel> subAudioCategories = [
    SubAudioCategoryModel(
      subAudioCategoryId: '1',
      subAudioCategoryName: 'Guided Meditation',
      audioCategoryId: '1',
      audioCategoryName: 'Meditation & Mindfulness',
    ),
    SubAudioCategoryModel(
      subAudioCategoryId: '2',
      subAudioCategoryName: 'Breathing Exercises',
      audioCategoryId: '1',
      audioCategoryName: 'Meditation & Mindfulness',
    ),
    SubAudioCategoryModel(
      subAudioCategoryId: '3',
      subAudioCategoryName: 'Bedtime Stories',
      audioCategoryId: '2',
      audioCategoryName: 'Sleep Stories',
    ),
    SubAudioCategoryModel(
      subAudioCategoryId: '4',
      subAudioCategoryName: 'Nature Sounds',
      audioCategoryId: '2',
      audioCategoryName: 'Sleep Stories',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // AudioCategory CRUD methods
  void _createAudioCategory() async {
    final newAudioCategory = await showDialog<AudioCategory>(
      context: context,
      builder: (context) => Dialog(
        child: AudioCategoryForm(
          onSave: (newAudioCategory) => Navigator.pop(context, newAudioCategory),
        ),
      ),
    );

    if (newAudioCategory != null) {
      setState(() => audioCategories.add(newAudioCategory));
    }
  }

  void _updateAudioCategory(AudioCategory audioCategory) async {
    final updatedAudioCategory = await showDialog<AudioCategory>(
      context: context,
      builder: (context) => Dialog(
        child: AudioCategoryForm(
          audioCategory: audioCategory,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );

    if (updatedAudioCategory != null) {
      setState(() {
        final index = audioCategories.indexWhere((c) => c.audioCategoryId == audioCategory.audioCategoryId);
        if (index != -1) {
          audioCategories[index] = updatedAudioCategory;
        }
      });
    }
  }

  void _deleteAudioCategory(AudioCategory audioCategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${audioCategory.audioCategoryName}"?\n\nThis will also delete all associated subcategories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        // Remove the category
        audioCategories.removeWhere((c) => c.audioCategoryId == audioCategory.audioCategoryId);
        // Remove all subcategories belonging to this category
        subAudioCategories.removeWhere((sub) => sub.audioCategoryId == audioCategory.audioCategoryId);
      });
    }
  }

  // SubAudioCategory CRUD methods
  void _createSubAudioCategory() async {
    final newSubAudioCategory = await showDialog<SubAudioCategoryModel>(
      context: context,
      builder: (context) => Dialog(
        child: SubAudioCategoryForm(
          audioCategories: audioCategories,
          onSave: (newSubAudioCategory) => Navigator.pop(context, newSubAudioCategory),
        ),
      ),
    );

    if (newSubAudioCategory != null) {
      setState(() => subAudioCategories.add(newSubAudioCategory));
    }
  }

  void _updateSubAudioCategory(SubAudioCategoryModel subAudioCategory) async {
    final updatedSubAudioCategory = await showDialog<SubAudioCategoryModel>(
      context: context,
      builder: (context) => Dialog(
        child: SubAudioCategoryForm(
          subAudioCategory: subAudioCategory,
          audioCategories: audioCategories,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );

    if (updatedSubAudioCategory != null) {
      setState(() {
        final index = subAudioCategories.indexWhere((c) => c.subAudioCategoryId == subAudioCategory.subAudioCategoryId);
        if (index != -1) {
          subAudioCategories[index] = updatedSubAudioCategory;
        }
      });
    }
  }

  void _deleteSubAudioCategory(SubAudioCategoryModel subAudioCategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${subAudioCategory.subAudioCategoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        subAudioCategories.removeWhere((c) => c.subAudioCategoryId == subAudioCategory.subAudioCategoryId);
      });
    }
  }

  // Search filters
  bool _audioCategorySearchFilter(AudioCategory audioCategory, String query) {
    return audioCategory.audioCategoryName.toLowerCase().contains(query.toLowerCase()) ||
        audioCategory.audioCategoryId.toLowerCase().contains(query.toLowerCase());
  }

  bool _subAudioCategorySearchFilter(SubAudioCategoryModel subAudioCategory, String query) {
    return subAudioCategory.subAudioCategoryName.toLowerCase().contains(query.toLowerCase()) ||
        subAudioCategory.audioCategoryName.toLowerCase().contains(query.toLowerCase()) ||
        subAudioCategory.subAudioCategoryId.toLowerCase().contains(query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Category Management'),
        // backgroundColor: Colors.teal[700],
        // foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          // indicatorColor: Colors.white,
          // labelColor: Colors.white,
          // unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.category),
              text: 'Categories',
            ),
            Tab(
              icon: Icon(Icons.subdirectory_arrow_right),
              text: 'Subcategories',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Audio Categories Tab
          EntityListScreen<AudioCategory>(
            title: 'Audio Categories',
            entities: audioCategories,
            onCreateEntity: (audioCategory) => _createAudioCategory(),
            onUpdateEntity: (audioCategory) => _updateAudioCategory(audioCategory),
            onDeleteEntity: (audioCategory) => _deleteAudioCategory(audioCategory),
            searchFilter: _audioCategorySearchFilter,
            itemBuilder: (context, audioCategory, onEdit, onDelete) {
              return AudioCategoryListItem(
                audioCategory: audioCategory,
                subCategoriesCount: subAudioCategories.where((sub) => sub.audioCategoryId == audioCategory.audioCategoryId).length,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
            formBuilder: (context, audioCategory, onSave) {
              return AudioCategoryForm(
                audioCategory: audioCategory,
                onSave: onSave,
              );
            },
          ),
          // Sub Audio Categories Tab
          EntityListScreen<SubAudioCategoryModel>(
            title: 'Sub Audio Categories',
            entities: subAudioCategories,
            onCreateEntity: (subAudioCategory) => _createSubAudioCategory(),
            onUpdateEntity: (subAudioCategory) => _updateSubAudioCategory(subAudioCategory),
            onDeleteEntity: (subAudioCategory) => _deleteSubAudioCategory(subAudioCategory),
            searchFilter: _subAudioCategorySearchFilter,
            itemBuilder: (context, subAudioCategory, onEdit, onDelete) {
              return SubAudioCategoryListItem(
                subAudioCategory: subAudioCategory,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
            formBuilder: (context, subAudioCategory, onSave) {
              return SubAudioCategoryForm(
                subAudioCategory: subAudioCategory,
                audioCategories: audioCategories,
                onSave: onSave,
              );
            },
          ),
        ],
      ),
    );
  }
}

// AudioCategory List Item Widget
class AudioCategoryListItem extends StatelessWidget {
  final AudioCategory audioCategory;
  final int subCategoriesCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AudioCategoryListItem({
    super.key,
    required this.audioCategory,
    required this.subCategoriesCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.teal[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.audiotrack,
              color: Colors.teal[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audioCategory.audioCategoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${audioCategory.audioCategoryId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$subCategoriesCount subcategories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[600]),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// SubAudioCategory List Item Widget
class SubAudioCategoryListItem extends StatelessWidget {
  final SubAudioCategoryModel subAudioCategory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubAudioCategoryListItem({
    super.key,
    required this.subAudioCategory,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.orange[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subAudioCategory.subAudioCategoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${subAudioCategory.audioCategoryName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'ID: ${subAudioCategory.subAudioCategoryId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[600]),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// AudioCategory Form Widget
class AudioCategoryForm extends StatefulWidget {
  final AudioCategory? audioCategory;
  final Function(AudioCategory) onSave;

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
  late final TextEditingController _categoryNameController;

  @override
  void initState() {
    super.initState();

    final audioCategory = widget.audioCategory;

    if (audioCategory != null) {
      _categoryNameController = TextEditingController(text: audioCategory.audioCategoryName);
    } else {
      _categoryNameController = TextEditingController();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final audioCategory = AudioCategory(
        audioCategoryId: widget.audioCategory?.audioCategoryId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        audioCategoryName: _categoryNameController.text.trim(),
        subAudioCategories: widget.audioCategory?.subAudioCategories ?? [],
      );

      widget.onSave(audioCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.audioCategory == null ? 'Create Audio Category' : 'Update Audio Category',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Category Name*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.audiotrack),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                if (value.trim().length < 2) {
                  return 'Category name must be at least 2 characters';
                }
                return null;
              },
            ),

            if (widget.audioCategory != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Category ID',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.audioCategory!.audioCategoryId,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(widget.audioCategory == null ? 'Create' : 'Update'),
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
    _categoryNameController.dispose();
    super.dispose();
  }
}

// SubAudioCategory Form Widget
class SubAudioCategoryForm extends StatefulWidget {
  final SubAudioCategoryModel? subAudioCategory;
  final List<AudioCategory> audioCategories;
  final Function(SubAudioCategoryModel) onSave;

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

  @override
  void initState() {
    super.initState();

    final subAudioCategory = widget.subAudioCategory;

    if (subAudioCategory != null) {
      _subCategoryNameController = TextEditingController(text: subAudioCategory.subAudioCategoryName);
      _selectedAudioCategoryId = subAudioCategory.audioCategoryId;
    } else {
      _subCategoryNameController = TextEditingController();
      _selectedAudioCategoryId = widget.audioCategories.isNotEmpty ? widget.audioCategories.first.audioCategoryId : null;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final selectedCategory = widget.audioCategories.firstWhere(
            (category) => category.audioCategoryId == _selectedAudioCategoryId,
      );

      final subAudioCategory = SubAudioCategoryModel(
        subAudioCategoryId: widget.subAudioCategory?.subAudioCategoryId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        subAudioCategoryName: _subCategoryNameController.text.trim(),
        audioCategoryId: _selectedAudioCategoryId!,
        audioCategoryName: selectedCategory.audioCategoryName,
      );

      widget.onSave(subAudioCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.subAudioCategory == null ? 'Create Sub Category' : 'Update Sub Category',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Sub Category Name*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subCategoryNameController,
              decoration: InputDecoration(
                hintText: 'Enter sub category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.subdirectory_arrow_right),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a sub category name';
                }
                if (value.trim().length < 2) {
                  return 'Sub category name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Parent Category*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAudioCategoryId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.category),
              ),
              items: widget.audioCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.audioCategoryId,
                  child: Text(category.audioCategoryName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAudioCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a parent category';
                }
                return null;
              },
            ),

            if (widget.subAudioCategory != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Sub Category ID',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.subAudioCategory!.subAudioCategoryId,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(widget.subAudioCategory == null ? 'Create' : 'Update'),
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
    _subCategoryNameController.dispose();
    super.dispose();
  }
}

// AudioCategory and SubAudioCategory models
class AudioCategory {
  final String audioCategoryId;
  final String audioCategoryName;
  final List<SubAudioCategoryModel> subAudioCategories;

  AudioCategory({
    required this.audioCategoryId,
    required this.audioCategoryName,
    required this.subAudioCategories,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      audioCategoryId: json['audioCategoryId'] as String,
      audioCategoryName: json['audioCategoryName'] as String,
      subAudioCategories: (json['subAudioCategories'] as List)
          .map((e) => SubAudioCategoryModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioCategoryId': audioCategoryId,
      'audioCategoryName': audioCategoryName,
      'subAudioCategories': subAudioCategories.map((e) => e.toJson()).toList(),
    };
  }
}

class SubAudioCategoryModel {
  final String subAudioCategoryId;
  final String subAudioCategoryName;
  final String audioCategoryId;
  final String audioCategoryName;

  SubAudioCategoryModel({
    required this.subAudioCategoryId,
    required this.subAudioCategoryName,
    required this.audioCategoryId,
    required this.audioCategoryName,
  });

  factory SubAudioCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubAudioCategoryModel(
      subAudioCategoryId: json['subAudioCategoryId'] as String,
      subAudioCategoryName: json['subAudioCategoryName'] as String,
      audioCategoryId: json['audioCategoryId'] as String,
      audioCategoryName: json['audioCategoryName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subAudioCategoryId': subAudioCategoryId,
      'subAudioCategoryName': subAudioCategoryName,
      'audioCategoryId': audioCategoryId,
      'audioCategoryName': audioCategoryName,
    };
  }
}