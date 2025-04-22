import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final List<Widget> settingsItems;

  @override
  void initState() {
    super.initState();
    settingsItems = [
      _buildSettingItem(
        icon: Icons.person,
        color: Colors.grey,
        title: 'Profile',
      ),
      _buildSettingItem(
        icon: Icons.star,
        color: Colors.amber,
        title: 'Family Moment Premium',
      ),
      _buildSettingItem(
        icon: Icons.photo_album,
        color: Colors.red.shade300,
        title: 'Album Settings',
      ),
      _buildSettingItem(
        icon: Icons.settings,
        color: Colors.red.shade300,
        title: 'App Settings',
      ),
      _buildSettingItem(
        icon: Icons.help_outline,
        color: Colors.grey,
        title: 'Support',
      ),
      _buildSettingItem(
        icon: Icons.attach_money,
        color: Colors.green,
        title: 'Subscription',
      ),
      _buildSettingItem(
        icon: Icons.exit_to_app,
        color: Colors.red,
        title: 'Logout',
      ),
    ];
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
                // child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Expanded(
                      child:
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: settingsItems.length,
                      itemBuilder: (context, index) {
                        final item = settingsItems[index];
                        return item;
                      },

                      separatorBuilder:
                          (context, index) => SizedBox(height: 10),
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

  Widget _buildSettingItem({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing:
            title.isNotEmpty
                ? const Icon(Icons.chevron_right, color: Colors.grey)
                : null,
        onTap: () {
          // Add navigation or action here
        },
      ),
    );
  }
}
