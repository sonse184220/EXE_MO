import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/entities/audio/create_audio_model.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';
import 'package:inner_child_app/domain/usecases/audio_subcategory_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioManagePage extends ConsumerStatefulWidget {
  const AudioManagePage({super.key});

  @override
  ConsumerState<AudioManagePage> createState() => _AudioManagePageState();
}

class _AudioManagePageState extends ConsumerState<AudioManagePage> {
  late final AudioUseCase _audioUsecase;
  late final AudioSubcategoryUsecase _audioSubcategoryUsecase;

  List<AudioModel> audios = [];
  List<SubAudioCategoryModel> subCategories = [];

  bool isLoadAudio = false;
  bool isAudioListError = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _fetchAudios() async {
    setState(() {
      isLoadAudio = true;
      isAudioListError = false;
    });

    try {
      final result = await _audioUsecase.getAllAudios();
      if (result.isSuccess) {
        setState(() {
          audios = result.data!;
          isLoadAudio = false;
        });
      } else {
        throw Exception('Fail to fetch audios');
      }
    } catch (_) {
      setState(() {
        isLoadAudio = false;
        isAudioListError = true;
      });
    }
  }

  Future<void> _fetchSubCategories() async {
    try {
      final result = await _audioSubcategoryUsecase.getAllSubAudioCategories();
      if (result.isSuccess) {
        setState(() {
          subCategories = result.data!;
        });
      }
    } catch (_) {
      // Handle error silently
    }
  }

  void _createAudio() async {
    final success = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AudioForm(
                subCategories: subCategories,
                onSave: (id, createAudioModel) async {
                  try {
                    final result = await _audioUsecase.createAudio(
                      createAudioModel,
                    );
                    return result.isSuccess;
                  } catch (_) {
                    return false;
                  } finally {
                    _fetchAudios();
                  }
                },
              ),
            ),
          ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Audio created successfully');
    } else {
      Notify.showFlushbar('Failed to create Audio', isError: true);
    }
  }

  void _updateAudio(AudioModel audio) async {
    final success = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AudioForm(
                audio: audio,
                subCategories: subCategories,
                onSave: (id, updated) async {
                  try {
                    final result = await _audioUsecase.updateAudio(id, updated);
                    return result.isSuccess;
                  } catch (_) {
                    return false;
                  } finally {
                    _fetchAudios();
                  }
                },
              ),
            ),
          ),
    );

    if (success ?? false) {
      Notify.showFlushbar('Audio updated successfully');
    } else {
      Notify.showFlushbar('Failed to update audio', isError: true);
    }
  }

  List<AudioModel> get filteredAudios {
    if (_searchQuery.isEmpty) return audios;
    return audios
        .where(
          (audio) =>
              audio.audioTitle!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              )
              //     ||
              // audio.subAudioCategoryName!.toLowerCase().contains(
              //   _searchQuery.toLowerCase(),
              // ),
        )
        .toList();
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
    super.initState();
    _audioUsecase = ref.read(audioUseCaseProvider);
    _audioSubcategoryUsecase = ref.read(audioSubcategoryUseCaseProvider);

    _fetchAudios();
    _fetchSubCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedAudios = filteredAudios;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Audio Management',
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
                        '${audios.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Audio Files',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
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
                    Icons.music_note,
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
                hintText: 'Search by audio title or category',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
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
                  borderSide: const BorderSide(
                    color: Color(0xFF89B7C2),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    'Found ${displayedAudios.length} audio${displayedAudios.length == 1 ? '' : 's'}',
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

          // Add Audio Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createAudio,
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
                    'Add New Audio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Audio List
          Expanded(
            child:
                isLoadAudio
                    ? const Center(child: CircularProgressIndicator())
                    : isAudioListError
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load audio files.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchAudios,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          displayedAudios.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _searchQuery.isEmpty
                                          ? Icons.music_note_outlined
                                          : Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'No audio files yet'
                                          : 'No audio files found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'Add your first audio file to get started'
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
                                itemCount: displayedAudios.length,
                                itemBuilder: (context, index) {
                                  final audio = displayedAudios[index];
                                  return AudioListItem(
                                    audio: audio,
                                    onEdit: () => _updateAudio(audio),
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

class AudioListItem extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onEdit;
  final String searchQuery;

  const AudioListItem({
    super.key,
    required this.audio,
    required this.onEdit,
    this.searchQuery = '',
  });

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
    final List<List<Color>> audioColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)],
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)],
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)],
      [const Color(0xFF89B7C2), const Color(0xFFE37083)],
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)],
    ];

    final colorIndex = audio.audioId.hashCode.abs() % audioColors.length;
    final gradientColors = audioColors[colorIndex];

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
              child: Icon(Icons.music_note, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  audio.audioTitle ?? 'Untitled',
                  searchQuery,
                ),
                const SizedBox(height: 4),
                Text(
                  audio.subAudioCategoryName ?? 'No Category',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            audio.audioStatus == 'active'
                                ? const Color(0xFFA8BF8A).withOpacity(0.15)
                                : const Color(0xFFE37083).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        audio.audioStatus?.toUpperCase() ?? 'UNKNOWN',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              audio.audioStatus == 'active'
                                  ? const Color(0xFFA8BF8A)
                                  : const Color(0xFFE37083),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (audio.audioIsPremium == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB876).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFB876),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
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
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioForm extends StatefulWidget {
  final AudioModel? audio;
  final List<SubAudioCategoryModel> subCategories;
  final Future<bool> Function(String id, CreateAudioModel updated) onSave;

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

  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  late final TextEditingController _titleController;

  File? _audioFile;
  File? _thumbnailFile;

  String? _selectedSubCategoryId;
  bool _isPremium = false;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final audio = widget.audio;
    _titleController = TextEditingController(text: audio?.audioTitle ?? '');
    _selectedSubCategoryId = audio?.subAudioCategoryId;
    _isPremium = audio?.audioIsPremium ?? false;
    _status = audio?.audioStatus ?? 'Active';
  }

  Future<bool> _isAndroid11OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  Future<void> _pickFile({required bool isAudio}) async {
    PermissionStatus status;

    // Android 11+ (API 30+)
    if (Platform.isAndroid && (await _isAndroid11OrHigher())) {
      status = await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any
    );

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final fileSize = await pickedFile.length();

      if (fileSize > _maxFileSizeBytes) {
        Notify.showFlushbar('File too large. Max size is 10MB.', isError: true);
        return;
      }

      setState(() {
        if (isAudio) {
          _audioFile = pickedFile;
        } else {
          _thumbnailFile = pickedFile;
        }
      });
    }
  }

  // Future<void> _pickFile({required bool isAudio}) async {
  //   PermissionStatus status;
  //
  //   // Android 11+ (API 30+)
  //   if (Platform.isAndroid && (await _isAndroid11OrHigher())) {
  //     status = await Permission.manageExternalStorage.request();
  //   } else {
  //     status = await Permission.storage.request();
  //   }
  //
  //   if (!status.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Permission denied')),
  //     );
  //     return;
  //   }
  //
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );
  //
  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       if (isAudio) {
  //         _audioFile = File(result.files.single.path!);
  //       } else {
  //         _thumbnailFile = File(result.files.single.path!);
  //       }
  //     });
  //   }
  // }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final createAudio = CreateAudioModel(
        audioTitle: _titleController.text.trim(),
        audioStatus: _status,
        audioIsPremium: _isPremium,
        subAudioCategoryId: _selectedSubCategoryId,
        audioFile: _audioFile,
        audioThumbnailFile: _thumbnailFile,
      );

      try {
        final id = widget.audio?.audioId ?? '';
        final success = await widget.onSave(id, createAudio);
        if (success && mounted) {
          Navigator.pop(context, true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
        Notify.showFlushbar('Save action error. Please try again', isError: true);
      }
    }
  }

  Widget _buildFilePicker({
    required String label,
    required bool isAudio,
    File? file,
    String? url,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Show file name if picked
        // if (file != null)
        //   Text('Selected file: ${file.path.split('/').last}'),
        if (file != null)
          Text(
            'Selected file: ${file.path.split('/').last} '
                '(${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB)',
          ),

        // Show audio player if URL exists
        if (isAudio && url != null && file == null)
          AudioPreviewPlayer(url: url),

        const SizedBox(height: 8),

        ElevatedButton.icon(
          icon: Icon(Icons.upload_file),
          label: Text(file == null ? 'Choose File' : 'Replace File'),
          onPressed: () {
            _pickFile(isAudio: isAudio);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 650),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Audio Title *',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Title required'
                            : null,
              ),
              const SizedBox(height: 16),

              _buildFilePicker(
                label: 'Audio File',
                isAudio: true,
                file: _audioFile,
                url: widget.audio?.audioUrl,
              ),
              const SizedBox(height: 16),

              _buildFilePicker(
                label: 'Thumbnail Image',
                isAudio: false,
                file: _thumbnailFile,
                url: widget.audio?.audioThumbnail,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSubCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Subcategory *',
                  border: OutlineInputBorder(),
                ),
                items:
                    widget.subCategories.map((subCat) {
                      return DropdownMenuItem(
                        value: subCat.subAudioCategoryId,
                        child: Text(subCat.subAudioCategoryName),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() {
                      _selectedSubCategoryId = value;
                    }),
                validator:
                    (value) =>
                        value == null ? 'Please select a subcategory' : null,
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Premium Content'),
                value: _isPremium,
                onChanged:
                    (value) => setState(() => _isPremium = value ?? false),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'Active'),
                validator: (value) => value == null ? 'Please select a status' : null,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(widget.audio == null ? 'Save' : 'Update'),
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
}

class AudioPreviewPlayer extends StatefulWidget {
  final String url;

  const AudioPreviewPlayer({super.key, required this.url});

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  late AudioPlayer _player;
  bool isLoading = false;
  bool isPlaying = false;
  bool isCompleted = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          isCompleted = true;
          position = duration;
        }
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _handlePlayPause() async {
    if (isPlaying) {
      await _player.pause();
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isCompleted) {
        // ⚠ Dispose old player, create new one to avoid replay bugs
        await _player.dispose();

        _player = AudioPlayer();
        _bindListeners(); // Reattach listeners
        setState(() {
          isCompleted = false;
          position = Duration.zero;
        });
      }

      await _player.play(UrlSource(widget.url));
    } catch (e) {
      setState(() => error = 'Playback failed: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _bindListeners() {
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          isCompleted = true;
          position = duration;
        }
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isCompleted = true;
        });
      }
    });
  }

  Future<void> _seekTo(double value) async {
    try {
      final newPos = Duration(seconds: value.toInt());
      await _player.seek(newPos);
      if (isCompleted) {
        setState(() => isCompleted = false);
      }
    } catch (e) {
      if (kDebugMode) print('Seek error: $e');
    }
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.replay : isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: _handlePlayPause,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Audio Preview', style: TextStyle(fontWeight: FontWeight.w500)),
                    if (duration > Duration.zero)
                      Text(
                        '${_format(position)} / ${_format(duration)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                  ],
                ),
              )
            ],
          ),
          if (duration > Duration.zero)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Slider(
                value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                min: 0,
                max: duration.inSeconds.toDouble(),
                onChanged: isLoading ? null : _seekTo,
              ),
            )
        ],
      ),
    );
  }
}