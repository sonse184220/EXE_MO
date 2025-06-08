import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/presentation/widgets/reusable_crud_base_page/entity_list_screen.dart';

class AudioManagePage extends ConsumerStatefulWidget {
  const AudioManagePage({super.key});

  @override
  ConsumerState<AudioManagePage> createState() => _AudioManagePageState();
}

class _AudioManagePageState extends ConsumerState<AudioManagePage> {
  List<AudioModel> audios = [
    AudioModel(
      audioId: '1',
      audioTitle: 'Relaxation Music',
      audioUrl: 'https://example.com/audio1.mp3',
      audioThumbnail: 'https://example.com/thumb1.jpg',
      audioCreatedAt: DateTime(2023, 1, 15),
      audioIsPremium: false,
      audioStatus: 'active',
      subAudioCategoryId: '1',
      subAudioCategoryName: 'Meditation',
    ),
    AudioModel(
      audioId: '2',
      audioTitle: 'Sleep Sounds',
      audioUrl: 'https://example.com/audio2.mp3',
      audioThumbnail: 'https://example.com/thumb2.jpg',
      audioCreatedAt: DateTime(2023, 2, 10),
      audioIsPremium: true,
      audioStatus: 'active',
      subAudioCategoryId: '2',
      subAudioCategoryName: 'Sleep',
    ),
  ];

  // Mock subcategories - replace with actual API call
  List<SubAudioCategory> subCategories = [
    SubAudioCategory(id: '1', name: 'Meditation'),
    SubAudioCategory(id: '2', name: 'Sleep'),
    SubAudioCategory(id: '3', name: 'Focus'),
    SubAudioCategory(id: '4', name: 'Relaxation'),
  ];

  void _createAudio() async {
    final newAudio = await showDialog<AudioModel>(
      context: context,
      builder: (context) => Dialog(
        child: AudioForm(
          subCategories: subCategories,
          onSave: (newAudio) => Navigator.pop(context, newAudio),
        ),
      ),
    );

    if (newAudio != null) {
      // Replace with real API call
      setState(() => audios.add(newAudio));
    }
  }

  void _updateAudio(AudioModel audio) async {
    final updatedAudio = await showDialog<AudioModel>(
      context: context,
      builder: (context) => Dialog(
        child: AudioForm(
          audio: audio,
          subCategories: subCategories,
          onSave: (updated) => Navigator.of(context).pop(updated),
        ),
      ),
    );

    if (updatedAudio != null) {
      // Replace with real API call
      setState(() {
        final index = audios.indexWhere((a) => a.audioId == audio.audioId);
        if (index != -1) {
          audios[index] = updatedAudio;
        }
      });
    }
  }

  void _deleteAudio(AudioModel audio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${audio.audioTitle}"?'),
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
      // Replace with real API call
      setState(() {
        audios.removeWhere((a) => a.audioId == audio.audioId);
      });
    }
  }

  // Custom search function for Audio entity
  bool _audioSearchFilter(AudioModel audio, String query) {
    return audio.audioTitle?.toLowerCase().contains(query) == true ||
        audio.subAudioCategoryName?.toLowerCase().contains(query) == true ||
        audio.audioStatus?.toLowerCase().contains(query) == true;
  }

  @override
  Widget build(BuildContext context) {
    return EntityListScreen<AudioModel>(
      title: 'Audio Management',
      entities: audios,
      onCreateEntity: (audio) => _createAudio(),
      onUpdateEntity: (audio) => _updateAudio(audio),
      onDeleteEntity: (audio) => _deleteAudio(audio),
      searchFilter: _audioSearchFilter,
      itemBuilder: (context, audio, onEdit, onDelete) {
        return AudioListItem(
          audio: audio,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
      formBuilder: (context, audio, onSave) {
        return AudioForm(
          audio: audio,
          subCategories: subCategories,
          onSave: onSave,
        );
      },
    );
  }
}

// Audio List Item Widget
class AudioListItem extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AudioListItem({
    super.key,
    required this.audio,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: audio.audioThumbnail?.isNotEmpty == true
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                audio.audioThumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.music_note, color: Colors.grey),
              ),
            )
                : const Icon(Icons.music_note, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        audio.audioTitle ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (audio.audioIsPremium == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  audio.subAudioCategoryName ?? 'No Category',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: audio.audioStatus == 'active'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        audio.audioStatus?.toUpperCase() ?? 'UNKNOWN',
                        style: TextStyle(
                          fontSize: 10,
                          color: audio.audioStatus == 'active'
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      audio.audioCreatedAt != null
                          ? '${audio.audioCreatedAt!.day}/${audio.audioCreatedAt!.month}/${audio.audioCreatedAt!.year}'
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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

// Audio Form Widget
class AudioForm extends StatefulWidget {
  final AudioModel? audio;
  final List<SubAudioCategory> subCategories;
  final Function(AudioModel) onSave;

  const AudioForm({
    super.key,
    this.audio,
    required this.subCategories,
    required this.onSave,
  });

  @override
  State<AudioForm> createState() => _AudioFormState();
}

class _AudioFormState extends State<AudioForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _thumbnailController;

  String? _selectedSubCategoryId;
  bool _isPremium = false;
  String _status = 'active';

  @override
  void initState() {
    super.initState();

    final audio = widget.audio;

    if (audio != null) {
      _titleController = TextEditingController(text: audio.audioTitle);
      _urlController = TextEditingController(text: audio.audioUrl);
      _thumbnailController = TextEditingController(text: audio.audioThumbnail);
      _selectedSubCategoryId = audio.subAudioCategoryId;
      _isPremium = audio.audioIsPremium ?? false;
      _status = audio.audioStatus ?? 'active';
    } else {
      _titleController = TextEditingController();
      _urlController = TextEditingController();
      _thumbnailController = TextEditingController();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subcategory')),
        );
        return;
      }

      final selectedSubCategory = widget.subCategories
          .firstWhere((cat) => cat.id == _selectedSubCategoryId);

      final audio = AudioModel(
        audioId: widget.audio?.audioId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        audioTitle: _titleController.text.trim(),
        audioUrl: _urlController.text.trim(),
        audioThumbnail: _thumbnailController.text.trim(),
        audioCreatedAt: widget.audio?.audioCreatedAt ?? DateTime.now(),
        audioIsPremium: _isPremium,
        audioStatus: _status,
        subAudioCategoryId: _selectedSubCategoryId,
        subAudioCategoryName: selectedSubCategory.name,
      );

      widget.onSave(audio);
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
          children: [
            Text(
              widget.audio == null ? 'Add New Audio' : 'Edit Audio',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Audio Title
            const Text(
              'Audio Title*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter audio title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an audio title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Audio URL
            const Text(
              'Audio URL*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://example.com/audio.mp3',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an audio URL';
                }
                if (!value.startsWith('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Thumbnail URL
            const Text(
              'Thumbnail URL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _thumbnailController,
              decoration: InputDecoration(
                hintText: 'https://example.com/thumbnail.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Subcategory Dropdown
            const Text(
              'Subcategory*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubCategoryId,
              decoration: InputDecoration(
                hintText: 'Select a subcategory',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: widget.subCategories.map<DropdownMenuItem<String>>((subCategory) {
                return DropdownMenuItem<String>(
                  value: subCategory.id,
                  child: Text(subCategory.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedSubCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a subcategory';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Toggle
            Row(
              children: [
                Checkbox(
                  value: _isPremium,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPremium = value ?? false;
                    });
                  },
                ),
                const Text(
                  'Premium Content',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            const Text(
              'Status*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _status = value ?? 'active';
                });
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
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
                  child: Text(widget.audio == null ? 'Save' : 'Update'),
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
    _titleController.dispose();
    _urlController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }
}

// SubAudioCategory model for dropdown
class SubAudioCategory {
  final String id;
  final String name;

  SubAudioCategory({
    required this.id,
    required this.name,
  });
}

// Your AudioModel class should be included here or imported
class AudioModel {
  final String? audioId;
  final String? audioTitle;
  final String? audioUrl;
  final String? audioThumbnail;
  final DateTime? audioCreatedAt;
  final bool? audioIsPremium;
  final String? audioStatus;
  final String? subAudioCategoryId;
  final String? subAudioCategoryName;

  AudioModel({
    this.audioId,
    this.audioTitle,
    this.audioUrl,
    this.audioThumbnail,
    this.audioCreatedAt,
    this.audioIsPremium,
    this.audioStatus,
    this.subAudioCategoryId,
    this.subAudioCategoryName,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      audioId: json['audioId'] as String?,
      audioTitle: json['audioTitle'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioThumbnail: json['audioThumbnail'] as String?,
      audioCreatedAt: json['audioCreatedAt'] != null
          ? DateTime.tryParse(json['audioCreatedAt'])
          : null,
      audioIsPremium: json['audioIsPremium'] as bool?,
      audioStatus: json['audioStatus'] as String?,
      subAudioCategoryId: json['subAudioCategoryId'] as String?,
      subAudioCategoryName: json['subAudioCategoryName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'audioTitle': audioTitle,
      'audioUrl': audioUrl,
      'audioThumbnail': audioThumbnail,
      'audioCreatedAt': audioCreatedAt?.toIso8601String(),
      'audioIsPremium': audioIsPremium,
      'audioStatus': audioStatus,
      'subAudioCategoryId': subAudioCategoryId,
    };
  }
}