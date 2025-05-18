import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:inner_child_app/presentation/pages/customer_services_page/help_screen_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/user_information/profile_edit_page.dart';
import 'package:inner_child_app/presentation/pages/subscription_pages/subscription_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final AuthUsecase _authUsecase;
  late final List<Widget> settingsItems;

  @override
  void initState() {
    super.initState();

    _authUsecase = ref.read(authUseCaseProvider);

    settingsItems = [
      _buildSettingItem(
        icon: Icons.person,
        color: Colors.grey,
        title: 'Profile',
        tap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileEditPage()),
          );
        },
      ),
      _buildSettingItem(
        icon: Icons.star,
        color: Colors.amber,
        title: 'Family Moment Premium',
        tap: null,
      ),
      _buildSettingItem(
        icon: Icons.photo_album,
        color: Colors.red.shade300,
        title: 'Album Settings',
        tap: null,
      ),
      _buildSettingItem(
        icon: Icons.settings,
        color: Colors.red.shade300,
        title: 'App Settings',
        tap: null,
      ),
      _buildSettingItem(
        icon: Icons.help_outline,
        color: Colors.grey,
        title: 'Support',
        tap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpScreenPage()),
          );
        },
      ),
      _buildSettingItem(
        icon: Icons.attach_money,
        color: Colors.green,
        title: 'Subscription',
        tap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubscriptionPage()),
          );
        },
      ),
      _buildSettingItem(
        icon: Icons.exit_to_app,
        color: Colors.red,
        title: 'Logout',
        tap: () async {
          final result = await _authUsecase.logout();
          if(result.isSuccess) {
            Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
          }else{
            NotifyAnotherFlushBar.showFlushbar('Logout fail');
          }
        }
        // tap: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => Login()),
        //   );
        // },
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
                      child: ListView.separated(
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
    required VoidCallback? tap,
  }) {
    return
      // GestureDetector(
      // onTap: tap,
      // child:
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFEEEEEE), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.1 * 255).round()),
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
          onTap: tap,
        ),
      );
    // );
  }
}
