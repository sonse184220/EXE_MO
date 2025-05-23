import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/main_pages/goals_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/homepage.dart';
import 'package:inner_child_app/presentation/pages/main_pages/notification.dart';
import 'package:inner_child_app/presentation/pages/main_pages/settings_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/therapy_tools_page.dart';
import 'package:inner_child_app/presentation/widgets/navbar.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
    const TherapyToolsPage(),
    const GoalsPage(),
    const SettingsPage(),
    const NotificationPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
