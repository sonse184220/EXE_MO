import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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




Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    ),
  );
}

class HelpTabContent extends StatelessWidget {
  const HelpTabContent({super.key});
  final List<Map<String, String>> mockHelpItems = const [
    {
      'question': 'How do I reset my password?',
      'answer': 'You can reset your password from the Settings page.',
    },
    {
      'question':
          'How to contact support button in the Help Center button in the Help Center?',
      'answer':
          'Use the "Contact us" button in the Help Center button in the Help Centerbutton in the Help Center.',
    },
    {
      'question': 'Where can I view my purchase history?',
      'answer': 'Go to your Profile and select Purchase History.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, from the Account Settings page.',
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

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  final List<String> tabLabels = [
    'General',
    'Account',
    'Payment',
    'Service',
    'Help',
    'Help',
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(tabLabels.length, (index) {
              return _buildTabButton(
                tabLabels[index],
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
        SizedBox(height: 14),
        buildSearchBox(),
        SizedBox(height: 14),
        Expanded(child: HelpTabContent()),
      ],
    );
  }
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
        _buildSocialMediaItem(FontAwesomeIcons.headphones, 'Customer Service'),
        _buildSocialMediaItem(FontAwesomeIcons.whatsapp, 'WhatsApp'),
        _buildSocialMediaItem(FontAwesomeIcons.globe, 'Website'),
        _buildSocialMediaItem(FontAwesomeIcons.facebook, 'Facebook'),
        _buildSocialMediaItem(FontAwesomeIcons.twitter, 'Twitter'),
        _buildSocialMediaItem(FontAwesomeIcons.instagram, 'Instagram'),

      ],
    );
  }

  Widget _buildSocialMediaItem(IconData icon, String label) {
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
              child: Text(
                'Details for $label go here.',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


