import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_detail_page.dart';

class CommunityGroupsPage extends ConsumerStatefulWidget {
  const CommunityGroupsPage({super.key});

  @override
  ConsumerState<CommunityGroupsPage> createState() => _CommunityGroupsPageState();
}

class _CommunityGroupsPageState extends ConsumerState<CommunityGroupsPage> {
  late final CommunityUsecase _communityUsecase;
  List<CommunityGroupModel> communityList = [];
  bool isLoading = true;

  late final List<Widget> communityGroups;

  Future<void> _fetchCommunityGroups() async {
    try {
      final result = await _communityUsecase.getAllCommunityGroups(); // adjust method name if needed
      setState(() {
        communityList = result.data!;
        // communityGroups = result.map((community) {
        //   return GroupListItem(
        //     name: community.communityName,
        //     status: community.communityStatus,
        //     details: 'Created: ${community.communityCreatedAt.toLocal().toString().split(' ')[0]}',
        //     imagePath: 'assets/images/meditation_page_image.png', // update if image is dynamic
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CommunityDetailPage(), // pass data if needed
        //         ),
        //       );
        //     },
        //   );
        // }).toList();
        isLoading = false;
      });
    } catch (e) {
      Notify.showFlushbar('Error fetch groups: $e', isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _communityUsecase = ref.read(communityUseCaseProvider);
    communityGroups = [// Community group list
      GroupListItem(
        name: 'Santa Fe Community',
        status: 'OPEN',
        details: 'created since June, 23',
        imagePath: 'assets/images/meditation_page_image.png',
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CommunityDetailPage(communityGroupId: commu,),
          //   ),
          // );
        },
      ),

      GroupListItem(
        name: 'Women\'s meditation Community',
        status: 'OPEN',
        details: 'reserved for July, 6 members',
        imagePath: 'assets/meditation.jpg',
        description: 'Looking for members:',
      ),

      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
      GroupListItem(
        name: 'UCLA students',
        status: 'Open',
        details: 'Share your thought',
        imagePath: 'assets/ucla.jpg',
      ),
    ];

    _fetchCommunityGroups();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return
              // SingleChildScrollView(
              // child:
              ConstrainedBox(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and centered title row
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Back button on the left
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // Centered title
                          Align(
                            alignment: Alignment.center,
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Healing Groups',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Community groups header
                      const Text(
                        'Community groups to join',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 15),
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: communityList.length,
                          itemBuilder: (context, index) {
                            // return communityGroups[index];
                            final community = communityList[index];
                            return GroupListItem(
                              name: community.communityName ?? 'Unknown Community',
                              status: community.communityStatus ?? 'Unknown',
                              details: 'Created: ${community.communityCreatedAt?.toLocal().toString().split(' ')[0]}',
                              imagePath: 'assets/images/meditation_page_image.png', // Replace with dynamic image if available
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailPage(communityGroupId: community.communityGroupId!,
                                      // pass community if needed
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Create group suggestion
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: const Text(
                          'Can\'t find the perfect group? You can create your own group from the settings in your profile.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
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
}

// Reusable Group List Item
class GroupListItem extends StatelessWidget {
  final String name;
  final String status;
  final String details;
  final String imagePath;
  final String? description;
  final VoidCallback? onTap;

  const GroupListItem({
    super.key,
    required this.name,
    required this.status,
    required this.details,
    required this.imagePath,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
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
                if (description != null)
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }
}