import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_detail_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/subscription_pages/subscription_page.dart';

class CommunityGroupsPage extends ConsumerStatefulWidget {
  const CommunityGroupsPage({super.key});

  @override
  ConsumerState<CommunityGroupsPage> createState() =>
      _CommunityGroupsPageState();
}

class _CommunityGroupsPageState extends ConsumerState<CommunityGroupsPage>
    with TickerProviderStateMixin {
  late final CommunityUsecase _communityUsecase;
  late final AuthUsecase _authUsecase;
  late TabController _tabController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<CommunityGroupModel> allCommunityList = [];
  List<CommunityGroupModel> myCommunityList = [];
  List<CommunityGroupModel> filteredAllCommunity = [];
  List<CommunityGroupModel> filteredMyCommunity = [];

  final GlobalKey<AnimatedListState> _allCommunityListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _myCommunityListKey =
      GlobalKey<AnimatedListState>();
  List<CommunityGroupModel> _animatedAllCommunity = [];
  List<CommunityGroupModel> _animatedMyCommunity = [];

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String searchQuery = '';
  String? _selectedStatus;

  // String? currentUserId;
  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late final String? currentPlan;

  bool get isPremiumUser => currentPlan == 'PremiumPlan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _tabController.previousIndex) {
        setState(() {});
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation
    _animationController.forward();

    _communityUsecase = ref.read(communityUseCaseProvider);
    _authUsecase = ref.read(authUseCaseProvider);
    currentPlan = ref.read(authNotifierProvider).userInfo?.purchasePlan;
    // _getCurrentUser();
    _fetchCommunityGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setAnimatedAllCommunity(List<CommunityGroupModel> list) {
    // Remove all existing items from AnimatedList
    for (int i = _animatedAllCommunity.length - 1; i >= 0; i--) {
      _allCommunityListKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildRemovedItem(_animatedAllCommunity[i], animation),
        duration: const Duration(milliseconds: 300),
      );
    }
    _animatedAllCommunity.clear();

    for (int i = 0; i < list.length; i++) {
      _animatedAllCommunity.insert(i, list[i]);
      _allCommunityListKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _setAnimatedMyCommunity(List<CommunityGroupModel> list) {
    // Remove all existing items from AnimatedList
    for (int i = _animatedMyCommunity.length - 1; i >= 0; i--) {
      _myCommunityListKey.currentState?.removeItem(
        i,
            (context, animation) =>
            _buildRemovedItem(_animatedMyCommunity[i], animation),
        duration: const Duration(milliseconds: 300),
      );
    }
    _animatedMyCommunity.clear();

    for (int i = 0; i < list.length; i++) {
      _animatedMyCommunity.insert(i, list[i]);
      _myCommunityListKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _fetchCommunityGroups() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final result = await _communityUsecase.getAllCommunityGroups();
      if (result.isSuccess) {
        allCommunityList = result.data!;
        myCommunityList =
            allCommunityList
                .where((community) => community.createdBy == currentUserId)
                .toList();

        myCommunityList.sort(
          (a, b) => (b.communityCreatedAt ?? DateTime.now()).compareTo(
            a.communityCreatedAt ?? DateTime.now(),
          ),
        );

        _filterCommunities();

        // update the animated list with the filtered results
        _setAnimatedAllCommunity(filteredAllCommunity);

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Fetch community groups fail');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error fetching groups';
      });
    }
  }

  void _filterCommunities() {
    final query = searchQuery.toLowerCase();

    filteredAllCommunity =
        allCommunityList
            .where(
              (community) =>
                  (community.communityName ?? '').toLowerCase().contains(query),
            )
            .toList();

    filteredMyCommunity =
        myCommunityList
            .where(
              (community) =>
                  (community.communityName ?? '').toLowerCase().contains(query),
            )
            .toList();

    _updateAnimatedAllCommunityList(filteredAllCommunity);
    _updateAnimatedMyCommunityList(filteredMyCommunity);
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _filterCommunities();
    });
  }

  void _updateAnimatedMyCommunityList(List<CommunityGroupModel> newList) {
    final oldList = List<CommunityGroupModel>.from(_animatedMyCommunity);

    // Remove items no longer present
    for (int i = oldList.length - 1; i >= 0; i--) {
      final item = oldList[i];
      if (!newList.contains(item)) {
        _animatedMyCommunity.removeAt(i);
        _myCommunityListKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(item, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Insert new items or reorder
    for (int i = 0; i < newList.length; i++) {
      final item = newList[i];

      if (i < _animatedMyCommunity.length &&
          _animatedMyCommunity[i] == item) {
        continue; // already in correct place
      }

      if (_animatedMyCommunity.contains(item)) {
        final oldIndex = _animatedMyCommunity.indexOf(item);
        _animatedMyCommunity.removeAt(oldIndex);
        _myCommunityListKey.currentState?.removeItem(
          oldIndex,
          (context, animation) => _buildRemovedItem(item, animation),
          duration: const Duration(milliseconds: 300),
        );
      }

      _animatedMyCommunity.insert(i, item);
      _myCommunityListKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _updateAnimatedAllCommunityList(List<CommunityGroupModel> newList) {
    final oldList = List<CommunityGroupModel>.from(_animatedAllCommunity);

    // Remove items no longer present
    for (int i = oldList.length - 1; i >= 0; i--) {
      final item = oldList[i];
      if (!newList.contains(item)) {
        _animatedAllCommunity.removeAt(i);
        _allCommunityListKey.currentState?.removeItem(
          i,
              (context, animation) => _buildRemovedItem(item, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Insert new items or reorder
    for (int i = 0; i < newList.length; i++) {
      final item = newList[i];

      if (i < _animatedAllCommunity.length &&
          _animatedAllCommunity[i] == item) {
        continue; // already in correct place
      }

      if (_animatedAllCommunity.contains(item)) {
        final oldIndex = _animatedAllCommunity.indexOf(item);
        _animatedAllCommunity.removeAt(oldIndex);
        _allCommunityListKey.currentState?.removeItem(
          oldIndex,
              (context, animation) => _buildRemovedItem(item, animation),
          duration: const Duration(milliseconds: 300),
        );
      }

      _animatedAllCommunity.insert(i, item);
      _allCommunityListKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget _buildRemovedItem(
    CommunityGroupModel community,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: GroupListItem(community: community, isMyGroup: false),
    );
  }

  Future<void> _createCommunityGroup() async {
    if (_nameController.text.trim().isEmpty) {
      Notify.showFlushbar('Please enter a community name', isError: true);
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      Notify.showFlushbar(
        'Please enter a community description',
        isError: true,
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _communityUsecase.createCommunityGroup(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        _selectedStatus ?? 'Active',
      );

      if (result.isSuccess) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Close create dialog
        _nameController.clear();
        _descriptionController.clear();
        Notify.showFlushbar('Community group created successfully!');
        _fetchCommunityGroups(); // Refresh list
      } else {
        throw Exception('Group created fail');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Notify.showFlushbar('Error creating group: $e', isError: true);
      }
    }
  }

  Future<void> _editCommunityGroup(CommunityGroupModel community) async {
    _nameController.text = community.communityName ?? '';
    _descriptionController.text = community.communityDescription ?? '';

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => _buildCommunityDialog(
            title: 'Edit Community Group',
            onSave: () async {
              if (_nameController.text.trim().isEmpty) {
                Notify.showFlushbar(
                  'Please enter a community name',
                  isError: true,
                );
                return;
              }

              if (_descriptionController.text.trim().isEmpty) {
                Notify.showFlushbar(
                  'Please enter a community description',
                  isError: true,
                );
                return;
              }

              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                );

                final result = await _communityUsecase.updateCommunityGroup(
                  community.communityGroupId!,
                  _nameController.text.trim(),
                  _descriptionController.text.trim(),
                  _selectedStatus ?? 'Active',
                );

                if (result.isSuccess) {
                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.of(context).pop(true); // Close edit dialog
                  Notify.showFlushbar('Community group updated successfully!');
                  _fetchCommunityGroups(); // Refresh list
                } else {
                  throw Exception('Group updated fail');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  Notify.showFlushbar(
                    'Error updating group: $e',
                    isError: true,
                  );
                }
              }
            },
          ),
    );

    _nameController.clear();
    _descriptionController.clear();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _buildCommunityDialog(
            title: 'Create New Community Group',
            onSave: _createCommunityGroup,
          ),
    );
  }

  Widget _buildCommunityDialog({
    required String title,
    required VoidCallback onSave,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.bold,
              color: Color(0xFFE37083), // RASPBERRY
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: _nameController,
                label: 'Community Name',
                icon: Icons.group,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF49AA2).withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(
                      color: const Color(0xFFE37083).withOpacity(0.8),
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.flag,
                      color: const Color(0xFFE37083).withOpacity(0.7),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE37083),
                // RASPBERRY
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF49AA2).withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFFE37083).withOpacity(0.8),
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFE37083).withOpacity(0.7),
          ),
        ),
        style: const TextStyle(fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF49AA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: const Color(0xFFE37083),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE37083),
                    fontFamily: 'League Spartan',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchCommunityGroups,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE37083),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF49AA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: const Color(0xFFE37083).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE37083) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFE37083)
                      : const Color(0xFFF49AA2).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFFE37083),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF49AA2).withOpacity(0.05),
            body: Stack(
              children: [
                // Background image behind AppBar
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/community.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        // Adjust the color and opacity for the fade
                        BlendMode.darken, // or BlendMode.srcATop, overlay, etc.
                      ),
                    ),
                  ),
                ),
                // Container(
                //   height: 200,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage('assets/images/community.png'), // Use your asset here
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),

                // Foreground content with rounded white background
                Column(
                  children: [
                    // Custom AppBar
                    // SafeArea(
                    //   child: ,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          const Text(
                            'Community Groups',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'League Spartan',
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(
                            width: 48,
                          ), // Space to balance back button
                        ],
                      ),
                    ),

                    // Main container with rounded corners
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                // Tab switch
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFF49AA2,
                                        ).withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTabButton(
                                        'My Groups',
                                        _tabController.index == 0,
                                        () => _tabController.animateTo(0),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildTabButton(
                                        'All Groups',
                                        _tabController.index == 1,
                                        () => _tabController.animateTo(1),
                                      ),
                                    ],
                                  ),
                                ),

                                // Search bar
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    // light pinkish tint
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE37083,
                                      ).withOpacity(0.5),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE37083,
                                        ).withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: const Color(
                                          0xFFE37083,
                                        ).withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search community groups...',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Colors.grey,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      if (searchQuery.isNotEmpty)
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: const Color(
                                              0xFFE37083,
                                            ).withOpacity(0.7),
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            _onSearchChanged('');
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Tab content
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10),
                                    color: const Color(0xFFFFEBEE),
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildCommunityList(
                                          filteredMyCommunity,
                                          isMyGroups: true,
                                        ),
                                        _buildCommunityList(
                                          filteredAllCommunity,
                                          isMyGroups: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // if (!isPremiumUser)
          //   Positioned.fill(
          //     child: Container(
          //       color: Colors.black.withOpacity(0.7),
          //       child: BackdropFilter(
          //         filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          //         child: Center(
          //           child: Padding(
          //             padding: const EdgeInsets.all(24),
          //             child: Container(
          //               constraints: const BoxConstraints(maxWidth: 360),
          //               padding: const EdgeInsets.all(28),
          //               decoration: BoxDecoration(
          //                 gradient: LinearGradient(
          //                   begin: Alignment.topLeft,
          //                   end: Alignment.bottomRight,
          //                   colors: [
          //                     Color(0xFFF49AA2), // ICE CREAM
          //                     Color(0xFFF49AA2).withOpacity(0.95),
          //                   ],
          //                 ),
          //                 borderRadius: BorderRadius.circular(24),
          //                 border: Border.all(
          //                   color: Color(0xFFFFB876), // PAPAYA
          //                   width: 2,
          //                 ),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Color(0xFFE37083).withOpacity(0.3),
          //                     // RASPBERRY
          //                     blurRadius: 20,
          //                     offset: const Offset(0, 10),
          //                   ),
          //                   BoxShadow(
          //                     color: Colors.white.withOpacity(0.1),
          //                     blurRadius: 1,
          //                     offset: const Offset(0, 1),
          //                   ),
          //                 ],
          //               ),
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   // Premium Icon
          //                   Container(
          //                     padding: const EdgeInsets.all(20),
          //                     decoration: BoxDecoration(
          //                       gradient: LinearGradient(
          //                         begin: Alignment.topLeft,
          //                         end: Alignment.bottomRight,
          //                         colors: [
          //                           Color(0xFFFFCB7C), // SUNSHINE
          //                           Color(0xFFFFB876), // PAPAYA
          //                         ],
          //                       ),
          //                       shape: BoxShape.circle,
          //                       boxShadow: [
          //                         BoxShadow(
          //                           color: Color(0xFFE37083).withOpacity(0.3),
          //                           blurRadius: 15,
          //                           offset: const Offset(0, 5),
          //                         ),
          //                       ],
          //                     ),
          //                     child: const Icon(
          //                       Icons.diamond,
          //                       color: Colors.white,
          //                       size: 40,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 20),
          //
          //                   // Title
          //                   const Text(
          //                     'Premium Feature',
          //                     style: TextStyle(
          //                       fontSize: 22,
          //                       fontWeight: FontWeight.bold,
          //                       color: Colors.white,
          //                       // Changed to white for better contrast
          //                       decoration: TextDecoration.none,
          //                       letterSpacing: 0.5,
          //                       shadows: [
          //                         Shadow(
          //                           color: Color(
          //                             0xFFE37083,
          //                           ), // RASPBERRY shadow
          //                           offset: Offset(0, 1),
          //                           blurRadius: 2,
          //                         ),
          //                       ],
          //                     ),
          //                     textAlign: TextAlign.center,
          //                   ),
          //                   const SizedBox(height: 8),
          //
          //                   // Subtitle
          //                   const Text(
          //                     'This feature is locked',
          //                     style: TextStyle(
          //                       fontSize: 14,
          //                       color: Colors.white,
          //                       // Changed to white for better contrast
          //                       decoration: TextDecoration.none,
          //                       fontWeight: FontWeight.w500,
          //                       shadows: [
          //                         Shadow(
          //                           color: Color(
          //                             0xFF89B7C2,
          //                           ), // SPRING SKY shadow
          //                           offset: Offset(0, 1),
          //                           blurRadius: 1,
          //                         ),
          //                       ],
          //                     ),
          //                     textAlign: TextAlign.center,
          //                   ),
          //                   const SizedBox(height: 16),
          //
          //                   // Description
          //                   Container(
          //                     padding: const EdgeInsets.all(16),
          //                     decoration: BoxDecoration(
          //                       color: Colors.white.withOpacity(0.9),
          //                       // More opaque background
          //                       borderRadius: BorderRadius.circular(12),
          //                       border: Border.all(
          //                         color: Color(0xFFFFB876).withOpacity(0.5),
          //                         // PAPAYA border
          //                         width: 1,
          //                       ),
          //                       boxShadow: [
          //                         BoxShadow(
          //                           color: Colors.white.withOpacity(0.3),
          //                           blurRadius: 4,
          //                           offset: const Offset(0, 2),
          //                         ),
          //                       ],
          //                     ),
          //                     child: const Text(
          //                       'Upgrade to Premium to unlock community sharing and advanced features!',
          //                       style: TextStyle(
          //                         fontSize: 13,
          //                         color: Color(0xFFE37083),
          //                         // RASPBERRY for better contrast
          //                         decoration: TextDecoration.none,
          //                         height: 1.4,
          //                         fontWeight: FontWeight.w600,
          //                       ),
          //                       textAlign: TextAlign.center,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 24),
          //
          //                   // Action Buttons - Fixed overflow by using Column
          //                   Column(
          //                     children: [
          //                       // Primary Button
          //                       Container(
          //                         width: double.infinity,
          //                         height: 48,
          //                         decoration: BoxDecoration(
          //                           // color: Color(0xFFE37083).withOpacity(0.3),
          //                           gradient: LinearGradient(
          //                             begin: Alignment.topLeft,
          //                             end: Alignment.bottomRight,
          //                             colors: [
          //                               Color(0xFFFFCB7C), // SUNSHINE
          //                               Color(0xFFFFB876), // PAPAYA
          //                             ],
          //                           ),
          //                           // gradient: LinearGradient(
          //                           //   begin: Alignment.topLeft,
          //                           //   end: Alignment.bottomRight,
          //                           //   // colors: [
          //                           //   //   Color(0xFFA8BF8A), // MEADOW
          //                           //   //   Color(0xFFA8BF8A).withOpacity(0.9),
          //                           //   // ],
          //                           // ),
          //                           borderRadius: BorderRadius.circular(12),
          //                           boxShadow: [
          //                             BoxShadow(
          //                               color: Color(
          //                                 0xFFA8BF8A,
          //                               ).withOpacity(0.4),
          //                               blurRadius: 8,
          //                               offset: const Offset(0, 4),
          //                             ),
          //                           ],
          //                         ),
          //                         child: ElevatedButton(
          //                           style: ElevatedButton.styleFrom(
          //                             backgroundColor: Colors.transparent,
          //                             foregroundColor: Colors.white,
          //                             shape: RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(12),
          //                             ),
          //                             elevation: 0,
          //                             shadowColor: Colors.transparent,
          //                           ),
          //                           onPressed: () {
          //                             Navigator.push(
          //                               context,
          //                               MaterialPageRoute(
          //                                 builder:
          //                                     (context) => SubscriptionPage(),
          //                               ),
          //                             );
          //                             // Notify.showFlushbar("Upgrade feature coming soon!");
          //                           },
          //                           child: const Row(
          //                             mainAxisAlignment:
          //                                 MainAxisAlignment.center,
          //                             mainAxisSize: MainAxisSize.min,
          //                             // Fix overflow
          //                             children: [
          //                               Icon(
          //                                 Icons.star,
          //                                 color: Colors.white,
          //                                 size: 18,
          //                               ),
          //                               SizedBox(width: 8),
          //                               Flexible(
          //                                 // Prevent text overflow
          //                                 child: Text(
          //                                   'Unlock Premium',
          //                                   style: TextStyle(
          //                                     fontSize: 16,
          //                                     fontWeight: FontWeight.bold,
          //                                     decoration: TextDecoration.none,
          //                                   ),
          //                                   overflow: TextOverflow.ellipsis,
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ),
          //                       const SizedBox(height: 12),
          //
          //                       // Secondary Button
          //                       Container(
          //                         width: double.infinity,
          //                         height: 44,
          //                         child: ElevatedButton(
          //                           style: ElevatedButton.styleFrom(
          //                             backgroundColor: Colors.white.withOpacity(
          //                               0.9,
          //                             ),
          //                             // More opaque
          //                             foregroundColor: Color(0xFFE37083),
          //                             // RASPBERRY for better contrast
          //                             shape: RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(12),
          //                               side: BorderSide(
          //                                 color: Color(
          //                                   0xFFFFB876,
          //                                 ).withOpacity(0.6),
          //                                 // PAPAYA border
          //                                 width: 1,
          //                               ),
          //                             ),
          //                             elevation: 0,
          //                           ),
          //                           onPressed: () {
          //                             Navigator.of(context).pop();
          //                           },
          //                           child: const Text(
          //                             'Maybe Later',
          //                             style: TextStyle(
          //                               fontSize: 14,
          //                               fontWeight: FontWeight.w600,
          //                               decoration: TextDecoration.none,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //
          //                   const SizedBox(height: 20),
          //
          //                   // Feature Pills - Fixed overflow with Wrap
          //                   Wrap(
          //                     spacing: 6,
          //                     runSpacing: 6,
          //                     alignment: WrapAlignment.center,
          //                     children: [
          //                       // _buildFeaturePill('Shared Healing Stories', Icons.book),
          //                       _buildFeaturePill(
          //                         'Safe Discussion Spaces',
          //                         Icons.forum,
          //                       ),
          //                       _buildFeaturePill(
          //                         'Peer Support Matching',
          //                         Icons.group,
          //                       ),
          //                       _buildFeaturePill(
          //                         'Guided Reflection Exercises',
          //                         Icons.psychology,
          //                       ),
          //
          //                       // _buildFeaturePill('Anonymous Sharing', Icons.visibility_off),
          //                       // _buildFeaturePill('Emotional Check-ins', Icons.emoji_emotions),
          //                     ],
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // More opaque background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFFFB876).withOpacity(0.6), // PAPAYA border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Color(0xFFA8BF8A), // MEADOW for better contrast
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            // Prevent text overflow
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFE37083), // RASPBERRY for better contrast
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityList(
    List<CommunityGroupModel> communities, {
    required bool isMyGroups,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE37083)),
        ),
      );
    }

    if (hasError) {
      return _buildErrorWidget();
    }

    if (communities.isEmpty) {
      return _buildEmptyState(
        isMyGroups
            ? 'You haven\'t created any groups yet.'
            : 'No community groups found.\nTry adjusting your search terms.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: AnimatedList(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // key: _allCommunityListKey,
            key: isMyGroups ? _myCommunityListKey : _allCommunityListKey,
            initialItemCount: communities.length,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GroupListItem(
                      community: communities[index],
                      isMyGroup: isMyGroups,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CommunityDetailPage(
                                  communityGroupId:
                                      communities[index].communityGroupId!,
                                ),
                          ),
                        );
                      },
                      onEdit:
                          isMyGroups
                              ? () => _editCommunityGroup(communities[index])
                              : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Create button at bottom
        Container(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCreateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE37083),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Create Your Own Group',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Group List Item with new styling
class GroupListItem extends StatelessWidget {
  final CommunityGroupModel community;
  final bool isMyGroup;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const GroupListItem({
    super.key,
    required this.community,
    required this.isMyGroup,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE37083).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF49AA2).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   boxShadow: [
        //     BoxShadow(
        //       color: const Color(0xFFF49AA2).withOpacity(0.1),
        //       blurRadius: 10,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image with gradient overlay
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF49AA2).withOpacity(0.8),
                    const Color(0xFFE37083).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/meditation_page_image.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF49AA2),
                            const Color(0xFFE37083),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.group,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          community.communityName ?? 'Unknown Community',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'League Spartan',
                            color: Color(0xFFE37083),
                          ),
                        ),
                      ),
                      if (isMyGroup && onEdit != null)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: const Color(0xFFE37083).withOpacity(0.7),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit!();
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Color(0xFFE37083),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFE37083),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                    ],
                  ),
                  if (community.communityDescription != null &&
                      community.communityDescription!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      community.communityDescription!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(community.communityStatus),
                              _getStatusColor(
                                community.communityStatus,
                              ).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          community.communityStatus ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        size: 16,
                        color: const Color(0xFFE37083).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      const Spacer(),
                      Text(
                        _formatDate(community.communityCreatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return const Color(0xFFA8BF8A); // MEADOW
      case 'open':
        return const Color(0xFF89B7C2); // SPRING SKY
      case 'closed':
        return const Color(0xFFE37083); // RASPBERRY
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
