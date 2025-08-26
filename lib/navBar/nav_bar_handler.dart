import 'package:Budget_App/mobile/expense_view_mobile.dart';
import 'package:Budget_App/mobile/login_view_mobile.dart';

import 'package:Budget_App/screens/report_page.dart';
import 'package:Budget_App/screens/setting_page.dart';
import 'package:Budget_App/screens/transaction_page.dart';
import 'package:Budget_App/screens/budget_page.dart'; // ✅ Create this new file
import 'package:flutter/material.dart';

class BottomNavHandler extends StatefulWidget {
  const BottomNavHandler({Key? key}) : super(key: key);

  @override
  State<BottomNavHandler> createState() => _BottomNavHandlerState();
}

class _BottomNavHandlerState extends State<BottomNavHandler> {
  int _currentIndex = 0;
  bool _isLoggedIn = false; // ✅ Track login state

  final List<Widget> _pages = [
    ExpenseViewMobile(),
    TransactionsPage(),
    BudgetPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  void _onLoginSuccess() {
    print("Login success called!");
    setState(() {
      _isLoggedIn = true; // Switch to bottom nav pages
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      // Show login screen first
      return LoginViewMobile(onLoginSuccess: _onLoginSuccess);
    }

    // After login, show bottom navigation
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Budgets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
