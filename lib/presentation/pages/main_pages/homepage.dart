import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/articles/article_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                // height: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Search Section
                      Container(
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  border: Border.all(
                                    color: Color.fromRGBO(230, 230, 230, 1),
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Search healing properties or article here',
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            153,
                                            153,
                                            153,
                                            1,
                                          ),
                                          fontSize: 14,
                                          fontFamily: 'League Spartan',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                const Icon(Icons.notifications_none, size: 28),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '+9',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      //Mood Tracker Card Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/moodTrackerHomeCard.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Record your mood!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'How do you feel today?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 160,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'See Details',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      //Healing Sessions Section
                      Container(
                        child: Column(
                          children: [
                            // Healing Sessions Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Healing Sessions',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'See all',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 12),

                            // Healing Sessions Cards
                            SizedBox(
                              height: 190,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildHealingSessionCard(
                                    image:
                                        'https://images.unsplash.com/photo-1518791841217-8f162f1e1131',
                                    title: 'Healing Frequency',
                                    subtitle: 'Relax Moment',
                                    icon: Icons.graphic_eq,
                                  ),
                                  _buildHealingSessionCard(
                                    image:
                                        'https://images.unsplash.com/photo-1499728603263-13726abce5fd',
                                    title: 'Meditation Method',
                                    subtitle: 'Find your own peace',
                                    icon: Icons.self_improvement,
                                  ),
                                  _buildHealingSessionCard(
                                    image:
                                        'https://images.unsplash.com/photo-1517021897933-0e0319cfbc28',
                                    title: 'Emotional Diary',
                                    subtitle: 'How do you feel?',
                                    icon: Icons.menu_book,
                                  ),
                                  _buildHealingSessionCard(
                                    image:
                                        'https://images.unsplash.com/photo-1544027993-37dbfe43562a',
                                    title: 'Sharing Community',
                                    subtitle: 'Sharing your emotion',
                                    icon: Icons.people,
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 24),

                            // Articles Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Articles',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'See all',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Articles Cards
                            SizedBox(
                              height: 210,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildArticleCard(
                                    image:
                                        'https://images.unsplash.com/photo-1560732488-6b0df240254a',
                                    title:
                                        'Why we heal: The evolution of psychological healing',
                                    category: 'PSYCHOLOGICAL',
                                    tap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ArticleDetail(article: ArticleObject(
                                          title: 'Papaver Somniferum',
                                          source: 'Wikipedia, the free encyclopedia',
                                          description: 'Prioritize your well-being! Manage stress, sleep well, stay active, and nourish your body. Small daily habits lead to a healthier, happier life. Your health is your greatest asset.',
                                          tags: [
                                            'Health',
                                            'Active',
                                            'Nourishment'
                                          ],
                                          category: 'Well-being',
                                          actionTags: [
                                            TagItem(
                                              label: 'Well being',
                                              icon: Icons.spa,
                                              color: Colors.green,
                                            ),
                                            TagItem(
                                              label: 'Stress',
                                              icon: Icons.circle,
                                              color: Colors.blue,
                                            ),
                                            TagItem(
                                              label: 'Emotion control',
                                              icon: Icons.sunny,
                                              color: Colors.orange,
                                            ),
                                            TagItem(
                                              label: 'Habit',
                                              icon: Icons.thermostat,
                                              color: Colors.purple,
                                            ),
                                          ],
                                        ))),
                                      );
                                    },
                                  ),
                                  _buildArticleCard(
                                    image:
                                        'https://images.unsplash.com/photo-1545389336-cf090694435e',
                                    title:
                                        'Healing: A journey, Not a destination',
                                    category: 'SPIRITUAL MINDSET',
                                      tap: null
                                  ),
                                  _buildArticleCard(
                                    image:
                                        'https://images.unsplash.com/photo-1555708982-8645ec9ce3cc',
                                    title: 'Healing the Healer',
                                    category: 'HEALING',
                                      tap: null
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // ),
      ),
    );
  }
}

Widget _buildHealingSessionCard({
  required String image,
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return Container(
    width: 120,
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image,
            height: 100,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(color: Color(0xFF2B2B2B), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.black, size: 14),
            const SizedBox(width: 4),
            Text(
              'Try it now',
              style: TextStyle(color: Color(0xFF999999), fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildArticleCard({
  required String image,
  required String title,
  required String category,
  required VoidCallback? tap,
}) {
  return GestureDetector(
    onTap: tap,
    child: Container(
      width: 160, // Fixed width for horizontal scrolling
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
