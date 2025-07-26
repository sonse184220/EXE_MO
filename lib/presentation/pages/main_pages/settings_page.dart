import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_child_app/core/utils/auth_utils/app_router.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/auth/user_detail_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:inner_child_app/presentation/pages/function_pages/customer_services_page/help_screen_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/payment_transaction_pages/payment_transaction_history.dart';
import 'package:inner_child_app/presentation/pages/function_pages/user_information/profile_edit_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/subscription_pages/subscription_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with TickerProviderStateMixin {
  late final AuthUsecase _authUsecase;
  late final List<Map<String, dynamic>> settingsItems;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  UserDetailModel? userDetail;
  bool isLoadingUserDetail = true;
  String? userDetailError;

  // Color palette
  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);

  @override
  void initState() {
    super.initState();

    _authUsecase = ref.read(authUseCaseProvider);

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Load user details
    _loadUserDetail();

    // Initialize settings items
    _initializeSettingsItems();

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _initializeSettingsItems() {
    settingsItems = [
      {
        'icon': Icons.credit_card,
        'color': springSky,
        'title': 'Your payment transactions',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentTransactionHistory(),
            ),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'color': meadow,
        'title': 'Support',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpScreenPage()),
          );
        },
      },
      {
        'icon': Icons.star,
        'color': sunshine,
        'title': 'Subscription',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubscriptionPage()),
          );
        },
      },
      {
        'icon': Icons.swap_horiz,
        'color': papaya,
        'title': 'Switch Profile',
        'onTap': () => _handleSwitchProfile(),
      },
      {
        'icon': Icons.logout,
        'color': raspberry,
        'title': 'Logout',
        'onTap': () => _handleLogout(),
      },
    ];
  }

  Future<void> _loadUserDetail() async {
    final userId = ref.read(authNotifierProvider).userInfo?.userId;
    if (userId == null) {
      setState(() {
        isLoadingUserDetail = false;
        userDetailError = "User ID is missing.";
      });
      return;
    }

    final result = await _authUsecase.getUserDetail(userId);
    if (result.isSuccess) {
      setState(() {
        userDetail = result.data;
        isLoadingUserDetail = false;
        userDetailError = null;
      });
    } else {
      setState(() {
        isLoadingUserDetail = false;
        userDetailError = "Failed to load user details.";
      });
    }
  }

  Future<void> _handleSwitchProfile() async {
    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Switch Profile'),
        content: const Text('Are you sure you want to switch profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (shouldSwitch == true) {
      final result = await _authUsecase.switchToProfileChoosing();
      if (result.isSuccess) {
        // Handle success
      } else {
        Notify.showFlushbar(
            'Switch failed due to error. Please logout and login again if you want to switch profile!'
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final result = await _authUsecase.logout();
      if (result.isSuccess) {
        // Handle success
      } else {
        Notify.showFlushbar('Logout failed');
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Profile Header Section
                SliverToBoxAdapter(
                  child: _buildProfileHeader(),
                ),

                // Settings Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),

                // Settings List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return AnimatedBuilder(
                          animation: _slideController,
                          builder: (context, child) {
                            final delay = index * 0.1;
                            final animationValue = Curves.easeOutCubic.transform(
                                (_slideController.value - delay).clamp(0.0, 1.0)
                            );

                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - animationValue)),
                              child: Opacity(
                                opacity: animationValue,
                                child: _buildSettingItem(
                                  settingsItems[index],
                                  index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: settingsItems.length,
                    ),
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            raspberry.withOpacity(0.8),
            iceCream.withOpacity(0.9),
            papaya.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: raspberry.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isLoadingUserDetail
          ? _buildProfileLoading()
          : userDetailError != null
          ? _buildProfileError()
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileLoading() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileError() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileEditPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Click to view your profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unable to load profile details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileEditPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: userDetail?.profilePicture != null
                  ? Image.network(
                userDetail!.profilePicture!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: raspberry,
                    size: 30,
                  );
                },
              )
                  : Icon(
                Icons.person,
                color: raspberry,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userDetail?.fullName ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item['icon'] as IconData,
            color: item['color'] as Color,
            size: 24,
          ),
        ),
        title: Text(
          item['title'] as String,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: item['onTap'] as VoidCallback?,
      ),
    );
  }
}