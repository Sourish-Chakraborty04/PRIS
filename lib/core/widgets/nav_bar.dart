import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../../features/dashboard/dashboard_view.dart';
import '../../features/work/shift_log_view.dart';
import '../../features/spend/expense_view.dart';
import '../../features/bike/bike_view.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const ShiftLogView(),
    const ExpenseView(),
    const BikeView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: PrisColors.background,
          selectedItemColor: PrisColors.primary,
          unselectedItemColor: PrisColors.onSurface,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Work'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Spend'),
            BottomNavigationBarItem(icon: Icon(Icons.motorcycle), label: 'Bike'),
          ],
        ),
      ),
    );
  }
}