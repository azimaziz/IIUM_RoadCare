import 'package:flutter/material.dart';
import 'package:roadcare/pages//user/create_report.dart';
import 'package:roadcare/pages/user/home_page.dart';
import 'package:roadcare/pages/user/view_status_report.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // List of widgets to display based on the selected tab
  final List<Widget> _pageOptions = [
    HomePage(),
    CreateReport(),
    ViewStatus(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions.elementAt(_selectedIndex), // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Status'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 255, 204, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}