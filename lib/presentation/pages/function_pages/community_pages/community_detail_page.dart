import 'package:flutter/material.dart';

class CommunityDetailPage extends StatefulWidget {
  const CommunityDetailPage({super.key});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late final List<Widget> communityPosts;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    communityPosts = [
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
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
                    // Community header image
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/meditation_page_image.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Community title and info
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Santa Fe Community',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '204 participants',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Pinned posts section
                            const Text(
                              'Pinned posts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: communityPosts.length,
                                itemBuilder: (context, index) {
                                  return communityPosts[index];
                                },
                                separatorBuilder:
                                    (context, index) => const Divider(),
                              ),
                            ),
                          ],
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

class CommunityPost extends StatelessWidget {
  final String authorName;
  final String communityName;
  final String postTitle;
  final String postImage;
  final String category;
  final String subcategory;

  const CommunityPost({
    super.key,
    required this.authorName,
    required this.communityName,
    required this.postTitle,
    required this.postImage,
    required this.category,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Author avatar
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(width: 8),
                // Author name and community
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' shared to '),
                      TextSpan(
                        text: communityName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              postTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // Post image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(postImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Post footer
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subcategory,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
