import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_detail_model.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/articles/article_detail.dart';
import 'package:inner_child_app/presentation/pages/function_pages/articles/article_list_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/all_audio_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/home_audio_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_session_list_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_groups_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/mood_journal_page/mood_journal_writing.dart';
import 'package:inner_child_app/presentation/pages/function_pages/quiz/all_quiz_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/therapy_tools_page.dart';
import 'package:inner_child_app/presentation/widgets/banner.dart';

import '../../../main.dart';
import '../function_pages/user_information/profile_edit_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late final ArticleUseCase _articleUseCase;
  late final AuthUsecase _authUsecase;

  List<ArticleModel> _articles = [];
  bool _isLoading = true;

  UserDetailModel? _userDetail;
  bool _isLoadingUserDetail = true;

  late final String? currentPlan;
  late final String? role;

  String? _userDetailError;
  String? _articlesError;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _articleUseCase = ref.read(articleUseCaseProvider);
    _authUsecase = ref.read(authUseCaseProvider);

    currentPlan = ref.read(authNotifierProvider).userInfo?.purchasePlan;
    role = ref.read(authNotifierProvider).userInfo?.role;

    _loadUserDetail();
    _loadArticles();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 1.1,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetail() async {
    final userId = ref.read(authNotifierProvider).userInfo?.userId;
    if (userId == null) {
      setState(() {
        _isLoadingUserDetail = false;
        _userDetailError = "User ID is missing.";
      });
      return;
    }

    final result = await _authUsecase.getUserDetail(userId);
    if (result.isSuccess) {
      setState(() {
        _userDetail = result.data;
        _isLoadingUserDetail = false;
        _userDetailError = null;
      });
    } else {
      setState(() {
        _isLoadingUserDetail = false;
        _userDetailError = "Failed to load user details.";
      });
    }
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await _articleUseCase.getAllArticles();
      setState(() {
        _articles = articles.data ?? [];
        _isLoading = false;
        _articlesError = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _articlesError = "Failed to load articles. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F7FA),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Home',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //   FadeTransition(
                  //   opacity: _fadeAnimation,
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 300,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(24),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.3),
                  //           blurRadius: 20,
                  //           offset: const Offset(0, 10),
                  //         ),
                  //       ],
                  //     ),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(24),
                  //       child: Stack(
                  //         children: [
                  //           // Background Image with scale animation
                  //           ScaleTransition(
                  //             scale: _scaleAnimation,
                  //             child: Container(
                  //               width: double.infinity,
                  //               height: double.infinity,
                  //               decoration: const BoxDecoration(
                  //                 image: DecorationImage(
                  //                   image: AssetImage('assets/images/banner_bg.jpg'),
                  //                   fit: BoxFit.cover,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //
                  //           // Gradient Overlay
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 begin: Alignment.topCenter,
                  //                 end: Alignment.bottomCenter,
                  //                 colors: [
                  //                   Colors.black.withOpacity(0.2),
                  //                   Colors.black.withOpacity(0.6),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //
                  //           // Animated Text Content
                  //           Positioned(
                  //             left: 24,
                  //             right: 24,
                  //             bottom: 40,
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 // Main Title - slides from left
                  //                 SlideTransition(
                  //                   position: _titleSlideAnimation,
                  //                   child: Text(
                  //                     'Welcome to MyApp',
                  //                     style: TextStyle(
                  //                       color: Colors.white,
                  //                       fontSize: 32,
                  //                       fontWeight: FontWeight.bold,
                  //                       letterSpacing: 1.2,
                  //                       shadows: [
                  //                         Shadow(
                  //                           color: Colors.black.withOpacity(0.8),
                  //                           blurRadius: 8,
                  //                           offset: const Offset(0, 3),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //
                  //                 const SizedBox(height: 12),
                  //
                  //                 // Subtitle - slides from right
                  //                 SlideTransition(
                  //                   position: _subtitleSlideAnimation,
                  //                   child: Text(
                  //                     'Discover amazing features and unlock your potential with our innovative platform designed for modern users.',
                  //                     style: TextStyle(
                  //                       color: Colors.white.withOpacity(0.9),
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w400,
                  //                       height: 1.5,
                  //                       shadows: [
                  //                         Shadow(
                  //                           color: Colors.black.withOpacity(0.6),
                  //                           blurRadius: 4,
                  //                           offset: const Offset(0, 2),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //
                  //                 const SizedBox(height: 20),
                  //
                  //                 // Call to Action Button - fades in
                  //                 FadeTransition(
                  //                   opacity: _fadeAnimation,
                  //                   child: Container(
                  //                     decoration: BoxDecoration(
                  //                       borderRadius: BorderRadius.circular(25),
                  //                       gradient: const LinearGradient(
                  //                         colors: [
                  //                           Color(0xFF667eea),
                  //                           Color(0xFF764ba2),
                  //                         ],
                  //                       ),
                  //                       boxShadow: [
                  //                         BoxShadow(
                  //                           color: Colors.black.withOpacity(0.3),
                  //                           blurRadius: 10,
                  //                           offset: const Offset(0, 5),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     child: ElevatedButton(
                  //                       onPressed: () {
                  //                         // Handle button press
                  //                         print('Get Started pressed');
                  //                       },
                  //                       style: ElevatedButton.styleFrom(
                  //                         backgroundColor: Colors.transparent,
                  //                         shadowColor: Colors.transparent,
                  //                         padding: const EdgeInsets.symmetric(
                  //                           horizontal: 32,
                  //                           vertical: 16,
                  //                         ),
                  //                         shape: RoundedRectangleBorder(
                  //                           borderRadius: BorderRadius.circular(25),
                  //                         ),
                  //                       ),
                  //                       child: const Row(
                  //                         mainAxisSize: MainAxisSize.min,
                  //                         children: [
                  //                           Text(
                  //                             'Get Started',
                  //                             style: TextStyle(
                  //                               color: Colors.white,
                  //                               fontSize: 16,
                  //                               fontWeight: FontWeight.w600,
                  //                             ),
                  //                           ),
                  //                           SizedBox(width: 8),
                  //                           Icon(
                  //                             Icons.arrow_forward,
                  //                             color: Colors.white,
                  //                             size: 20,
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //
                  //           // Decorative Elements
                  //           Positioned(
                  //             top: 30,
                  //             right: 30,
                  //             child: FadeTransition(
                  //               opacity: _fadeAnimation,
                  //               child: Container(
                  //                 padding: const EdgeInsets.all(12),
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withOpacity(0.15),
                  //                   borderRadius: BorderRadius.circular(20),
                  //                   border: Border.all(
                  //                     color: Colors.white.withOpacity(0.2),
                  //                     width: 1,
                  //                   ),
                  //                 ),
                  //                 child: const Icon(
                  //                   Icons.star,
                  //                   color: Colors.white,
                  //                   size: 24,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  AppBanner(),

                  // // Profile Card
                  // if (_isLoadingUserDetail) ...[
                  //   const Center(child: CircularProgressIndicator()),
                  // ] else if (_userDetailError != null) ...[
                  //   Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.all(20),
                  //     decoration: BoxDecoration(
                  //       gradient: const LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                  //       ),
                  //       borderRadius: BorderRadius.circular(20),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black26,
                  //           blurRadius: 10,
                  //           offset: Offset(0, 5),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Center(
                  //       child: Column(
                  //         children: [
                  //           Text(
                  //             _userDetailError!,
                  //             style: TextStyle(color: Colors.brown),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //           const SizedBox(height: 8),
                  //           ElevatedButton(
                  //             onPressed: _loadUserDetail,
                  //             child: Text("Retry"),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ] else if (_userDetail == null) ...[
                  //   Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.all(20),
                  //     decoration: BoxDecoration(
                  //       gradient: const LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                  //       ),
                  //       borderRadius: BorderRadius.circular(20),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black26,
                  //           blurRadius: 10,
                  //           offset: Offset(0, 5),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Text(
                  //       "User info unavailable.",
                  //       style: TextStyle(color: Colors.brown),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ] else ...[
                  //   // The profile card
                  //   GestureDetector(
                  //     onTap: () {
                  //       // Navigate to profile edit page
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => ProfileEditPage(),
                  //         ),
                  //       );
                  //     },
                  //     child: Container(
                  //       width: double.infinity,
                  //       padding: const EdgeInsets.all(20),
                  //       decoration: BoxDecoration(
                  //         gradient: const LinearGradient(
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //           colors: [Color(0xFF89B7C2), Color(0xFFA8BF8A)],
                  //         ),
                  //         borderRadius: BorderRadius.circular(20),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black26,
                  //             blurRadius: 10,
                  //             offset: Offset(0, 5),
                  //           ),
                  //         ],
                  //       ),
                  //       child: Column(
                  //         children: [
                  //           Container(
                  //             width: 80,
                  //             height: 80,
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               border: Border.all(
                  //                 color: Colors.white,
                  //                 width: 3,
                  //               ),
                  //             ),
                  //             child: ClipOval(
                  //               child:
                  //                   _userDetail?.profilePicture != null
                  //                       ? Image.network(
                  //                         _userDetail!.profilePicture!,
                  //                         width: 80,
                  //                         height: 80,
                  //                         fit: BoxFit.cover,
                  //                         errorBuilder: (
                  //                           context,
                  //                           error,
                  //                           stackTrace,
                  //                         ) {
                  //                           return Image.asset(
                  //                             'assets/images/user_avt.png',
                  //                             width: 80,
                  //                             height: 80,
                  //                             fit: BoxFit.cover,
                  //                           );
                  //                         },
                  //                       )
                  //                       : Image.asset(
                  //                         'assets/images/user_avt.png',
                  //                         width: 80,
                  //                         height: 80,
                  //                         fit: BoxFit.cover,
                  //                       ),
                  //             ),
                  //           ),
                  //           // Container(
                  //           //   width: 80,
                  //           //   height: 80,
                  //           //   decoration: BoxDecoration(
                  //           //     shape: BoxShape.circle,
                  //           //     border: Border.all(color: Colors.white, width: 3),
                  //           //     image: DecorationImage(
                  //           //       image: NetworkImage(
                  //           //         _userDetail?.profilePicture ??
                  //           //             'https://images.unsplash.com/photo-1494790108755-2616b9214825?w=400&h=400&fit=crop&crop=face',
                  //           //       ),
                  //           //       fit: BoxFit.cover,
                  //           //     ),
                  //           //   ),
                  //           // ),
                  //           const SizedBox(height: 12),
                  //           Text(
                  //             _userDetail?.fullName ?? "No Name",
                  //             style: const TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 4),
                  //           Text(
                  //             _userDetail?.gender ?? "",
                  //             style: TextStyle(
                  //               color: Colors.white.withOpacity(0.8),
                  //               fontSize: 14,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 16),
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //             children: [
                  //               _buildStatItem(currentPlan ?? 'Free', 'Plan'),
                  //               Container(
                  //                 height: 30,
                  //                 width: 1,
                  //                 color: Colors.white.withOpacity(0.3),
                  //               ),
                  //               _buildStatItem(role ?? 'User', 'Role'),
                  //             ],
                  //           ),
                  //           // Row(
                  //           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           //   children: [
                  //           //     _buildStatItem('75k', 'Followers'),
                  //           //     Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3)),
                  //           //     _buildStatItem('16k', 'Following'),
                  //           //     // Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3)),
                  //           //     // _buildStatItem('600', 'Projects'),
                  //           //   ],
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(height: 24),

                  // Healing Sessions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Healing Sessions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // TextButton(
                      //   onPressed:
                      //       () =>
                      //           mainScreenKey.currentState
                      //               ?.switchToTherapyTab(),
                      //   child: Text(
                      //     'See all',
                      //     style: TextStyle(
                      //       color: Color(0xFF89B7C2),
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Healing Sessions Cards (Square Cards)
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildHealingSessionCard(
                          image:
                              'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop',
                          title: 'AI Chat',
                          subtitle: 'Helpful talk',
                          icon: Icons.chat,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatAiSessionListPage(),
                                ),
                              ),
                        ),
                        _buildHealingSessionCard(
                          image:
                              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
                          title: 'Audio Library',
                          subtitle: 'Find peace',
                          icon: Icons.audio_file_outlined,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllAudioPage(),
                                ),
                              ),
                        ),
                        _buildHealingSessionCard(
                          image:
                              'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400&h=400&fit=crop',
                          title: 'Emotional Diary',
                          subtitle: 'Your feelings',
                          icon: Icons.note_alt_outlined,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoodJournalWriting(),
                                ),
                              ),
                        ),
                        _buildHealingSessionCard(
                          image:
                              'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&h=400&fit=crop',
                          title: 'Community',
                          subtitle: 'Share emotions',
                          icon: Icons.people,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommunityGroupsPage(),
                                ),
                              ),
                        ),
                        _buildHealingSessionCard(
                          image:
                              'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400&h=400&fit=crop',
                          title: 'Mental Quiz',
                          subtitle: 'Check wellness',
                          icon: Icons.quiz,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllQuizPage(),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Articles Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reading Articles',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleListPage(),
                              ),
                            ),
                        child: Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFF89B7C2),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Articles List (Live Channel Style)
                  if (_isLoading) ...[
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF89B7C2),
                        ),
                      ),
                    ),
                  ] else if (_articlesError != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: double.infinity,
                      height: 200, // adjust as needed
                      child: Stack(
                        children: [
                          // background image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/error_article_box.jpg",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                          // blurred overlay
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.white.withOpacity(0.3),
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                child: FractionallySizedBox(
                                  widthFactor: 0.95,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _articlesError!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _loadArticles,
                                        child: const Text("Retry"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_articles.isEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: double.infinity,
                      height: 120, // adjust as you like
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/error_article_box.jpg",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.white.withOpacity(0.3),
                                alignment: Alignment.center,
                                child: Text(
                                  "No articles found.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          _articles.length > 5
                              ? 5
                              : _articles.length, // Max 5 items
                      itemBuilder: (context, index) {
                        final article = _articles[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: OpenContainer(
                            transitionDuration: Duration(milliseconds: 500),
                            closedElevation: 0,
                            closedColor: Colors.transparent,
                            openElevation: 0,
                            openColor: Colors.transparent,
                            closedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            openShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            closedBuilder: (context, openContainer) {
                              return FractionallySizedBox(
                                widthFactor: 0.95,
                                // 85% of the screen width; adjust as desired
                                child: _buildArticleCard(
                                  image:
                                      article.articleUrl ??
                                      'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=400&h=400&fit=crop',
                                  title: article.articleName ?? 'Unknown',
                                  category:
                                      article.articleDescription ?? 'Unknown',
                                  onTap:
                                      article.articleId != null
                                          ? openContainer
                                          : () {
                                            Notify.showFlushbar(
                                              'Cannot view article details.',
                                            );
                                          },
                                ),
                              );
                            },
                            openBuilder:
                                (context, _) =>
                                    article.articleId != null
                                        ? ArticleDetail(
                                          articleId: article.articleId!,
                                        )
                                        : Container(),
                          ),
                        );
                      },
                    ),
                  ],
                  // _isLoading
                  //     ? Center(
                  //   child: CircularProgressIndicator(
                  //     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF89B7C2)),
                  //   ),
                  // )
                  //     : ListView.builder(
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemCount: _articles.length > 5 ? 5 : _articles.length, // Max 5 items
                  //   itemBuilder: (context, index) {
                  //     final article = _articles[index];
                  //
                  //     return Container(
                  //       margin: const EdgeInsets.only(bottom: 12),
                  //       child: OpenContainer(
                  //         transitionDuration: Duration(milliseconds: 500),
                  //         closedElevation: 0,
                  //         closedColor: Colors.transparent,
                  //         openElevation: 0,
                  //         openColor: Colors.transparent,
                  //         closedShape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(16),
                  //         ),
                  //         openShape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(16),
                  //         ),
                  //         closedBuilder: (context, openContainer) {
                  //           return
                  //             FractionallySizedBox(
                  //               widthFactor: 0.95, // 85% of the screen width; adjust as desired
                  //               child:_buildArticleCard(
                  //             image: article.articleUrl ?? 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=400&h=400&fit=crop',
                  //             title: article.articleName ?? 'Unknown',
                  //             category: article.articleDescription ?? 'Unknown',
                  //             onTap: article.articleId != null ? openContainer : () {
                  //               Notify.showFlushbar('Cannot view article details.');
                  //             },
                  //           ));
                  //         },
                  //         openBuilder: (context, _) => article.articleId != null
                  //             ? ArticleDetail(articleId: article.articleId!)
                  //             : Container(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHealingSessionCard({
    required String image,
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Container(
                height: 180,
                width: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                height: 180,
                width: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Try it now',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
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
      ),
    );
  }

  Widget _buildArticleCard({
    required String image,
    required String title,
    required String category,
    required VoidCallback onTap,
  }) {
    const String fallbackImage =
        'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=400&h=400&fit=crop';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image.isNotEmpty ? image : fallbackImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    fallbackImage,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Text(
                  //   category,
                  //   style: TextStyle(
                  //     color: Colors.grey[600],
                  //     fontSize: 12,
                  //   ),
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFE37083),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Read more',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live indicator
          ],
        ),
      ),
    );
  }
}

// Widget _buildHealingSessionCard({
//   required String image,
//   required String title,
//   required String subtitle,
//   required IconData icon,
//   VoidCallback? onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: 120,
//       margin: const EdgeInsets.only(right: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               image,
//               height: 100,
//               width: 120,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Color(0xFF666666),
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             subtitle,
//             style: TextStyle(color: Color(0xFF2B2B2B), fontSize: 11),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Icon(icon, color: Colors.black, size: 14),
//               const SizedBox(width: 4),
//               Text(
//                 'Try it now',
//                 style: TextStyle(color: Color(0xFF999999), fontSize: 10),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildArticleCard({
//   required String image,
//   required String title,
//   required String category,
//   required VoidCallback? tap,
// }) {
//   const String fallbackImage =
//       'https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=';
//   // 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/495px-No-Image-Placeholder.svg.png?20200912122019';
//   return GestureDetector(
//     onTap: tap,
//     child: Container(
//       width: 160, // Fixed width for horizontal scrolling
//       margin: const EdgeInsets.only(right: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(12),
//               topRight: Radius.circular(12),
//             ),
//             child: Image.network(
//               // image ?? '',
//               (image.isNotEmpty) ? image : fallbackImage,
//               // image,
//               height: 120,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Image.network(
//                   fallbackImage,
//                   height: 120,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category
//                 Text(
//                   category.toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 6),
//                 // Title
//                 Text(
//                   title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
