import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/data/datasources/remote/help_category_api_service.dart';
import 'package:inner_child_app/domain/usecases/help_category_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import '../../../core/utils/result_model.dart';
import '../../../domain/entities/help/help_category_model.dart';
import '../../../domain/entities/help/help_model.dart';
import 'package:url_launcher/url_launcher.dart';
class HelpScreenPage extends StatefulWidget {
  const HelpScreenPage({super.key});

  @override
  State<HelpScreenPage> createState() => _HelpScreenPageState();
}

class _HelpScreenPageState extends State<HelpScreenPage> {

  final List<Widget> helpSection = [
    FAQ(),ContactUs()
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded),
            color: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               Expanded(child: _buildTabSelector('FAQ', 0)) ,
                 Expanded(child: _buildTabSelector('Contact us', 1))
              ],
            ),
            Expanded(child: helpSection[selectedIndex]),
          ],
        ),
      ),
    );
  }
  Widget _buildTabSelector(String title, int index) {
    bool isSelected = selectedIndex == index;
    final widthBlackBar = MediaQuery.of(context).size.width / 2;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: widthBlackBar,
            color: isSelected ? Colors.black : Colors.grey[200],
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }



}




// Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
//   return Container(
//     margin: const EdgeInsets.only(right: 8),
//     child: ElevatedButton(
//       onPressed: onTap,
//       style: ElevatedButton.styleFrom(
//         foregroundColor: isSelected ? Colors.white : Colors.black,
//         backgroundColor: isSelected ? Colors.black : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       ),
//       child: Text(label, style: const TextStyle(fontSize: 14)),
//     ),
//   );
// }

class HelpTabContent extends StatelessWidget {
  const HelpTabContent({super.key});
  final List<Map<String, String>> mockHelpItems = const [
    {
      'question': 'How do I reset my password?',
      'answer': 'You can reset your password from the Settings page.',
    },

  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mockHelpItems.length,
      itemBuilder: (context, index) {
        final item = mockHelpItems[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: Border(),
            title: Text(
              item['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['answer']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildSearchBox() {
  return Container(
    height: 40,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Row(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.search, color: Colors.grey),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search for help",
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ],
    ),
  );
}

class FAQ extends ConsumerStatefulWidget {
  const FAQ({super.key});

  @override
  ConsumerState<FAQ> createState() => _FAQState();
}

class _FAQState extends ConsumerState<FAQ> {
  late Future<Result<List<HelpCategoryModel>>> _futureHelpCategories;
  int selectedIndex =0;
  @override
  void initState() {
    super.initState();
    final helpCategoryUseCase = ref.read(helpCategoryUseCaseProvider);
    _futureHelpCategories = helpCategoryUseCase.getAllHelpCategory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<HelpCategoryModel>>>(
      future: _futureHelpCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isFailure) {
          return const Center(child: Text('Failed to load data'));
        }

        final helpCategories = snapshot.data!.data!;
        final currentHelps = helpCategories[selectedIndex].helps;

        return Column(
          children: [
            // Tab horizontal
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(helpCategories.length, (index) {
                  return _buildTabButton(
                    helpCategories[index].helpCategoryName,
                    index == selectedIndex,
                        () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            buildSearchBox(),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: currentHelps.length,
                itemBuilder: (context, index) {
                  final help = currentHelps[index];
                  return _buildHelpTile(help);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black, // text color
        backgroundColor: isSelected ? Colors.black : Colors.white, // background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: isSelected ? 3 : 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}


Widget _buildHelpTile(HelpModel help) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ExpansionTile(
      shape: const Border(),
      title: Text(
        help.helpQuestion,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(help.helpAnswer),
        ),
      ],
    ),
  );
}



class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSocialMediaItem(FontAwesomeIcons.headphones, 'Customer Service','a'),
        _buildSocialMediaItem(FontAwesomeIcons.whatsapp, 'WhatsApp','a'),
        _buildSocialMediaItem(FontAwesomeIcons.globe, 'Website','a'),
        _buildSocialMediaItem(FontAwesomeIcons.facebook, 'Facebook','https://www.facebook.com/profile.php?id=100067662162826'),
        _buildSocialMediaItem(FontAwesomeIcons.twitter, 'Twitter','a'),
        _buildSocialMediaItem(FontAwesomeIcons.instagram, 'Instagram','a'),

      ],
    );
  }

  Widget _buildSocialMediaItem(IconData icon, String label,String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: Border(),
        leading: Icon(icon, color: Colors.black),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _launchURL(url),
                child: Text(
                  url,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}




