import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/main_pages/main_screen.dart';

class ProfileChoosingPage extends ConsumerStatefulWidget {
  const ProfileChoosingPage({super.key});

  @override
  ConsumerState<ProfileChoosingPage> createState() =>
      _ProfileChoosingPageState();
}

class _ProfileChoosingPageState extends ConsumerState<ProfileChoosingPage> {
  late final AuthUsecase _authUseCase;
  List<AccountProfile> profileList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authUseCase = ref.read(authUseCaseProvider);
    fetchProfiles();
  }

  final List<ProfileData> profiles = [
    ProfileData(
      name: "Playful",
      image: "assets/images/appLogo.png",
      color: Colors.orangeAccent,
    ),
    ProfileData(
      name: "Creative",
      image: "assets/images/appLogo.png",
      color: Colors.purpleAccent,
    ),
    ProfileData(
      name: "Curious",
      image: "assets/images/appLogo.png",
      color: Colors.greenAccent,
    ),
    ProfileData(
      name: "Add Profile",
      isAddProfile: true,
      color: Colors.grey.shade300,
    ),
  ];

  Future<void> fetchProfiles() async {
    try {
      final result = await _authUseCase.getAvailableProfiles();

      if (result.isSuccess && result.data != null) {
        setState(() {
          profileList = result.data!;
        });
      } else {
        debugPrint('Fetch failed: ${result.error}');
      }
      // profileList = fetchedProfiles?.map((e) => AccountProfile(
      //   profileId: e.profileId,
      //   profileStatus: e.profileStatus,
      //   profileToken: e.profileToken,
      //   userId: e.userId// if needed
      // )).toList();
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    }
  }

  Future<void> _handleProfileSelection(AccountProfile profile) async {
    try {
      final result = await _authUseCase.loginWithProfile(profile.profileToken);

      if (!mounted) return;

      if (result.isSuccess) {
        // Proceed to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        debugPrint("Profile check failed: ${result.error}");
        // Optionally show error dialog/snackbar
      }
    } catch (e) {
      debugPrint("Error during profile check: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.6],
                  colors: [Color(0xFFFFA450), Color(0x8CFF5C00)],
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Logo
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Image.asset(
                          'assets/images/[EXE101]_Logo_INNER_CHILD.png',
                          height: 100,
                        ),
                      ),

                      // Who's Playing Text
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

                      // Profiles Grid
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
                              return
                              // GestureDetector(
                              // onTap: () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => MainScreen(),
                              //     ),
                              //   );
                              // },
                              // child:
                              ProfileAvatar(
                                profile: selectedProfile,
                                onTap:
                                    () => _handleProfileSelection(
                                      selectedProfile,
                                    ),
                              );
                              // );
                            },
                          ),
                        ),
                      ),

                      // Edit Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle edit action
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "Edit",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  const ProfileAvatar({super.key, required this.profile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
      onTap,
      // () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => MainScreen()),
      //   );
      // },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              // color: profile.color,
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
              child: Image.asset(
                'assets/images/appLogo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              profile.profileId,
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
          ),
        ],
      ),
    );
  }
}
