import 'package:flutter/material.dart';

class CustomSideBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  const CustomSideBar({super.key, required this.currentIndex, required this.onIndexChanged});

  @override
  State<CustomSideBar> createState() => _CustomSideBarState();
}

class _CustomSideBarState extends State<CustomSideBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown.shade700,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your application',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              index: 0,
              selected: widget.currentIndex == 0,
            ),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'User Management',
              index: 1,
              selected: widget.currentIndex == 1,
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              title: 'Analytics',
              index: 2,
              selected: widget.currentIndex == 2,
            ),
            _buildDrawerItem(
              icon: Icons.content_paste,
              title: 'Content Management',
              index: 3,
              selected: widget.currentIndex == 3,
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Admin Settings',
              index: 4,
              selected: widget.currentIndex == 4,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Exit Admin Mode',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Implement logic to exit admin mode
                Navigator.pop(context);
                // You might want to navigate to a different screen or reset state
                // For example: Navigator.pushReplacementNamed(context, '/user-mode');
              },
            ),
          ],
        ),
      ),
    ));

  }



  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.brown.shade700 : Colors.brown,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.brown.shade700 : Colors.black,
        ),
      ),
      tileColor: selected ? Colors.brown.shade50 : null,
      onTap: () {
        widget.onIndexChanged(index);
        // Close the drawer after selection on mobile
        // Don't close it on tablets/desktop for better UX
        if (MediaQuery.of(currentContext!).size.width < 600) {
          Navigator.pop(currentContext!);
        }
      },
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    // Close the drawer
    Navigator.pop(context);

    // Navigate to the selected page
    // You would implement actual navigation based on your routing system
    // For example:
    // Navigator.pushNamed(context, route);

    // For demonstration purposes, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $route')),
    );
  }

  BuildContext? get currentContext => _AdminSidebarInheritedWidget.of(0)?.context;
}

// Helper widget to access BuildContext
class _AdminSidebarInheritedWidget extends InheritedWidget {
  final BuildContext context;
  static final Map<int, _AdminSidebarInheritedWidget> _instances = {};

  const _AdminSidebarInheritedWidget({
    super.key,
    required super.child,
    required this.context,
  });

  static _AdminSidebarInheritedWidget? of(int id) => _instances[id];

  static void register(int id, BuildContext context, Widget child) {
    _instances[id] = _AdminSidebarInheritedWidget(
      context: context,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(_AdminSidebarInheritedWidget oldWidget) => false;
}