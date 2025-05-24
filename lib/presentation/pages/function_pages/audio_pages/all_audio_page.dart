import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';
import 'package:inner_child_app/domain/usecases/audio_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_subcategory_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/audio_playing_page.dart';

class AllAudioPage extends ConsumerStatefulWidget {
  const AllAudioPage({super.key});

  @override
  ConsumerState<AllAudioPage> createState() => _AllAudioPageState();
}

class _AllAudioPageState extends ConsumerState<AllAudioPage> {
  late final AudioCategoryUsecase _audioCategoryUsecase;
  late final AudioSubcategoryUsecase _audioSubcategoryUsecase;
  late final AudioUseCase _audioUseCase;

  List<AudioModel> allAudioList = [];
  List<AudioModel> filteredAudioList = [];
  List<AudioCategory> categories = [];
  List<SubAudioCategoryModel> allSubCategories = [];

  bool isLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize use cases
    _audioCategoryUsecase = ref.read(audioCategoryUseCaseProvider);
    _audioSubcategoryUsecase = ref.read(audioSubcategoryUseCaseProvider);
    _audioUseCase = ref.read(audioUseCaseProvider);

    // Load data after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final audioResult = await _audioUseCase.getAllAudios();
      final loadedCategories = await _loadCategories();
      final loadedSubCategories = await _loadSubCategories();

      setState(() {
        allAudioList = audioResult.data!;
        filteredAudioList = List.from(allAudioList);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<AudioCategory>> _loadCategories() async {
    try {
      final result = await _audioCategoryUsecase.getAllAudioCategories();
      final loadedCategories = result.data!;

      setState(() {
        categories = loadedCategories;
      });

      return loadedCategories;
    } catch (e) {
      debugPrint('Error loading categories: $e');

      final mockCategories = [
        AudioCategory(
          audioCategoryId: '1',
          audioCategoryName: 'Meditation',
          subAudioCategories: [],
        ),
        AudioCategory(
          audioCategoryId: '2',
          audioCategoryName: 'Sleep',
          subAudioCategories: [],
        ),
        AudioCategory(
          audioCategoryId: '3',
          audioCategoryName: 'Mindfulness',
          subAudioCategories: [],
        ),
        AudioCategory(
          audioCategoryId: '4',
          audioCategoryName: 'Relaxation',
          subAudioCategories: [],
        ),
      ];

      setState(() {
        categories = mockCategories;
      });

      return mockCategories;
    }
  }

  Future<List<SubAudioCategoryModel>> _loadSubCategories() async {
    try {
      final result = await _audioSubcategoryUsecase.getAllSubAudioCategories();
      final loadedSubCategories = result.data!;

      setState(() {
        allSubCategories = loadedSubCategories;
      });

      return loadedSubCategories;
    } catch (e) {
      debugPrint('Error loading subcategories: $e');

      final mockSubCategories = [
        SubAudioCategoryModel(
          subAudioCategoryId: '1',
          subAudioCategoryName: 'Guided Meditation',
          audioCategoryId: '1',
          audioCategoryName: 'Meditation',
        ),
        SubAudioCategoryModel(
          subAudioCategoryId: '2',
          subAudioCategoryName: 'Breathing Exercises',
          audioCategoryId: '1',
          audioCategoryName: 'Meditation',
        ),
        SubAudioCategoryModel(
          subAudioCategoryId: '3',
          subAudioCategoryName: 'Sleep Stories',
          audioCategoryId: '2',
          audioCategoryName: 'Sleep',
        ),
        SubAudioCategoryModel(
          subAudioCategoryId: '4',
          subAudioCategoryName: 'White Noise',
          audioCategoryId: '2',
          audioCategoryName: 'Sleep',
        ),
        SubAudioCategoryModel(
          subAudioCategoryId: '5',
          subAudioCategoryName: 'Body Scan',
          audioCategoryId: '3',
          audioCategoryName: 'Mindfulness',
        ),
        SubAudioCategoryModel(
          subAudioCategoryId: '6',
          subAudioCategoryName: 'Nature Sounds',
          audioCategoryId: '4',
          audioCategoryName: 'Relaxation',
        ),
      ];

      setState(() {
        allSubCategories = mockSubCategories;
      });

      return mockSubCategories;
    }
  }

  void _filterAudiosBySubCategory() {
    setState(() {
      if (selectedSubCategoryId == null) {
        filteredAudioList = allAudioList.where((audio) {
          return searchQuery.isEmpty ||
              (audio.audioTitle?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false);
        }).toList();
      } else {
        filteredAudioList = allAudioList.where((audio) {
          bool matchesSearch = searchQuery.isEmpty ||
              (audio.audioTitle?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
                  false);

          bool matchesSubCategory =
              audio.subAudioCategoryId == selectedSubCategoryId;

          return matchesSearch && matchesSubCategory;
        }).toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterAudiosBySubCategory();
  }

  void _clearFilters() {
    setState(() {
      selectedCategoryId = null;
      selectedSubCategoryId = null;
      searchQuery = '';
      _searchController.clear();
      filteredAudioList = List.from(allAudioList);
    });
  }

  List<SubAudioCategoryModel> _getSubCategoriesForCategory(String categoryId) {
    return allSubCategories
        .where((sub) => sub.audioCategoryId == categoryId)
        .toList();
  }

  String _formatDuration(String? url) {
    return '10 min';
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                color: const Color(0xFF4B3621),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: (screenHeight * 1 / 2) * 0.6,
                      child: Image.asset(
                        'assets/images/daily_mindfulness_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header Section
                          _buildHeader(),

                          const SizedBox(height: 20),

                          // Search and Filter Row
                          _buildSearchAndFilterRow(),

                          const SizedBox(height: 16),

                          // Active Filters Display
                          if (selectedSubCategoryId != null || searchQuery.isNotEmpty)
                            _buildActiveFilters(),

                          const SizedBox(height: 16),

                          // Audio List
                          Expanded(
                            child: isLoading ? _buildLoadingState() : _buildAudioList(),
                          ),
                        ],
                      ),
                    ),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Audio Library',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (selectedSubCategoryId != null || searchQuery.isNotEmpty)
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child:
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  size: 20,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child:
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search audio...',
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha((0.7 * 255).round()),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Button
        GestureDetector(
          onTap: _showFilterModal,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 20,
                ),
                if (selectedSubCategoryId != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (selectedSubCategoryId != null) ...[
            _buildFilterChip(
              _getSubCategoryName(selectedSubCategoryId!),
                  () {
                setState(() {
                  selectedSubCategoryId = null;
                  selectedCategoryId = null;
                });
                _filterAudiosBySubCategory();
              },
            ),
            const SizedBox(width: 8),
          ],
          if (searchQuery.isNotEmpty) ...[
            _buildFilterChip(
              'Search: "$searchQuery"',
                  () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Filter Audio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Dropdown
                      _buildCategoryDropdown(setModalState),

                      const SizedBox(height: 24),

                      // Subcategory Section
                      if (selectedCategoryId != null) ...[
                        const Text(
                          'Subcategory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSubcategoryList(setModalState),
                      ],
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _filterAudiosBySubCategory();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          hint: const Text('Select Category'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.audioCategoryId,
                child: Text(category.audioCategoryName),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setModalState(() {
              selectedCategoryId = value;
              selectedSubCategoryId = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(StateSetter setModalState) {
    final subCategories = _getSubCategoriesForCategory(selectedCategoryId!);

    if (subCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No subcategories available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: subCategories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          final isSelected = selectedSubCategoryId == subCategory.subAudioCategoryId;

          return GestureDetector(
            onTap: () {
              setModalState(() {
                if (selectedSubCategoryId == subCategory.subAudioCategoryId) {
                  selectedSubCategoryId = null;
                } else {
                  selectedSubCategoryId = subCategory.subAudioCategoryId;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subCategory.subAudioCategoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.orange.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSubCategoryName(String subCategoryId) {
    try {
      final subCategory = allSubCategories.firstWhere(
            (sub) => sub.subAudioCategoryId == subCategoryId,
      );
      return subCategory.subAudioCategoryName;
    } catch (e) {
      return 'Selected Subcategory';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildAudioList() {
    if (filteredAudioList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 64, color: Colors.white.withAlpha((0.6 * 255).round())),
            const SizedBox(height: 16),
            Text(
              'No audio found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha((0.8 * 255).round()),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha((0.6 * 255).round()),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredAudioList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final audio = filteredAudioList[index];
        return _buildSessionCard(audio: audio);
      },
    );
  }

  Widget _buildSessionCard({required AudioModel audio}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  audio.audioTitle ?? 'Untitled Audio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(audio.audioUrl),
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (audio.audioIsPremium == true) _buildTag('Premium'),
                    if (audio.audioStatus != null) _buildTag(audio.audioStatus!),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioPlayingPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xFF4B3621),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}