import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/goal_pages/goal_home_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/homepage.dart';
import 'package:inner_child_app/presentation/pages/main_pages/notification.dart';
import 'package:inner_child_app/presentation/pages/main_pages/settings_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/therapy_tools_page.dart';
import 'package:inner_child_app/presentation/widgets/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
    // const TherapyToolsPage(),
    const GoalHomePage(),
    const NotificationPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  void switchToTherapyTab() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // body: _pages[_currentIndex],
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: CustomNavbar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
