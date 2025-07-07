import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';

class ProfileChoosingPage extends ConsumerStatefulWidget {
  const ProfileChoosingPage({super.key});

  @override
  ConsumerState<ProfileChoosingPage> createState() =>
      _ProfileChoosingPageState();
}

class _ProfileChoosingPageState extends ConsumerState<ProfileChoosingPage> {
  late final AuthUsecase _authUseCase;

  List<AccountProfile> profileList = [];

  String? deviceToken;
  bool isLoading = false;
  bool isProfileLoggingIn = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _authUseCase = ref.read(authUseCaseProvider);
    deviceToken = ref.read(fcmTokenProvider);

    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _authUseCase.getAvailableProfiles();

      if (result.isSuccess && result.data != null) {
        setState(() {
          profileList = result.data!;
        });
      } else {
        setState(() {
          errorMessage = result.error ?? "Failed to load profiles.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred.";
      });
      debugPrint('Error fetching profiles: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleProfileSelection(AccountProfile profile) async {
    setState(() {
      isProfileLoggingIn = true;
    });
    try {
      final result = await _authUseCase.loginWithProfile(profile.profileToken, deviceToken);

      if (!mounted) return;

      if (result.isSuccess) {
        // ref.read(authNotifierProvider.notifier).initSignalRAuthorize();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => MainScreen()),
        // );
      } else {
        Notify.showFlushbar('Login with profile failed', isError: true);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(result.error ?? "Login failed")),
        // );
      }
    } catch (e) {
      debugPrint("Error during profile check: $e");
    } finally {
      if (mounted) {
        setState(() {
          isProfileLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (errorMessage != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.6],
                        // colors: [Color(0xFFFFA450), Color(0x8CFF5C00)],
                        colors: [
                          Color(0xFF89B7C2), // SPRING SKY
                          Color(0xFFA8BF8A), // MEADOW
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchProfiles,
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.6],
                      // colors: [Color(0xFFFFA450), Color(0x8CFF5C00)],
                      colors: [
                        Color(0xFF89B7C2), // SPRING SKY
                        Color(0xFFA8BF8A), // MEADOW
                      ],
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20), // Change this number!
                              child: Image.asset(
                                'assets/images/app_logo_nobackground2.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            "Who's Playing?",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.9,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 30,
                                    ),
                                itemCount: profileList.length,
                                itemBuilder: (context, index) {
                                  final selectedProfile = profileList[index];
                                  return ProfileAvatar(
                                    profile: selectedProfile,
                                    onTap:
                                        () => _handleProfileSelection(
                                          selectedProfile,
                                        ),
                                    index: index,
                                  );
                                },
                              ),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       // Handle edit action
                          //     },
                          //     style: TextButton.styleFrom(
                          //       foregroundColor: Colors.white,
                          //     ),
                          //     child: Text(
                          //       "Edit",
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 18,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (isProfileLoggingIn)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileData {
  final String name;
  final String? image;
  final Color color;
  final bool isAddProfile;

  ProfileData({
    required this.name,
    this.image,
    required this.color,
    this.isAddProfile = false,
  });
}

class ProfileAvatar extends StatelessWidget {
  final AccountProfile profile;
  final VoidCallback? onTap;
  final int index;

  const ProfileAvatar({super.key, required this.profile, this.onTap, required this.index,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ProfileColors.getRandomColor(), // Use the profile's assigned color from the theme
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profile ${index + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black26,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // Highlight background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white70, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   '#${index + 1}',
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //     shadows: [
                  //       Shadow(
                  //         blurRadius: 3.0,
                  //         color: Colors.black26,
                  //         offset: Offset(0, 1),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  Text(
                    profile.profileStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black26,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 12),
          //   child: Text(
          //     profile.profileStatus,
          //     style: TextStyle(
          //       fontSize: 11,
          //       fontWeight: FontWeight.w500,
          //       color: Colors.white,
          //       shadows: [
          //         Shadow(
          //           blurRadius: 3.0,
          //           color: Colors.black26,
          //           offset: Offset(0, 1),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
    // return GestureDetector(
    //   onTap: onTap,
    //   // () {
    //   //   Navigator.push(
    //   //     context,
    //   //     MaterialPageRoute(builder: (context) => MainScreen()),
    //   //   );
    //   // },
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Container(
    //         width: 120,
    //         height: 120,
    //         decoration: BoxDecoration(
    //           // color: profile.color,
    //           borderRadius: BorderRadius.circular(16),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black.withAlpha((0.2 * 255).toInt()),
    //               blurRadius: 8,
    //               offset: Offset(0, 4),
    //             ),
    //           ],
    //           border: Border.all(color: Colors.white, width: 3),
    //         ),
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.circular(13),
    //           child: Image.asset(
    //             'assets/images/appLogo.png',
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 12),
    //         child: Text(
    //           profile.profileId,
    //           style: TextStyle(
    //             fontSize: 11,
    //             fontWeight: FontWeight.w500,
    //             color: Colors.white,
    //             shadows: [
    //               Shadow(
    //                 blurRadius: 3.0,
    //                 color: Colors.black26,
    //                 offset: Offset(0, 1),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class ProfileColors {
  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);

  static const List<Color> allColors = [
    raspberry,
    papaya,
    iceCream,
    meadow,
    sunshine,
    springSky,
  ];

  static final _random = Random();

  /// Get a random color from the list
  static Color getRandomColor() {
    return allColors[_random.nextInt(allColors.length)];
  }
}