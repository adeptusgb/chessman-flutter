import 'package:flutter/material.dart';
import 'home_page.dart';
import 'bmi_calculator_page.dart';
import 'dieta_page.dart';
import 'aerobics_page.dart';

// Create a controller class to manage navigation state
class NavigationController {
  // Static callback that will be set by NavigationPage
  static Function(int)? _tabSwitchCallback;

  // Method to register the callback
  static void setTabSwitchCallback(Function(int) callback) {
    _tabSwitchCallback = callback;
  }

  // Method to switch tabs
  static void switchToTab(int index) {
    if (_tabSwitchCallback != null) {
      _tabSwitchCallback!(index);
    }
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    BMICalculatorPage(),
    DietaPage(),
    AerobicsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Register the callback when the state is initialized
    NavigationController.setTabSwitchCallback(_onItemTapped);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'IMC'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Dieta'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run_sharp),
            label: 'Aeróbicos',
          ),
        ],
      ),
    );
  }
}
