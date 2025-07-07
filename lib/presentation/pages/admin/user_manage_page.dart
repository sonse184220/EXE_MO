import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/admin_view_user_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class UserManagePage extends ConsumerStatefulWidget {
  const UserManagePage({super.key});
  @override
  ConsumerState<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends ConsumerState<UserManagePage> {
  late final AuthUsecase _authUsecase;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<AdminViewUserModel> users = [];
  bool isLoadUsers = false;
  bool isUserListError = false;

  Future<void> _fetchUsers() async {
    setState(() {
      isLoadUsers = true;
      isUserListError = false;
    });

    try {
      final result = await _authUsecase.getAllUsersForAdmin();
      if (result.isSuccess) {
        setState(() {
          users = result.data!;
          isLoadUsers = false;
        });
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (_) {
      setState(() {
        isLoadUsers = false;
        isUserListError = true;
      });
    }
  }

  Future<void> _toggleUserStatus(AdminViewUserModel user) async {
    final newStatus = user.status == 'Active' ? 'Inactive' : 'Active';
    final action = user.status == 'Active' ? 'disable' : 'enable';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm ${action.toUpperCase()}'),
        content: Text('Are you sure you want to ${action} ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: user.status == 'Active'
                  ? const Color(0xFFF49AA2).withOpacity(0.1)
                  : const Color(0xFFA8BF8A).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              action.toUpperCase(),
              style: TextStyle(
                  color: user.status == 'Active'
                      ? const Color(0xFFE37083)
                      : const Color(0xFFA8BF8A)
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = Result.success('data');
        // final result = await _authUsecase.toggleUserStatus(user.userId, newStatus);
        if (result.isSuccess) {
          setState(() {
            final index = users.indexWhere((u) => u.userId == user.userId);
            if (index != -1) {
              users[index] = user.copyWith(status: newStatus);
            }
          });
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${action}d successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to ${action} user');
        }
      } catch (_) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${action} user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get filtered users based on search query
  List<AdminViewUserModel> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((user) => _userSearchFilter(user, _searchQuery)).toList();
  }

  bool _userSearchFilter(AdminViewUserModel user, String query) {
    final searchQuery = query.toLowerCase();
    return (user.fullName ?? '').toLowerCase().contains(searchQuery) ||
        (user.email ?? '').toLowerCase().contains(searchQuery) ||
        (user.phoneNumber ?? '').toLowerCase().contains(searchQuery);
  }

  // bool _userSearchFilter(AdminViewUserModel user, String query) {
  //   final searchQuery = query.toLowerCase();
  //   return user.fullName.toLowerCase().contains(searchQuery) ||
  //       user.email.toLowerCase().contains(searchQuery) ||
  //       user.phoneNumber.toLowerCase().contains(searchQuery);
  // }

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
    _authUsecase = ref.read(authUseCaseProvider);
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedUsers = filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Management',
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
                        '${users.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Users',
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
                    Icons.people_outline,
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
                hintText: 'Search by name, email, or phone...',
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
                    'Found ${displayedUsers.length} user${displayedUsers.length == 1 ? '' : 's'}',
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

          // Refresh Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadUsers ? null : _fetchUsers,
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
              child: isLoadUsers
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Refresh Users',
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

          // User List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoadUsers
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF89B7C2),
                ),
              )
                  : isUserListError
                  ? Center(
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
                      'Error loading users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : displayedUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No users found'
                          : 'No users match your search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Users will appear here once loaded'
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
                itemCount: displayedUsers.length,
                itemBuilder: (context, index) {
                  final user = displayedUsers[index];
                  return UserListItem(
                    user: user,
                    onToggleStatus: () => _toggleUserStatus(user),
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

class UserListItem extends StatelessWidget {
  final AdminViewUserModel user;
  final VoidCallback onToggleStatus;
  final String searchQuery;

  const UserListItem({
    super.key,
    required this.user,
    required this.onToggleStatus,
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
    final List<List<Color>> userColors = [
      [const Color(0xFFE37083), const Color(0xFFF49AA2)],
      [const Color(0xFFFFB876), const Color(0xFFFFCB7C)],
      [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)],
      [const Color(0xFF89B7C2), const Color(0xFFE37083)],
      [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)],
    ];

    final colorIndex = (user.userId ?? '').hashCode % userColors.length;
    final gradientColors = userColors[colorIndex];

    final fullName = user.fullName ?? 'Unknown';
    final email = user.email ?? 'No email';
    final phoneNumber = user.phoneNumber ?? '';
    final status = user.status ?? 'Unknown';
    final roleName = user.roleName ?? 'Unknown';

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
            child: Center(
              child: Text(
                fullName
                    .split(' ')
                    .where((n) => n.isNotEmpty)
                    .map((n) => n[0])
                    .take(2)
                    .join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(fullName, searchQuery),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Active'
                            ? const Color(0xFFA8BF8A).withOpacity(0.15)
                            : const Color(0xFFE37083).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'Active'
                              ? const Color(0xFFA8BF8A)
                              : const Color(0xFFE37083),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF89B7C2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF89B7C2),
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
              color: status == 'Active'
                  ? const Color(0xFFE37083).withOpacity(0.15)
                  : const Color(0xFFA8BF8A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                status == 'Active' ? Icons.block : Icons.check_circle_outline,
                color: status == 'Active'
                    ? const Color(0xFFE37083)
                    : const Color(0xFFA8BF8A),
                size: 20,
              ),
              onPressed: onToggleStatus,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}


// class UserListItem extends StatelessWidget {
//   final AdminViewUserModel user;
//   final VoidCallback onToggleStatus;
//   final String searchQuery;
//
//   const UserListItem({
//     super.key,
//     required this.user,
//     required this.onToggleStatus,
//     this.searchQuery = '',
//   });
//
//   // Helper method to highlight search terms
//   Widget _buildHighlightedText(String text, String query) {
//     if (query.isEmpty) {
//       return Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF2C3E50),
//         ),
//       );
//     }
//
//     final lowerText = text.toLowerCase();
//     final lowerQuery = query.toLowerCase();
//
//     if (!lowerText.contains(lowerQuery)) {
//       return Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF2C3E50),
//         ),
//       );
//     }
//
//     final startIndex = lowerText.indexOf(lowerQuery);
//     final endIndex = startIndex + query.length;
//
//     return RichText(
//       text: TextSpan(
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF2C3E50),
//         ),
//         children: [
//           TextSpan(text: text.substring(0, startIndex)),
//           TextSpan(
//             text: text.substring(startIndex, endIndex),
//             style: const TextStyle(
//               backgroundColor: Color(0xFFFFB876),
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           TextSpan(text: text.substring(endIndex)),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Generate a harmonious color for each user
//     final List<List<Color>> userColors = [
//       [const Color(0xFFE37083), const Color(0xFFF49AA2)], // Raspberry to Ice Cream
//       [const Color(0xFFFFB876), const Color(0xFFFFCB7C)], // Papaya to Sunshine
//       [const Color(0xFFA8BF8A), const Color(0xFF89B7C2)], // Meadow to Spring Sky
//       [const Color(0xFF89B7C2), const Color(0xFFE37083)], // Spring Sky to Raspberry
//       [const Color(0xFFF49AA2), const Color(0xFFA8BF8A)], // Ice Cream to Meadow
//     ];
//
//     final colorIndex = user.userId.hashCode % userColors.length;
//     final gradientColors = userColors[colorIndex];
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFF0F0F0)),
//         boxShadow: [
//           BoxShadow(
//             color: gradientColors[0].withOpacity(0.1),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               gradient: LinearGradient(
//                 colors: gradientColors,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 user.fullName.split(' ').map((n) => n[0]).take(2).join(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHighlightedText(user.fullName, searchQuery),
//                 const SizedBox(height: 4),
//                 Text(
//                   user.email,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF7F8C8D),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: user.status == 'Active'
//                             ? const Color(0xFFA8BF8A).withOpacity(0.15)
//                             : const Color(0xFFE37083).withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         user.status,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: user.status == 'Active'
//                               ? const Color(0xFFA8BF8A)
//                               : const Color(0xFFE37083),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF89B7C2).withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         user.roleName,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF89B7C2),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: user.status == 'Active'
//                   ? const Color(0xFFE37083).withOpacity(0.15)
//                   : const Color(0xFFA8BF8A).withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 user.status == 'Active' ? Icons.block : Icons.check_circle_outline,
//                 color: user.status == 'Active'
//                     ? const Color(0xFFE37083)
//                     : const Color(0xFFA8BF8A),
//                 size: 20,
//               ),
//               onPressed: onToggleStatus,
//               constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }