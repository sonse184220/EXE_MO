import 'package:flutter/material.dart';

class TherapyToolsPage extends StatefulWidget {
  const TherapyToolsPage({super.key});

  @override
  State<TherapyToolsPage> createState() => _TherapyToolsPageState();
}

class _TherapyToolsPageState extends State<TherapyToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Therapy', style: TextStyle(fontSize: 50),),);
  }
}
