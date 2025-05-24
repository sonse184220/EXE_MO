import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/admin/admin_home_page.dart';
import 'package:inner_child_app/presentation/pages/admin/user_manage_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/goals_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/notification.dart';
import 'package:inner_child_app/presentation/pages/main_pages/settings_page.dart';
import 'package:inner_child_app/presentation/widgets/sidebar.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _adminIndex = 0;
  final List<Widget> _adminPages = [
    // const AdminDashboardPage(),
    // const AdminUsersPage(),
    // const AdminAnalyticsPage(),
    // const AdminContentPage(),
    // const AdminSettingsPage(),
    const AdminHomePage(),
    const UserManagePage(),
    const GoalsPage(),
    const SettingsPage(),
    const NotificationPage(),
  ];

  void _onAdminItemTapped(int index) {
    setState(() {
      _adminIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage =
        _adminPages[_adminIndex]; // Show admin page if user is admin
    return SafeArea(
      child: Scaffold(
        // Add drawer only if user is admin
        drawer: CustomSideBar(
          currentIndex: _adminIndex,
          onIndexChanged: _onAdminItemTapped,
        ),
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.brown.shade700,
          elevation: 0,
        ),
        body: currentPage,
      ),
    );
  }
}
