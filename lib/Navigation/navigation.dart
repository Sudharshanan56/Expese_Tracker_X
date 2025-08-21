import 'package:expense_tracker_x/Budget/budget.dart';
import 'package:expense_tracker_x/Home/home_screen.dart';
import 'package:expense_tracker_x/Insight/insight.dart';
import 'package:expense_tracker_x/Profile/profile.dart';
import 'package:flutter/material.dart';

// Main Screen with Navigation Bar
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    BudgetScreen(),
    InsightScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
