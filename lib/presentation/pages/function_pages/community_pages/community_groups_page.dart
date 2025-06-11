import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_detail_page.dart';

class CommunityGroupsPage extends ConsumerStatefulWidget {
  const CommunityGroupsPage({super.key});

  @override
  ConsumerState<CommunityGroupsPage> createState() => _CommunityGroupsPageState();
}

class _CommunityGroupsPageState extends ConsumerState<CommunityGroupsPage>
    with SingleTickerProviderStateMixin {
  late final CommunityUsecase _communityUsecase;
  late final AuthUsecase _authUsecase;
  late TabController _tabController;

  List<CommunityGroupModel> allCommunityList = [];
  List<CommunityGroupModel> myCommunityList = [];
  List<CommunityGroupModel> filteredAllCommunity = [];
  List<CommunityGroupModel> filteredMyCommunity = [];

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String searchQuery = '';
  String? _selectedStatus;

  // String? currentUserId;
  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;
  TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _communityUsecase = ref.read(communityUseCaseProvider);
    _authUsecase = ref.read(authUseCaseProvider);
    // _getCurrentUser();
    _fetchCommunityGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // void _getCurrentUser() {
  //   final authState = _authUsecase.authState;
  //   currentUserId = authState?.userInfo?.userId;
  // }

  Future<void> _fetchCommunityGroups() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final result = await _communityUsecase.getAllCommunityGroups();
      if (result.isSuccess) {
        setState(() {
          allCommunityList = result.data!;
          myCommunityList = allCommunityList
              .where((community) => community.createdBy == currentUserId)
              .toList();

          // Sort my communities by creation date (newest first)
          myCommunityList.sort((a, b) =>
              (b.communityCreatedAt ?? DateTime.now())
                  .compareTo(a.communityCreatedAt ?? DateTime.now()));

          _filterCommunities();
          isLoading = false;
        });
      }else{
        throw Exception('Fetch community groups fail');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error fetching groups: $e';
      });
    }
  }

  void _filterCommunities() {
    final query = searchQuery.toLowerCase();

    filteredAllCommunity = allCommunityList
        .where((community) =>
        (community.communityName ?? '').toLowerCase().contains(query))
        .toList();

    filteredMyCommunity = myCommunityList
        .where((community) =>
        (community.communityName ?? '').toLowerCase().contains(query))
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _filterCommunities();
    });
  }

  Future<void> _createCommunityGroup() async {
    if (_nameController.text.trim().isEmpty) {
      Notify.showFlushbar('Please enter a community name', isError: true);
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      Notify.showFlushbar('Please enter a community description', isError: true);
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
      }else{
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
      builder: (context) => _buildCommunityDialog(
        title: 'Edit Community Group',
        onSave: () async {
          if (_nameController.text.trim().isEmpty) {
            Notify.showFlushbar('Please enter a community name', isError: true);
            return;
          }

          if (_descriptionController.text.trim().isEmpty) {
            Notify.showFlushbar('Please enter a community description', isError: true);
            return;
          }

          try {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
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
            }else{
              throw Exception('Group updated fail');
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              Notify.showFlushbar('Error updating group: $e', isError: true);
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
      builder: (context) => _buildCommunityDialog(
        title: 'Create New Community Group',
        onSave: _createCommunityGroup,
      ),
    );
  }

  Widget _buildCommunityDialog({
    required String title,
    required VoidCallback onSave,
  }) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'League Spartan',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Community Name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'Inter'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
            ],
            onChanged: (value) {
              _selectedStatus = value!;
            },
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter')),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Save', style: TextStyle(fontFamily: 'Inter')),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'League Spartan',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchCommunityGroups,
            child: const Text(
              'Retry',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with back button, title, and add button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.blue),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Community Groups',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'League Spartan',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: _showCreateDialog,
                        ),
                      ],
                    ),

                    // Search input field
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: const InputDecoration(
                                hintText: 'Search community groups...',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                        ],
                      ),
                    ),

                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Text(
                            'My Groups',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'All Groups',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                    ),

                    const SizedBox(height: 15),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // My Groups Tab
                          _buildCommunityList(filteredMyCommunity, isMyGroups: true),
                          // All Groups Tab
                          _buildCommunityList(filteredAllCommunity, isMyGroups: false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Create group suggestion
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Can\'t find the perfect group? You can create your own group using the + button above.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildCommunityList(List<CommunityGroupModel> communities, {required bool isMyGroups}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return _buildErrorWidget();
    }

    if (communities.isEmpty) {
      return _buildEmptyState(
        isMyGroups
            ? 'You haven\'t created any groups yet.\nTap the + button to create your first group!'
            : 'No community groups found.\nTry adjusting your search terms.',
      );
    }

    return ListView.separated(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        return GroupListItem(
          community: community,
          isMyGroup: isMyGroups,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDetailPage(
                  communityGroupId: community.communityGroupId!,
                ),
              ),
            );
          },
          onEdit: isMyGroups ? () => _editCommunityGroup(community) : null,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}

// Enhanced Group List Item
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage('assets/images/meditation_page_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),

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
                          ),
                        ),
                      ),
                      if (isMyGroup && onEdit != null)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit!();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: TextStyle(fontFamily: 'Inter'),
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
                    const SizedBox(height: 4),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(community.communityStatus),
                          borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.people, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${community.communityMembersDetail?.length ?? 0} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Inter',
                        ),
                      ),
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
        return Colors.green;
      case 'open':
        return Colors.blue;
      case 'closed':
        return Colors.red;
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